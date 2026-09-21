local RMR_EarthUnlocked = {}
local RMR_EarthPriceDone = {}
local ToggleGS = true
local CargoListWrapped
local PrefabListWrapped
local PayloadLockedWrapped
local LockWrapped
local GSTechWrapped
local OldGSResearch
GameVar("RMR_EarthSponsorsDone", {})

local SPONSOR_ROCKET = {
    NASA = "UniversalZeusRocket",
    IMM = "UniversalZeusRocket",
    SpaceY = "UniversalDragonRocket",
    CNSA = "UniversalRocket",
    ESA = "UniversalRocket",
    Roscosmos = "UniversalRocket",
    ISRO = "UniversalRocket",
    BlueSun = "UniversalRocket",
    NewArk = "UniversalRocket",
    Brazil = "UniversalRocket",
    Japan = "UniversalRocket",
    TerraInitiative = "UniversalRocket",
    paradox = "UniversalRocket",
}

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Global_Support_Rebalance")
        if v ~= nil then
            ToggleGS = v
        end
    end
end

local BUILD_RES = {
    "Concrete",
    "Metals",
    "Polymers",
    "MachineParts",
    "Electronics",
}

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

local function PlayerRocketClass()
    if GetRocketClass then
        return GetRocketClass()
    end
    return "UniversalRocket"
end

local function EnsureSponsorRocketCargo(sponsor)
    local class = SPONSOR_ROCKET[sponsor]
    local weight
    if not class then
        return
    end
    local mine = PlayerRocketClass()
    if class == mine then
        return
    end
    if CargoPreset and CargoPreset[class] then
        return class
    end
    if not PlaceObj then
        return
    end
    local price
    if class == "UniversalDragonRocket" then
        price = 2000000000
        weight = 30000
    elseif class == "UniversalZeusRocket" then
        price = 4000000000
        weight = 50000
    elseif class == "UniversalRocket" then
        price = 3000000000
        weight= 40000
    else
        price = UnitPrice(mine)
        if price <= 0 and g_Consts then
            price = g_Consts.RocketPrice
        end
    end
    if price <= 0 and g_Consts then
        price = g_Consts.RocketPrice
    end
    PlaceObj("CargoUnit", {
        id = class,
        unit = class,
        kg = weight,
        price = price,
        locked = true,
        hidden = false,
        verifier = function(self, s)
            return s == sponsor
        end,
    })
    if ResupplyItemsInit then
        ResupplyItemsInit()
    end
    print("RMR earth rocket cargo", sponsor, class, price)
    return class
end

local function RivalDisplayName(sponsor)
    local ai = RivalAIs and RivalAIs[sponsor]
    return ai and ai.display_name or Untranslated(sponsor)
end

local function EarthPopup(kind, sponsor, unlocked)
    unlocked = unlocked or {}
    local names = {}
    for i = 1, #unlocked do
        local def = GetResupplyItem and GetResupplyItem(unlocked[i])
        local cargo = CargoPreset and CargoPreset[unlocked[i]]
        local n = def and def.GetDisplayName and def:GetDisplayName()
            or (cargo and cargo.GetDisplayName and cargo:GetDisplayName())
            or Untranslated(unlocked[i])
        names[#names + 1] = n
    end
    local list = table.concat(names, ", ")
    local title, text, image
    if kind == "standing" then
        title = T{"Grateful Rival"}
        text = T{"After months of careful diplomacy, <name> has opened its Earth catalog. Unique prefabs and hardware can be ordered at a premium. Construction rights on Mars remain theirs.", name = RivalDisplayName(sponsor)}
        image = "UI/Messages/sponsor_" .. sponsor .. ".tga"
    else
        title = T{"Strongarmed Rival"}
        text = T{"Pressure and quiet payments did what goodwill would not. <name> has opened its Earth catalog. The crates will cost more than their own purchases. Due to lack of familiarity with that technology we are not able to reverse engineer and lay the blueprints ourselves.", name = RivalDisplayName(sponsor)}
        image = "UI/Messages/covert_ops_" .. sponsor .. ".tga"
    end
    text = text .. T{"\n\n<effect><list> prefabs unlocked on Earth", list = list}
    CreateRealTimeThread(function()
        WaitPopupNotification(false, {
            title = title,
            text = text,
            image = image,
            choice1 = T{"This is great news"},
        })
    end)
end

local function MarkSponsorDone(sponsor)
    RMR_EarthSponsorsDone = RMR_EarthSponsorsDone or {}
    RMR_EarthSponsorsDone[sponsor] = true
    if UIColony then
        UIColony.RMR_EarthSponsorsDone = UIColony.RMR_EarthSponsorsDone or {}
        UIColony.RMR_EarthSponsorsDone[sponsor] = true
    end
end

local function WrapBuildingLock()
    if LockWrapped or not GetAdditionalBuildingLock then
        return
    end
    local old = GetAdditionalBuildingLock
    function GetAdditionalBuildingLock(template)
        if template and (RMR_EarthUnlocked[template.class] or RMR_EarthUnlocked[template.id]) then
            return false
        end
        return old(template)
    end
    LockWrapped = true
    print("RMR wrap building lock")
end

local function WrapPayloadLocks()
    if PayloadLockedWrapped or not RocketPayloadObject then
        return
    end
    local old_locked = RocketPayloadObject.IsLocked
    function RocketPayloadObject:IsLocked(item_id)
        if RMR_EarthUnlocked[item_id] then
            return false
        end
        return old_locked(self, item_id)
    end
    local old_hidden = RocketPayloadObject.IsHidden
    function RocketPayloadObject:IsHidden(prop_meta)
        if prop_meta and RMR_EarthUnlocked[prop_meta.id] then
            return false
        end
        return old_hidden(self, prop_meta)
    end
    local old_import = RocketPayloadObject.IsImportLocked
    function RocketPayloadObject:IsImportLocked(prop_meta)
        if prop_meta and RMR_EarthUnlocked[prop_meta.id] then
            return false
        end
        return old_import(self, prop_meta)
    end
    local old_black = RocketPayloadObject.IsBlacklisted
    function RocketPayloadObject:IsBlacklisted(prop_meta)
        if prop_meta and RMR_EarthUnlocked[prop_meta.id] then
            return false
        end
        return old_black(self, prop_meta)
    end
    PayloadLockedWrapped = true
    print("RMR wrap payload locks")
end

local function CargoTemplate(cargo, id)
    if not BuildingTemplates then
        return
    end
    local key = cargo.building or cargo.unit or id
    return BuildingTemplates[key] or BuildingTemplates[key .. "Building"]
end

local function IsSponsorUniqueCargo(cargo, id, sponsor)
    if id == "Seeds" or id == "MysteryResource" or id == "RCTerraformer" then
        return
    end
    local tmpl = CargoTemplate(cargo, id)
    if tmpl and tmpl.sponsor_name1 == sponsor and tmpl.sponsor_status1 == "required" then
        return true
    end
    if cargo.locked and cargo.verifier and cargo.unit and cargo.verifier(cargo, sponsor) then
        return true
    end
    if cargo.locked and cargo.verifier and id and string.find(id, "Rocket") and cargo.verifier(cargo, sponsor) then
        return true
    end
    if cargo.locked and cargo.verifier and not cargo.unit and not cargo.building and cargo.verifier(cargo, sponsor) then
        return true
    end
    local fn = cargo.RMR_Verifier or cargo.verifier
    if fn and not cargo.unit and not cargo.building and fn(cargo, sponsor) then
        local others = { "NASA", "IMM", "SpaceY", "CNSA", "ESA", "Roscosmos", "ISRO", "BlueSun", "NewArk", "Brazil", "Japan", "TerraInitiative", "paradox" }
        local shared
        for i = 1, #others do
            if others[i] ~= sponsor and fn(cargo, others[i]) then
                shared = true
                break
            end
        end
        if not shared then
            return true
        end
    end
end

local function WrapPrefabList()
    if PrefabListWrapped or not CargoTransporterNew or not CargoTransporterNew.GetTransportablePrefabs then
        return
    end
    local old_prefab = CargoTransporterNew.GetTransportablePrefabs
    function CargoTransporterNew:GetTransportablePrefabs(...)
        local list = old_prefab(self, ...) or {}
        for id in pairs(RMR_EarthUnlocked) do
            local cargo = CargoPreset and CargoPreset[id]
            local def = GetResupplyItem and GetResupplyItem(id)
            local tmpl = cargo and ((cargo.building and BuildingTemplates and BuildingTemplates[cargo.building]) or CargoTemplate(cargo, id))
            if cargo and def and tmpl then
                local found
                for i = 1, #list do
                    if list[i].id == id then
                        found = true
                        break
                    end
                end
                if not found then
                    list[#list + 1] = def
                    print("RMR prefab add", id)
                end
            end
        end
        return list
    end
    for _, class in pairs(g_Classes) do
        if class.GetTransportablePrefabs == old_prefab then
            class.GetTransportablePrefabs = CargoTransporterNew.GetTransportablePrefabs
        end
    end
    PrefabListWrapped = true
    print("RMR wrap prefab all")
end

local function WrapCargoList()
    if CargoListWrapped or not CargoRequestNew or not CargoRequestNew.GetTransportableCargo then
        return
    end
    local old = CargoRequestNew.GetTransportableCargo
    function CargoRequestNew:GetTransportableCargo(transporter)
        local cargo_items, cargo_type_items = old(self, transporter)
        cargo_items = cargo_items or {}
        cargo_type_items = cargo_type_items or {}
        for id in pairs(RMR_EarthUnlocked) do
            if not cargo_items[id] then
                local def = GetResupplyItem and GetResupplyItem(id)
                local cargo = CargoPreset and CargoPreset[id]
                if def and cargo then
                    local typ
                    if cargo.building then
                        typ = CargoType.Prefab
                    elseif cargo.unit and IsKindOf(g_Classes[cargo.unit], "Drone") then
                        typ = CargoType.Drone
                    elseif cargo.unit then
                        typ = CargoType.Rover
                    end
                    if typ == CargoType.Drone and transporter:CanTransportCargoType(CargoType.Drone) then
                        local item = CargoRequestItemNew:new{
                            type = CargoType.Drone,
                            id = id,
                            name = def.GetDisplayName and def:GetDisplayName() or Untranslated(id),
                        }
                        cargo_items[id] = item
                        cargo_type_items[CargoType.Drone] = cargo_type_items[CargoType.Drone] or {}
                        cargo_type_items[CargoType.Drone][#cargo_type_items[CargoType.Drone] + 1] = item
                    end
                    if cargo.unit and string.find(id, "Rocket") and transporter:CanTransportCargoType(CargoType.Drone) then
                        local item = CargoRequestItemNew:new{
                            type = CargoType.Drone,
                            id = id,
                            name = def.GetDisplayName and def:GetDisplayName() or Untranslated(id),
                        }
                        cargo_items[id] = item
                        cargo_type_items[CargoType.Drone] = cargo_type_items[CargoType.Drone] or {}
                        cargo_type_items[CargoType.Drone][#cargo_type_items[CargoType.Drone] + 1] = item
                    end
                end
            end
        end
        return cargo_items, cargo_type_items
    end
    CargoListWrapped = true
    print("RMR wrap cargo list")
end

local function WrapGlobalSupportTech()
    if GSTechWrapped then
        return
    end
    local def = Techs and Techs.GlobalSupport
    if not def then
        def = TechDef and TechDef.GlobalSupport
    end
    if not def or not def.OnResearched then
        print("RMR gs tech skip")
        return
    end
    OldGSResearch = def.OnResearched
    function def.OnResearched(self, research, first_time)
        if not ToggleGS then
            return OldGSResearch(self, research, first_time)
        end
        local ids = { "NASA", "IMM", "SpaceY", "CNSA", "ESA", "Roscosmos", "ISRO", "BlueSun", "NewArk", "Brazil", "Japan", "TerraInitiative", "paradox" }
        local done = RMR_EarthSponsorsDone or {}
        local self_id = GetMissionSponsor and GetMissionSponsor().id
        local left = {}
        for i = 1, #ids do
            local id = ids[i]
            if not done[id] and id ~= self_id then
                left[#left + 1] = id
            end
        end
        if #left == 0 then
            print("RMR gs none left")
            if UIColony and UIColony.ChangeTechRepeatable then
                UIColony:ChangeTechRepeatable("GlobalSupport", false)
            end
            return
        end
        local pick = left[1 + (AsyncRand and AsyncRand(#left) or (#left - 1))]
        print("RMR gs pick", pick)
        MarkSponsorDone(pick)
        RMR_UnlockSponsorEarthPrefabs(pick, "gs")
        if #left == 1 and UIColony and UIColony.ChangeTechRepeatable then
            UIColony:ChangeTechRepeatable("GlobalSupport", false)
        end
    end
    GSTechWrapped = true
    print("RMR wrap gs tech")
end

function RMR_UnlockSponsorEarthPrefabs(sponsor, reason)
    if not ToggleGS then
        print("RMR earth skip toggle off", sponsor, "\n")
        return
    end
    if not sponsor or not CargoPreset then
        print("RMR earth skip", sponsor, "\n")
        return
    end
    EnsureSponsorRocketCargo(sponsor)
    local unlocked = {}
    local missing = {}
    for id, cargo in pairs(CargoPreset) do
        local fn = cargo.RMR_Verifier or cargo.verifier
        local locked0 = cargo.RMR_Locked
        if locked0 == nil then
            locked0 = cargo.locked
        end
        local probe = { locked = locked0, verifier = fn, unit = cargo.unit, building = cargo.building }
        if IsSponsorUniqueCargo(probe, id, sponsor) then
            if cargo.RMR_PriceBase then
                print("RMR earth already", id, cargo.price)
            else
                cargo.RMR_PriceBase = cargo.price
                cargo.RMR_Locked = cargo.locked
                cargo.RMR_Hidden = cargo.hidden
                cargo.RMR_Verifier = cargo.verifier
                if cargo.price == 999000000 and EarthBuildValue then
                    local val = EarthBuildValue(id)
                    if type(val) == "number" and val > 0 then
                        cargo.price = MulDivRound(val, 125, 100)
                    end
                elseif type(cargo.price) == "number" then
                    cargo.price = MulDivRound(cargo.price, 125, 100)
                end
                if id == "UniversalDragonRocket" then
                    cargo.price = 2000000000
                elseif id == "UniversalZeusRocket" then
                    cargo.price = 4000000000
                end
                cargo.locked = false
                cargo.hidden = false
                cargo.verifier = function()
                    return true
                end
                print("RMR earth cargo", id, cargo.RMR_PriceBase, cargo.price)
            end
            local def = GetResupplyItem and GetResupplyItem(id)
            if cargo.building then
                cargo.PayloadCategory = "prefab"
            end
            if cargo.unit and id and string.find(id, "Rocket") then
                cargo.PayloadCategory = "unit"
            end
            if not def then
                missing[#missing + 1] = id
                print("RMR earth no resupply", sponsor, id)
            else
                if Effect_UnlockResupplyItem and Effect_UnlockResupplyItem.OnApplyEffect then
                    Effect_UnlockResupplyItem:new{ Item = id }:OnApplyEffect(UIColony)
                end
                def.verifier = function()
                    return true
                end
                def.locked = false
                def.hidden = false
                def.filter = nil
                cargo.filter = nil
                if cargo.building then
                    def.PayloadCategory = "prefab"
                end
                if cargo.unit and id and string.find(id, "Rocket") then
                    def.PayloadCategory = "unit"
                end
                if type(def.price) == "number" and cargo.price then
                    def.price = cargo.price
                end
                if UnlockImport then
                    UnlockImport(id)
                end
                print("RMR earth shop", id, def.locked, cargo.locked)
            end
            if not UIColony.RMR_EarthUnlocked then
                UIColony.RMR_EarthUnlocked = {}
            end
            UIColony.RMR_EarthUnlocked[id] = true
            RMR_EarthUnlocked[id] = true
            print("RMR earth flag", id, cargo.building)
            unlocked[#unlocked + 1] = id
        end
    end
    RMR_EarthPriceDone[sponsor] = true
    WrapCargoList()
    WrapPayloadLocks()
    WrapPrefabList()
    print("RMR earth done", sponsor, table.concat(unlocked, " "))
    print("RMR earth missing", sponsor, #missing == 0 and "none" or table.concat(missing, " "), "\n")
    if reason and #unlocked > 0 then
        EarthPopup(reason, sponsor, unlocked)
    end
end

function RMR_LockSponsorEarthPrefabs(sponsor)
    if not sponsor or not CargoPreset then
        print("RMR earth lock skip", sponsor, "\n")
        return
    end
    for id, cargo in pairs(CargoPreset) do
        local fn = cargo.RMR_Verifier or cargo.verifier
        local locked0 = cargo.RMR_Locked
        if locked0 == nil then
            locked0 = cargo.locked
        end
        local probe = { locked = locked0, verifier = fn, unit = cargo.unit, building = cargo.building }
        if IsSponsorUniqueCargo(probe, id, sponsor) then
            cargo.verifier = cargo.RMR_Verifier
            cargo.locked = cargo.RMR_Locked
            cargo.hidden = cargo.RMR_Hidden
            if cargo.RMR_PriceBase then
                cargo.price = cargo.RMR_PriceBase
            end
            cargo.RMR_Verifier = nil
            cargo.RMR_Locked = nil
            cargo.RMR_Hidden = nil
            cargo.RMR_PriceBase = nil
            local def = GetResupplyItem and GetResupplyItem(id)
            if def then
                def.verifier = cargo.verifier
                def.locked = cargo.locked
                def.hidden = cargo.hidden
                if cargo.price then
                    def.price = cargo.price
                end
            end
            RMR_EarthUnlocked[id] = nil
            print("RMR earth relock", sponsor, id)
        end
    end
    RMR_EarthPriceDone[sponsor] = nil
    print("RMR earth lock done", sponsor, "\n")
end

function RMR_UnlockAllSponsorEarthPrefabs()
    local ids = { "NASA", "IMM", "SpaceY", "CNSA", "ESA", "Roscosmos", "ISRO", "BlueSun", "NewArk", "Brazil", "Japan", "TerraInitiative", "paradox" }
    for i = 1, #ids do
        RMR_UnlockSponsorEarthPrefabs(ids[i])
    end
end

function OnMsg.ModsReloaded()
    ReadToggle()
    WrapCargoList()
    WrapPrefabList()
    WrapPayloadLocks()
    WrapBuildingLock()
    WrapGlobalSupportTech()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
    end
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    WrapCargoList()
    WrapPrefabList()
    WrapPayloadLocks()
    WrapBuildingLock()
    WrapGlobalSupportTech()
end

function OnMsg.LoadGame()
    ReadToggle()
    WrapCargoList()
    WrapPrefabList()
    WrapPayloadLocks()
    WrapBuildingLock()
    WrapGlobalSupportTech()
    if type(RMR_EarthSponsorsDone) == "table" then
        for id in pairs(RMR_EarthSponsorsDone) do
            RMR_UnlockSponsorEarthPrefabs(id)
        end
    end
end

function OnMsg.NewDay()
    ReadToggle()
    if not ToggleGS or not RivalAIs or not UIColony then
        return
    end
    RMR_EarthSponsorsDone = RMR_EarthSponsorsDone or {}
    for id, ai in pairs(RivalAIs) do
        local st = ai.resources.standing
        if type(st) == "number" and st >= 90 and not RMR_EarthSponsorsDone[id] then
            MarkSponsorDone(id)
            print("RMR earth standing", id, st)
            RMR_UnlockSponsorEarthPrefabs(id, "standing")
        end
    end
end