local ToggleFaction = true

local ComfortDelta = {
    breaking_point = -18,
    unhappy = -13,
    not_content = -8,
    content = 0,
    happy = 8,
    happy_plus = 16,
}

local SanityDelta = {
    breaking_point = -9,
    unhappy = -6,
    not_content = -3,
    content = 0,
    happy = 3,
    happy_plus = 6,
}

local ShiftUp = {
    breaking_point = "unhappy",
    unhappy = "not_content",
    not_content = "content",
    content = "happy",
    happy = "happy_plus",
    happy_plus = "happy_plus",
}

local Reason = T{"Faction Politics"}

local function ReadToggle()
    if not CurrentModOptions then
        return
    end
    local v = CurrentModOptions:GetProperty("Faction_Rebalance")
    if v ~= nil then
        ToggleFaction = v
    end
end

local function ScaleAmt(n)
    local scale = const and const.Scale and const.Scale.Stat or 1
    return (n or 0) * scale
end

local function InAssembly(fid)
    local members = g_Legislature and g_Legislature.legislature_members
    return fid and members and members[fid] and true or false
end

local function LevelOf(fid)
    if not fid then
        return "content"
    end
    local lvl = "content"
    local holder = rawget(_G, "g_FactionsHolder")
    if holder and holder.GetFactionApprovalLevel then
        lvl = holder:GetFactionApprovalLevel(fid) or "content"
    else
        local fn = rawget(_G, "GetFactionApprovalLevel")
        if fn then
            lvl = fn(fid) or "content"
        end
    end
    if InAssembly(fid) and ShiftUp[lvl] then
        lvl = ShiftUp[lvl]
    end
    return lvl
end

local function ReasonText(r)
    if type(r) == "table" and _InternalTranslate then
        return _InternalTranslate(r)
    end
    return tostring(r or "")
end

local function IsPoliticsReason(r)
    return ReasonText(r) == ReasonText(Reason)
end

local function LogSum(log)
    local sum = 0
    if type(log) ~= "table" then
        return 0
    end
    for i = 1, #log, 3 do
        if IsPoliticsReason(log[i + 2]) then
            sum = sum + (tonumber(log[i + 1]) or 0)
        end
    end
    return sum
end

local function LogStrip(log)
    local sum = 0
    if type(log) ~= "table" then
        return 0
    end
    local i = 1
    while i + 2 <= #log do
        if IsPoliticsReason(log[i + 2]) then
            sum = sum + (tonumber(log[i + 1]) or 0)
            table.remove(log, i)
            table.remove(log, i)
            table.remove(log, i)
        else
            i = i + 3
        end
    end
    return sum
end

local function Want(c)
    if not ToggleFaction or not c then
        return false, 0, 0
    end
    local fid = c.faction_supported
    if not fid then
        return false, 0, 0
    end
    local lvl = LevelOf(fid)
    return lvl, ScaleAmt(ComfortDelta[lvl] or 0), ScaleAmt(SanityDelta[lvl] or 0)
end

local function SetComfort(c, soll)
    if not c then
        return
    end
    local ist = LogSum(c.log_comfort)
    if ist == soll then
        return
    end
    LogStrip(c.log_comfort)
    if c.stat_comfort then
        local scale = const and const.Scale and const.Scale.Stat or 1
        local maxs = 100 * scale
        local v = (c.stat_comfort or 0) - ist
        if v < 0 then
            v = 0
        end
        if v > maxs then
            v = maxs
        end
        c.stat_comfort = v
    end
    if soll ~= 0 and c.ChangeComfort then
        c:ChangeComfort(soll, Reason, true)
    end
end

local function SetSanity(c, soll)
    if not c then
        return
    end
    local ist = LogSum(c.log_sanity)
    if ist == soll then
        return
    end
    LogStrip(c.log_sanity)
    if c.stat_sanity then
        local scale = const and const.Scale and const.Scale.Stat or 1
        local maxs = 100 * scale
        local v = (c.stat_sanity or 0) - ist
        if v < 0 then
            v = 0
        end
        if v > maxs then
            v = maxs
        end
        c.stat_sanity = v
    end
    if soll ~= 0 and c.ChangeSanity then
        c:ChangeSanity(soll, Reason)
    end
end

local function ApplyOne(c)
    if not c then
        return
    end
    local lvl, want_c, want_s = Want(c)
    if not lvl then
        SetComfort(c, 0)
        SetSanity(c, 0)
        return
    end
    SetComfort(c, want_c)
    SetSanity(c, want_s)
end

local function ApplyAll()
    ReadToggle()
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Colonist
    for _, c in ipairs(list or empty_table) do
        ApplyOne(c)
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ApplyAll()
    end
end

function OnMsg.NewDay()
    ApplyAll()
end

function OnMsg.LoadGame()
    ApplyAll()
end

function OnMsg.NewMapLoaded()
    ReadToggle()
end