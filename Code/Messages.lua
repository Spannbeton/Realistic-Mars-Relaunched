GameVar("RMR_IntroShown", false)

local function Opt(id)
    return CurrentModOptions and CurrentModOptions:GetProperty(id)
end

local function OptNum(id, fallback)
    local v = tonumber(Opt(id))
    if v == nil then
        return fallback
    end
    return floatfloor(v)
end

local function CountBand(n)
    if n < 5 then
        return T{"Scarce"}
    end
    if n < 10 then
        return T{"Average"}
    end
    return T{"Plenty"}
end

local function ConcreteCountBand(n)
    if n < 8 then
        return T{"Scarce"}
    end
    if n < 15 then
        return T{"Average"}
    end
    return T{"Plenty"}
end

local function YieldBand(amount, low_max, avg_max)
    if amount <= low_max then
        return T{"low"}
    end
    if amount <= avg_max then
        return T{"average"}
    end
    return T{"high"}
end

local function ResDepositLine(count, amount, noun, low_max, avg_max)
    if count <= 0 then
        return T{"No <noun>.", noun = noun}
    end
    return T{"<band> <noun> of <yield> yield",
        band = CountBand(count),
        noun = noun,
        yield = YieldBand(amount, low_max, avg_max),
    }
end

local function ResConcreteLine(count, amount)
    if count <= 0 then
        return T{"No regolith patches."}
    end
    return T{"<band> regolith patches of <yield> yield",
        band = ConcreteCountBand(count),
        yield = YieldBand(amount, 500, 1500),
    }
end

local function RMR_IntroText()
    local parts = {
        T{"Welcome to Mars.\n\nRealistic Mars Relaunched aims to recreate survival on a hostile red planet. Sound infrastructure and logistics are required merely to persist here, still more to turn the wrathful god of war into the jewel of the solar system."},
    }

    local solar = Opt("Solar_Rebalance")
    local wind = Opt("Wind_Rebalance")
    local bat = Opt("Battery_Rebalance")
    if solar or wind or bat then
        local power = { T{"\n\n<em>Power</em>\n"} }
        if solar then
            power[#power + 1] = T{"Solar arrays accumulate dust and lose output. "}
        end
        if wind then
            power[#power + 1] = T{"Wind is not a dependable servant. "}
        end
        power[#power + 1] = T{"The grid must be sized for the worst hour, or the colony will suffer blackouts."}
        if bat then
            power[#power + 1] = T{" Accumulators, likewise, return less energy than was stored. The environment is unkind to reserves."}
        end
        parts[#parts + 1] = table.concat(power)
    end

    if Opt("Research_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Research</em>\nA vast research campus is not feasible on an early colony. Scientific capacity on Mars is deliberately scarce. Demand for zero-gravity work in the private sector is high. Additional laboratories belong where gravity releases its hold."}
    end

    if Opt("Underground_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Underground</em>\nThe surface remains a short hour from disaster. Sensitive equipment will not be certified in the open until the air can be trusted. The most vulnerable colonists refuse that risk. Preliminary surveys of a small lava-cave network nearby show a roof, passages, and almost nothing worth digging. That is sufficient. A shelter is not a mine."}
    end

    if Opt("Resource_Rebalance") then
        local m_n = OptNum("Resource_Metals_NormalDeposits", 2)
        local m_d = OptNum("Resource_Metals_DeepDeposits", 1)
        local m_a = OptNum("Resource_Metals_MaxAmount", 10000)
        local r_n = OptNum("Resource_PreciousMetals_NormalDeposits", 2)
        local r_d = OptNum("Resource_PreciousMetals_DeepDeposits", 1)
        local r_a = OptNum("Resource_PreciousMetals_MaxAmount", 5000)
        local w_n = OptNum("Resource_Water_NormalDeposits", 3)
        local w_d = OptNum("Resource_Water_DeepDeposits", 2)
        local w_a = OptNum("Resource_Water_MaxAmount", 40000)
        local c_n = OptNum("Resource_Concrete_Patches", 12)
        local c_a = OptNum("Resource_Concrete_MaxAmount", 800)

        local m_c = m_n + m_d
        local r_c = r_n + r_d
        local w_c = w_n + w_d

        local lean = (m_c < 5) or (r_c < 5) or (w_c < 5) or (c_n < 8)
            or (m_c <= 0) or (r_c <= 0) or (w_c <= 0) or (c_n <= 0)

        local res = { T{"\n\n<em>Resources</em>\n"} }
        if lean then
            res[#res + 1] = T{"Mars does not lay its resources at your feet."}
        else
            res[#res + 1] = T{"Mars lays its resources at your feet."}
        end
        res[#res + 1] = T{" Initial surveys confirm:\n"}
        res[#res + 1] = ResDepositLine(m_c, m_a, T{"Metals deposits"}, 5000, 15000)
        res[#res + 1] = T{"\n"}
        res[#res + 1] = ResDepositLine(r_c, r_a, T{"Rare Metals deposits"}, 5000, 15000)
        res[#res + 1] = T{"\n"}
        res[#res + 1] = ResDepositLine(w_c, w_a, T{"Water sources"}, 15000, 40000)
        res[#res + 1] = T{"\n"}
        res[#res + 1] = ResConcreteLine(c_n, c_a)
        if lean then
            res[#res + 1] = T{"\nThe good veins want looking for: survey teams, a stretch of rail, or a haul from some nameless rock in the black."}
        end
        parts[#parts + 1] = table.concat(res)
    end

    if Opt("Wonder_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Wonders</em>\nThe Telescope is a very expensive pair of eyes. The Mohole is a mine that never empties and never stops eating power. The Space Elevator gets more expensive to build the further you are from the equator. All useful. None is automatically the smart spend."}
    end

    if Opt("Terraforming_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Terraforming</em>\nGreen plains will remain a dream for decades, if not centuries. The work will not do itself, and it will not sit politely to one side. It will fight your industry, your export, and your other settlements for the same scarce resources. Countless times the colony will have to choose between growth, independence, exports, and greenery before the first rain falls on Mars."}
    end

    if Opt("Law_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Laws</em>\nMars was sold as a frontier without clerks or filing cabinets. The colonists believed that. A short law book still feels like freedom. A working Assembly and its ministries can carry a few more pages. Excess bureaucracy will make your colonists lose Comfort and Sanity."}
    end

    if Opt("Prefab_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Prefabs</em>\nEarth will still sell you a building in a crate. It will not undercut a colony that already mines and machines the same parts. A Drone Hub on the manifest costs what the hub is worth plus the drones inside it. The catalog curiosities stay priced as curiosities."}
    end

    do
        local flight = Opt("Flight_Time_Mult") or 2
        local fund = Opt("Funding_Percent") or 90
        local exp = Opt("Export_Price_Delta") or -2
        if flight ~= 1 or fund ~= 100 or exp ~= 0 then
            parts[#parts + 1] = T{"\n\n<em>Logistics</em>\nEarth is farther than the brochures claimed. Transit takes <em><flight>x</em> as long. Sponsor funding is <em><fund>%</em> of the advertised sum. Rare metals fetch <em><exp> M</em> per ingot against the listed price.", flight = flight, fund = fund, exp = exp}
        end
    end

    if Opt("Rival_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Rivals</em>\nRival colonies follow Assembly standing and their own tempers. Some forgive slowly. Some snap. Cargo sent their way can raise standing and quiet sympathizers. Asking for cargo does the opposite, and only a trusted neighbour will listen. Poor standing invites covert work inside your domes."}
    end
	
	if Opt("Faction_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Factions</em>\nPolitics does not stop at the chamber door. Supporters live with their faction’s mood. Content does nothing. Happy raises comfort and morale a little. Discontent cuts both. At breaking point they also lose sanity, and Earthborn may turn Earthsick. A working Assembly moves the effect one step toward the good."}
    end

    if Opt("Global_Support_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Global Support</em>\nA rival that holds you in high regard will open its Earth catalog: unique prefabs, vehicles, and hardware, sold at a premium. The Global Support breakthrough does the same for one random sponsor. Their structures remain theirs to design; you only buy the crate."}
    end

    parts[#parts + 1] = T{"\n\nEach of these systems may be switched off in the mod options."}
    return table.concat(parts)
end

local function RMR_ShowIntro()
    if RMR_IntroShown then
        return
    end
    RMR_IntroShown = true
    if not WaitPopupNotification then
        print("RMR intro no WaitPopupNotification")
        return
    end
    CreateRealTimeThread(function()
        WaitPopupNotification(false, {
            title = T{"Colony Briefing"},
            text = RMR_IntroText(),
            choice1 = T{"Understood"},
            image = "UI/Messages/dome.tga",
        })
    end)
end

function OnMsg.NewMapLoaded()
    RMR_ShowIntro()
end


---Starman
---Starman
local FlagSpacemanTrigger = false
local FlagSpacemanHappened = false
local Spacemantime = -300000

GameVar("RMR_StarmanHappened", false)

local function IsSpaceY()
    local s = GetMissionSponsor and GetMissionSponsor()
    if not s then
        return false
    end
    return s.id == "SpaceY" or s.name == "SpaceY"
end

local function ApplySanity(points, label)
    local city = UIColony or MainCity or UICity
    local list = city and city.labels and city.labels.Colonist
    if not list then
        print("RMR Starman no colonists")
        return
    end
    local delta = points * const.Scale.Stat
    print("RMR Starman sanity", points, delta, #list)
    for _, c in ipairs(list) do
        if c.ChangeSanity then
            c:ChangeSanity(delta, T(0000, label))
        end
    end
end

local function StarmanPopup()
    print("RMR Starman popup")
    if RMR_StarmanHappened or FlagSpacemanHappened then
        return
    end
    FlagSpacemanHappened = true
    RMR_StarmanHappened = true
    local spacey = IsSpaceY()
    local sanity = spacey and -10 or -2
    local choice = spacey and T{"Wait, this is our fault."} or T{"What a stupid joke"}
    local label = spacey and T{"Wait, this is our fault."} or T{"Near miss"}
    local effect = spacey
        and T{"\n\n<effect> All Colonists: <em>Sanity</em> -10."}
        or T{"\n\n<effect> All Colonists: <em>Sanity</em> -2."}
    local body = T{"Our passenger rocket nearly collided with an unidentified heavy metal object en route to Mars. The captain executed a last-minute high-G burn and avoided what would have been a critical impact. Footage from the monitoring system showed a red roadster, and what appeared to be an astronaut in the driver's seat.<newline> The captain, age 48, could not stop laughing for several minutes, repeating ''Don't Panic! Don't Panic!'' on speaker. This did not reassure the passengers."}
    print("RMR Starman variant", spacey and "SpaceY" or "other", sanity)
    CreateRealTimeThread(function()
        if WaitPopupNotification then
            WaitPopupNotification(false, {
                title = T{"Near Miss"},
                text = T{"<body><effect>", body = body, effect = effect},
                choice1 = choice,
                image = CurrentModPath .. "/Images/Starman2.tga",
            })
        end
        ApplySanity(sanity, label)
    end)
end

function RMR_StarmanTest()
    print("RMR Starman TEST")
    FlagSpacemanHappened = false
    RMR_StarmanHappened = false
    FlagSpacemanTrigger = false
    StarmanPopup()
end

local function RMR_RestartPopup()
    CreateRealTimeThread(function()
        if type(Notifications) ~= "table" then
            local res = WaitQuestion(nil,
                T{"Restart Required"},
                T{"Since you changed Realistic Mars Relaunched options, a full restart is recommended. Some buildings and wrappers only apply when classes are built."},
                T{"Quit Game"},
                T{"No, I hate waiting and I know what I'm doing"}
            )
            if res == "ok" then
                quit()
            end
            return
        end
        local res = WaitPopupNotification(false, {
            title = T{"Restart Required"},
            text = T{"Since you changed Realistic Mars Relaunched options, a full restart is recommended. Some buildings and wrappers only apply when classes are built."},
            image = "UI/Messages/emergency.tga",
            choice1 = T{"Quit Game"},
            choice2 = T{"No, I hate waiting and I know what I'm doing"},
        })
        if res == 1 then
            quit()
        end
    end)
end

function OnMsg.GameTimeStart()
    FlagSpacemanTrigger = false
    FlagSpacemanHappened = false
    Spacemantime = -300000
end

function OnMsg.RocketLaunchFromEarth(rocket)
    print("RMR Starman launch", rocket and rocket.class)
    if FlagSpacemanHappened or RMR_StarmanHappened or FlagSpacemanTrigger then
        return
    end
    if not rocket or not rocket.cargo then
        return
    end
    if not table.find(rocket.cargo, "class", "Passengers") then
        print("RMR Starman not passenger")
        return
    end
    local roll = InteractionRand and InteractionRand(1000, "RMRStarman") or 999
    print("RMR Starman roll", roll)
    if roll >= 10 then
        return
    end
    FlagSpacemanTrigger = true
    local travel = (g_Consts and g_Consts.TravelTimeEarthMars) or const.DayDuration
    Spacemantime = GameTime() + floatfloor(0.576 * travel)
    print("RMR Starman armed", Spacemantime)
    CreateGameTimeThread(function()
        while GameTime() < Spacemantime do
            Sleep(const.HourDuration)
        end
        StarmanPopup()
    end)
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        RMR_RestartPopup()
    end
end


----------------------------Fast Map switching

local old_Init = GameShortcuts.Init
function GameShortcuts:Init(parent, context)
    old_Init(self, parent, context)

    local function GetMapForKey(key)
        if key == 1 then return MainMap end
        if key == 2 then return UIColony.underground_map_unlocked and UndergroundMap end
        local asteroid = UIColony.asteroids[key - 2]
        return asteroid and asteroid.available and asteroid:GetMap()
    end

    for key = 1, 9 do
        XAction:new({
            ActionId = "ChangeMap" .. key,
            ActionTranslate = false,
            ActionName = "Change Map " .. key,
            ActionShortcut = "Ctrl-" .. key,
            OnAction = function()
                print("ChangeMap: Ctrl-" .. key .. " pressed")
                local map = GetMapForKey(key)
                if map then
                    print("ChangeMap: switching to slot", map.slot)
                    CreateRealTimeThread(ChangeCurrentMapSlot, map.slot, false)
                else
                    print("ChangeMap: no map available for key", key)
                end
            end,
        }, parent, context, true)
    end
end