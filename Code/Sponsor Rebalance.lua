local ToggleSponsor = true
local Vanilla
local NASA_WANT = 50
local OrigGMS
local OrigSummary
local OrigDescr

print("RMR sponsor lua loaded")

local FUNDING = {
    IMM = 6000,
    NASA = 5000,
    BlueSun = 5500,
    CNSA = 4500,
    ISRO = 4000,
    ESA = 4000,
    SpaceY = 5000,
    Brazil = 4000,
    TerraInitiative = 4000,
    Japan = 5000,
    Roscosmos = 4000,
    NewArk = 4000,
    paradox = 3500,
}

local ROCKET_CAP = {
    SpaceY = 3,
}

local DEFAULT_ROCKET_CAP = 2

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Sponsor_Rebalance")
        if v ~= nil then
            ToggleSponsor = v
        end
    end
end

local function EachSponsor(fn)
    local seen = {}
    local function go(s)
        if type(s) ~= "table" or not s.id or s.id == "random" or s.hidden then
            return
        end
        if seen[s] then
            return
        end
        seen[s] = true
        fn(s)
    end
    if ForEachPreset then
        ForEachPreset("MissionSponsorPreset", go)
    end
    if MissionSponsors then
        for _, s in pairs(MissionSponsors) do
            go(s)
        end
    end
end

local function RocketCap(id)
    return ROCKET_CAP[id] or DEFAULT_ROCKET_CAP
end

local function FindNASAIntervalFx(s)
    for i = 1, #s do
        local fx = s[i]
        if type(fx) == "table" and fx.Prop == "SponsorFundingPerInterval" then
            return fx
        end
    end
end

local function SaveVanilla()
    if Vanilla and #Vanilla > 0 then
        return true
    end
    Vanilla = {}
    EachSponsor(function(s)
        local fx = FindNASAIntervalFx(s)
        Vanilla[#Vanilla + 1] = {
            obj = s,
            funding = s.funding,
            rockets = s.initial_rockets,
            nasa_fx = fx,
            nasa_amt = fx and fx.Amount,
        }
    end)
    print("RMR sponsor snap", #Vanilla)
    if #Vanilla == 0 then
        Vanilla = nil
        return false
    end
    return true
end

local function ApplyOne(s)
    if type(s) ~= "table" or not s.id then
        return s
    end
    if not ToggleSponsor then
        return s
    end
    local want = FUNDING[s.id]
    if want and type(s.funding) == "number" and s.funding > want then
        s.funding = want
    end
    local cap = RocketCap(s.id)
    if type(s.initial_rockets) == "number" and s.initial_rockets > cap then
        s.initial_rockets = cap
    end
    local fx = FindNASAIntervalFx(s)
    if fx then
        fx.Amount = NASA_WANT
    end
    return s
end

local function WrapReaders()
    local gms = rawget(_G, "GetMissionSponsor")
    if gms and not OrigGMS then
        OrigGMS = gms
        function GetMissionSponsor(name)
            return ApplyOne(OrigGMS(name))
        end
        print("RMR sponsor wrap GetMissionSponsor")
    end
    local sum = rawget(_G, "GetSponsorSummary")
    if sum and not OrigSummary then
        OrigSummary = sum
        function GetSponsorSummary(sponsor)
            ApplyOne(sponsor)
            return OrigSummary(sponsor)
        end
        print("RMR sponsor wrap GetSponsorSummary")
    end
    local descr = rawget(_G, "GetSponsorDescr")
    if descr and not OrigDescr then
        OrigDescr = descr
        function GetSponsorDescr(sponsor)
            ApplyOne(sponsor)
            return OrigDescr(sponsor)
        end
        print("RMR sponsor wrap GetSponsorDescr")
    end
end

local function ApplyNASAConst()
    if not g_Consts or not g_Consts.SetModifier then
        return
    end
    local fn = OrigGMS or rawget(_G, "GetMissionSponsor")
    local s = fn and fn()
    if ToggleSponsor and s and s.id == "NASA" then
        g_Consts:SetModifier("SponsorFundingPerInterval", "RMR_SponsorNASA", NASA_WANT - 500, 0)
        print("RMR sponsor NASA stipend", g_Consts.SponsorFundingPerInterval)
    else
        if g_Consts.SetModifier then
            g_Consts:SetModifier("SponsorFundingPerInterval", "RMR_SponsorNASA", 0, 0)
        end
    end
end

local function ApplySponsors()
    ReadToggle()
    if not SaveVanilla() then
        print("RMR sponsor skip")
        return
    end
    for i = 1, #Vanilla do
        local row = Vanilla[i]
        local s = row.obj
        if s then
            if not ToggleSponsor then
                s.funding = row.funding
                s.initial_rockets = row.rockets
                if row.nasa_fx then
                    row.nasa_fx.Amount = row.nasa_amt
                end
            else
                ApplyOne(s)
                print("RMR sponsor", s.id, "funding", s.funding, "rockets", s.initial_rockets)
            end
        end
    end
    ApplyNASAConst()
    WrapReaders()
end

function OnMsg.ModsReloaded()
    CreateRealTimeThread(function()
        Sleep(1)
        ApplySponsors()
    end)
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        Msg("ModsReloaded")
    end
end

function OnMsg.NewMapLoaded()
    ApplySponsors()
end

function OnMsg.LoadGame()
    ApplySponsors()
end
