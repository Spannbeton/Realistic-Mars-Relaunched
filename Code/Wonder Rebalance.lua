local Wonder_Toggle = true
local Mohole_PowerPerWorker = 2000
local Mohole_MetalPerWorker = 2500
local Mohole_RarePerWorker = 525
local Mohole_WastePerWorker = 5000
local Telescope_ReconPerDay = 120000
local Asteroids_OldGetMax
local Mohole_PowerWrapped

local TelescopeDescOff = T{"Peering beyond the veil of the unknown, this radio telescope gives access to new Breakthrough Technologies and reduces overall Research costs."}
local TelescopeDescOn = T{"A deep-space array that must be staffed by Scientists. Generates Recon for asteroid detection, reveals Breakthroughs, and reduces Research costs. Additional asteroid slots come from upgrades. Rare asteroids yield further Breakthroughs."}

local MoholeDescOff = T{"Mining deep into the crust of Mars, the Mohole Mine produces Metals, Rare Metals and Waste Rock, while heating the surrounding area."}
local MoholeDescOn = T{"Mines Metals, Rare Metals and large amounts of Waste Rock without a deposit, and heats the surrounding area. Requires a large workforce; Power use scales with staff on site."}

local ElevatorVanilla
local ElevatorTechVanilla
local ElevatorTechOn = T{"Wonder: <em>Space Elevator</em> (<buildinginfo('SpaceElevator')>) - Exports <em>Rare Metals</em> to Earth and offers resupply materials and prefabs at preferential prices. Construction cost rises with distance from the equator."}

local function DupT(t)
    if type(t) ~= "table" then
        return t
    end
    local n = {}
    for k, v in pairs(t) do
        n[k] = v
    end
    local mt = getmetatable(t)
    if mt then
        setmetatable(n, mt)
    end
    return n
end

local function Wonder_ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Wonder_Rebalance")
        if v ~= nil then
            Wonder_Toggle = v
        end
    end
end

local function Wonder_AddParent(cls, parent)
    if cls and cls.__parents and not table.find(cls.__parents, parent) then
        cls.__parents[#cls.__parents + 1] = parent
    end
end

local function Wonder_Set(obj, key, value)
    if not obj then
        return
    end
    if obj.SetProperty and obj.HasMember and obj:HasMember(key) then
        obj:SetProperty(key, value)
        return
    end
    obj[key] = value
end

local function Wonder_CountSlotUpgrades(labels)
    local n = 0
    if not labels then
        return 0
    end
    for _, bld in ipairs(labels) do
        if bld.HasUpgrade then
            if bld:HasUpgrade("ReconCenter_Slot2") then
                n = n + 1
            end
            if bld:HasUpgrade("ReconCenter_Slot3") then
                n = n + 1
            end
        end
    end
    return n
end

local function Wonder_GetMaxAsteroids(self, ...)
    if not Wonder_Toggle then
        if Asteroids_OldGetMax then
            return Asteroids_OldGetMax(self, ...)
        end
        return 1
    end
    local labels = UIColony and UIColony.labels
    local n = 1
    if labels then
        n = n + Wonder_CountSlotUpgrades(labels.ReconCenter)
        n = n + Wonder_CountSlotUpgrades(labels.OmegaTelescope)
    end
    return n
end

local function Wonder_HookAsteroids()
    if Asteroids and Asteroids.GetMaxAsteroids then
        if not Asteroids_OldGetMax then
            Asteroids_OldGetMax = Asteroids.GetMaxAsteroids
        end
        Asteroids.GetMaxAsteroids = Wonder_GetMaxAsteroids
    end
    if UIColony and UIColony.GetMaxAsteroids then
        UIColony.GetMaxAsteroids = Wonder_GetMaxAsteroids
    end
end

function OnMsg.ClassesGenerate()
    Wonder_AddParent(rawget(_G, "OmegaTelescopeBase"), "ReconCenterBase")
    Wonder_AddParent(rawget(_G, "MoholeMineBase"), "Workplace")
    Wonder_AddParent(rawget(_G, "MoholeMine"), "Workplace")
    Wonder_AddParent(rawget(_G, "ArtificialSunBase"), "Workplace")
    Wonder_AddParent(rawget(_G, "ArtificialSun"), "Workplace")
end

function OnMsg.ClassesBuilt()
    Wonder_HookAsteroids()
    if Mohole_PowerWrapped or not MoholeMine or not MoholeMine.UpdatePerformance then
        return
    end
    Mohole_PowerWrapped = true
    local old = MoholeMine.UpdatePerformance
    function MoholeMine:UpdatePerformance(...)
        old(self, ...)
        if not Wonder_Toggle then
            return
        end
        local staffed = 0
        if type(self.workers) == "table" then
            for _, shift in ipairs(self.workers) do
                staffed = staffed + #(shift or empty_table)
            end
        end
        if self.SetBase then
            self:SetBase("electricity_consumption", Mohole_PowerPerWorker * staffed)
        end
    end
end

local function Telescope_LockSurface()
    if type(DisabledInEnvironment) ~= "table" then
        return
    end
    if Wonder_Toggle then
        DisableInEnvironment("OmegaTelescope", "Surface")
        UndisableInEnvironment("OmegaTelescope", "Asteroid")
    else
        UndisableInEnvironment("OmegaTelescope", "Surface")
        DisableInEnvironment("OmegaTelescope", "Asteroid")
    end
    if RefreshXBuildMenu and GetDialog and GetDialog("XBuildMenu") then
        RefreshXBuildMenu()
    end
end

local function Telescope_Apply()
    local recon = BuildingTemplates and BuildingTemplates.ReconCenter
    local tmpl = BuildingTemplates and BuildingTemplates.OmegaTelescope
    local cls = rawget(_G, "OmegaTelescope")
    local base = rawget(_G, "OmegaTelescopeBase")
    if not tmpl then
        return
    end
    if not Wonder_Toggle then
        tmpl.description = DupT(TelescopeDescOff)
        if cls then
            cls.description = DupT(TelescopeDescOff)
        end
        if base then
            base.description = DupT(TelescopeDescOff)
        end
        return
    end

    local workers = ((recon and recon.max_workers) or 3) * 2

    for _, obj in ipairs({ tmpl, cls, base }) do
        Wonder_Set(obj, "max_workers", workers)
        Wonder_Set(obj, "specialist", "scientist")
        Wonder_Set(obj, "work_type", "Mental")
        Wonder_Set(obj, "ReconPointsPerDay", Telescope_ReconPerDay)
        Wonder_Set(obj, "base_ReconPointsPerDay", Telescope_ReconPerDay)

        Wonder_Set(obj, "upgrade1_id", "ReconCenter_DeepSpaceScanning")
        Wonder_Set(obj, "upgrade1_display_name", Untranslated("Deep Space Scanning"))
        Wonder_Set(obj, "upgrade1_description", Untranslated("+50% Recon per Sol; +10 Power."))
        Wonder_Set(obj, "upgrade1_mod_label_1", "OmegaTelescope")
        Wonder_Set(obj, "upgrade1_mod_prop_id_1", "electricity_consumption")
        Wonder_Set(obj, "upgrade1_add_value_1", 10000)
        Wonder_Set(obj, "upgrade1_mod_label_2", "OmegaTelescope")
        Wonder_Set(obj, "upgrade1_mod_prop_id_2", "ReconPointsPerDay")
        Wonder_Set(obj, "upgrade1_mul_value_2", 50)
        Wonder_Set(obj, "upgrade1_upgrade_cost_PreciousMinerals", 500000)

        Wonder_Set(obj, "upgrade2_id", "ReconCenter_Slot2")
        Wonder_Set(obj, "upgrade2_display_name", Untranslated("Additional Asteroid slot"))
        Wonder_Set(obj, "upgrade2_description", Untranslated("Allows additional asteroid to be explored and be available to visit"))
        Wonder_Set(obj, "upgrade2_upgrade_cost_Electronics", 200000)
        Wonder_Set(obj, "upgrade2_upgrade_cost_PreciousMinerals", 100000)

        Wonder_Set(obj, "upgrade3_id", "ReconCenter_Slot3")
        Wonder_Set(obj, "upgrade3_display_name", Untranslated("Additional Asteroid Slot"))
        Wonder_Set(obj, "upgrade3_description", Untranslated("Allows additional asteroid to be explored and be available to visit"))
        Wonder_Set(obj, "upgrade3_upgrade_cost_Electronics", 200000)
        Wonder_Set(obj, "upgrade3_upgrade_cost_PreciousMinerals", 100000)
    end

    tmpl.description = DupT(TelescopeDescOn)
    if cls then
        cls.description = DupT(TelescopeDescOn)
    end
    if base then
        base.description = DupT(TelescopeDescOn)
    end

    local labels = UIColony and UIColony.labels and UIColony.labels.OmegaTelescope
    if labels then
        for _, bld in ipairs(labels) do
            Wonder_Set(bld, "ReconPointsPerDay", Telescope_ReconPerDay)
            Wonder_Set(bld, "base_ReconPointsPerDay", Telescope_ReconPerDay)
            Wonder_Set(bld, "max_workers", workers)
            Wonder_Set(bld, "work_type", "Mental")
        end
    end
    Wonder_HookAsteroids()
end

local function Mohole_Apply()
    local tmpl = BuildingTemplates and BuildingTemplates.MoholeMine
    local cls = rawget(_G, "MoholeMine")
    local base = rawget(_G, "MoholeMineBase")
    if not tmpl then
        return
    end
    if not Wonder_Toggle then
        tmpl.description = DupT(MoholeDescOff)
        if cls then
            cls.description = DupT(MoholeDescOff)
        end
        if base then
            base.description = DupT(MoholeDescOff)
        end
        return
    end

    local metal = Mohole_MetalPerWorker * 5
    local rare = Mohole_RarePerWorker * 5
    local waste = Mohole_WastePerWorker * 5

    for _, key in ipairs({
        "construction_cost_Concrete", "construction_cost_Metals",
        "construction_cost_MachineParts", "construction_cost_Electronics",
        "construction_cost_Polymers", "construction_cost_PreciousMetals",
        "construction_cost_PreciousMinerals",
    }) do
        local v = tmpl[key]
        if type(v) == "number" and v > 0 then
            local half = floatfloor(v / 2)
            Wonder_Set(tmpl, key, half)
            Wonder_Set(cls, key, half)
            Wonder_Set(base, key, half)
        end
    end

    for _, obj in ipairs({ tmpl, cls, base }) do
        Wonder_Set(obj, "max_workers", 5)
        Wonder_Set(obj, "specialist", "geologist")
        Wonder_Set(obj, "work_type", "Physical")
        Wonder_Set(obj, "base_production_per_day1", metal)
        Wonder_Set(obj, "base_production_per_day2", rare)
        Wonder_Set(obj, "base_production_per_day3", waste)
        Wonder_Set(obj, "production_per_day1", metal)
        Wonder_Set(obj, "production_per_day2", rare)
        Wonder_Set(obj, "production_per_day3", waste)
        Wonder_Set(obj, "electricity_consumption", Mohole_PowerPerWorker * 5)
        Wonder_Set(obj, "max_storage", 100000)
        Wonder_Set(obj, "max_storage1", 100000)
        Wonder_Set(obj, "max_storage3", 100000)

        Wonder_Set(obj, "upgrade1_id", "Mohole_ExpandMohole_1")
        Wonder_Set(obj, "upgrade1_mod_prop_id_1", "max_workers")
        Wonder_Set(obj, "upgrade1_add_value_1", 5)
        Wonder_Set(obj, "upgrade1_mul_value_1", 0)
        Wonder_Set(obj, "upgrade1_mod_label_1", "MoholeMine")
        Wonder_Set(obj, "upgrade1_mod_prop_id_2", "production_per_day1")
        Wonder_Set(obj, "upgrade1_mul_value_2", 100)
        Wonder_Set(obj, "upgrade1_add_value_2", 0)
        Wonder_Set(obj, "upgrade1_mod_label_2", "MoholeMine")
        Wonder_Set(obj, "upgrade1_mod_prop_id_3", "production_per_day2")
        Wonder_Set(obj, "upgrade1_mul_value_3", 100)
        Wonder_Set(obj, "upgrade1_add_value_3", 0)
        Wonder_Set(obj, "upgrade1_mod_label_3", "MoholeMine")
        Wonder_Set(obj, "upgrade1_upgrade_cost_MachineParts", 500000)
        Wonder_Set(obj, "upgrade1_upgrade_cost_Concrete", 1000000)
        Wonder_Set(obj, "upgrade1_upgrade_cost_Electronics", 0)
        Wonder_Set(obj, "upgrade1_display_name", Untranslated("Expand Mohole I"))
        Wonder_Set(obj, "upgrade1_description", Untranslated("+5 workers per shift. Double Metals and Rares."))

        Wonder_Set(obj, "upgrade2_id", "Mohole_ExpandMohole_2")
        Wonder_Set(obj, "upgrade2_mod_prop_id_1", "max_workers")
        Wonder_Set(obj, "upgrade2_add_value_1", 10)
        Wonder_Set(obj, "upgrade2_mul_value_1", 0)
        Wonder_Set(obj, "upgrade2_mod_label_1", "MoholeMine")
        Wonder_Set(obj, "upgrade2_mod_prop_id_2", "production_per_day1")
        Wonder_Set(obj, "upgrade2_mul_value_2", 100)
        Wonder_Set(obj, "upgrade2_add_value_2", 0)
        Wonder_Set(obj, "upgrade2_mod_label_2", "MoholeMine")
        Wonder_Set(obj, "upgrade2_mod_prop_id_3", "production_per_day2")
        Wonder_Set(obj, "upgrade2_mul_value_3", 100)
        Wonder_Set(obj, "upgrade2_add_value_3", 0)
        Wonder_Set(obj, "upgrade2_mod_label_3", "MoholeMine")
        Wonder_Set(obj, "upgrade2_upgrade_cost_MachineParts", 200000)
        Wonder_Set(obj, "upgrade2_upgrade_cost_Metals", 1000000)
        Wonder_Set(obj, "upgrade2_upgrade_cost_Concrete", 2000000)
        Wonder_Set(obj, "upgrade2_display_name", Untranslated("Expand Mohole II"))
        Wonder_Set(obj, "upgrade2_description", Untranslated("+10 workers per shift. Double Metals and Rares."))

        Wonder_Set(obj, "upgrade3_id", "Mohole_ExpandMohole_3")
        Wonder_Set(obj, "upgrade3_mod_prop_id_1", "production_per_day1")
        Wonder_Set(obj, "upgrade3_mul_value_1", 100)
        Wonder_Set(obj, "upgrade3_add_value_1", 0)
        Wonder_Set(obj, "upgrade3_mod_label_1", "MoholeMine")
        Wonder_Set(obj, "upgrade3_mod_prop_id_2", "production_per_day2")
        Wonder_Set(obj, "upgrade3_mul_value_2", 100)
        Wonder_Set(obj, "upgrade3_add_value_2", 0)
        Wonder_Set(obj, "upgrade3_mod_label_2", "MoholeMine")
        Wonder_Set(obj, "upgrade3_mod_prop_id_3", "electricity_consumption")
        Wonder_Set(obj, "upgrade3_mul_value_3", 200)
        Wonder_Set(obj, "upgrade3_add_value_3", 0)
        Wonder_Set(obj, "upgrade3_mod_label_3", "MoholeMine")
        Wonder_Set(obj, "upgrade3_upgrade_cost_MachineParts", 200000)
        Wonder_Set(obj, "upgrade3_upgrade_cost_Electronics", 100000)
        Wonder_Set(obj, "upgrade3_upgrade_cost_PreciousMinerals", 200000)
        Wonder_Set(obj, "upgrade3_display_name", Untranslated("Fusion Drills"))
        Wonder_Set(obj, "upgrade3_description", Untranslated("Double Metals and Rares. Triple power use."))
    end

    tmpl.description = DupT(MoholeDescOn)
    if cls then
        cls.description = DupT(MoholeDescOn)
    end
    if base then
        base.description = DupT(MoholeDescOn)
    end
end

local function Elevator_Write(obj, key, value)
    if not obj then
        return
    end
    if obj.SetProperty then
        obj:SetProperty(key, value)
    else
        Wonder_Set(obj, key, value)
    end
end

local function Elevator_SetDesc(obj, desc)
    if not obj or not desc then
        return
    end
    Elevator_Write(obj, "description", DupT(desc))
end

local function Elevator_CollectCosts(tmpl)
    local costs = {}
    if tmpl.GetProperties then
        for _, prop in ipairs(tmpl:GetProperties() or empty_table) do
            local id = prop and prop.id
            if type(id) == "string" and string.find(id, "^construction_cost_") then
                local v
                if tmpl.GetProperty then
                    v = tmpl:GetProperty(id)
                else
                    v = tmpl[id]
                end
                if type(v) == "number" then
                    costs[id] = v
                end
            end
        end
    else
        for k, v in pairs(tmpl) do
            if type(k) == "string" and string.find(k, "^construction_cost_") and type(v) == "number" then
                costs[k] = v
            end
        end
    end
    return costs
end

local function Elevator_Snapshot(tmpl)
    if ElevatorVanilla then
        return
    end
    ElevatorVanilla = {
        costs = Elevator_CollectCosts(tmpl),
        desc = tmpl.description,
    }
    local tech = rawget(_G, "Techs") and Techs.OrbitalEngineering
    if not tech then
        tech = rawget(_G, "TechDef") and TechDef.OrbitalEngineering
    end
    if not tech and Presets and Presets.TechPreset then
        for _, field in pairs(Presets.TechPreset) do
            if type(field) == "table" and field.OrbitalEngineering then
                tech = field.OrbitalEngineering
                break
            end
        end
    end
    if tech then
        ElevatorTechVanilla = tech.description
    end
    local n = 0
    for _ in pairs(ElevatorVanilla.costs) do
        n = n + 1
    end
    print("RMR elevator snapshot", n)
end

local function Elevator_SetTech(desc)
    if not desc then
        return
    end
    local function apply(t)
        if t then
            t.description = DupT(desc)
        end
    end
    apply(rawget(_G, "Techs") and Techs.OrbitalEngineering)
    apply(rawget(_G, "TechDef") and TechDef.OrbitalEngineering)
    local fields = Presets and Presets.TechPreset
    if type(fields) == "table" then
        for _, field in pairs(fields) do
            if type(field) == "table" then
                apply(field.OrbitalEngineering)
            end
        end
    end
end

local function Elevator_Latitude()
    local p = g_CurrentMapParams
    if p and type(p.latitude) == "number" then
        return p.latitude
    end
end

local function Elevator_Factor(lat)
    if type(lat) ~= "number" then
        return 1
    end
    local a = math.abs(lat)
    if a >= 78.5 then
        return 5
    end
    local c = math.cos(math.rad(a))
    if c <= 0.2 then
        return 5
    end
    local f = 1 / c
    if f > 5 then
        return 5
    end
    if f < 1 then
        return 1
    end
    return f
end

local function Elevator_Apply()
    local tmpl = BuildingTemplates and BuildingTemplates.SpaceElevator
    local cls = rawget(_G, "SpaceElevator")
    local base = rawget(_G, "SpaceElevatorBase")
    if not tmpl then
        print("RMR elevator skip, no template")
        return
    end
    Elevator_Snapshot(tmpl)
    if not Wonder_Toggle then
        for k, v in pairs(ElevatorVanilla.costs) do
            Elevator_Write(tmpl, k, v)
            Elevator_Write(cls, k, v)
            Elevator_Write(base, k, v)
            print("RMR elevator cost", k, "vanilla", v, "scaled", v)
        end
        Elevator_SetDesc(tmpl, ElevatorVanilla.desc)
        Elevator_SetDesc(cls, ElevatorVanilla.desc)
        Elevator_SetDesc(base, ElevatorVanilla.desc)
        if ElevatorTechVanilla then
            Elevator_SetTech(ElevatorTechVanilla)
        end
        print("RMR elevator off")
        if RefreshXBuildMenu and GetDialog and GetDialog("XBuildMenu") then
            RefreshXBuildMenu()
        end
        return
    end
    local lat = Elevator_Latitude()
    local factor = Elevator_Factor(lat)
    local extra = floatfloor((factor - 1) * 100 + 0.5)
    print("RMR elevator lat", lat, "factor", factor, "extra", extra)
    for k, v in pairs(ElevatorVanilla.costs) do
        local scaled = floatfloor(v * factor + 0.5)
        Elevator_Write(tmpl, k, scaled)
        Elevator_Write(cls, k, scaled)
        Elevator_Write(base, k, scaled)
        print("RMR elevator cost", k, "vanilla", v, "scaled", scaled)
    end
    local desc = ElevatorVanilla.desc
    if extra > 0 then
        desc = T{"<base>\n\n<em>Due to distance to the equator, build cost is increased by <n>%</em>", base = ElevatorVanilla.desc, n = extra}
    end
    Elevator_SetDesc(tmpl, desc)
    Elevator_SetDesc(cls, desc)
    Elevator_SetDesc(base, desc)
    Elevator_SetTech(ElevatorTechOn)
    if RefreshXBuildMenu and GetDialog and GetDialog("XBuildMenu") then
        RefreshXBuildMenu()
    end
end

local function ArtificialSun_Apply()
    local tmpl = BuildingTemplates and BuildingTemplates.ArtificialSun
    local cls = rawget(_G, "ArtificialSun")
    local base = rawget(_G, "ArtificialSunBase")
    if not tmpl then
        return
    end
    if not Wonder_Toggle then
        return
    end
    for _, obj in ipairs({ tmpl, cls, base }) do
        Wonder_Set(obj, "max_workers", 6)
        Wonder_Set(obj, "specialist", "scientist")
        Wonder_Set(obj, "work_type", "Skilled")
    end
    local labels = UIColony and UIColony.labels and UIColony.labels.ArtificialSun
    if labels then
        for _, bld in ipairs(labels) do
            Wonder_Set(bld, "max_workers", 6)
            Wonder_Set(bld, "specialist", "scientist")
            Wonder_Set(bld, "work_type", "Skilled")
        end
    end
end

function OnMsg.ModsReloaded()
    Wonder_ReadToggle()
    Telescope_LockSurface()
    Telescope_Apply()
    Mohole_Apply()
    Elevator_Apply()
    Wonder_HookAsteroids()
    ArtificialSun_Apply()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        Wonder_ReadToggle()
        Telescope_LockSurface()
        Telescope_Apply()
        Mohole_Apply()
        Elevator_Apply()
        Wonder_HookAsteroids()
        ArtificialSun_Apply()
    end
end

function OnMsg.LoadGame()
    Wonder_ReadToggle()
    Telescope_LockSurface()
    Telescope_Apply()
    Mohole_Apply()
    Elevator_Apply()
    Wonder_HookAsteroids()
    ArtificialSun_Apply()
end

function OnMsg.NewMapLoaded()
    Wonder_ReadToggle()
    Telescope_LockSurface()
    Telescope_Apply()
    Mohole_Apply()
    Elevator_Apply()
    Wonder_HookAsteroids()
    ArtificialSun_Apply()
end

function OnMsg.TechResearched()
    Telescope_LockSurface()
    Wonder_HookAsteroids()
end