local FlightMult = 2
local FundingPct = 100
local ExportDelta = -2

local function ReadToggle()
    if not CurrentModOptions then
        return
    end
    local a = CurrentModOptions:GetProperty("Flight_Time_Mult")
    if type(a) == "number" then
        FlightMult = a
    end
    local b = CurrentModOptions:GetProperty("Funding_Percent")
    if type(b) == "number" then
        FundingPct = b
    end
    local c = CurrentModOptions:GetProperty("Export_Price_Delta")
    if type(c) == "number" then
        ExportDelta = c
    end
end

local function Snapshot()
    if not g_Consts then
        return false
    end
    local s = GetMissionSponsor and GetMissionSponsor()
    return {
        EarthMars = g_Consts.base_TravelTimeEarthMars or g_Consts.TravelTimeEarthMars,
        MarsEarth = g_Consts.base_TravelTimeMarsEarth or g_Consts.TravelTimeMarsEarth,
        MarsAsteroid = g_Consts.base_TravelTimeMarsAsteroid,
        MarsRival = g_Consts.base_TravelTimeMarsRival,
        MinTravel = g_Consts.base_RocketMinTravelTime,
        export_metals = (s and s.precious_metals_export_price) or g_Consts.base_ExportPricePreciousMetals or 25,
        export_minerals = (s and s.precious_minerals_export_price) or g_Consts.base_ExportPricePreciousMinerals or 32,
    }
end

local function RestoreVanillaConsts()
    if not g_Consts then
        return
    end
    g_Consts.TravelTimeEarthMars = g_Consts.base_TravelTimeEarthMars or g_Consts.TravelTimeEarthMars
    g_Consts.TravelTimeMarsEarth = g_Consts.base_TravelTimeMarsEarth or g_Consts.TravelTimeMarsEarth
    if g_Consts.base_TravelTimeMarsAsteroid then
        g_Consts.TravelTimeMarsAsteroid = g_Consts.base_TravelTimeMarsAsteroid
    end
    if g_Consts.base_TravelTimeMarsRival then
        g_Consts.TravelTimeMarsRival = g_Consts.base_TravelTimeMarsRival
    end
    if g_Consts.base_RocketMinTravelTime then
        g_Consts.RocketMinTravelTime = g_Consts.base_RocketMinTravelTime
    end
    g_Consts.FundingGainsModifier = g_Consts.base_FundingGainsModifier or 100
    g_Consts.ExportPricePreciousMetals = g_Consts.base_ExportPricePreciousMetals or g_Consts.ExportPricePreciousMetals
    g_Consts.ExportPricePreciousMinerals = g_Consts.base_ExportPricePreciousMinerals or g_Consts.ExportPricePreciousMinerals
    print("RMR misc restore")
end

local function ApplyMisc()
    ReadToggle()
    local snap = Snapshot()
    if not snap then
        print("RMR misc skip")
        return
    end
    g_Consts.TravelTimeEarthMars = snap.EarthMars * FlightMult
    g_Consts.TravelTimeMarsEarth = (snap.MarsEarth or snap.EarthMars) * FlightMult
    if snap.MarsAsteroid then
        g_Consts.TravelTimeMarsAsteroid = snap.MarsAsteroid * FlightMult
    end
    if snap.MarsRival then
        g_Consts.TravelTimeMarsRival = snap.MarsRival * FlightMult
    end
    if snap.MinTravel then
        g_Consts.RocketMinTravelTime = snap.MinTravel * FlightMult
    end
    g_Consts.FundingGainsModifier = FundingPct
    g_Consts.ExportPricePreciousMetals = snap.export_metals + ExportDelta
    g_Consts.ExportPricePreciousMinerals = snap.export_minerals + ExportDelta
    print("RMR misc snap", snap.export_metals, snap.export_minerals)
    print("RMR misc flight", FlightMult, g_Consts.TravelTimeEarthMars, g_Consts.TravelTimeMarsEarth)
    print("RMR misc funding", FundingPct, g_Consts.FundingGainsModifier)
    print("RMR misc export", ExportDelta, g_Consts.ExportPricePreciousMetals, g_Consts.ExportPricePreciousMinerals)
end

function OnMsg.ModsReloaded()
    ReadToggle()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ApplyMisc()
    end
end

function OnMsg.CityStart()
    ApplyMisc()
end

function OnMsg.NewMapLoaded()
    ApplyMisc()
end

function OnMsg.LoadGame()
    ApplyMisc()
end

function OnMsg.DoneGame()
    RestoreVanillaConsts()
end

function OnMsg.ChangeMap()
    RestoreVanillaConsts()
end