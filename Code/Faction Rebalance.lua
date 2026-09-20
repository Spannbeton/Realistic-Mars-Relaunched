local ToggleFaction = true
local TargetWrapped

GameVar("RMR_FactionPol", {})

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
    if not fid or not GetFactionApprovalLevel then
        return "content"
    end
    local lvl = GetFactionApprovalLevel(fid) or "content"
    if InAssembly(fid) and ShiftUp[lvl] then
        lvl = ShiftUp[lvl]
    end
    return lvl
end

local function Want(c)
    if not ToggleFaction or not c  then
        return false, 0, 0
    end
    local fid = c.faction_supported
    if not fid then
        return false, 0, 0
    end
    local lvl = LevelOf(fid)
    return lvl, ScaleAmt(ComfortDelta[lvl] or 0), ScaleAmt(SanityDelta[lvl] or 0)
end

local function ClearSanity(c)
    local st = c.rmr_fp
    if st and st.sanity and st.sanity ~= 0 and c.ChangeSanity then
        c:ChangeSanity(-st.sanity, T(0000, Reason))
    end
end

local function ApplyOne(c)
    if not c then
        return
    end
    local lvl, want_c, want_s = Want(c)
    local st = c.rmr_fp or { comfort = 0, sanity = 0, level = false, fid = false }
    if not lvl then
        ClearSanity(c)
        c.rmr_fp = nil
        return
    end
    if st.fid ~= c.faction_supported or st.level ~= lvl then
        ClearSanity(c)
        st.sanity = 0
    end
    if want_s ~= 0 and c.ChangeSanity then
        c:ChangeSanity(want_s, T(0000, Reason))
        st.sanity = want_s
    else
        st.sanity = 0
    end
    st.comfort = want_c
    st.level = lvl
    st.fid = c.faction_supported
    c.rmr_fp = st
end

local function ApplyAll()
    ReadToggle()
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Colonist
    for _, c in ipairs(list or empty_table) do
        ApplyOne(c)
    end
end

local function WrapTarget()
    if TargetWrapped or not Colonist or not Colonist.GetRestStatTarget then
        return
    end
    TargetWrapped = true
    local old = Colonist.GetRestStatTarget
    function Colonist:GetRestStatTarget(...)
        local t = old(self, ...)
        local st = rawget(self, "rmr_fp")
        if ToggleFaction and st and st.comfort and st.comfort ~= 0 then
            return (t or 0) + st.comfort
        end
        return t
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
    WrapTarget()
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
    WrapTarget()
    ApplyAll()
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    WrapTarget()
end

function OnMsg.ClassesBuilt()
    WrapTarget()
end