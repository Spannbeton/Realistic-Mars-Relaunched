return {
	PlaceObj('ModItemFolder', {
		'name', "Solar Rebalance",
	}, {
		PlaceObj('ModItemOptionToggle', {
			'name', "Solar_Rebalance",
			'DisplayName', "Solar Rebalance",
			'Help', "Dust on solar cells cuts Power output. The loss grows with maintenance buildup, up to the Dust Power Loss setting.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Solar Rebalance",
			'CodeFileName', "Code/Solar Rebalance.lua",
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Solar_BaseMult",
			'DisplayName', "Solar Efficiency",
			'Help', "Multiplier for clean-panel output, in percent of the building’s base production.",
			'DefaultValue', 100,
			'MinValue', 50,
			'MaxValue', 200,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Power_Loss",
			'DisplayName', "Dust Power Loss",
			'Help', "Maximum Power lost when a panel is fully dirty, in percent of current output.",
			'DefaultValue', 50,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Wind Rebalance",
	}, {
		PlaceObj('ModItemOptionToggle', {
			'name', "Wind_Rebalance",
			'DisplayName', "Wind Rebalance",
			'Help', "Turbine output rises and falls over a set period, with random gusts. Dust Storm bonuses are unchanged.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Wind Rebalance",
			'CodeFileName', "Code/Wind Rebalance.lua",
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Wind_Gusts",
			'DisplayName', "Gusts",
			'Help', "Extra random spike on top of the current wind factor, in percent.",
			'DefaultValue', 40,
			'MaxValue', 500,
			'StepSize', 10,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Wind_Periodicity",
			'DisplayName', "Periodicity",
			'Help', "Hours for one full high–low wind cycle.",
			'DefaultValue', 32,
			'MinValue', 1,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Wind_Minimum",
			'DisplayName', "Minimum",
			'Help', "Floor of the sine wave, in percent of base production.",
			'DefaultValue', 30,
			'StepSize', 5,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Wind_Amplitude",
			'DisplayName', "Amplitude",
			'Help', "Swing of the sine wave above the minimum, in percent of base production.",
			'DefaultValue', 50,
			'StepSize', 5,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Battery Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Battery Rebalance",
			'CodeFileName', "Code/Battery Rebalance.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Battery_Rebalance",
			'DisplayName', "Battery Rebalance",
			'Help', "Accumulators lose Power on charge and discharge (90% / 85%). Names show the working efficiency.",
			'DefaultValue', true,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Research Rebalance",
	}, {
		PlaceObj('ModItemOptionToggle', {
			'name', "Research_Rebalance",
			'DisplayName', "Research Rebalance",
			'Help', "Each Mars lab and the Network Node may be built only once. Additional research belongs in micro-G on asteroids.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Research Rebalance",
			'CodeFileName', "Code/Research Rebalance.lua",
		}),
		PlaceObj('ModItemRef', {1} --[[RMR_Micro_G_Lab ScienceInstitute]]),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Underground and Asteroid Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "BB Rebalance",
			'CodeFileName', "Code/BB Rebalance.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Underground_Rebalance",
			'DisplayName', "Underground Rebalance",
			'Help', "Factories, schools, homes, workshops and ministries stay underground until the atmosphere is breathable. Children and Seniors suffer on the surface. Underground deposits are disabled.",
			'DefaultValue', true,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Resource Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Resource Rebalance",
			'CodeFileName', "Code/Resource Rebalance.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Resource_Rebalance",
			'DisplayName', "Resource Rebalance",
			'Help', "Fewer, smaller surface and underground deposits. Asteroids are unchanged. Prospect, rail and haul off-world to keep industry running.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_Metals_MaxDeposits",
			'DisplayName', "Metals deposits",
			'Help', "Maximum number of deposits of this resource on the map (surface and underground).",
			'DefaultValue', 3,
			'MinValue', 1,
			'MaxValue', 20,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_Metals_MaxAmount",
			'DisplayName', "Metals per deep deposit",
			'Help', "Deep-deposit size. Shallow deposits use 25% of this value. Rolled amount is 70–100% of the cap.",
			'DefaultValue', 10000,
			'MinValue', 1000,
			'MaxValue', 100000,
			'StepSize', 1000,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_Water_MaxDeposits",
			'DisplayName', "Water deposits",
			'Help', "Maximum number of deposits of this resource on the map (surface and underground).",
			'DefaultValue', 3,
			'MinValue', 1,
			'MaxValue', 20,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_Water_MaxAmount",
			'DisplayName', "Water per deep deposit",
			'Help', "Deep-deposit size. Shallow deposits use 25% of this value. Rolled amount is 70–100% of the cap.",
			'DefaultValue', 20000,
			'MinValue', 1000,
			'MaxValue', 100000,
			'StepSize', 1000,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_PreciousMetals_MaxDeposits",
			'DisplayName', "Rare Metals deposits",
			'Help', "Maximum number of deposits of this resource on the map (surface and underground).",
			'DefaultValue', 2,
			'MinValue', 1,
			'MaxValue', 20,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Resource_PreciousMetals_MaxAmount",
			'DisplayName', "Rare Metals per deep deposit",
			'Help', "Deep-deposit size. Shallow deposits use 25% of this value. Rolled amount is 70–100% of the cap.",
			'DefaultValue', 5000,
			'MinValue', 1000,
			'MaxValue', 100000,
			'StepSize', 1000,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Wonder Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Wonder Rebalance",
			'CodeFileName', "Code/Wonder Rebalance.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Wonder_Rebalance",
			'DisplayName', "Wonder Rebalance",
			'Help', "Wonders become staffed industrial projects instead of free passive bonuses.",
			'DefaultValue', true,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Terraforming Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Terraforming Rebalance",
			'CodeFileName', "Code/Terraforming Rebalance.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Terraforming_Rebalance",
			'DisplayName', "Terraforming Rebalance",
			'Help', "Changing the planet is slow, expensive, and tied to specialists and logistics. Life-support and extraction work against you.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Terraforming Projects",
			'CodeFileName', "Code/Terraforming Projects.lua",
		}),
		}),
	PlaceObj('ModItemCode', {
		'name', "Messages",
		'CodeFileName', "Code/Messages.lua",
	}),
	PlaceObj('ModItemFolder', {
		'name', "Law Rebalance",
	}, {
		PlaceObj('ModItemOptionToggle', {
			'name', "Law_Rebalance",
			'DisplayName', "Law Rebalance",
			'Help', "A light statute book keeps Comfort up. Past the free allowance Comfort falls, then Sanity. An operating Assembly and each operating ministry raise that allowance. Government staff are unmoved.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Law Rebalance",
			'CodeFileName', "Code/Law Rebalance.lua",
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Free_Laws",
			'DisplayName', "Free Laws",
			'Help', "Number of laws before penalties apply. Comfort drops after this many statutes. Sanity follows at half that pace.",
			'DefaultValue', 4,
			'MaxValue', 200,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Free_Laws_Assembly",
			'DisplayName', "Free Laws Martian Assembly",
			'Help', "Extra laws permitted while a Martian Assembly is operating.",
			'DefaultValue', 2,
			'MaxValue', 20,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Free_Laws_Ministry",
			'DisplayName', "Free Laws per Ministry",
			'Help', "Extra laws permitted per operating ministry.",
			'DefaultValue', 1,
			'MaxValue', 10,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Laws_Comfort_Penalty",
			'DisplayName', "Comfort Penalty for excess Laws",
			'DefaultValue', 2,
			'MaxValue', 5,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Laws_Sanity_Penalty",
			'DisplayName', "Sanity Panalty for excess Laws",
			'DefaultValue', 1,
			'MaxValue', 5,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Prefab Rebalance",
	}, {
		PlaceObj('ModItemOptionToggle', {
			'name', "Prefab_Rebalance",
			'DisplayName', "Prefab Rebalance",
			'Help', "Earth prefabs cost at least fifty percent more than the funding value of their construction materials. A Drone Hub also adds the catalog price of the drones it ships with.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemCode', {
			'name', "Prefab Rebalance",
			'CodeFileName', "Code/Prefab Rebalance.lua",
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Misc Settings",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Misc Settings",
			'CodeFileName', "Code/Misc Settings.lua",
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Flight_Time_Mult",
			'DisplayName', "Flight time to Earth multiplier",
			'Help', "Multiplier for Earth–Mars travel time. 1 is vanilla. 2 is twice as long.",
			'DefaultValue', 2,
			'MinValue', 1,
			'MaxValue', 10,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Funding_Percent",
			'DisplayName', "Funding gains",
			'Help', "Funding percentage. Values below 100 reduce all funding, including export prices.",
			'DefaultValue', 100,
			'MaxValue', 200,
			'StepSize', 5,
		}),
		PlaceObj('ModItemOptionNumber', {
			'name', "Export_Price_Delta",
			'DisplayName', "Export Price",
			'Help', "Change to Rare Metals export price, in millions per ingot. Vanilla plus this number.",
			'DefaultValue', -2,
			'MinValue', -10,
			'MaxValue', 10,
		}),
		}),
	PlaceObj('ModItemFolder', {
		'name', "Rival Rebalance",
	}, {
		PlaceObj('ModItemCode', {
			'name', "Rival Rebalance",
			'CodeFileName', "Code/Rival Rebalance.lua",
		}),
		PlaceObj('ModItemCode', {
			'name', "Rivals UI",
			'CodeFileName', "Code/Rivals UI.lua",
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Rival_Rebalance",
			'DisplayName', "Rival Rebalance",
			'Help', "Rival standing follows Assembly approval and how that sponsor sits with yours. It drifts toward that target at a pace that depends on the rival. Poor standing can create sympathizers among your colonists.",
			'DefaultValue', true,
		}),
		PlaceObj('ModItemOptionToggle', {
			'name', "Rival_Sabotage",
			'DisplayName', "Rival Sabotage",
			'Help', "Sympathizers may sabotage or destroy their workplace when standing with that rival is poor. Work penalties from the trait still apply if this is off.",
			'DefaultValue', true,
		}),
		}),
}