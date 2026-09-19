print("RMR faction mood lua loaded")

local ToggleFaction = true
local Scale = const.Scale.Stat

local MoodOrder = {
    "breaking_point",
    "unhappy",
    "not_content",
    "content",
    "happy",
    "represented",
}

local MoodEffect = {
    represented = { comfort = 8, morale = 6, sanity = 0 },
    happy = { comfort = 4, morale = 3, sanity = 0 },
    content = { comfort = 0, morale = 0, sanity = 0 },
    not_content = { comfort = -8, morale = -3, sanity = 0 },
    unhappy = { comfort = -12, morale = -6, sanity = -2 },
    breaking_point = { comfort = -16, morale = -9, sanity = -4 },
}

GameVar("RMR_FactionMoodApplied", function()
    return {}
end)

local function ReadToggle()
    if not CurrentModOptions then
        return
    end
    local v = CurrentModOptions:GetProperty("Faction_Rebalance")
    if v ~= nil then
        ToggleFaction = v
    end
    print("RMR faction mood toggle", ToggleFaction)
end

local function MoodIndex(level)
    for i, id in ipairs(MoodOrder) do
        if id == level then
            return i
        end
    end
end

local function HasAssembly()
    local colony = rawget(_G, "UIColony")
    local labels = colony and colony.labels
    if labels then
        local list = labels.MartianAssembly or labels.Assembly
        if list and list[1] then
            return true
        end
    end
    local leg = rawget(_G, "g_Legislature")
    if leg and leg.IsSponsorFactions then
        return not leg:IsSponsorFactions()
    end
    return false
end

local function EffectiveLevel(raw)
    local idx = MoodIndex(raw) or MoodIndex("content")
    if HasAssembly() then
        idx = Min(idx + 1, #MoodOrder)
    end
    return MoodOrder[idx]
end

local function ClearOne(colonist, prev)
    if not IsValid(colonist) or not prev then
        return
    end
    local dc = -(prev.comfort or 0) * Scale
    if dc ~= 0 and colonist.ChangeComfort then
        colonist:ChangeComfort(dc, "Faction Politics", true)
    end
    if colonist.SetModifier then
        colonist:SetModifier("base_morale", "RMR_FactionMood", 0, 0)
    elseif (prev.morale or 0) ~= 0 and colonist.ChangeMorale then
        colonist:ChangeMorale(-(prev.morale or 0) * Scale, "Faction Politics", true)
    end
end

local function ApplyOne(colonist)
    if not IsValid(colonist) or not colonist.CanVote or not colonist:CanVote() then
        return
    end
    local fid = colonist.faction_supported
    if not fid then
        return
    end
    local holder = rawget(_G, "g_FactionsHolder")
    if not holder or not holder.GetFactionApprovalLevel then
        return
    end
    local raw = holder:GetFactionApprovalLevel(fid) or "content"
    local level = EffectiveLevel(raw)
    local fx = MoodEffect[level] or MoodEffect.content
    local applied = rawget(_G, "RMR_FactionMoodApplied")
    if type(applied) ~= "table" then
        applied = {}
        RMR_FactionMoodApplied = applied
    end
    local handle = colonist.handle
    local prev = applied[handle] or MoodEffect.content
    local dc = (fx.comfort - (prev.comfort or 0)) * Scale
    if dc ~= 0 and colonist.ChangeComfort then
        colonist:ChangeComfort(dc, "Faction Politics", true)
    end
    if colonist.SetModifier then
        colonist:SetModifier("base_morale", "RMR_FactionMood", (fx.morale or 0) * Scale, 0)
    else
        local dm = (fx.morale - (prev.morale or 0)) * Scale
        if dm ~= 0 and colonist.ChangeMorale then
            colonist:ChangeMorale(dm, "Faction Politics", true)
        end
    end
    if (fx.sanity or 0) ~= 0 and colonist.ChangeSanity then
        colonist:ChangeSanity(fx.sanity * Scale, "Faction Politics")
    end
    applied[handle] = { comfort = fx.comfort, morale = fx.morale, sanity = fx.sanity, level = level }
end

local function ClearAll()
    local applied = rawget(_G, "RMR_FactionMoodApplied")
    if type(applied) ~= "table" then
        return
    end
    local colony = rawget(_G, "UIColony")
    local list = colony and colony.labels and colony.labels.FactionObject
    if list then
        for _, colonist in ipairs(list) do
            if IsValid(colonist) then
                ClearOne(colonist, applied[colonist.handle])
            end
        end
    end
    RMR_FactionMoodApplied = {}
    print("RMR faction mood cleared")
end

function RMR_ApplyFactionMood()
    if not ToggleFaction then
        return
    end
    if IsGameRuleActive and IsGameRuleActive("NoPolitics") then
        return
    end
    local colony = rawget(_G, "UIColony")
    local list = colony and colony.labels and colony.labels.FactionObject
    if not list then
        return
    end
    local n = 0
    for _, colonist in ipairs(list) do
        local ok, err = pcall(ApplyOne, colonist)
        if not ok then
            print("RMR faction mood err", err)
        else
            n = n + 1
        end
    end
    print("RMR faction mood applied", n, HasAssembly() and "assembly" or "noassembly")
end

function OnMsg.FactionsUpdateEnd()
    RMR_ApplyFactionMood()
end

function OnMsg.LoadGame()
    ReadToggle()
    if ToggleFaction then
        RMR_ApplyFactionMood()
    else
        ClearAll()
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
    print("RMR faction mood ModsReloaded")
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        local was = ToggleFaction
        ReadToggle()
        if ToggleFaction then
            RMR_ApplyFactionMood()
        elseif was then
            ClearAll()
        end
    end
end