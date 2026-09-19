local ToggleLaw = true
local FreeLaws = 4
local FreeLawsAssembly = 2
local FreeLawsMinistry = 1
local ComfortPenalty = 1
local SanityPenalty = 1

local LAW_IMMUNE = {
    EarthEmbassy = true,
    MartianAssembly = true,
    MinistryInternalAffairs = true,
    MinistryEconomy = true,
    MinistryTechnology = true,
    MinistryWelfare = true,
    MinistryResearch = true,
}

local MINISTRIES = {
    "MinistryInternalAffairs",
    "MinistryEconomy",
    "MinistryTechnology",
    "MinistryWelfare",
    "MinistryResearch",
}

local LawState = {
    n = 0,
    cap = 4,
    comfort = 0,
    san = 0,
    assembly = false,
    ministries = 0,
}

local function ReadToggle()
    if not CurrentModOptions then
        return
    end
    local v = CurrentModOptions:GetProperty("Law_Rebalance")
    if v ~= nil then
        ToggleLaw = v
    end
    local a = CurrentModOptions:GetProperty("Free_Laws")
    if type(a) == "number" then
        FreeLaws = a
    end
    local b = CurrentModOptions:GetProperty("Free_Laws_Assembly")
    if type(b) == "number" then
        FreeLawsAssembly = b
    end
    local c = CurrentModOptions:GetProperty("Free_Laws_Ministry")
    if type(c) == "number" then
        FreeLawsMinistry = c
    end
    local d = CurrentModOptions:GetProperty("Laws_Comfort_Penalty")
    if type(d) == "number" then
        ComfortPenalty = d
    end
    local e = CurrentModOptions:GetProperty("Laws_Sanity_Penalty")
    if type(e) == "number" then
        SanityPenalty = e
    end
end

local function LawCount()
    return (ActiveLaws and #ActiveLaws) or 0
end

local function IsWorkingId(id)
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Building
    for _, b in ipairs(list or empty_table) do
        if b.working and (b.template_name == id or b.class == id) then
            return true
        end
    end
    return false
end

local function IsImmune(c)
    local w = c.workplace
    if not w then
        return false
    end
    return LAW_IMMUNE[w.class] or LAW_IMMUNE[w.template_name]
end

local function LawDaily(self)
    if not ToggleLaw or not self or (self.traits and self.traits.Android) then
        return
    end
    if IsImmune(self) then
        return
    end
    local comfort = LawState.comfort
    local san = LawState.san
    if comfort > 0 and self.ChangeComfort then
        self:ChangeComfort(comfort * const.Scale.Stat, T{"<green>A free place</green>"})
    elseif comfort < 0 and self.ChangeComfort then
        local x = LawState.n - LawState.cap
        local reason = x > 5
            and T{"<red>More red tape than Earth</red>"}
            or T{"<red>I hate bureaucracy</red>"}
        self:ChangeComfort(comfort * const.Scale.Stat, reason)
    end
    if san ~= 0 and self.ChangeSanity then
        self:ChangeSanity(san * const.Scale.Stat, "Too many Laws & Regulations")
    end
end

local function RebuildLawState()
    ReadToggle()
    local n = LawCount()
    local assembly = IsWorkingId("MartianAssembly")
    local ministries = 0
    for _, id in ipairs(MINISTRIES) do
        if IsWorkingId(id) then
            ministries = ministries + 1
        end
    end
    local cap = FreeLaws
    if assembly then
        cap = cap + FreeLawsAssembly
    end
    cap = cap + ministries * FreeLawsMinistry
    local comfort = 0
    local san = 0
    if n <= 0 then
        comfort = 3
    elseif n == 1 then
        comfort = 2
    elseif n == 2 then
        comfort = 1
    elseif n > cap then
        local x = n - cap
        comfort = -x * ComfortPenalty
        san = -x * SanityPenalty
    end
    LawState.n = n
    LawState.cap = cap
    LawState.comfort = comfort
    LawState.san = san
    LawState.assembly = assembly
    LawState.ministries = ministries
    print("RMR law day", "on", ToggleLaw, "laws", n, "cap", cap, "cPen", ComfortPenalty, "sPen", SanityPenalty, "comfort", comfort, "sanity", san, "assembly", assembly, "min", ministries)
    if not ToggleLaw then
        return
    end
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Colonist
    local applied = 0
    for _, c in ipairs(list or empty_table) do
        if c and not (c.traits and c.traits.Android) and not IsImmune(c) then
            LawDaily(c)
            applied = applied + 1
        end
    end
    print("RMR law apply", applied)
end

function OnMsg.ModsReloaded()
    ReadToggle()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        RebuildLawState()
    end
end

function OnMsg.NewDay()
    RebuildLawState()
end

function OnMsg.NewMapLoaded()
    ReadToggle()
end

function OnMsg.LoadGame()
    ReadToggle()
end