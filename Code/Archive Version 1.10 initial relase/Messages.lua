GameVar("RMR_IntroShown", false)

local function Opt(id)
    return CurrentModOptions and CurrentModOptions:GetProperty(id)
end

local function RMR_IntroText()
    local parts = {
        T{"Welcome to Mars.\n\nRealistic Mars Relaunched is survival on a hostile red planet. Sound infrastructure and logistics are required merely to persist here, and far more to turn the wrathful god of war into the jewel of the solar system."},
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
        parts[#parts + 1] = T{"\n\n<em>Resources</em>\nMars does not lay its wealth at the landing strut. The good veins want looking for: survey teams, a stretch of rail, perhaps a haul from some nameless rock in the black. It is farther than the first map suggests. It is still there."}
    end

    if Opt("Wonder_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Wonders</em>\nThe Telescope is a very expensive pair of eyes. The Mohole is a mine that never empties and never stops eating power. Both useful. Neither is automatically the smart spend."}
    end

    if Opt("Terraforming_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Terraforming</em>\nGreen plains will remain a dream for decades, if not centuries. The work will not do itself, and it will not sit politely to one side. It will fight your industry and your export for the same scarce resources. Countless times the colony will have to choose between growth, independence, exports, and greenery before the first rain falls on Mars."}
    end

    if Opt("Law_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Laws</em>\nMars was sold as a frontier without clerks or filing cabinets. The colonists believed that. A short law book still feels like freedom. A working Assembly and its ministries can carry a few more pages. Excess bureaucracy will make your colonists lose Comfort and Sanity."}
    end
	
	if Opt("Prefab_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Prefabs</em>\nEarth will still sell you a building in a crate. It will not undercut a colony that already mines and machines the same parts. A Drone Hub on the manifest costs what the hub is worth plus the drones inside it. The catalog curiosities stay priced as curiosities."}
    end
	
	do
        local flight = Opt("Flight_Time_Mult") or 2
        local fund = Opt("Funding_Percent") or 100
        local exp = Opt("Export_Price_Delta") or -2
        if flight ~= 1 or fund ~= 100 or exp ~= 0 then
            parts[#parts + 1] = T{"\n\n<em>Logistics</em>\nEarth is farther than the brochures claimed. Transit takes <em><flight>x</em> as long. Sponsor funding is <em><fund>%</em> of the advertised sum. Rare metals fetch <em><exp> M</em> per ingot against the listed price.", flight = flight, fund = fund, exp = exp}
        end
    end
	
	if Opt("Rival_Rebalance") then
        parts[#parts + 1] = T{"\n\n<em>Rivals</em>\nRival colonies follow Assembly standing and their own tempers. Some forgive slowly. Some snap. Cargo sent their way can raise standing and quiet sympathizers. Asking for cargo does the opposite, and only a trusted neighbour will listen. Poor standing invites covert work inside your domes."}
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
            c:ChangeSanity(delta, label)
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
                T{"Since you changed Realistic Mars Relaunched options, some changes need a full restart to apply."},
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
            text = T{"Since you changed Realistic Mars Relaunched options, some changes need a full restart to apply."},
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