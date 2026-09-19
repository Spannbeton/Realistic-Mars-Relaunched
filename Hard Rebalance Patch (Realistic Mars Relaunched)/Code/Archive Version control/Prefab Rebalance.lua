local ToggleCargo = true
local SavedCargoPrice = false

local BUILD_RES = {
    "Concrete",
    "Metals",
    "Polymers",
    "MachineParts",
    "Electronics",
}

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Prefab_Rebalance")
        if v ~= nil then
            ToggleCargo = v
        end
    end
end

local function UnitPrice(id)
    local p = CargoPreset and CargoPreset[id]
    return p and p.price or 0
end

local function EarthBuildValue(tid)
    local t = BuildingTemplates and BuildingTemplates[tid]
    if not t then
        return 0
    end
    local scale = const.ResourceScale or 1000
    local v = 0
    for _, res in ipairs(BUILD_RES) do
        local amt = t["construction_cost_" .. res]
        if amt and amt > 0 then
            v = v + (amt / scale) * UnitPrice(res)
        end
    end
    local drones = t.starting_drones
    if drones and drones > 0 then
        v = v + drones * UnitPrice("Drone")
    end
    return v
end

local function SaveVanilla()
    if not CargoPreset then
        return
    end
    SavedCargoPrice = SavedCargoPrice or {}
    for id, p in pairs(CargoPreset) do
        if not SavedCargoPrice[id] and GetCargoType(id) == "Prefab" and p.price then
            SavedCargoPrice[id] = p.price
        end
    end
end

local function ApplyCargo()
    if not CargoPreset then
        print("RMR cargo skip, no CargoPreset")
        return
    end
    SaveVanilla()
    for id, p in pairs(CargoPreset) do
        if GetCargoType(id) == "Prefab" and p.price then
            local saved = SavedCargoPrice[id] or p.price
            SavedCargoPrice[id] = saved
            if ToggleCargo and saved < 900000000 then
                local target = MulDivRound(EarthBuildValue(id), 150, 100)
                p.price = target > saved and target or saved
                if p.price ~= saved then
                    print("RMR cargo", id, saved, p.price)
                end
            else
                p.price = saved
            end
            if ObjModified then
                ObjModified(p)
            end
        end
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
    ApplyCargo()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        ApplyCargo()
    end
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    ApplyCargo()
end

function OnMsg.LoadGame()
    ReadToggle()
    ApplyCargo()
end
