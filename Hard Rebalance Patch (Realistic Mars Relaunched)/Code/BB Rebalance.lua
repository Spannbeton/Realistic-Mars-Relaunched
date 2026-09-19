local ToggleUG = true
local last_breath

local DisableOnSurface = {
    "FusionReactor",
    "PolymerPlant",
    "MachinePartsFactory_Small",
    "MachinePartsFactory",
    "ElectronicsFactory_Small",
    "ElectronicsFactory",
    "DroneFactory",
    "SeniorsResidenceCCP1",
    "Nursery",
    "LargeNurseryCCP1",
    "Playground",
    "School",
    "MartianUniversity",
    "TVStudioWorkshopCCP1",
    "ArtWorkshop",
    "BioroboticsWorkshop",
    "VRWorkshop",
    "Sanatorium",
    "SchoolSpireCCP1",
    "EarthEmbassy",
    "MartianAssembly",
    "MinistryInternalAffairs",
    "MinistryEconomy",
    "MinistryTechnology",
    "MinistryWelfare",
    "MinistryResearch",
    "LawOffice",
    "GameDeveloper",
    "CorporateOffice",
    "Temple",
}
local DisableUnderground = {
    "MOXIE"
}

local UGDescOff = {
    FusionReactor = T{"Generates significant amounts of Power but requires Workers from a nearby Dome."},
    PolymerPlant = T{"Produces Polymers from Water and Fuel."},
    MachinePartsFactory_Small = T{"Produces Machine Parts from Metals."},
    MachinePartsFactory = T{"Produces Machine Parts from Metals."},
    ElectronicsFactory_Small = T{"Creates Electronics from Rare Metals."},
    ElectronicsFactory = T{"Creates Electronics from Rare Metals."},
    DroneFactory = T{"Produces Drones Prefabs which can then be used to order new drones in Drone Hubs multiplying the obedient workforce of the Colony. Probably not a threat to humans."},
    SeniorsResidenceCCP1 = T{"Provide a very comfortable living space exclusively for Seniors. Residents will recover additional Sanity when resting."},
    Nursery = T{"Provides living space for children."},
    LargeNurseryCCP1 = T{"Provides living space for children."},
    Playground = T{"Cultivates Perks in Children through special nurturing programs."},
    School = T{"Cultivates desired Perks in children using modern remote learning techniques."},
    MartianUniversity = T{"Trains Specialists using modern remote learning techniques. Graduation speed depends on the individual student performance."},
    TVStudioWorkshopCCP1 = T{"A vocation building dedicated to the creation of TV Reality Show for the Earth folks. Workers receive Comfort and Morale boost and count towards the Workshop milestone. Generates funding and Consumes Electronics."},
    ArtWorkshop = T{"A vocation building dedicated to creation of works of art. Workers receive Comfort and Morale boost and count towards the Workshop milestone. Consumes Polymers."},
    BioroboticsWorkshop = T{"A vocation building dedicated to the creation of Biorobots. Workers receive Comfort and Morale boost and count towards the Workshop milestone. Consumes Machine Parts."},
    VRWorkshop = T{"A vocation building dedicated to the creation of virtual worlds. Workers receive Comfort and Morale boost and count towards the Workshop milestone. Consumes Electronics."},
    Sanatorium = T{"Treats Colonists for flaws through advanced and (mostly) humane medical practices."},
    SchoolSpireCCP1 = T{"Cultivates desired Perks in children using modern remote learning techniques."},
    EarthEmbassy = T{"Generates funding or other rewards if the Diplomacy laws are enacted. The period at which the rewards are given depends on the building performance"},
    MartianAssembly = T{"Unlocks new laws and allows setting the form of Government"},
    MinistryInternalAffairs = T{"Reduces building resource costs and boosts the Education and Effective Governing laws from the Permits & Efficiency category"},
    MinistryEconomy = T{"Increases export costs and boosts the Heavy Mining, Shift Optimization and Underground Exploitation laws from the Economy & Industry category"},
    MinistryTechnology = T{"Increases factory (Machine parts, Electronics, Polymers) production and boosts the Rocket Speed Deregulation, Energy Efficiency, and Shuttle Fuel Conservation laws from the Tech Deregulation category"},
    MinistryWelfare = T{"Improves worker performance and boosts the Crowded Living, Quiet Hours, and Mars Appreciation laws from the Society category"},
    MinistryResearch = T{"Provides additional sponsor research and boosts the Research Focus, Safety Standards Deregulation, and Forestation Effort laws from the Research & Ecology category"},
    LawOffice = T{"Automatically prepares laws and lowers their upkeep"},
    GameDeveloper = T{"Works on awesome new titles that gamers on Earth and Mars can enjoy. Released titles grant Funding, but profits tend to be unpredictable."},
    CorporateOffice = T{"Generates funding. Working in a corporate environment can be soul-sucking so all workers take Comfort penalties."},
    Temple = T{"A place to meditate and seek meaning beyond the physical world. Visitors recover Sanity."},
}

local UGLockedExtra = {
    FusionReactor = T{" Can only be built on the surface once the atmosphere is breathable. The reactor cannot be certified under our current surface conditions."},
    PolymerPlant = T{" Can only be built on the surface once the atmosphere is breathable. Chemical processing cannot be certified under our current surface conditions."},
    MachinePartsFactory_Small = T{" Can only be built on the surface once the atmosphere is breathable. Precision manufacturing cannot be certified under our current surface conditions."},
    MachinePartsFactory = T{" Can only be built on the surface once the atmosphere is breathable. Precision manufacturing cannot be certified under our current surface conditions."},
    ElectronicsFactory_Small = T{" Can only be built on the surface once the atmosphere is breathable. Clean-room production cannot be certified under our current surface conditions."},
    ElectronicsFactory = T{" Can only be built on the surface once the atmosphere is breathable. Clean-room production cannot be certified under our current surface conditions."},
    DroneFactory = T{" Can only be built on the surface once the atmosphere is breathable. Drone assembly cannot be certified under our current surface conditions."},
    SeniorsResidenceCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. The old-timers will wait for air they can breathe."},
    Nursery = T{" Can only be built on the surface once the atmosphere is breathable. Kids would rather wait until they can play outside without a helmet."},
    LargeNurseryCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Kids would rather wait until they can play outside without a helmet."},
    Playground = T{" Can only be built on the surface once the atmosphere is breathable. Kids would rather wait until they can play outside without a helmet."},
    School = T{" Can only be built on the surface once the atmosphere is breathable. Kids would rather wait until they can play outside without a helmet."},
    SchoolSpireCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Kids would rather wait until they can play outside without a helmet."},
    MartianUniversity = T{" Can only be built on the surface once the atmosphere is breathable. Teaching labs cannot be certified under our current surface conditions."},
    TVStudioWorkshopCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Broadcast equipment cannot be certified under our current surface conditions."},
    ArtWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. Studio equipment cannot be certified under our current surface conditions."},
    BioroboticsWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. Biorobot workshops cannot be certified under our current surface conditions."},
    VRWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. VR hardware cannot be certified under our current surface conditions."},
    Sanatorium = T{" Can only be built on the surface once the atmosphere is breathable. Medical facilities cannot be certified under our current surface conditions."},
    EarthEmbassy = T{" Can only be built on the surface once the atmosphere is breathable. Earth will not accredit an embassy until visitors can take their helmets off at the door."},
    MartianAssembly = T{" Can only be built on the surface once the atmosphere is breathable. We can't hold session in a spacesuit."},
    MinistryInternalAffairs = T{" Can only be built on the surface once the atmosphere is breathable. Surface postings declined. Workplace safety still files the atmosphere as unfit for occupancy."},
    MinistryEconomy = T{" Can only be built on the surface once the atmosphere is breathable. Surface postings declined. Workplace safety still files the atmosphere as unfit for occupancy."},
    MinistryTechnology = T{" Can only be built on the surface once the atmosphere is breathable. Surface postings declined. Workplace safety still files the atmosphere as unfit for occupancy."},
    MinistryWelfare = T{" Can only be built on the surface once the atmosphere is breathable. Surface postings declined. Workplace safety still files the atmosphere as unfit for occupancy."},
    MinistryResearch = T{" Can only be built on the surface once the atmosphere is breathable. Surface postings declined. Workplace safety still files the atmosphere as unfit for occupancy."},
    LawOffice = T{" Can only be built on the surface once the atmosphere is breathable. Legal will not open surface chambers while the air is still a workplace violation."},
    GameDeveloper = T{" Can only be built on the surface once the atmosphere is breathable. Earth publishers will not fund a studio where the staff work in helmets."},
    CorporateOffice = T{" Can only be built on the surface once the atmosphere is breathable. Head office stays put until the air passes a safety review."},
    Temple = T{" Can only be built on the surface once the atmosphere is breathable. A congregation cannot gather for worship in unbreathable air."},
}

local UG_RES = {
    "Metals",
    "Water",
    "Concrete",
    "Polymers",
    "PreciousMetals",
    "PreciousMinerals",
}

local function SurfaceAllowed()
    if not ToggleUG then
        return true
    end
    if not GetAtmosphereBreathable then
        return false
    end
    local city = MainCity or UICity
    if city and city.GetMap then
        return GetAtmosphereBreathable(city:GetMap()) and true or false
    end
    return false
end

local function SetBldDesc(id, desc)
    if not desc then
        return
    end
    local bt = BuildingTemplates and BuildingTemplates[id]
    if not bt then
        return
    end
    if bt.SetProperty then
        bt:SetProperty("description", desc)
    elseif rawget(bt, "description") ~= nil or bt.description ~= nil then
        bt.description = desc
    end
end

local function ApplyUGDesc()
    if not BuildingTemplates then
        return
    end
    local locked = ToggleUG and not SurfaceAllowed()
    for _, id in ipairs(DisableOnSurface) do
        local off = UGDescOff[id]
        if locked and off and UGLockedExtra[id] then
            SetBldDesc(id, T{ "<base><extra>", base = off, extra = UGLockedExtra[id] })
        else
            SetBldDesc(id, off)
        end
    end
end

local function StripUndergroundDeposits()
    if not ToggleUG then
        return
    end
    local p = RandomMapPresets and RandomMapPresets.Underground
    if not p then
        print("RMR: no RandomMapPresets.Underground")
        return
    end
    for _, res in ipairs(UG_RES) do
        local key = "ResEnabled_" .. res
        if p[key] ~= nil then
            p[key] = false
        end
    end
end

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Underground_Rebalance")
        if v ~= nil then
            ToggleUG = v
        end
    end
end

local function SurfaceBuildChange()
    if type(DisabledInEnvironment) ~= "table" then
        return
    end
    local lock_surface = ToggleUG and not SurfaceAllowed()
    for _, id in ipairs(DisableOnSurface) do
        if BuildingTemplates[id] then
            if lock_surface then
                DisableInEnvironment(id, "Surface")
            else
                UndisableInEnvironment(id, "Surface")
            end
        end
    end
    for _, id in ipairs(DisableUnderground) do
        if BuildingTemplates[id] then
            if ToggleUG then
                DisableInEnvironment(id, "Underground")
            else
                UndisableInEnvironment(id, "Underground")
            end
        end
    end
    ApplyUGDesc()
    if RefreshXBuildMenu and GetDialog and GetDialog("XBuildMenu") then
        RefreshXBuildMenu()
    end
end

if GetAtmosphereBreathable and not rawget(_G, "RMR_BreathWrapped") then
    local OldBreath = GetAtmosphereBreathable
    function GetAtmosphereBreathable(...)
        local r = OldBreath(...)
        if r ~= last_breath then
            last_breath = r
            SurfaceBuildChange()
        end
        return r
    end
    rawset(_G, "RMR_BreathWrapped", true)
end

local function EligibleAge(c)
    return c and c.traits and (c.traits.Child or c.traits.Senior) and not c.traits.Android
end

local function ApplyUGSanityDay()
    if not ToggleUG then
        return
    end
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Colonist
    local lack = g_Consts and g_Consts.LackOfLight or 0
    for _, c in ipairs(list or empty_table) do
        if EligibleAge(c) and c.ChangeSanity then
            if ObjectIsInEnvironment(c, "Underground") then
                if lack > 0 then
                    c:ChangeSanity(lack, "I am safe underground")
                end
            elseif ObjectIsInEnvironment(c, "Surface") and c.GetMap and not GetAtmosphereBreathable(c:GetMap()) then
                c:ChangeSanity(-lack * 2, "This place is unsafe")
            end
        end
    end
end

local OldMoraleAdj = Colonist.GetMoraleAdjustment
function Colonist:GetMoraleAdjustment(...)
    if ToggleUG and (self.traits.Child or self.traits.Senior)
        and ObjectIsInEnvironment(self, "Underground") then
        return 0
    end
    return OldMoraleAdj(self, ...)
end

function OnMsg.NewDay()
    ApplyUGSanityDay()
end

function OnMsg.ModsReloaded()
    ReadToggle()
    StripUndergroundDeposits()
    SurfaceBuildChange()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        SurfaceBuildChange()
        StripUndergroundDeposits()
    end
end

function OnMsg.LoadGame()
    ReadToggle()
    SurfaceBuildChange()
    StripUndergroundDeposits()
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    SurfaceBuildChange()
    StripUndergroundDeposits()
end

function OnMsg.TechResearched()
    SurfaceBuildChange()
end

function OnMsg.TerraformThresholdPassed(id, reached)
    if id == "AtmosphereBreathable" then
        SurfaceBuildChange()
    end
end