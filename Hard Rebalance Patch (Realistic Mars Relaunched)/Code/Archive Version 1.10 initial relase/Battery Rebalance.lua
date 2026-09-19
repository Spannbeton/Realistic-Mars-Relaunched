local ToggleBattery = true

local BATTERY = {
    AtomicBattery = { eff = 85, base = "Atomic Accumulator" },
    Battery_WaterFuelCell = { eff = 90, base = "Power Accumulator" },
}

local BatteryDescOff = {
    AtomicBattery = T{"Stores Power. High capacity and max output, but charges slowly."},
    Battery_WaterFuelCell = T{"Stores Power. Amount of Power supplied is limited by the battery's max output."},
}

local BatteryDescOn = {
    AtomicBattery = T{"Stores Power. High capacity and max output, but charges slowly. Round-trip efficiency 85%."},
    Battery_WaterFuelCell = T{"Stores Power. Amount of Power supplied is limited by the battery's max output. Round-trip efficiency 90%."},
}

local BatteryNameOff = {
    AtomicBattery = Untranslated("Atomic Accumulator"),
    Battery_WaterFuelCell = Untranslated("Power Accumulator"),
}

local function EffName(base, eff)
    return Untranslated(base)
end

local function ApplyTo(obj, id)
    local cfg = BATTERY[id]
    if not cfg or not obj or not obj.SetProperty then
        return
    end
    local eff = ToggleBattery and cfg.eff or 100
    local name = ToggleBattery and EffName(cfg.base, eff) or BatteryNameOff[id]
    local desc = ToggleBattery and BatteryDescOn[id] or BatteryDescOff[id]
    obj:SetProperty("base_conversion_efficiency", eff)
    obj:SetProperty("display_name", name)
    obj:SetProperty("display_name_pl", name)
    obj:SetProperty("description", desc)
end

local function PatchOne(bld)
    if bld and bld.class and BATTERY[bld.class] then
        ApplyTo(bld, bld.class)
    end
end

local function ApplyTemplates()
    if not BuildingTemplates then
        return
    end
    for id in pairs(BATTERY) do
        if BuildingTemplates[id] then
            ApplyTo(BuildingTemplates[id], id)
        end
    end
end

local function ApplyInstances()
    local seen = {}
    local cities = Cities or (UIColony and UIColony.cities) or (UICity and { UICity })
    if not cities then
        return
    end
    for _, city in pairs(cities) do
        local e = city.electricity
        local grids = e and (e[1] and e or e.grids or { e })
        if grids then
            for _, grid in pairs(grids) do
                if type(grid) == "table" then
                    for _, el in pairs(grid.elements or grid.storages or empty_table) do
                        local obj = (type(el) == "table" and (el.building or el.parent)) or el
                        if type(obj) == "table" and obj.handle and not seen[obj.handle] then
                            seen[obj.handle] = true
                            PatchOne(obj)
                        end
                    end
                end
            end
        end
    end
end

local function ApplyAll()
    ApplyTemplates()
    ApplyInstances()
end

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Battery_Rebalance")
        if v ~= nil then
            ToggleBattery = v
        end
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
    ApplyTemplates()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        ApplyAll()
    end
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    ApplyAll()
end

function OnMsg.LoadGame()
    ReadToggle()
    ApplyAll()
end

function OnMsg.BuildingInit(bld)
    PatchOne(bld)
end

function OnMsg.ConstructionComplete(bld)
    PatchOne(bld)
end