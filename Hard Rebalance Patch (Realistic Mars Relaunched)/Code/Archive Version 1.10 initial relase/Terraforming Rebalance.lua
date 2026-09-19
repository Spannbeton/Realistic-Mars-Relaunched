local Moxie_PARAM = "Atmosphere"
local Moxie_ATM = -50
local Vap_PARAM = "Water"
local Conc_PARAM = "Vegetation"
local Heat_PARAM = "Temperature"
local Heat_TF = 50
local ToggleTF = true
local Moxie_ProdWrapped
local Vap_ProdWrapped
local Conc_ProdWrapped
local Exc_ProdWrapped
local FP_ProdWrapped
local GHG_ProdWrapped
local Carb_ProdWrapped
local Heat_ProdWrapped
local Heat_ConvWrapped
local Shield_ProdWrapped

local GHG_FUEL = 20000
local GHG_MAINT = 5000
local Carb_WASTE = 100000
local Carb_POWER = 100000
local Carb_AMP_POWER = 150000
local Carb_MAINT = 10000
local Heat_UPG = "RMR_CentralHeating"
local Heat_POWER = 10000
local Heat_WATER = 2000
local Heat_MAINT = 20000
local Shield_POWER = 150000
local Shield_EXOTIC = 2000
local Shield_MAINT = 5000

function FormatTerraformingValue(value)
    local sign = ""
    if type(value) ~= "number" then
        value = 0
    end
    if value < 0 then
        sign = "-"
        value = -value
    end
    local mul = MaxTerraformingValue
    local v = value * 100
    local n = v / mul
    local d1 = MulDivTrunc(v, 10, mul) % 10
    local d2 = MulDivTrunc(v, 100, mul) % 10
    local d3 = MulDivTrunc(v, 1000, mul) % 10
    return Untranslated(string.format("%s%d.%d%d%d%%", sign, n, d1, d2, d3))
end

local OldTFRes = TFormat.terraform_resource
function TFormat.terraform_resource(context_obj, value, resource, space)
    if type(resource) ~= "string" or resource == "" then
        resource = "Atmosphere"
    end
    if context_obj then
        if context_obj.class == "MagneticFieldGenerator" and context_obj.GetAtmosphereLossReductionSum then
            value = context_obj:GetAtmosphereLossReductionSum()
        elseif context_obj.GetTerraformingBoostSol and value == context_obj.terraforming_boost_sol then
            value = context_obj:GetTerraformingBoostSol()
        end
    end
    return OldTFRes(context_obj, value, resource, space)
end

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Terraforming_Rebalance")
        if v ~= nil then
            ToggleTF = v
        end
    end
end

local function AddParent(cls, parent)
    if not cls or not cls.__parents then
        return
    end
    if not table.find(cls.__parents, parent) then
        cls.__parents[#cls.__parents + 1] = parent
    end
end

local function SetTechText(id, name, desc)
    local function apply(t)
        if not t then
            return
        end
        if name then
            t.display_name = name
        end
        if desc then
            t.description = desc
        end
    end
    apply(rawget(_G, "TechDef") and TechDef[id])
    local fields = Presets and Presets.TechPreset
    if type(fields) == "table" then
        for _, field in pairs(fields) do
            if type(field) == "table" then
                apply(field[id])
            end
        end
    end
end

local function SetBldText(bt, cls, desc, name, name_pl, name_two)
    if bt then
        if name then
            bt.display_name = name
        end
        if name_pl then
            bt.display_name_pl = name_pl
        end
        if name_two then
            bt.display_name_twolines = name_two
        end
        if desc then
            bt.description = desc
        end
    end
    if cls then
        if name then
            cls.display_name = name
        end
        if name_pl then
            cls.display_name_pl = name_pl
        end
        if desc then
            cls.description = desc
        end
    end
end

local function ApplyTFTexts(cls_name)
    local bt = BuildingTemplates and BuildingTemplates[cls_name]
    local cls = rawget(_G, cls_name)
    if cls_name == "MOXIE" then
        SetBldText(bt, cls, T{"Produces Oxygen. No production during Dust Storms. While operating, slowly reduces global Atmosphere <icon_AtmosphereTP_alt> in proportion to Oxygen output."})
    elseif cls_name == "MoistureVaporator" then
        SetBldText(bt, cls, T{"Produces Water from the atmosphere. Production lowered when placed near other Vaporators. No production during Dust Storms. While operating, slowly reduces global Water <icon_WaterTP_alt> in proportion to Water output."})
        SetTechText("MoistureFarming", nil,
            T{"New Building: <em>Moisture Vaporator</em> (<buildinginfo('MoistureVaporator')>) - Produces Water from the atmosphere. Doesn't produce during Dust Storms. While operating, slowly reduces global Water <icon_WaterTP_alt> in proportion to Water output.\n\n<grey>\"What I really need is a drone that understands the binary language of moisture vaporators.\"\n<right>Unknown Martian Colonist</grey><left>"})
    elseif cls_name == "RegolithExtractor" then
        SetBldText(bt, cls, T{"Extracts sulfurous rich regolith from Concrete deposits and produces Concrete.<newline><newline>All extractors raise dust resulting in more frequent maintenance for buildings in the grey area.<newline><newline>While operating, slowly reduces global Vegetation <icon_VegetationTP_alt> in proportion to Concrete output."})
    elseif cls_name == "TheExcavator" then
        SetBldText(bt, cls, T{"Using advanced extraction technology, allows for production of Concrete directly from the Martian soil without the requirement for a deposit. While operating, slowly reduces global Vegetation <icon_VegetationTP_alt> in proportion to Concrete output."})
        SetTechText("LargeScaleExcavation", nil,
            T{"Wonder: <em>The Excavator</em> (<buildinginfo('TheExcavator')>) - Produces Concrete directly from the Martian soil without requiring a deposit. While operating, slowly reduces global Vegetation <icon_VegetationTP_alt> in proportion to Concrete output.\n\n<grey>Martian concrete, made from equal parts regolith and sulfur, has some vast improvements over its Earth counterpart. Red concrete is stronger, more durable and can be recycled and reused simply by reheating it.</grey>"})
    elseif cls_name == "ForestationPlant" then
        SetBldText(bt, cls, T{"Consumes Seeds to plant wild vegetation, increasing local Soil Quality. Requires a Botanist per shift. Output and planting rate scale with performance. Plants will wither or grow according to local Soil Quality and global Temperature <icon_TemperatureTP_alt> and Water <icon_WaterTP_alt>. Improves global Vegetation <icon_VegetationTP_alt> if it's less than <terraform_resource(vegetation_terraforming_threshold,'Vegetation')>. Doesn't work during Dust Storms and Toxic Rains."})
        SetTechText("MartianVegetation", nil,
            T{"New Resource: <em>Seeds</em> - used to plant vegetation on Mars. Can be brought from Earth or grown in Farms and Hydroponic Farms.\n\nNew Building: <em>Forestation Plant</em> (<buildinginfo('ForestationPlant')>) - plants vegetation around itself at the cost of Seeds. Requires a Botanist per shift. Increases local Soil Quality and improves global Vegetation <icon_VegetationTP_alt>.\n\n<grey>\"Vegetation is the basic instrument the creator uses to set all of nature in motion.\" \n<right>Antoine Lavoisier</grey><left>"})
    elseif cls_name == "GHGFactory" then
        SetBldText(bt, cls, T{"Burns huge amounts of Fuel and locally extracted carbon to release greenhouse gases, raising global Temperature <icon_TemperatureTP_alt>. Requires Engineers; output scales with performance. Has significantly boosted terraforming effect at low Temperature <icon_TemperatureTP_alt>."})
        SetTechText("GreenhouseMars", nil,
            T{"New Building: <em>GHG Factory</em> (<buildinginfo('GHGFactory')>) - burns huge amounts of Fuel to increase the Temperature<icon_TemperatureTP_alt> of Mars, using greenhouse gases. Requires Engineers.\n\n<grey>\"You could warm Mars up, over time, with greenhouse gases.\" \n<right>Elon Musk</grey><left>"})
    elseif cls_name == "CarbonateProcessor" then
        SetBldText(bt, cls, T{"Improves Atmosphere <icon_AtmosphereTP_alt> by processing vast quantities of Waste Rock. Requires Geologists; output scales with performance. High Power demand. Plan hauling and storage — a single plant will empty Waste Rock stockpiles."})
        SetTechText("CarbonateProcessor", nil,
            T{"New Building: <em>Carbonate Processor</em> (<buildinginfo('CarbonateProcessor')>) - improves the Atmosphere <icon_AtmosphereTP_alt> of Mars by consuming vast quantities of Waste Rock. Requires Geologists. Needs a dedicated Waste Rock logistics chain.\n\n<grey>\"When fire is applied to a stone it cracks.\"</grey>"})
    elseif cls_name == "CoreHeatConvector" then
        local heat_name = Untranslated("Central Heating System")
        SetBldText(bt, cls,
            T{"Unique heating hub. When staffed by Engineers, reduces Power and Water use of Subsurface Heaters and Power use of Domes with workplace performance. Slightly raises Temperature <icon_TemperatureTP_alt>."},
            heat_name,
            Untranslated("Central Heating Systems"),
            Untranslated("Central Heating System"))
        SetTechText("CoreHeatConvertor", heat_name,
            T{"New Building: <em>Central Heating System</em> (<buildinginfo('CoreHeatConvector')>) - unique heating hub for Heaters and Domes. Requires Engineers. Slightly improves Temperature <icon_TemperatureTP_alt>.\n\n<grey>\"If the world seems cold to you, kindle fires to warm it.\" \n<right>Lucy Larcom</grey><left>"})
        SetTechText("TerraformingAmplification", nil,
            T{"GHG Factory, Magnetic Field Generator and Carbonate Processor gain <em>Amplify</em> upgrade, which improves their performance at the cost of increased Power consumption.\n\n<grey>\"It takes as much energy to wish as it does to plan.\" \n<right>Eleanor Roosevelt</grey><left>"})
    elseif cls_name == "MagneticFieldGenerator" then
        SetBldText(bt, cls, T{"Decreases Atmosphere <icon_AtmosphereTP_alt> loss from the weak Martian magnetic field. Requires Scientists; reduction scales with performance. Consumes Precious Minerals."})
        SetTechText("MagneticFieldGenerator", nil,
            T{"New Building: <em>Magnetic Field Generator</em> (<buildinginfo('MagneticFieldGenerator')>) - decreases the loss of Atmosphere <icon_AtmosphereTP_alt> due to lack of magnetic field. Requires Scientists and Precious Minerals.\n\n<grey>\"Magnetism, as you recall from physics class, is a powerful force that causes certain items to be attracted to refrigerators.\" \n<right>Dave Barry</grey><left>"})
    end
end

local function AirAmount(self)
    if type(self.air) == "table" and self.GetAirProduction then
        return self:GetAirProduction() or 0
    end
    return tonumber(self.air_production) or tonumber(self.base_air_production) or 0
end

local function WaterAmount(self)
    if type(self.water) == "table" and self.GetWaterProduction then
        return self:GetWaterProduction() or 0
    end
    return tonumber(self.water_production) or tonumber(self.base_water_production) or 0
end

local function ConcreteAmount(self)
    local n = 0
    if self.PredictedDailyProduction then
        n = self:PredictedDailyProduction() or 0
    elseif self.GetClassValue and self.HasMember and self:HasMember("production_per_day1") then
        n = self:GetClassValue("production_per_day1") or 0
    else
        n = tonumber(self.production_per_day1) or 0
    end
    return n
end

local function CountShiftWorkers(list)
    local n = 0
    if type(list) ~= "table" then
        return 0
    end
    for _, w in ipairs(list) do
        if w then
            n = n + 1
        end
    end
    return n
end

local function ActiveWorkers(self)
    if type(self.workers) ~= "table" then
        return 0
    end
    local shift = self.current_shift
    if type(shift) == "number" and self.workers[shift] then
        return CountShiftWorkers(self.workers[shift])
    end
    local n = 0
    for i = 1, (tonumber(self.max_shifts) or 3) do
        n = n + CountShiftWorkers(self.workers[i])
    end
    return n
end

local function IsPlaced(self)
    return self and self.handle
end

local function WorkScale(self)
    if not IsPlaced(self) then
        return 100
    end
    if not self.working then
        return 0
    end
    local perf = 0
    if self.GetPerformance then
        perf = self:GetPerformance() or 0
    elseif type(self.performance) == "number" then
        perf = self.performance
    end
    local maxw = tonumber(self.max_workers) or 0
    if maxw <= 0 then
        return 0
    end
    local active = ActiveWorkers(self)
    if active <= 0 then
        return 0
    end
    return floatfloor(MulDivRound(perf, active, maxw))
end

local function MoxieBoost(self)
    if not ToggleTF then
        return 0
    end
    return floatfloor(-2 * AirAmount(self) / 100)
end

local function VapBoost(self)
    if not ToggleTF then
        return 0
    end
    return floatfloor(-5 * WaterAmount(self) / 100)
end

local function ConcBoost(self)
    if not ToggleTF then
        return 0
    end
    local conc = ConcreteAmount(self)
    if type(conc) == "number" and conc > 100 then
        conc = conc / 1000.0
    end
    return floatfloor(-10 * conc / 100)
end

local function MapLabel(name)
    return (MainCity and MainCity.labels and MainCity.labels[name])
        or (UIColony and UIColony.labels and UIColony.labels[name])
        or empty_table
end

local function EnsureTFLabel(bld)
    if not bld then
        return
    end
    local city = bld.city or MainCity or UICity
    if city and city.AddToLabel then
        city:AddToLabel("TerraformingBuilding", bld)
    elseif bld.AddToLabel then
        bld:AddToLabel("TerraformingBuilding")
    end
end

local function ApplyTFFields(obj, param, boost)
    if not obj then
        return
    end
    obj.terraforming_param = param
    obj.terraforming_boost_sol = boost
    obj.base_terraforming_boost_sol = boost
    if param == "Vegetation" and obj.class ~= "ForestationPlant" and obj.handle then
        obj.vegetation_terraforming_threshold = 0
    end
    if obj.SetBase and obj.HasMember and obj:HasMember("terraforming_boost_sol") then
        obj:SetBase("terraforming_boost_sol", boost)
    end
end

local function ApplyConsumption(obj, amount, res, storage)
    if not obj then
        return
    end
    if res then
        obj.consumption_resource_type = res
    end
    if storage then
        obj.consumption_max_storage = storage
    end
    obj.consumption_amount = amount
    if obj.SetBase and obj.HasMember and obj:HasMember("consumption_amount") then
        obj:SetBase("consumption_amount", amount)
    end
end

local function ApplyPower(obj, amount)
    if not obj then
        return
    end
    obj.electricity_consumption = amount
    if obj.SetBase and obj.HasMember and obj:HasMember("electricity_consumption") then
        obj:SetBase("electricity_consumption", amount)
    end
end

local function ApplyWater(obj, amount)
    if not obj then
        return
    end
    obj.water_consumption = amount
    if obj.SetBase and obj.HasMember and obj:HasMember("water_consumption") then
        obj:SetBase("water_consumption", amount)
    end
end

local function ApplyMaint(obj, res, amount)
    if not obj then
        return
    end
    if res then
        obj.maintenance_resource_type = res
    end
    obj.maintenance_resource_amount = amount
    if obj.SetBase and obj.HasMember and obj:HasMember("maintenance_resource_amount") then
        obj:SetBase("maintenance_resource_amount", amount)
    end
end

local function PatchLabelAndDefs(name, fn)
    local bt = BuildingTemplates and BuildingTemplates[name]
    local cls = rawget(_G, name)
    if bt then
        fn(bt)
    end
    if cls then
        fn(cls)
    end
    for _, bld in ipairs(MapLabel(name)) do
        fn(bld)
    end
end

local function PatchConsumption(cls_name, amount, res, storage)
    PatchLabelAndDefs(cls_name, function(obj)
        ApplyConsumption(obj, amount, res, storage)
    end)
end

local function PatchCarbPower()
    PatchLabelAndDefs("CarbonateProcessor", function(obj)
        ApplyPower(obj, Carb_POWER)
        obj.upgrade1_add_value_2 = Carb_AMP_POWER
    end)
end

local function PatchWorkplaceObj(obj, workers, spec)
    if not obj then
        return
    end
    if not obj.handle and not (obj.HasMember and obj:HasMember("max_workers")) then
        return
    end
    obj.max_workers = workers
    obj.specialist = spec
    if type(obj.overtime) ~= "table" then
        obj.overtime = {}
    end
    if type(obj.closed_shifts) ~= "table" then
        obj.closed_shifts = {}
    end
    if obj.SetBase and obj.HasMember and obj:HasMember("max_workers") then
        obj:SetBase("max_workers", workers)
    end
    if IsValid(obj) then
        local wp = rawget(_G, "Workplace")
        if wp and wp.Init and not obj.workplace_init_done then
            if type(obj.max_shifts) ~= "number" then
                obj.max_shifts = 3
            end
            wp.Init(obj)
            obj.workplace_init_done = true
        end
        if obj.SetBase and obj.HasMember and obj:HasMember("max_workers") then
            obj:SetBase("max_workers", workers)
        end
    end
end

local function MakeTFWorkplace(cls_name, template_id, workers, spec, work_type)
    local cls = rawget(_G, cls_name)
    local base = rawget(_G, cls_name .. "Base")
    local wp = rawget(_G, "Workplace")
    AddParent(cls, "Workplace")
    AddParent(base, "Workplace")
    if cls and wp and wp.building_update_time ~= nil then
        cls.building_update_time = wp.building_update_time
    end
    if base and wp and wp.building_update_time ~= nil then
        base.building_update_time = wp.building_update_time
    end
    local bt = BuildingTemplates and BuildingTemplates[template_id]
    if not bt or not cls then
        print(cls_name, "skip", not not bt, not not cls)
        return
    end
    bt.max_workers = workers
    bt.specialist = spec
    if work_type then
        bt.work_type = work_type
    end
    if type(bt.overtime) ~= "table" then
        bt.overtime = {}
    end
    if type(bt.closed_shifts) ~= "table" then
        bt.closed_shifts = {}
    end
    cls.max_workers = workers
    cls.specialist = spec
    if work_type then
        cls.work_type = work_type
    end
    if type(cls.overtime) ~= "table" then
        cls.overtime = {}
    end
    if type(cls.closed_shifts) ~= "table" then
        cls.closed_shifts = {}
    end
    if cls.SetBase and cls.HasMember and cls:HasMember("max_workers") then
        cls:SetBase("max_workers", workers)
    end
       if base then
        if not base.HasMember or base:HasMember("max_workers") then
            base.max_workers = workers
        end
        if not base.HasMember or base:HasMember("specialist") then
            base.specialist = spec
        end
        if work_type and (not base.HasMember or base:HasMember("work_type")) then
            base.work_type = work_type
        end
        if base.SetBase and base.HasMember and base:HasMember("max_workers") then
            base:SetBase("max_workers", workers)
        end
    end
    for _, bld in ipairs(MapLabel(cls_name)) do
        PatchWorkplaceObj(bld, workers, spec)
    end
end

local function ModifyTFProducer(cls_name, base_name, param, static_boost, inst_fn)
    AddParent(rawget(_G, cls_name), "TerraformingBuildingBase")
    if base_name then
        AddParent(rawget(_G, base_name), "TerraformingBuildingBase")
    end
    local bt = BuildingTemplates and BuildingTemplates[cls_name]
    local cls = rawget(_G, cls_name)
    if not bt or not cls then
        print(cls_name, "skip", not not bt, not not cls)
        return
    end
    local static = static_boost
    if type(static_boost) == "function" then
        static = static_boost(bt)
    end
    if not ToggleTF then
        static = 0
    end
    ApplyTFFields(bt, param, static)
    ApplyTFFields(cls, param, static)
    ApplyTFTexts(cls_name)
    for _, bld in ipairs(MapLabel(cls_name)) do
        local boost = inst_fn and inst_fn(bld) or static
        ApplyTFFields(bld, param, boost)
        EnsureTFLabel(bld)
    end
end

local function SetHeatMul(bld, pct, with_water)
    if not bld or (IsValid and not IsValid(bld)) then
        return
    end
    if not bld.SetModifier then
        return
    end
    if pct and pct ~= 0 then
        bld:SetModifier("electricity_consumption", Heat_UPG, 0, -pct)
        if with_water then
            bld:SetModifier("water_consumption", Heat_UPG, 0, -pct)
        end
    else
        bld:SetModifier("electricity_consumption", Heat_UPG, 0, 0)
        if with_water then
            bld:SetModifier("water_consumption", Heat_UPG, 0, 0)
        end
    end
end

local function SavedVsOurMod(bld, prop)
    if not bld or not bld.FindModifier then
        return 0
    end
    local ours = bld:FindModifier(Heat_UPG, prop)
    if not ours then
        return 0
    end
    local mods = bld:GetPropertyModifiers(prop)
    if not mods then
        return 0
    end
    local base = bld["base_" .. prop] or 0
    local without = MulDivRound(base, (mods.percent or 100) - (ours.percent or 0), 100)
        + ((mods.amount or 0) - (ours.amount or 0))
    return Max(0, without - (bld[prop] or 0))
end

local function HeatPowerSavedTotal()
    local n = 0
    for _, bld in ipairs(MapLabel("SubsurfaceHeater")) do
        n = n + SavedVsOurMod(bld, "electricity_consumption")
    end
    for _, bld in ipairs(MapLabel("Dome")) do
        n = n + SavedVsOurMod(bld, "electricity_consumption")
    end
    return n
end

local function HeatWaterSavedTotal()
    local n = 0
    for _, bld in ipairs(MapLabel("SubsurfaceHeater")) do
        n = n + SavedVsOurMod(bld, "water_consumption")
    end
    return n
end

local function ApplyHeatToMap(pct)
    for _, bld in ipairs(MapLabel("SubsurfaceHeater")) do
        if not IsValid or IsValid(bld) then
            SetHeatMul(bld, pct, true)
        end
    end
    for _, bld in ipairs(MapLabel("Dome")) do
        if not IsValid or IsValid(bld) then
            SetHeatMul(bld, pct, false)
        end
    end
end

local function UpdateHeatFromConvector(self)
    local pct = 0
    if ToggleTF and self.working then
        pct = floatfloor(WorkScale(self) / 3)
    end
    ApplyHeatToMap(pct)
end

local function ModifyHeatConvector()
    local cls = rawget(_G, "CoreHeatConvector")
    AddParent(cls, "Workplace")
    local wp = rawget(_G, "Workplace")
    if cls and wp and wp.building_update_time ~= nil then
        cls.building_update_time = wp.building_update_time
    end
    local bt = BuildingTemplates and BuildingTemplates.CoreHeatConvector
    if not bt or not cls then
        print("CoreHeatConvector skip", not not bt, not not cls)
        return
    end
    ApplyTFTexts("CoreHeatConvector")
    bt.build_once = true
    cls.build_once = true
    bt.upgrade1_id = ""
    cls.upgrade1_id = ""
    ApplyPower(bt, Heat_POWER)
    ApplyPower(cls, Heat_POWER)
    ApplyWater(bt, Heat_WATER)
    ApplyWater(cls, Heat_WATER)
    ApplyMaint(bt, "Metals", Heat_MAINT)
    ApplyMaint(cls, "Metals", Heat_MAINT)
    local boost = ToggleTF and Heat_TF or 0
    ApplyTFFields(bt, Heat_PARAM, boost)
    ApplyTFFields(cls, Heat_PARAM, boost)
    MakeTFWorkplace("CoreHeatConvector", "CoreHeatConvector", 8, "engineer", "Skilled")
    for _, bld in ipairs(MapLabel("CoreHeatConvector")) do
        PatchWorkplaceObj(bld, 8, "engineer")
        ApplyTFFields(bld, Heat_PARAM, boost)
        ApplyPower(bld, Heat_POWER)
        ApplyWater(bld, Heat_WATER)
        ApplyMaint(bld, "Metals", Heat_MAINT)
        EnsureTFLabel(bld)
    end
end

local function ModifyMagneticShield()
    local name = "MagneticFieldGenerator"
    AddParent(rawget(_G, "MagneticFieldGeneratorBase"), "Workplace")
    local bt = BuildingTemplates and BuildingTemplates[name]
    local cls = rawget(_G, name)
    if not bt or not cls then
        print("MagneticFieldGenerator skip", not not bt, not not cls)
        return
    end
    ApplyTFTexts(name)
    if ToggleTF then
        ApplyPower(bt, Shield_POWER)
        ApplyPower(cls, Shield_POWER)
        ApplyConsumption(bt, Shield_EXOTIC, "PreciousMinerals", 10000)
        ApplyConsumption(cls, Shield_EXOTIC, "PreciousMinerals", 10000)
        ApplyMaint(bt, "Electronics", Shield_MAINT)
        ApplyMaint(cls, "Electronics", Shield_MAINT)
    end
    MakeTFWorkplace(name, name, 4, "scientist", "Mental")
    for _, bld in ipairs(MapLabel(name)) do
        PatchWorkplaceObj(bld, 4, "scientist")
        if ToggleTF then
            ApplyPower(bld, Shield_POWER)
            ApplyConsumption(bld, Shield_EXOTIC, "PreciousMinerals", 10000)
            ApplyMaint(bld, "Electronics", Shield_MAINT)
        end
    end
end

local function ModifyForestation()
    MakeTFWorkplace("ForestationPlant", "ForestationPlant", 1, "botanist", "Skilled")
    ApplyTFTexts("ForestationPlant")
end

local function ModifyGHGFactory()
    MakeTFWorkplace("GHGFactory", "GHGFactory", 2, "engineer", "Physical")
    ApplyTFTexts("GHGFactory")
end

local function ModifyCarbonateProcessor()
    MakeTFWorkplace("CarbonateProcessor", "CarbonateProcessor", 6, "geologist", "Physical")
    ApplyTFTexts("CarbonateProcessor")
end

local function WrapHeatConvector(cls)
    if not cls then
        return false
    end

    if cls.BuildingUpdate then
        local old = cls.BuildingUpdate
        function cls:BuildingUpdate(...)
            local r = old(self, ...)
            if IsValid and not IsValid(self) then
                return r
            end
            UpdateHeatFromConvector(self)
            return r
        end
    else
        function cls:BuildingUpdate(...)
            if IsValid and not IsValid(self) then
                return
            end
            UpdateHeatFromConvector(self)
        end
    end
    if cls.SetWorking then
        local old_sw = cls.SetWorking
        function cls:SetWorking(...)
            local r = old_sw(self, ...)
            if IsValid and IsValid(self) then
                UpdateHeatFromConvector(self)
            end
            return r
        end
    end
    if cls.Done then
        local old_done = cls.Done
        function cls:Done(...)
            local r = old_done(self, ...)
            CreateRealTimeThread(function()
                ApplyHeatToMap(0)
            end)
            return r
        end
    end
    return true
end

local function ShieldDecayValue(self)
    local base = 200
    if self and self.GetClassValue then
        local v = self:GetClassValue("decay_atmosphere_reduct")
        if type(v) == "number" and v > 0 then
            base = v
        end
    end
    if not ToggleTF then
        return base
    end
    return floatfloor(MulDivRound(base, WorkScale(self), 100))
end

local function ApplyShieldDecay(self)
    if not self or not self.handle then
        return
    end
    if IsValid and not IsValid(self) then
        return
    end
    if not (self.SetBase and self.HasMember and self:HasMember("decay_atmosphere_reduct")) then
        return
    end
    self:SetBase("decay_atmosphere_reduct", ShieldDecayValue(self))
end

local function WrapShieldDecay(cls)
    if not cls then
        return false
    end
    if cls.GetAtmosphereLossReductionSum then
        function cls:GetAtmosphereLossReductionSum(...)
            return ShieldDecayValue(self)
        end
    end
    if cls.BuildingUpdate then
        local old = cls.BuildingUpdate
        function cls:BuildingUpdate(...)
            local r = old(self, ...)
            ApplyShieldDecay(self)
            return r
        end
    end
    if cls.SetWorking then
        local old_sw = cls.SetWorking
        function cls:SetWorking(...)
            local r = old_sw(self, ...)
            ApplyShieldDecay(self)
            return r
        end
    end
    return cls.GetAtmosphereLossReductionSum and true or false
end

local function WrapSolByScale(cls)
    if not cls or not cls.GetTerraformingBoostSol then
        return false
    end
    local old_sol = cls.GetTerraformingBoostSol
    function cls:GetTerraformingBoostSol(...)
        local base = old_sol(self, ...) or 0
        return floatfloor(MulDivRound(base, WorkScale(self), 100))
    end
    return true
end

local function WrapWorkplaceReason(cls)
    if not cls or not cls.GetWorkNotPossibleReason then
        return
    end
    local old_reason = cls.GetWorkNotPossibleReason
    function cls:GetWorkNotPossibleReason(...)
        local r = old_reason(self, ...)
        if r then
            return r
        end
        local wp = rawget(_G, "Workplace")
        if wp and wp.GetWorkNotPossibleReason then
            return wp.GetWorkNotPossibleReason(self, ...)
        end
    end
end

local function ModifyConsumption()
    if not ToggleTF then
        return
    end
    PatchConsumption("GHGFactory", GHG_FUEL)
    PatchLabelAndDefs("GHGFactory", function(obj)
        ApplyMaint(obj, "MachineParts", GHG_MAINT)
    end)
    PatchConsumption("CarbonateProcessor", Carb_WASTE)
    PatchCarbPower()
    PatchLabelAndDefs("CarbonateProcessor", function(obj)
        ApplyMaint(obj, "MachineParts", Carb_MAINT)
    end)
end

local OldGetConstructionDescription
local function WrapConstructionDesc()
    if OldGetConstructionDescription or not GetConstructionDescription then
        return
    end
    OldGetConstructionDescription = GetConstructionDescription
    function GetConstructionDescription(template_class, cost1, dont_modify)
        local oldFR = FormatResource
        if ToggleTF and template_class and oldFR then
            function FormatResource(ctx, amount, res, ...)
                if amount == 1000 and template_class.DoesHaveConsumption and template_class:DoesHaveConsumption()
                    and res == template_class.consumption_resource_type
                    and type(template_class.consumption_amount) == "number" then
                    amount = template_class.consumption_amount
                end
                return oldFR(ctx, amount, res, ...)
            end
        end
        local ok, result = pcall(OldGetConstructionDescription, template_class, cost1, dont_modify)
        FormatResource = oldFR
        if not ok then
            return OldGetConstructionDescription(template_class, cost1, dont_modify)
        end
        if not ToggleTF or not template_class or not IsKindOf(template_class, "TerraformingBuildingBase") then
            return result
        end
        if not template_class.GetTerraformingBoostSol then
            return result
        end
        local n = template_class:GetTerraformingBoostSol()
        if type(n) ~= "number" or n >= 0 then
            return result
        end
        if not _InternalTranslate then
            return result
        end
        local s = _InternalTranslate(result)
        if type(s) ~= "string" then
            return result
        end
        s = s:gsub("%+%-", "-")
        return Untranslated(s)
    end
end

local function WrapTFGetters(cls, boost_fn)
    if not cls or not cls.GetTerraformingBoostSol then
        return false
    end
    function cls:GetTerraformingBoostSol(...)
        if self.handle and not self.working then
            return 0
        end
        return boost_fn(self)
    end
    if cls.GetTerraformingBoost then
        function cls:GetTerraformingBoost(...)
            if self.handle and not self.working then
                return 0
            end
            return boost_fn(self)
        end
    end
    return true
end

local function WrapForestationPerf(cls)
    if not WrapSolByScale(cls) then
        return false
    end
    if cls.GetTerraformingBoost then
        local old_boost = cls.GetTerraformingBoost
        function cls:GetTerraformingBoost(...)
            local base = old_boost(self, ...) or 0
            return floatfloor(MulDivRound(base, WorkScale(self), 100))
        end
    end
    if cls.TryPlantVegetation then
        local old_plant = cls.TryPlantVegetation
        function cls:TryPlantVegetation(...)
            local scale = WorkScale(self)
            if scale <= 0 then
                return
            end
            old_plant(self, ...)
            local extra = scale - 100
            while extra >= 100 do
                old_plant(self, ...)
                extra = extra - 100
            end
            if extra > 0 then
                local roll = 100
                if self.Random then
                    roll = self:Random(100)
                end
                if roll < extra then
                    old_plant(self, ...)
                end
            end
        end
    end
    WrapWorkplaceReason(cls)
    return true
end

local function PatchTFWorld()
    ModifyTFProducer("MOXIE", "MOXIEBase", Moxie_PARAM, Moxie_ATM, MoxieBoost)
    ModifyTFProducer("MoistureVaporator", "MoistureVaporatorBase", Vap_PARAM, -50, VapBoost)
    ModifyTFProducer("RegolithExtractor", "RegolithExtractorBase", Conc_PARAM, -2, ConcBoost)
    ModifyTFProducer("TheExcavator", "TheExcavatorBase", Conc_PARAM, ConcBoost, ConcBoost)
    ModifyForestation()
    ModifyGHGFactory()
    ModifyCarbonateProcessor()
    ModifyHeatConvector()
    ModifyMagneticShield()
    ModifyConsumption()
end

local function OnBuildingReady(bld)
    if not bld then
        return
    end
    if bld.class == "MOXIE" then
        ApplyTFFields(bld, Moxie_PARAM, MoxieBoost(bld))
        EnsureTFLabel(bld)
    elseif bld.class == "MoistureVaporator" then
        ApplyTFFields(bld, Vap_PARAM, VapBoost(bld))
        EnsureTFLabel(bld)
    elseif bld.class == "RegolithExtractor" then
        ApplyTFFields(bld, Conc_PARAM, ConcBoost(bld))
        EnsureTFLabel(bld)
    elseif bld.class == "TheExcavator" then
        ApplyTFFields(bld, Conc_PARAM, ConcBoost(bld))
        EnsureTFLabel(bld)
    elseif bld.class == "ForestationPlant" then
        PatchWorkplaceObj(bld, 1, "botanist")
    elseif bld.class == "GHGFactory" then
        PatchWorkplaceObj(bld, 2, "engineer")
        if ToggleTF then
            ApplyConsumption(bld, GHG_FUEL)
            ApplyMaint(bld, "MachineParts", GHG_MAINT)
        end
    elseif bld.class == "CarbonateProcessor" then
        PatchWorkplaceObj(bld, 6, "geologist")
        if ToggleTF then
            ApplyConsumption(bld, Carb_WASTE)
            ApplyPower(bld, Carb_POWER)
            bld.upgrade1_add_value_2 = Carb_AMP_POWER
            ApplyMaint(bld, "MachineParts", Carb_MAINT)
        end
    elseif bld.class == "CoreHeatConvector" then
        PatchWorkplaceObj(bld, 8, "engineer")
        ApplyTFFields(bld, Heat_PARAM, ToggleTF and Heat_TF or 0)
        ApplyPower(bld, Heat_POWER)
        ApplyWater(bld, Heat_WATER)
        ApplyMaint(bld, "Metals", Heat_MAINT)
        EnsureTFLabel(bld)
    elseif bld.class == "MagneticFieldGenerator" then
        PatchWorkplaceObj(bld, 4, "scientist")
        if ToggleTF then
            ApplyPower(bld, Shield_POWER)
            ApplyConsumption(bld, Shield_EXOTIC, "PreciousMinerals", 10000)
            ApplyMaint(bld, "Electronics", Shield_MAINT)
        end
        ApplyShieldDecay(bld)
    end
end

function RMR_DumpTF()
    local function one(name)
        print("====", name)
        local bt = BuildingTemplates and BuildingTemplates[name]
        if bt then
            print(" tmpl consume", bt.consumption_amount, bt.consumption_resource_type, "power", bt.electricity_consumption)
        end
        local list = MapLabel(name)
        print(" count", list and #list)
        for _, bld in ipairs(list) do
            print(" h", bld.handle, "work", bld.working, "GetTFSol", bld.GetTerraformingBoostSol and bld:GetTerraformingBoostSol())
        end
    end
    print("RMR_DumpTF", ToggleTF)
    one("RegolithExtractor")
    one("TheExcavator")
    one("CoreHeatConvector")
    one("MagneticFieldGenerator")
end

UndefineClass("sectionHeatSavings")
DefineClass.sectionHeatSavings = {
    __parents = { "InfopanelSection" },
    Title = Untranslated("Savings"),
    Icon = "UI/IconsRemaster/Sections/grid.png",
}

function sectionHeatSavings:new(args, parent, context)
    if not IsKindOf(context, "CoreHeatConvector") then
        return
    end
    return InfopanelSection.new(self, args, parent, context)
end

function sectionHeatSavings:Init(parent, context)
    local parent = InfopanelSection.__content(self, context)
    InfopanelText:new({
        Id = "idPowerSaved",
        Text = T{"Power<right><green><power(HeatPowerSaved)></green>"},
    }, parent, context)
    InfopanelText:new({
        Id = "idWaterSaved",
        Text = T{"Water<right><green><water(HeatWaterSaved)></green>"},
    }, parent, context)
end

function sectionHeatSavings:OnContextUpdate(context, ...)
    local e = context:GetHeatPowerSaved() or 0
    local w = context:GetHeatWaterSaved() or 0
    self:SetVisible(e > 0 or w > 0)
end

local OldSectionConsumptionNew
local function WrapSectionConsumptionNew()
    if OldSectionConsumptionNew or not sectionConsumption or not sectionConsumption.new then
        return
    end
    OldSectionConsumptionNew = sectionConsumption.new
    function sectionConsumption.new(self, args, parent, context)
        local win = OldSectionConsumptionNew(self, args, parent, context)
        if IsKindOf(context, "CoreHeatConvector") then
            sectionHeatSavings:new(nil, parent, context)
        end
        return win
    end
end
function OnMsg.ClassesGenerate(classdefs)
    local function ParentWorkplace(name)
        local def = classdefs and classdefs[name]
        if def and def.__parents and not table.find(def.__parents, "Workplace") then
            def.__parents[#def.__parents + 1] = "Workplace"
        end
        if def and rawget(_G, "Workplace") and Workplace.building_update_time then
            def.building_update_time = Workplace.building_update_time
        end
    end
	local function HeatGetters(name)
		local def = classdefs and classdefs[name]
		if not def then
			return
		end
		function def:GetHeatPowerSaved()
			return HeatPowerSavedTotal()
		end
		function def:GetHeatWaterSaved()
			return HeatWaterSavedTotal()
		end
	end
	HeatGetters("CoreHeatConvector")
	HeatGetters("CoreHeatConvectorBase")
    ParentWorkplace("CoreHeatConvector")
    ParentWorkplace("CoreHeatConvectorBase")
    ParentWorkplace("ForestationPlant")
    ParentWorkplace("ForestationPlantBase")
    ParentWorkplace("GHGFactory")
    ParentWorkplace("GHGFactoryBase")
    ParentWorkplace("CarbonateProcessor")
    ParentWorkplace("CarbonateProcessorBase")
    ParentWorkplace("MagneticFieldGenerator")
    ParentWorkplace("MagneticFieldGeneratorBase")
    PatchTFWorld()
end

function OnMsg.ClassesBuilt()
    WrapConstructionDesc()
    if not Moxie_ProdWrapped then
        WrapTFGetters(rawget(_G, "MOXIE"), MoxieBoost)
        Moxie_ProdWrapped = true
    end
    if not Vap_ProdWrapped then
        WrapTFGetters(rawget(_G, "MoistureVaporator"), VapBoost)
        Vap_ProdWrapped = true
    end
    if not Conc_ProdWrapped then
        WrapTFGetters(rawget(_G, "RegolithExtractorBase"), ConcBoost)
        WrapTFGetters(rawget(_G, "RegolithExtractor"), ConcBoost)
        Conc_ProdWrapped = true
    end
    if not Exc_ProdWrapped then
        WrapTFGetters(rawget(_G, "TheExcavatorBase"), ConcBoost)
        WrapTFGetters(rawget(_G, "TheExcavator"), ConcBoost)
        Exc_ProdWrapped = true
    end
    if not FP_ProdWrapped then
        WrapForestationPerf(rawget(_G, "ForestationPlantBase"))
        WrapForestationPerf(rawget(_G, "ForestationPlant"))
        FP_ProdWrapped = true
    end
    if not GHG_ProdWrapped then
        WrapSolByScale(rawget(_G, "GHGFactoryBase"))
        WrapSolByScale(rawget(_G, "GHGFactory"))
        WrapWorkplaceReason(rawget(_G, "GHGFactory"))
        GHG_ProdWrapped = true
    end
    if not Carb_ProdWrapped then
        WrapSolByScale(rawget(_G, "CarbonateProcessorBase"))
        WrapSolByScale(rawget(_G, "CarbonateProcessor"))
        WrapWorkplaceReason(rawget(_G, "CarbonateProcessor"))
        Carb_ProdWrapped = true
    end
    if not Heat_ProdWrapped then
        WrapSolByScale(rawget(_G, "CoreHeatConvectorBase"))
        WrapSolByScale(rawget(_G, "CoreHeatConvector"))
        WrapWorkplaceReason(rawget(_G, "CoreHeatConvector"))
        Heat_ProdWrapped = true
    end
    if not Heat_ConvWrapped then
        Heat_ConvWrapped = WrapHeatConvector(rawget(_G, "CoreHeatConvector"))
        WrapHeatConvector(rawget(_G, "CoreHeatConvectorBase"))
    end
    if not Shield_ProdWrapped then
        WrapShieldDecay(rawget(_G, "MagneticFieldGeneratorBase"))
        WrapShieldDecay(rawget(_G, "MagneticFieldGenerator"))
        WrapWorkplaceReason(rawget(_G, "MagneticFieldGenerator"))
        Shield_ProdWrapped = true
    end
    MakeTFWorkplace("ForestationPlant", "ForestationPlant", 1, "botanist", "Skilled")
    MakeTFWorkplace("GHGFactory", "GHGFactory", 2, "engineer", "Physical")
    MakeTFWorkplace("CarbonateProcessor", "CarbonateProcessor", 6, "geologist", "Physical")
    MakeTFWorkplace("CoreHeatConvector", "CoreHeatConvector", 8, "engineer", "Skilled")
    MakeTFWorkplace("MagneticFieldGenerator", "MagneticFieldGenerator", 4, "scientist", "Mental")
	WrapSectionConsumptionNew()
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    PatchTFWorld()
end

function OnMsg.LoadGame()
    ReadToggle()
    PatchTFWorld()
end

function OnMsg.ModsReloaded()
    ReadToggle()
    WrapConstructionDesc()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        PatchTFWorld()
    end
end

function OnMsg.BuildingInit(bld)
    OnBuildingReady(bld)
end

function OnMsg.ConstructionComplete(bld)
    OnBuildingReady(bld)
end