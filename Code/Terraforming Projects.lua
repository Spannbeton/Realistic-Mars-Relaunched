local ToggleTF = true
local SavedPOI = false
local SavedIceTerraforming = false
local OrigCmdLoad = false
local OrigSetFlightData = false
local OrigSetUIProjectParams = false

local TF_POI = {
    "CaptureIceAsteroids",
    "ImportGreenhouseGases",
    "CloudSeeding",
    "SeedVegetation",
    "MeltThePolarCaps",
    "LaunchSpaceMirror",
    "LaunchSpaceSunshade",
}

local RMR_COST = {
    CaptureIceAsteroids = {
        { "Fuel", 1000000 },
        { "MachineParts", 50000 },
        { "Funding", 2000000000 },
    },
    ImportGreenhouseGases = {
        { "Fuel", 600000 },
        { "Polymers", 30000 },
        { "Funding", 2000000000 },
    },
    CloudSeeding = {
        { "Fuel", 800000 },
        { "PreciousMinerals", 50000 },
        { "Funding", 2000000000 },
    },
    SeedVegetation = {
        { "Seeds", 2000000 },
        { "Fuel", 200000 },
        { "Funding", 3000000000 },
    },
    MeltThePolarCaps = {
        { "Metals", 500000 },
        { "PreciousMetals", 100000 },
        { "Electronics", 10000 },
        { "Fuel", 200000 },
        { "Funding", 5000000000 },
    },
    LaunchSpaceMirror = {
        { "Metals", 1000000 },
        { "Fuel", 100000 },
        { "PreciousMinerals", 30000 },
        { "Funding", 3000000000 },
    },
    LaunchSpaceSunshade = {
        { "Metals", 150000 },
        { "Fuel", 100000 },
        { "Electronics", 150000 },
        { "Funding", 3000000000 },
    },
    RepairSpaceMirror = {
        { "Fuel", 100000 },
        { "Metals", 50000 },
        { "PreciousMinerals", 10000 },
        { "Funding", 1000000000 },
    },
    RepairSpaceSunshade = {
        { "Fuel", 100000 },
        { "Electronics", 20000 },
        { "Funding", 1000000000 },
    },
}

local RMR_CREW = {
    CaptureIceAsteroids = { n = 7, spec = "engineer" },
    ImportGreenhouseGases = { n = 3, spec = "engineer" },
    CloudSeeding = { n = 3, spec = "scientist" },
    SeedVegetation = { n = 3, spec = "botanist" },
    RepairSpaceMirror = { n = 6, spec = "engineer" },
    RepairSpaceSunshade = { n = 6, spec = "engineer" },
}

local RMR_DESC = {
    CaptureIceAsteroids = T{0, "An engineering crew flies into the belt and bolts engines onto several ice asteroids. Mission Control will have the choice on the last correction burn.\n\n<effect>\nScatter: <resource(n5, res)>\nMars: <resource(n3, res)>, large high-quality water deposit, possible Marsquake\nAsteroid: <resource(n4, res)>, small high-quality water deposit, your colonists will feel the impact", n5 = 5000, n3 = 3000, n4 = 4000, res = "Water" .. (const.TerraformingParamSuffix or "T")},
    ImportGreenhouseGases = Untranslated("A flight crew takes a refurbished rocket to Earth, fills it with greenhouse gases and dumps the load into the Martian sky.\n\n<em>This action will cause Toxic Rains (even if Toxic Rains no longer occur due to terraforming) that are harmful to soil quality and plant life.</em>"),
    CloudSeeding = Untranslated("A scientific crew seeds the thin Martian clouds so rain can fall where Temperature and Atmosphere already allow liquid water. Exotic minerals go into the dispersal payload."),
    SeedVegetation = Untranslated("A botanical crew hauls a vast seed stock and spreads cyanophytes, algae, lichens and hardier plants across the surface. The colony must grow the seeds first."),
    MeltThePolarCaps = Untranslated("An unmanned rocket carries a nuclear package to the poles and melts the caps. Each successive strike has less effect on Water and Atmosphere.\n\n<em>Stops ongoing Cold Waves. Causes a prolonged Dust Storm even if Dust Storms no longer occur due to terraforming. Consumes the rocket.</em>"),
    LaunchSpaceMirror = Untranslated("A flight crew launches an L1 space mirror to throw more sunlight onto Mars. Raises Temperature and the output of Solar Panels."),
    LaunchSpaceSunshade = Untranslated("A flight crew launches an L1 magnetic shield against the solar wind and slows the loss of Atmosphere."),
    RepairSpaceMirror = Untranslated("An engineering crew flies to L1 and sets a damaged space mirror true again."),
    RepairSpaceSunshade = Untranslated("An engineering crew flies to L1 and brings a magnetic shield back online."),
}

local RMR_ICE_TITLE = Untranslated("Icefall")
local RMR_ICE_VOICE = Untranslated("Several ice asteroids are en route to Mars. Mission Control can order one last correction burn to decide their fate.")
local RMR_ICE_BODY = T{0, "Scatter the cluster in the atmosphere:\n<effect><resource(n5, res)>\n\nGuide the largest body down to Mars:\n<effect><resource(n3, res)>, large high-quality water deposit, possible Marsquake\n\nSend a smaller body to a tracked asteroid:\n<effect><resource(n4, res)>, small high-quality water deposit, your colonists will feel the impact", n5 = 5000, n3 = 3000, n4 = 4000, res = "Water" .. (const.TerraformingParamSuffix or "T")}
local RMR_ICE_SCATTER = Untranslated("Scatter the cluster")
local RMR_ICE_MARS = Untranslated("Guide the largest body down to Mars")

local IceBusy = false
local RepairPending = { RepairSpaceMirror = false, RepairSpaceSunshade = false }
local REPAIR_SRC = {
    RepairSpaceMirror = "LaunchSpaceMirror",
    RepairSpaceSunshade = "LaunchSpaceSunshade",
}

local function ReadToggle()
    if CurrentModOptions then
        local v = CurrentModOptions:GetProperty("Terraforming_Rebalance")
        if v ~= nil then
            ToggleTF = v
        end
    end
end

local function HasRes(list)
    local r = list and list[1]
    return r and r.resource and r.amount
end

local function CopyRes(list)
    local t = {}
    for _, r in ipairs(list or empty_table) do
        if r.resource and r.amount then
            t[#t + 1] = PlaceObj("ResourceAmount", {
                "resource", r.resource,
                "amount", r.amount,
            })
        end
    end
    return t
end

local function MakeRes(rows)
    local t = {}
    for _, row in ipairs(rows) do
        t[#t + 1] = PlaceObj("ResourceAmount", {
            "resource", row[1],
            "amount", row[2],
        })
    end
    return t
end

local function CopyTerraforming(list)
    local t = {}
    for _, row in ipairs(list or empty_table) do
        t[#t + 1] = PlaceObj("TerraformingParamAmount", {
            "param", row.param,
            "amount", row.amount,
        })
    end
    return t
end

local function CompletedCount(id)
    return (g_SpecialProjectCompleted and g_SpecialProjectCompleted[id]) or 0
end

local function SetCompletedCount(id, n)
    g_SpecialProjectCompleted = g_SpecialProjectCompleted or {}
    if n < 0 then
        n = 0
    end
    g_SpecialProjectCompleted[id] = n
end

local function FirstString(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "string" and v ~= "" then
            return v
        end
    end
end

local function SourceImage(src_id)
    local src = Presets.POI and Presets.POI.Default and Presets.POI.Default[src_id]
    return FirstString(src and src.display_icon, src and src.icon, src and src.image)
end

local function CrewSpecName(spec)
    local t = const.ColonistSpecialization and const.ColonistSpecialization[spec]
    return t and t.display_name or Untranslated(spec)
end

local function ProjectId(spot)
    return spot and (spot.project_id or spot.id)
end

local function InjectCrewRequest(rocket, cargo_request)
    local loc = rocket and (rocket.arrival_loc or rocket.departure_loc)
    local id = ProjectId(loc)
    local crew = ToggleTF and id and RMR_CREW[id]
    print("RMR cmdload", id, loc and loc.spot_type)
    if not crew then
        return cargo_request
    end
    if IsKindOf(cargo_request, "CargoRequestNew") then
        print("RMR cargo CargoRequestNew")
        return cargo_request
    end
    cargo_request = cargo_request or {}
    cargo_request[crew.spec] = {
        class = crew.spec,
        amount = crew.n,
        type = "Colonist",
    }
    rocket.cargo_request_passengers = true
    print("RMR crew request", id, crew.spec, crew.n)
    return cargo_request
end

local function WrappedCmdLoad(self, cargo_request, instant)
    cargo_request = InjectCrewRequest(self, cargo_request)
    return OrigCmdLoad(self, cargo_request, instant)
end

local function WrappedSetFlightData(self, departure_loc, arrival_loc)
    local result = OrigSetFlightData(self, departure_loc, arrival_loc)
    local loc = self.arrival_loc
    local id = ProjectId(loc)
    local crew = ToggleTF and id and RMR_CREW[id]
    if crew and self.SetCargoRequest and self.command == "CmdLoad" then
        local req = self.GetCurrentCargoAsRequest and self:GetCurrentCargoAsRequest() or {}
        req[crew.spec] = {
            class = crew.spec,
            amount = crew.n,
            type = "Colonist",
        }
        self.cargo_request_passengers = true
        self:SetCargoRequest(req)
        print("RMR crew flight", id, crew.spec, crew.n)
    end
    return result
end

local function WrappedSetUIProjectParams(self)
    local result = OrigSetUIProjectParams(self)
    local spot = self.selected_spot
    local pid = ProjectId(spot)
    local crew = ToggleTF and pid and RMR_CREW[pid]
    if not crew or not self.dialog then
        return result
    end
    local spec_name = CrewSpecName(crew.spec)
    local crew_ctrl = self.dialog:ResolveId("idCrew")
    local spec_ctrl = self.dialog:ResolveId("idSpecialization")
    if crew_ctrl then
        crew_ctrl:SetText(T{11539, "<colonist(colonists)>", colonists = crew.n})
    end
    if spec_ctrl then
        spec_ctrl:SetText(spec_name)
    end
    local inv = self.dialog:ResolveId("idInventory")
    if inv and not crew_ctrl then
        local old = inv.GetText and inv:GetText() or ""
        inv:SetText(T{0, "<old>  <colonist(n)> <spec>", old = old, n = crew.n, spec = spec_name})
    end
    print("RMR ui crew", pid, crew.n, crew.spec)
    return result
end

local function WrapClass(cls)
    if not cls then
        return
    end
    if cls.CmdLoad and cls.CmdLoad ~= WrappedCmdLoad then
        OrigCmdLoad = OrigCmdLoad or cls.CmdLoad
        cls.CmdLoad = WrappedCmdLoad
        print("RMR wrap CmdLoad", cls.class or cls)
    end
    if cls.SetFlightData and cls.SetFlightData ~= WrappedSetFlightData then
        OrigSetFlightData = OrigSetFlightData or cls.SetFlightData
        cls.SetFlightData = WrappedSetFlightData
        print("RMR wrap SetFlightData", cls.class or cls)
    end
end

local function WrapExpedition()
    WrapClass(rawget(_G, "UniversalRocket"))
    WrapClass(rawget(_G, "UniversalRocketBase"))
    local ui = rawget(_G, "LandingSiteObject")
    if ui and ui.SetUIProjectParams and ui.SetUIProjectParams ~= WrappedSetUIProjectParams then
        OrigSetUIProjectParams = OrigSetUIProjectParams or ui.SetUIProjectParams
        ui.SetUIProjectParams = WrappedSetUIProjectParams
        print("RMR wrap SetUIProjectParams")
    end
end

local function SaveVanilla()
    local presets = Presets.POI and Presets.POI.Default
    if not presets then
        return
    end
    SavedPOI = SavedPOI or {}
    for _, id in ipairs(TF_POI) do
        if not SavedPOI[id] then
            local p = presets[id]
            if p and HasRes(p.rocket_required_resources) then
                SavedPOI[id] = {
                    rocket_required_resources = CopyRes(p.rocket_required_resources),
                    description = p.description,
                }
            end
        end
    end
    local ice = presets.CaptureIceAsteroids
    if ice and not SavedIceTerraforming then
        SavedIceTerraforming = CopyTerraforming(ice.terraforming_changes)
    end
end

local function CityMap(city)
    if city and city.GetMap then
        return city:GetMap()
    end
    return city and city.map
end

local function MapId(map)
    if map and map.GetMapID then
        return map:GetMapID()
    end
    return map and map.slot
end

local function SurfaceCity()
    return MainCity or (Cities and Cities[1])
end

local function MapByName(name)
    for _, city in ipairs(Cities or empty_table) do
        local map = CityMap(city)
        if map and map.name == name then
            return map, city
        end
    end
    return false, false
end

local function WaitCityMap(city, tries)
    local map
    for _ = 1, (tries or 80) do
        map = CityMap(city)
        if map and MapId(map) then
            return map
        end
        Sleep(100)
    end
    return map
end

local function RandomPosOnMap(map)
    local fn = rawget(_G, "GetRandomPassableAwayFromBuildingOnMap")
    if fn then
        local center = point((map.Width or 614400) / 2, (map.Height or 614400) / 2)
        local pos = fn(map, center)
        if pos then
            return pos
        end
    end
    return GetRandomPassable(map)
end

local function SpawnWaterDeposit(city, base, spread, tag)
    CreateGameTimeThread(function()
        local map = WaitCityMap(city)
        local map_id = MapId(map)
        print("RMR ice pin resolve", tag, map and map.name, map_id)
        if not map or not map_id then
            print("RMR ice pin FAIL", tag, "map", map, "id", map_id)
            return
        end
        local pos = RandomPosOnMap(map)
        if not pos then
            print("RMR ice pin FAIL no passable", tag, map.name, map_id)
            return
        end
        local amount = (base + Random(0, spread)) * const.ResourceScale
        print("RMR ice pin try", tag, map.name, map_id, pos, amount)
        local marker = PlaceObjectIn("SubsurfaceDepositMarker", map_id, {
            resource = "Water",
            max_amount = amount,
            grade = "High",
            depth_layer = 1,
            revealed = true,
        })
        if marker and marker.SetPos then
            marker:SetPos(pos)
        end
        local dep = marker and marker.PlaceDeposit and marker:PlaceDeposit()
        if not dep then
            dep = PlaceObjectIn("SubsurfaceDepositWater", map_id, {
                max_amount = amount,
                amount = amount,
                grade = "High",
                depth_layer = 1,
                revealed = true,
            })
            if dep and dep.SetPos then
                dep:SetPos(pos)
            end
        end
        if not dep then
            print("RMR ice pin FAIL spawn", tag, map.name, map_id, pos)
            return
        end
        if dep.SetRevealed then
            dep:SetRevealed(true)
        end
        print("RMR ice pin OK", tag, map.name, map_id, dep.GetPos and dep:GetPos() or pos, dep.amount or amount)
    end)
end

local function DoMarsquake()
    local rand = Random(0, 100)
    if rand > 60 then
        print("RMR ice quake skip")
        return
    end
    local data_instances = Presets.MapSettings and Presets.MapSettings.Marsquake
    local settings = data_instances and (data_instances.Marsquake_Medium or data_instances[1])
    if not settings then
        print("RMR ice quake skip, no api")
        return
    end
    local range, targets_count = DetermineMarsquakeParams(settings)
    CreateGameTimeThread(TriggerMarsquake, "Building", range, targets_count)
    print("RMR ice quake")
end

local function HitAsteroidCrew(city)
    if not city then
        print("RMR ice crew skip, no city")
        return
    end
    local scale = const.Scale.Stat
    local n = 0
    for _, c in ipairs((city.labels and city.labels.Colonist) or empty_table) do
        if c.ChangeSanity then
            c:ChangeSanity(-20 * scale, "Armageddon")
        end
        if c.ChangeComfort then
            c:ChangeComfort(-60 * scale, "Deep Impact")
        end
        n = n + 1
    end
    print("RMR ice crew", n)
end

local function IceTargets()
    local actions = { "scatter", "mars" }
    local labels = { RMR_ICE_SCATTER, RMR_ICE_MARS }
    for _, s in ipairs(MarsScreenLandingSpots or empty_table) do
        if s.spot_type == "asteroid" and s.id then
            local map, city = MapByName(s.id)
            if map and city then
                actions[#actions + 1] = s.id
                labels[#labels + 1] = T{0, "Send a smaller body to <name>", name = s.display_name}
            end
        end
    end
    return actions, labels
end

local function EnsureIcePreset(labels)
    local presets = Presets.PopupNotificationPreset
    if not presets then
        print("RMR ice popup skip, no PopupNotificationPreset")
        return false
    end
    presets.Default = presets.Default or {}
    presets.POI = presets.POI or {}
    local p = PlaceObj("PopupNotificationPreset", {
        group = "POI",
        id = "RMR_Icefall",
        image = "UI/Messages/capture_ice_asteroids.png",
        start_minimized = false,
        title = RMR_ICE_TITLE,
        text = RMR_ICE_BODY,
        voiced_text = RMR_ICE_VOICE,
    })
    for i, label in ipairs(labels) do
        p["choice" .. i] = label
    end
    presets.Default.RMR_Icefall = p
    presets.POI.RMR_Icefall = p
    return true
end

local function ApplyIceChoice(key)
    print("RMR ice apply", key)
    if key == "scatter" then
        ChangeTerraformParam("Water", 5000)
        print("RMR ice water", 5000)
        return
    end
    if key == "mars" then
        ChangeTerraformParam("Water", 3000)
        print("RMR ice water", 3000)
        SpawnWaterDeposit(SurfaceCity(), 50000, 20000, "mars")
        DoMarsquake()
        return
    end
    local _, city = MapByName(key)
    if not city then
        print("RMR ice pin FAIL asteroid city missing", key)
        return
    end
    ChangeTerraformParam("Water", 4000)
    print("RMR ice water", 4000)
    SpawnWaterDeposit(city, 15000, 5000, key)
    HitAsteroidCrew(city)
end

local function RunIceChoice()
    if IceBusy then
        print("RMR ice skip, busy")
        return
    end
    IceBusy = true
    local actions, labels = IceTargets()
    if not EnsureIcePreset(labels) then
        IceBusy = false
        print("RMR ice popup missing")
        return
    end
    local idx = WaitPopupNotification("RMR_Icefall")
    print("RMR ice choice", idx)
    ApplyIceChoice(actions[idx] or actions[1])
    IceBusy = false
end

local function IceOnCompletion(self, object, city, idx)
    if IsValidThread(CurrentThread()) then
        RunIceChoice()
    else
        CreateRealTimeThread(RunIceChoice)
    end
end

local function RepairOnCompletion(self, object, city, idx)
    local src = REPAIR_SRC[self.id]
    if src then
        SetCompletedCount(src, CompletedCount(src) + 1)
        print("RMR repair restore", self.id, src, CompletedCount(src))
    end
    RepairPending[self.id] = false
end

local function SetRepairDisabled(id, disabled)
    local map = rawget(_G, "g_SpecialProjectsDisabled")
    if type(map) ~= "table" then
        print("RMR repair disable miss table", id, disabled)
        return
    end
    map[id] = disabled and true or nil
    print("RMR repair disable", id, disabled)
end

local function BindRepairPreset(id, p)
    local presets = Presets.POI and Presets.POI.Default
    if presets then
        presets[id] = p
    end
    local flat = rawget(_G, "POIPresets")
    if type(flat) == "table" then
        flat[id] = p
    end
end

local function EnsureRepairPreset(id, src_id, display)
    local presets = Presets.POI and Presets.POI.Default
    if not presets then
        return
    end
    local src = presets[src_id]
    local img = SourceImage(src_id)
    print("RMR repair visuals", id, src_id, img)
    local p = presets[id]
    if not p then
        p = PlaceObj("POI", {
            id = id,
            display_name = display,
        })
        print("RMR repair preset", id)
    end
    BindRepairPreset(id, p)
    p.id = id
    p.display_name = display
    p.description = RMR_DESC[id]
    p.rocket_required_resources = MakeRes(RMR_COST[id])
    p.terraforming_changes = {}
    p.OnCompletion = RepairOnCompletion
    p.consume_rocket = false
    p.expedition_time = src and src.expedition_time
    p.display_icon = img
    p.icon = img
    if not RepairPending[id] then
        SetRepairDisabled(id, true)
    end
end

local RefreshSpots

local function SweepRepairSpots()
    local fn = rawget(_G, "RemoveAllSpotsForSpecialProject")
    if not fn then
        print("RMR repair sweep miss RemoveAllSpotsForSpecialProject")
        return
    end
    for id in pairs(REPAIR_SRC) do
        if not RepairPending[id] then
            fn(id)
            print("RMR repair sweep", id)
        end
    end
end

local function SpawnRepairPOI(id)
    local city = MainCity
    if not city then
        print("RMR repair spawn skip, no MainCity")
        return
    end
    RepairPending[id] = true
    SetRepairDisabled(id, false)
    local init = not (g_SpecialProjectSpawnNextIdx and g_SpecialProjectSpawnNextIdx[id])
    local obj = SpawnSpecialProject(id, city, init)
    print("RMR repair spawn", id, obj and obj.id or "blocked")
    SetRepairDisabled(id, true)
    RefreshSpots()
end

local function ShowImpactThenSpawn(kind)
    local repair_id = kind == "mirror" and "RepairSpaceMirror" or "RepairSpaceSunshade"
    if RepairPending[repair_id] then
        print("RMR repair already pending", repair_id)
        return
    end
    CreateRealTimeThread(function()
        local presets = Presets.PopupNotificationPreset
        if presets then
            presets.Default = presets.Default or {}
            local id = kind == "mirror" and "RMR_MirrorHit" or "RMR_ShieldHit"
            local p = PlaceObj("PopupNotificationPreset", {
                group = "POI",
                id = id,
                image = kind == "mirror" and "UI/Messages/launch_space_mirror.dds" or "UI/Messages/launch_space_sunshide.dds",
                start_minimized = false,
                title = Untranslated("Orbital Silence"),
                voiced_text = kind == "mirror"
                    and Untranslated("Mission Control has lost telemetry from an L1 space mirror.")
                    or Untranslated("Mission Control has seen fluctuations in the L1 magnetic field generators."),
                text = kind == "mirror"
                    and Untranslated("We expect a micrometeoroid strike knocked the sheet out of alignment. A repair team will have to go up and set it true again.")
                    or Untranslated("We have taken it offline to limit damage. A maintenance team will have to restore the web before we can bring it back."),
                choice1 = kind == "mirror" and Untranslated("Dispatch a repair rocket") or Untranslated("Dispatch a maintenance rocket"),
            })
            presets.Default[id] = p
            WaitPopupNotification(id)
        end
        SpawnRepairPOI(repair_id)
    end)
end

local function DailyOrbitalWear()
    if not ToggleTF then
        print("RMR wear skip, toggle off")
        return
    end
    local function roll(src, kind)
        local n = CompletedCount(src)
        if n <= 0 then
            print("RMR wear skip", src, "count", n)
            return
        end
        local r = Random(1000)
        local hit = r < 5
        print("RMR wear roll", src, "count", n, "rng", r, "hit", hit and "yes" or "no")
        if not hit then
            return
        end
        SetCompletedCount(src, n - 1)
        print("RMR wear result", src, CompletedCount(src))
        ShowImpactThenSpawn(kind)
    end
    roll("LaunchSpaceMirror", "mirror")
    roll("LaunchSpaceSunshade", "shield")
end

function RefreshSpots()
    local presets = Presets.POI and Presets.POI.Default
    for _, spot in ipairs(MarsScreenLandingSpots or empty_table) do
        if spot.spot_type ~= "project" then
            goto continue
        end
        local pid = ProjectId(spot)
        if not (pid and RMR_COST[pid]) then
            goto continue
        end
        local p = presets and presets[pid]
        if p then
            spot.description = p.description
            if not spot.project_id then
                spot.project_id = pid
            end
        end
        spot.fuel = false
        spot.funding = false
        local resources = spot.GetRocketResources and spot:GetRocketResources() or empty_table
        if (not resources or #resources == 0) and p then
            resources = p.rocket_required_resources or empty_table
        end
        for _, res in ipairs(resources) do
            if res.resource == "Fuel" then
                spot.fuel = res.amount
            elseif res.resource == "Funding" then
                spot.funding = res.amount
            end
        end
        if ObjModified then
            ObjModified(spot)
        end
        ::continue::
    end
end

local function ApplyPOI()
    local presets = Presets.POI and Presets.POI.Default
    if not presets then
        print("RMR POI skip, no Presets.POI.Default")
        return
    end
    SaveVanilla()
    WrapExpedition()
    for _, id in ipairs(TF_POI) do
        local p = presets[id]
        local saved = SavedPOI and SavedPOI[id]
        if p and saved then
            if ToggleTF then
                p.rocket_required_resources = MakeRes(RMR_COST[id])
                p.description = RMR_DESC[id]
            else
                p.rocket_required_resources = CopyRes(saved.rocket_required_resources)
                p.description = saved.description
            end
            if ObjModified then
                ObjModified(p)
            end
        else
            print("RMR POI missing", id)
        end
    end
    local ice = presets.CaptureIceAsteroids
    if ice then
        if ToggleTF then
            ice.OnCompletion = IceOnCompletion
            ice.terraforming_changes = {}
        else
            ice.OnCompletion = nil
            ice.terraforming_changes = CopyTerraforming(SavedIceTerraforming)
        end
    end
    if ToggleTF then
        EnsureRepairPreset("RepairSpaceMirror", "LaunchSpaceMirror", Untranslated("Repair Space Mirror"))
        EnsureRepairPreset("RepairSpaceSunshade", "LaunchSpaceSunshade", Untranslated("Repair Magnetic Shield"))
    end
    RefreshSpots()
end

function RMR_SpawnTFProjects()
    ApplyPOI()
    local city = MainCity
    if not city then
        print("RMR spawn skip, no MainCity")
        return
    end
    for _, id in ipairs(TF_POI) do
        local init = not (g_SpecialProjectSpawnNextIdx and g_SpecialProjectSpawnNextIdx[id])
        local obj = SpawnSpecialProject(id, city, init)
        print("RMR spawn", id, obj and obj.id or "blocked")
    end
end

function RMR_FinishTFProject(id)
    id = id or "CaptureIceAsteroids"
    ApplyPOI()
    local project = Presets.POI and Presets.POI.Default and Presets.POI.Default[id]
    if not project then
        print("RMR finish skip, no preset", id)
        return
    end
    if not IsValidThread(CurrentThread()) then
        CreateRealTimeThread(RMR_FinishTFProject, id)
        return
    end
    if project.OnCompletion then
        project:OnCompletion(false, MainCity, 1)
    end
end

function RMR_PrintOrbital()
    print("RMR orbital mirror", CompletedCount("LaunchSpaceMirror"), "shield", CompletedCount("LaunchSpaceSunshade"), "pendingM", RepairPending.RepairSpaceMirror, "pendingS", RepairPending.RepairSpaceSunshade)
end

function RMR_AddOrbital(kind, n)
    kind = kind or "mirror"
    local src = kind == "shield" and "LaunchSpaceSunshade" or "LaunchSpaceMirror"
    SetCompletedCount(src, CompletedCount(src) + (n or 1))
    print("RMR add", src, CompletedCount(src))
end

function RMR_ForceOrbitalHit(kind)
    ApplyPOI()
    kind = kind or "mirror"
    local src = kind == "shield" and "LaunchSpaceSunshade" or "LaunchSpaceMirror"
    local n = CompletedCount(src)
    print("RMR force before", src, n)
    if n <= 0 then
        SetCompletedCount(src, 1)
        n = 1
        print("RMR force seed", src, n)
    end
    print("RMR wear roll", src, "count", n, "rng", 0, "hit", "yes")
    SetCompletedCount(src, n - 1)
    print("RMR wear result", src, CompletedCount(src))
    ShowImpactThenSpawn(kind)
end

function RMR_ForceMirrorHit()
    RMR_ForceOrbitalHit("mirror")
end

function RMR_ForceShieldHit()
    RMR_ForceOrbitalHit("shield")
end

function OnMsg.ModsReloaded()
    ReadToggle()
    ApplyPOI()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadToggle()
        ApplyPOI()
    end
end

function OnMsg.NewMapLoaded()
    ReadToggle()
    ApplyPOI()
    SweepRepairSpots()
end

function OnMsg.LoadGame()
    ReadToggle()
    ApplyPOI()
end

function OnMsg.NewDay()
    DailyOrbitalWear()
end