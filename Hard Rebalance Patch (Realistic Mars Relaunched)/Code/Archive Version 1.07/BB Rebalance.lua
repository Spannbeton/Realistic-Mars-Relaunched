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
    SeniorsResidenceCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Seniors remain fearful on the surface until then."},
    Nursery = T{" Can only be built on the surface once the atmosphere is breathable. Children remain fearful on the surface until then."},
    LargeNurseryCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Children remain fearful on the surface until then."},
    Playground = T{" Can only be built on the surface once the atmosphere is breathable. Children remain fearful on the surface until then."},
    School = T{" Can only be built on the surface once the atmosphere is breathable. Children remain fearful on the surface until then."},
    SchoolSpireCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Children remain fearful on the surface until then."},
    MartianUniversity = T{" Can only be built on the surface once the atmosphere is breathable. Teaching labs cannot be certified under our current surface conditions."},
    TVStudioWorkshopCCP1 = T{" Can only be built on the surface once the atmosphere is breathable. Broadcast equipment cannot be certified under our current surface conditions."},
    ArtWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. Studio equipment cannot be certified under our current surface conditions."},
    BioroboticsWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. Biorobot workshops cannot be certified under our current surface conditions."},
    VRWorkshop = T{" Can only be built on the surface once the atmosphere is breathable. VR hardware cannot be certified under our current surface conditions."},
    Sanatorium = T{" Can only be built on the surface once the atmosphere is breathable. Medical facilities cannot be certified under our current surface conditions."},
    EarthEmbassy = T{" Can only be built on the surface once the atmosphere is breathable. Earth will not accredit an embassy that risks a diplomatic incident in unbreathable air."},
    MartianAssembly = T{" Can only be built on the surface once the atmosphere is breathable. A legislature cannot claim legitimacy if it sits where the public cannot breathe."},
    MinistryInternalAffairs = T{" Can only be built on the surface once the atmosphere is breathable. Ministry staff refuse surface postings while workplace-safety law still classifies the air as unsafe."},
    MinistryEconomy = T{" Can only be built on the surface once the atmosphere is breathable. Ministry staff refuse surface postings while workplace-safety law still classifies the air as unsafe."},
    MinistryTechnology = T{" Can only be built on the surface once the atmosphere is breathable. Ministry staff refuse surface postings while workplace-safety law still classifies the air as unsafe."},
    MinistryWelfare = T{" Can only be built on the surface once the atmosphere is breathable. Ministry staff refuse surface postings while workplace-safety law still classifies the air as unsafe."},
    MinistryResearch = T{" Can only be built on the surface once the atmosphere is breathable. Ministry staff refuse surface postings while workplace-safety law still classifies the air as unsafe."},
    LawOffice = T{" Can only be built on the surface once the atmosphere is breathable. Counsel will not open chambers on the surface while lawsuit exposure from an unsafe workplace remains unbounded."},
    GameDeveloper = T{" Can only be built on the surface once the atmosphere is breathable. Earth publishers will not fund a studio that can be sued for sending staff into unbreathable air."},
    CorporateOffice = T{" Can only be built on the surface once the atmosphere is breathable. Corporate counsel blocks a surface office while lawsuit risk from an unsafe workplace remains unbounded."},
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
    local bt = BuildingTemplates and BuildingTemplates[id]
    local cls = rawget(_G, id)
    if bt and desc then
        bt.description = desc
    end
    if cls and desc then
        cls.description = desc
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

local OldDaily = Colonist.DailyUpdate
function Colonist:DailyUpdate(...)
    OldDaily(self, ...)
    if not ToggleUG then
        self:Affect("StatusEffect_UnsafeSurface", false)
        return
    end
    if self.traits.Android then
        return
    end
    if not (self.traits.Child or self.traits.Senior) then
        return
    end

    if ObjectIsInEnvironment(self, "Underground") then
        if g_Consts.LackOfLight > 0 then
            self:ChangeSanity(g_Consts.LackOfLight, "I am safe underground")
        end
        return
    end

    if ObjectIsInEnvironment(self, "Surface") and not GetAtmosphereBreathable(self:GetMap()) then
        self:ChangeSanity(-g_Consts.LackOfLight * 2, "This place is unsafe")
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