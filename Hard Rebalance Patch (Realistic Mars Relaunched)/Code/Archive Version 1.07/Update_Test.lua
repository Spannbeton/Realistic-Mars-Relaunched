-- Update_Test.lua
-- Load FIRST in metadata.lua `code` and items.lua. Snapshots vanilla before any RMR wrap.
--
-- 1.07 once:  RMR_GenerateWrapHashes()  and  RMR_GenerateCallHashes()
--             paste the printed blocks into the baseline tables at the bottom.
-- After patch: RMR_TestAll()

local WRAP = {}
local CALL = {}
local SNAP = { wrap = {}, call = {} }
local SnapWarned = {}
local WRAP_BASELINE = {}
local CALL_BASELINE = {}

local function Rec(list, file, kind, id, path, optional)
	list[#list + 1] = {
		file = file,
		kind = kind,
		id = id,
		path = path or id,
		optional = optional,
	}
end

local function W(file, kind, id, path, optional)
	Rec(WRAP, file, kind, id, path, optional)
end

local function C(file, id, path, optional)
	Rec(CALL, file, "call", id, path, optional)
end

local function Wcls(file, kind, cls, methods, optional)
	for i = 1, #methods do
		W(file, kind, cls .. "." .. methods[i], nil, optional)
	end
end

-- ---------------------------------------------------------------------------
-- Wrap registry (vanilla functions RMR replaces)
-- ---------------------------------------------------------------------------

W("Global Support Rebalance.lua", "wrap", "GetAdditionalBuildingLock")
Wcls("Global Support Rebalance.lua", "wrap", "RocketPayloadObject", {
	"IsLocked", "IsHidden", "IsImportLocked", "IsBlacklisted",
})
W("Global Support Rebalance.lua", "wrap", "CargoTransporterNew.GetTransportablePrefabs")
W("Global Support Rebalance.lua", "wrap", "CargoRequestNew.GetTransportableCargo")
W("Global Support Rebalance.lua", "wrap", "TechDef.GlobalSupport.OnResearched")

W("Rival Rebalance.lua", "wrap", "Colonist.WorkCycle")
W("Rival Rebalance.lua", "wrap", "RivalCallHelpRocket.Execute")
W("Rival Rebalance.lua", "wrap", "RivalChangeStending.Execute")
W("Rival Rebalance.lua", "wrap", "DumbAIPlayer.DistressCallForResource")
W("Rival Rebalance.lua", "wrap", "RocketExpeditionBase.__InternalExpeditionBegin")
W("Rival Rebalance.lua", "wrap", "DumbAIDef.Standing.Run", "DumbAIDef.Standing.Run")

do
	local poi = { "LandingSiteObject", "POIAdditionalContent", "PlanetaryViewResources" }
	for i = 1, #poi do
		Wcls("rivalPOI.lua", "wrap", poi[i], { "SetUIResourceValues", "ShowContent", "Open" }, true)
		Wcls("rivalPOI.lua", "replace", poi[i], { "GetAILog", "RivalSelectedHasLog" }, true)
	end
end

W("Rivals UI.lua", "wrap", "RivalIsStanding.__eval")
W("Rivals UI.lua", "wrap", "RivalIsStanding2.__eval")
W("Rivals UI.lua", "wrap", "CreateNegotiationStateFromGroup")

Wcls("Terraforming Projects.lua", "wrap", "UniversalRocket", { "CmdLoad", "SetFlightData" }, true)
Wcls("Terraforming Projects.lua", "wrap", "UniversalRocketBase", { "CmdLoad", "SetFlightData" }, true)
W("Terraforming Projects.lua", "wrap", "LandingSiteObject.SetUIProjectParams", nil, true)

W("Terraforming Rebalance.lua", "wrap", "TFormat.terraform_resource")
W("Terraforming Rebalance.lua", "wrap", "GetConstructionDescription")

Wcls("Terraforming Rebalance.lua", "replace", "MOXIE", { "GetTerraformingBoostSol" }, true)
W("Terraforming Rebalance.lua", "replace", "MOXIE.GetTerraformingBoost", nil, true)
Wcls("Terraforming Rebalance.lua", "replace", "MoistureVaporator", { "GetTerraformingBoostSol" }, true)
W("Terraforming Rebalance.lua", "replace", "MoistureVaporator.GetTerraformingBoost", nil, true)
Wcls("Terraforming Rebalance.lua", "replace", "RegolithExtractorBase", { "GetTerraformingBoostSol" }, true)
Wcls("Terraforming Rebalance.lua", "replace", "RegolithExtractor", { "GetTerraformingBoostSol" }, true)
Wcls("Terraforming Rebalance.lua", "replace", "TheExcavatorBase", { "GetTerraformingBoostSol" }, true)
Wcls("Terraforming Rebalance.lua", "replace", "TheExcavator", { "GetTerraformingBoostSol" }, true)

do
	local fp = { "GetTerraformingBoostSol", "GetTerraformingBoost", "TryPlantVegetation", "GetWorkNotPossibleReason" }
	Wcls("Terraforming Rebalance.lua", "wrap", "ForestationPlantBase", fp, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "ForestationPlant", fp, true)
end
do
	local sc = { "GetTerraformingBoostSol", "GetWorkNotPossibleReason" }
	Wcls("Terraforming Rebalance.lua", "wrap", "GHGFactoryBase", sc, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "GHGFactory", sc, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "CarbonateProcessorBase", sc, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "CarbonateProcessor", sc, true)
end
do
	local ht = { "GetTerraformingBoostSol", "GetWorkNotPossibleReason", "BuildingUpdate", "SetWorking", "Done" }
	Wcls("Terraforming Rebalance.lua", "wrap", "CoreHeatConvectorBase", ht, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "CoreHeatConvector", ht, true)
end
do
	local sh = { "GetAtmosphereLossReductionSum", "BuildingUpdate", "SetWorking" }
	Wcls("Terraforming Rebalance.lua", "wrap", "MagneticFieldGeneratorBase", sh, true)
	Wcls("Terraforming Rebalance.lua", "wrap", "MagneticFieldGenerator", sh, true)
	W("Terraforming Rebalance.lua", "wrap", "MagneticFieldGenerator.GetWorkNotPossibleReason", nil, true)
end

W("Wonder Rebalance.lua", "wrap", "Asteroids.GetMaxAsteroids", nil, true)
W("Wonder Rebalance.lua", "wrap", "UIColony.GetMaxAsteroids", nil, true)
W("Wonder Rebalance.lua", "wrap", "MoholeMine.UpdatePerformance")

W("BB Rebalance.lua", "wrap", "GetAtmosphereBreathable")
W("BB Rebalance.lua", "wrap", "Colonist.DailyUpdate")
W("BB Rebalance.lua", "wrap", "Colonist.GetMoraleAdjustment")

W("Solar Rebalance.lua", "replace", "SolarPanelBase.UpdateProduction")
W("Wind Rebalance.lua", "replace", "WindTurbineBase.CalcProduction")

-- ---------------------------------------------------------------------------
-- Call registry (vanilla functions used, including wrap targets via TestAll)
-- ---------------------------------------------------------------------------

local function calls(file, ids)
	for i = 1, #ids do
		C(file, ids[i], nil, true)
	end
end

calls("Global Support Rebalance.lua", {
	"GetMissionSponsor",
	"GetRocketClass",
	"GetResupplyItem",
	"UnlockImport",
	"ResupplyItemsInit",
	"PlaceObj",
	"UIColony.ChangeTechRepeatable",
	"Effect_UnlockResupplyItem.OnApplyEffect",
})
calls("Rival Rebalance.lua", {
	"GetMissionSponsor",
	"GetCommanderProfile",
	"GetStandingText",
	"g_FactionsHolder.RecalcFactionsApproval",
	"g_FactionsHolder.GetFactionLikeData",
	"PlaceObj",
	"DestroyBuildingImmediate",
	"Colonist.AddTrait",
	"Colonist.RemoveTrait",
	"Colonist.SetModifier",
	"Colonist.UpdatePerformance",
	"Colonist.RecalcFactionSupport",
	"Colonist.ChangeSanity",
	"Colonist.ChangeComfort",
	"Colonist.PushDestructor",
	"Colonist.PopAndCallDestructor",
	"Colonist.GetDisplayName",
	"Colonist.Random",
})
calls("rivalPOI.lua", {
	"GetStandingText",
	"GetDialog",
	"IsKindOf",
	"TList",
})
calls("Rivals UI.lua", {
	"GetCommanderProfile",
	"CreateNegotiationState",
	"IsKindOf",
})
calls("Terraforming Projects.lua", {
	"PlaceObj",
	"WaitPopupNotification",
	"SpawnSpecialProject",
	"ChangeTerraformParam",
	"GetRandomPassable",
	"GetRandomPassableAwayFromBuildingOnMap",
	"PlaceObjectIn",
	"DetermineMarsquakeParams",
	"TriggerMarsquake",
	"UniversalRocket.GetCurrentCargoAsRequest",
	"UniversalRocket.SetCargoRequest",
})
calls("Terraforming Rebalance.lua", {
	"FormatResource",
	"Workplace.Init",
	"Workplace.GetWorkNotPossibleReason",
	"Building.SetBase",
	"Building.GetClassValue",
	"Building.GetPerformance",
	"Building.HasMember",
	"Building.SetWorking",
	"Building.DoesHaveConsumption",
})
calls("Wonder Rebalance.lua", {
	"DisableInEnvironment",
	"UndisableInEnvironment",
	"RefreshXBuildMenu",
	"Building.HasUpgrade",
	"Building.SetBase",
	"Building.HasMember",
})
calls("BB Rebalance.lua", {
	"DisableInEnvironment",
	"UndisableInEnvironment",
	"RefreshXBuildMenu",
	"ObjectIsInEnvironment",
	"Colonist.Affect",
	"Colonist.ChangeSanity",
})
calls("Solar Rebalance.lua", {
	"RebuildInfopanel",
	"SolarPanelBase.CanBeOpened",
	"SolarPanelBase.GetClassValue",
	"SolarPanelBase.UpdateCounterAtmosphereModifier",
	"SolarPanelBase.SetBase",
})
calls("Wind Rebalance.lua", {
	"WindTurbineBase.GetElevationBonus",
	"WindTurbineBase.GetClassValue",
	"WindTurbineBase.SetAnimSpeedModifier",
	"WindTurbineBase.SetBase",
	"WindTurbineBase.UpdateWorking",
	"InteractionRand",
})
calls("Prefab Rebalance.lua", {
	"GetCargoType",
	"ObjModified",
})
calls("Battery Rebalance.lua", {
	"Building.SetProperty",
})
calls("Messages.lua", {
	"WaitPopupNotification",
	"GetMissionSponsor",
	"InteractionRand",
	"quit",
	"Colonist.ChangeSanity",
})
calls("Misc Settings.lua", {
	"GetMissionSponsor",
})
calls("Law Rebalance.lua", {
	"Colonist.ChangeComfort",
	"Colonist.ChangeSanity",
})
calls("several", {
	"CreateRealTimeThread",
	"CreateGameTimeThread",
	"IsValid",
	"IsValidThread",
	"IsKindOf",
	"ObjModified",
	"PlaceObj",
	"GetDialog",
	"AsyncRand",
	"Random",
})

-- ---------------------------------------------------------------------------
-- Resolve / hash
-- ---------------------------------------------------------------------------

local function ResolveStandingRun()
	local presets = rawget(_G, "Presets")
	local def = presets and presets.DumbAIDef and presets.DumbAIDef.Default and presets.DumbAIDef.Default.default
	local rules = def and def.production_rules
	if type(rules) ~= "table" then
		return
	end
	for _, rule in ipairs(rules) do
		if rule.rule_id == "Standing" and type(rule.Run) == "function" then
			return rule.Run
		end
	end
end

local function WalkPath(path)
	if path == "DumbAIDef.Standing.Run" then
		return ResolveStandingRun()
	end
	local cur = _G
	for part in string.gmatch(path, "[^%.]+") do
		if type(cur) ~= "table" then
			return
		end
		local nxt
		if cur == _G then
			nxt = rawget(_G, part)
		else
			nxt = rawget(cur, part)
			if nxt == nil then
				local ok, got = pcall(function()
					return cur[part]
				end)
				if ok then
					nxt = got
				end
			end
		end
		cur = nxt
	end
	return cur
end

local function Resolve(entry)
	return WalkPath(entry.path or entry.id)
end

local function HashString(s)
	s = s or ""
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + s:byte(i)) % 4294967296
	end
	return string.format("%08x", h)
end

local function DumpFn(fn)
	if type(string.dump) ~= "function" then
		return
	end
	local ok, d = pcall(string.dump, fn, true)
	if ok and type(d) == "string" then
		return d
	end
	ok, d = pcall(string.dump, fn)
	if ok and type(d) == "string" then
		return d
	end
end

local function SourceBody(fn)
	local gfs = rawget(_G, "GetFuncSourceString")
	if type(gfs) == "function" then
		local ok, s = pcall(gfs, fn)
		if ok and type(s) == "string" and s ~= "" then
			return s
		end
	end
	local gf = rawget(_G, "GetFuncSource")
	if type(gf) == "function" then
		local ok, a, b, c = pcall(gf, fn)
		if ok then
			if type(c) == "string" and c ~= "" then
				return c
			end
			if type(a) == "string" and a ~= "" and b == nil then
				return a
			end
		end
	end
end

local function Fingerprint(fn)
	local fp = {
		hash = "",
		kind = "?",
		source = "",
		linedefined = 0,
		lastlinedefined = 0,
		nparams = -1,
		nups = -1,
		isvararg = false,
		src_hash = "",
	}
	if type(fn) ~= "function" then
		fp.kind = type(fn)
		fp.hash = HashString("notfn:" .. tostring(fp.kind))
		return fp
	end
	local dbg = rawget(_G, "debug")
	if dbg and dbg.getinfo then
		local info = dbg.getinfo(fn, "Snu")
		if info then
			fp.kind = info.what or "?"
			fp.source = info.source or info.short_src or ""
			fp.linedefined = info.linedefined or 0
			fp.lastlinedefined = info.lastlinedefined or 0
			fp.nparams = info.nparams or -1
			fp.nups = info.nups or -1
			fp.isvararg = info.isvararg and true or false
		end
	end
	local dump = DumpFn(fn)
	local body = SourceBody(fn)
	if body then
		fp.src_hash = HashString(body)
	end
	if dump then
		fp.hash = HashString(dump)
	elseif fp.src_hash ~= "" then
		fp.hash = "src:" .. fp.src_hash
	else
		fp.hash = HashString(table.concat({
			fp.kind, fp.source, tostring(fp.nparams), tostring(fp.nups), tostring(fp.isvararg),
		}, "|"))
	end
	return fp
end

local function LooksLikeMod(fp)
	if not fp or not fp.source then
		return false
	end
	local s = fp.source
	local modpath = rawget(_G, "CurrentModPath")
	if type(modpath) == "string" and s:find(modpath, 1, true) then
		return true
	end
	if s:find("Update_Test", 1, true) then
		return true
	end
	if s:find("Realistic Mars", 1, true) or s:find("JTTAEkH", 1, true) then
		return true
	end
	if s:find("AppData", 1, true) and s:find("[Mm]od", 1) then
		return true
	end
	return false
end

local function SnapOne(bucket, entry)
	if SNAP[bucket][entry.id] then
		return
	end
	local fn = Resolve(entry)
	if type(fn) ~= "function" then
		return
	end
	local fp = Fingerprint(fn)
	fp.file = entry.file
	fp.wrap_kind = entry.kind
	SNAP[bucket][entry.id] = fp
	if LooksLikeMod(fp) and not SnapWarned[entry.id] then
		SnapWarned[entry.id] = true
		print("RMR hash WARN snapshot looks like mod code", entry.id, fp.source, "file", entry.file)
	end
end

local function SnapshotAll()
	for i = 1, #WRAP do
		SnapOne("wrap", WRAP[i])
	end
	for i = 1, #CALL do
		SnapOne("call", CALL[i])
	end
end

local function CountSnap(bucket, list)
	local n = 0
	for i = 1, #list do
		if SNAP[bucket][list[i].id] then
			n = n + 1
		end
	end
	return n, #list
end

-- ---------------------------------------------------------------------------
-- Serialize / IO
-- ---------------------------------------------------------------------------

local function Q(s)
	return string.format("%q", tostring(s or ""))
end

local function EmitEntry(id, fp)
	return string.format(
		"\t[%s] = { hash = %s, kind = %s, source = %s, linedefined = %s, lastlinedefined = %s, nparams = %s, nups = %s, isvararg = %s, src_hash = %s, file = %s, wrap_kind = %s },",
		Q(id),
		Q(fp.hash),
		Q(fp.kind),
		Q(fp.source),
		tostring(fp.linedefined or 0),
		tostring(fp.lastlinedefined or 0),
		tostring(fp.nparams or -1),
		tostring(fp.nups or -1),
		fp.isvararg and "true" or "false",
		Q(fp.src_hash or ""),
		Q(fp.file or ""),
		Q(fp.wrap_kind or "")
	)
end

local function SortedIds(map)
	local ids = {}
	for id in pairs(map) do
		ids[#ids + 1] = id
	end
	table.sort(ids)
	return ids
end

local function EmitTable(varname, map, marker)
	local lines = {
		"-- [[" .. marker .. "]]",
		varname .. " = {",
	}
	local ids = SortedIds(map)
	for i = 1, #ids do
		lines[#lines + 1] = EmitEntry(ids[i], map[ids[i]])
	end
	lines[#lines + 1] = "}"
	lines[#lines + 1] = "-- [[END_" .. marker .. "]]"
	return table.concat(lines, "\n"), #ids
end

local function PrintChunked(text)
	for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
		print(line)
	end
end

local function TryWrite(filename, text)
	local rel = "AppData/" .. filename
	local to_os = rawget(_G, "ConvertToOSPath")
	if type(to_os) == "function" then
		local ok, os_path = pcall(to_os, rel)
		if ok and os_path then
			print("RMR hash path", os_path)
		end
	end
	local writer = rawget(_G, "AsyncStringToFile")
	if type(writer) == "function" then
		local ok, err = pcall(writer, rel, text)
		if ok then
			print("RMR hash wrote", rel)
			return true
		end
		print("RMR hash write fail", err)
	end
	return false
end

local function ById(list)
	local m = {}
	for i = 1, #list do
		m[list[i].id] = list[i]
	end
	return m
end

-- ---------------------------------------------------------------------------
-- Generate / test
-- ---------------------------------------------------------------------------

local function BaselineEmpty(t)
	return type(t) ~= "table" or next(t) == nil
end

local function Generate(bucket, list, varname, marker, filename)
	SnapshotAll()
	local map = SNAP[bucket]
	local text, n = EmitTable(varname, map, marker)
	print("RMR hash generate", varname, n, "/", #list, "snapped")
	TryWrite(filename, text)
	print("---------- BEGIN " .. varname .. " (paste into Update_Test.lua) ----------")
	PrintChunked(text)
	print("---------- END " .. varname .. " ----------")
	local missing = {}
	for i = 1, #list do
		local e = list[i]
		if not map[e.id] and not e.optional then
			missing[#missing + 1] = e.id .. " [" .. e.file .. "]"
		end
	end
	if #missing > 0 then
		print("RMR hash generate missing (required)")
		for i = 1, #missing do
			print("  ", missing[i])
		end
	end
	return n
end

local function Test(bucket, list, baseline, label)
	SnapshotAll()
	if BaselineEmpty(baseline) then
		print("RMR", label, "BASELINE EMPTY. Run generate on 1.07 and paste the block into Update_Test.lua")
		return { ok = 0, diff = 0, miss = 0, extra = 0, gone = 0, skip = 0 }
	end
	local snap = SNAP[bucket]
	local wrap_by = ById(list)
	local ok_n, diff_n, miss_n, extra_n, gone_n, skip_n = 0, 0, 0, 0, 0, 0

	local ids = {}
	local seen = {}
	for id in pairs(baseline) do
		ids[#ids + 1] = id
		seen[id] = true
	end
	for id in pairs(snap) do
		if not seen[id] then
			ids[#ids + 1] = id
			seen[id] = true
		end
	end
	for i = 1, #list do
		local id = list[i].id
		if not seen[id] then
			ids[#ids + 1] = id
			seen[id] = true
		end
	end
	table.sort(ids)

	for i = 1, #ids do
		local id = ids[i]
		local rec = wrap_by[id]
		local file = (rec and rec.file) or (baseline[id] and baseline[id].file) or (snap[id] and snap[id].file) or "?"
		local kind = (rec and rec.kind) or (baseline[id] and baseline[id].wrap_kind) or "?"
		local live = snap[id]
		local base = baseline[id]
		if live and base and live.hash ~= base.hash then
			diff_n = diff_n + 1
			print("RMR HASH DIFF ", id)
			print("  file  ", file)
			print("  kind  ", kind)
			print("  was   ", base.hash, base.kind, base.source, "L" .. tostring(base.linedefined) .. "-" .. tostring(base.lastlinedefined), "nparams", base.nparams, "nups", base.nups)
			print("  now   ", live.hash, live.kind, live.source, "L" .. tostring(live.linedefined) .. "-" .. tostring(live.lastlinedefined), "nparams", live.nparams, "nups", live.nups)
			if live.nparams ~= base.nparams or live.isvararg ~= base.isvararg then
				print("  SIG   nparams/vararg changed")
			end
		elseif live and base then
			ok_n = ok_n + 1
		elseif live and not base then
			extra_n = extra_n + 1
			print("RMR HASH EXTRA", id)
			print("  file  ", file)
			print("  kind  ", kind)
			print("  now   ", live.hash, live.kind, live.source, "L" .. tostring(live.linedefined) .. "-" .. tostring(live.lastlinedefined))
		elseif not live and base then
			gone_n = gone_n + 1
			print("RMR HASH GONE ", id)
			print("  file  ", file)
			print("  kind  ", kind)
			print("  was   ", base.hash, base.kind, base.source, "L" .. tostring(base.linedefined) .. "-" .. tostring(base.lastlinedefined))
		elseif rec and rec.optional then
			skip_n = skip_n + 1
		else
			miss_n = miss_n + 1
			print("RMR HASH MISS ", id)
			print("  file  ", file)
			print("  kind  ", kind)
		end
	end

	print("RMR", label, "ok", ok_n, "diff", diff_n, "gone", gone_n, "extra", extra_n, "miss", miss_n, "skip", skip_n)
	return { ok = ok_n, diff = diff_n, miss = miss_n, extra = extra_n, gone = gone_n, skip = skip_n }
end

-- ---------------------------------------------------------------------------
-- Shape tests (no baseline; fail if API/presets moved)
-- ---------------------------------------------------------------------------

local ShapeFail = {}

local function ShapeOk(name, cond, detail)
	if cond then
		print("RMR shape ok  ", name)
		return true
	end
	ShapeFail[#ShapeFail + 1] = name
	print("RMR shape FAIL", name, detail or "")
	return false
end

local function ExistsFn(path)
	return type(WalkPath(path)) == "function"
end

local function ExistsTbl(path)
	return type(WalkPath(path)) == "table"
end

local function HasParent(cls_name, parent)
	local cls = rawget(_G, cls_name)
	if not cls or type(cls.__parents) ~= "table" then
		return false
	end
	if table.find then
		return table.find(cls.__parents, parent) and true or false
	end
	for _, p in ipairs(cls.__parents) do
		if p == parent then
			return true
		end
	end
	return false
end

local function Tmpl(id)
	local t = rawget(_G, "BuildingTemplates")
	return t and t[id]
end

function RMR_TestShape()
	ShapeFail = {}
	print("RMR shape begin")

	ShapeOk("BuildingTemplates", type(rawget(_G, "BuildingTemplates")) == "table")
	ShapeOk("CargoPreset", type(rawget(_G, "CargoPreset")) == "table")
	ShapeOk("TechDef", type(rawget(_G, "TechDef")) == "table")
	ShapeOk("g_Consts", type(rawget(_G, "g_Consts")) == "table")
	ShapeOk("PlaceObj", ExistsFn("PlaceObj"))
	ShapeOk("WaitPopupNotification", ExistsFn("WaitPopupNotification"))
	ShapeOk("ObjModified", ExistsFn("ObjModified"))
	ShapeOk("IsKindOf", ExistsFn("IsKindOf"))
	ShapeOk("DisableInEnvironment", ExistsFn("DisableInEnvironment"))
	ShapeOk("UndisableInEnvironment", ExistsFn("UndisableInEnvironment"))
	ShapeOk("GetAtmosphereBreathable", ExistsFn("GetAtmosphereBreathable"))
	ShapeOk("GetMissionSponsor", ExistsFn("GetMissionSponsor"))
	ShapeOk("GetConstructionDescription", ExistsFn("GetConstructionDescription"))
	ShapeOk("SpawnSpecialProject", ExistsFn("SpawnSpecialProject"))
	ShapeOk("ChangeTerraformParam", ExistsFn("ChangeTerraformParam"))
	ShapeOk("CreateNegotiationStateFromGroup", ExistsFn("CreateNegotiationStateFromGroup"))
	ShapeOk("GetAdditionalBuildingLock", ExistsFn("GetAdditionalBuildingLock"))

	local blds = {
		"SolarPanel", "SolarPanelBig", "SolarArray",
		"WindTurbine", "WindTurbine_Large",
		"AtomicBattery", "Battery_WaterFuelCell",
		"ScienceInstitute", "ResearchLab", "NetworkNode", "LowGLab",
		"OmegaTelescope", "MoholeMine", "ArtificialSun",
		"MOXIE", "MoistureVaporator", "RegolithExtractor", "TheExcavator",
		"ForestationPlant", "GHGFactory", "CarbonateProcessor",
		"CoreHeatConvector", "MagneticFieldGenerator",
		"MartianAssembly", "EarthEmbassy",
		"FusionReactor", "PolymerPlant",
	}
	for i = 1, #blds do
		ShapeOk("tmpl " .. blds[i], Tmpl(blds[i]) ~= nil)
	end

	ShapeOk("class Colonist", type(rawget(_G, "Colonist")) == "table")
	ShapeOk("class SolarPanelBase", type(rawget(_G, "SolarPanelBase")) == "table")
	ShapeOk("class WindTurbineBase", type(rawget(_G, "WindTurbineBase")) == "table")
	ShapeOk("class RocketPayloadObject", type(rawget(_G, "RocketPayloadObject")) == "table")
	ShapeOk("class Workplace", type(rawget(_G, "Workplace")) == "table")
	ShapeOk("class TerraformingBuildingBase", type(rawget(_G, "TerraformingBuildingBase")) == "table", "needed for TF wrap parents")

	ShapeOk("Colonist.DailyUpdate", ExistsFn("Colonist.DailyUpdate"))
	ShapeOk("Colonist.WorkCycle", ExistsFn("Colonist.WorkCycle"))
	ShapeOk("Colonist.GetMoraleAdjustment", ExistsFn("Colonist.GetMoraleAdjustment"))
	ShapeOk("SolarPanelBase.UpdateProduction", ExistsFn("SolarPanelBase.UpdateProduction"))
	ShapeOk("WindTurbineBase.CalcProduction", ExistsFn("WindTurbineBase.CalcProduction"))
	ShapeOk("MoholeMine.UpdatePerformance", ExistsFn("MoholeMine.UpdatePerformance"))

	ShapeOk("TechDef.GlobalSupport", ExistsTbl("TechDef.GlobalSupport"), "Global Support wrap target")
	ShapeOk("TechDef.GlobalSupport.OnResearched", ExistsFn("TechDef.GlobalSupport.OnResearched"))

	local presets = rawget(_G, "Presets")
	local poi = presets and presets.POI and presets.POI.Default
	ShapeOk("Presets.POI.Default", type(poi) == "table")
	if type(poi) == "table" then
		local ids = {
			"CaptureIceAsteroids", "ImportGreenhouseGases", "CloudSeeding", "SeedVegetation",
			"MeltThePolarCaps", "LaunchSpaceMirror", "LaunchSpaceSunshade",
		}
		for i = 1, #ids do
			ShapeOk("POI " .. ids[i], poi[ids[i]] ~= nil)
		end
	end

	ShapeOk("Negotiations", type(rawget(_G, "Negotiations")) == "table")
	local N = rawget(_G, "Negotiations")
	if type(N) == "table" then
		ShapeOk("Negotiations.HelpOffer_Accepted_1", N.HelpOffer_Accepted_1 ~= nil)
		ShapeOk("Negotiations.RepliesHelpOfferAccepted", N.RepliesHelpOfferAccepted ~= nil)
		ShapeOk("Negotiations.RepliesDistressCallAccepted", N.RepliesDistressCallAccepted ~= nil)
	end

	ShapeOk("RivalCallHelpRocket.Execute", ExistsFn("RivalCallHelpRocket.Execute"))
	ShapeOk("RivalChangeStending.Execute", ExistsFn("RivalChangeStending.Execute"), "vanilla typo name")
	ShapeOk("DumbAIPlayer.DistressCallForResource", ExistsFn("DumbAIPlayer.DistressCallForResource"))
	ShapeOk("RocketExpeditionBase.__InternalExpeditionBegin", ExistsFn("RocketExpeditionBase.__InternalExpeditionBegin"))
	ShapeOk("RivalIsStanding.__eval", ExistsFn("RivalIsStanding.__eval"))
	ShapeOk("CargoTransporterNew.GetTransportablePrefabs", ExistsFn("CargoTransporterNew.GetTransportablePrefabs"))
	ShapeOk("CargoRequestNew.GetTransportableCargo", ExistsFn("CargoRequestNew.GetTransportableCargo"))

	ShapeOk("TFormat.terraform_resource", ExistsFn("TFormat.terraform_resource"))
	ShapeOk("ResourcePresets", type(rawget(_G, "ResourcePresets")) == "table")
	ShapeOk("RandomMapPresets.Underground", ExistsTbl("RandomMapPresets.Underground"))
	ShapeOk("DisabledInEnvironment", type(rawget(_G, "DisabledInEnvironment")) == "table")
	ShapeOk("TraitPresets", type(rawget(_G, "TraitPresets")) == "table")
	ShapeOk("FactionDefs", type(rawget(_G, "FactionDefs")) == "table")
	ShapeOk("CargoType", type(rawget(_G, "CargoType")) == "table")

	local consts = rawget(_G, "g_Consts")
	if type(consts) == "table" then
		ShapeOk("g_Consts.TravelTimeEarthMars", type(consts.TravelTimeEarthMars) == "number")
		ShapeOk("g_Consts.ExportPricePreciousMetals", type(consts.ExportPricePreciousMetals) == "number")
	end

	local law = rawget(_G, "ActiveLaws") or rawget(_G, "LawDefs")
	ShapeOk("ActiveLaws or LawDefs", type(law) == "table", "1.1.0 may have renamed law storage")

	if Tmpl("ScienceInstitute") then
		local bt = Tmpl("ScienceInstitute")
		ShapeOk("ScienceInstitute.max_workers", type(bt.max_workers) == "number")
		print("RMR shape note ScienceInstitute.build_once", tostring(bt.build_once), "max_workers", bt.max_workers)
	end

	ShapeOk("exported RMR_UnlockSponsorEarthPrefabs", type(rawget(_G, "RMR_UnlockSponsorEarthPrefabs")) == "function")
	ShapeOk("exported RMR_TargetStanding", type(rawget(_G, "RMR_TargetStanding")) == "function")
	ShapeOk("exported RMR_StarmanTest", type(rawget(_G, "RMR_StarmanTest")) == "function")
	ShapeOk("exported RMR_PatchGiftTexts", type(rawget(_G, "RMR_PatchGiftTexts")) == "function")

	print("RMR shape done fails", #ShapeFail)
	for i = 1, #ShapeFail do
		print("  ", ShapeFail[i])
	end
	return #ShapeFail
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function RMR_HashHelp()
	print("RMR Update_Test")
	print("  MUST load first in metadata.lua code list.")
	print("  On 1.07, once, after a map or main menu ModsReloaded:")
	print("    RMR_GenerateWrapHashes()")
	print("    RMR_GenerateCallHashes()")
	print("  Paste each printed block into Update_Test.lua (markers [[BASELINE_WRAP]] / [[BASELINE_CALL]]).")
	print("  After the game patch:")
	print("    RMR_TestAll()")
	print("  Also: RMR_TestWrapHashes  RMR_TestCallHashes  RMR_TestShape  RMR_HashStatus")
end

function RMR_HashStatus()
	SnapshotAll()
	local w, wt = CountSnap("wrap", WRAP)
	local c, ct = CountSnap("call", CALL)
	print("RMR hash status wrap", w, "/", wt, "call", c, "/", ct, "baseline_wrap", BaselineEmpty(WRAP_BASELINE) and "EMPTY" or "set", "baseline_call", BaselineEmpty(CALL_BASELINE) and "EMPTY" or "set")
	local missing = {}
	for i = 1, #WRAP do
		local e = WRAP[i]
		if not SNAP.wrap[e.id] and not e.optional then
			missing[#missing + 1] = e.id .. " [" .. e.file .. "]"
		end
	end
	if #missing > 0 then
		print("RMR hash unsapped required wraps:")
		for i = 1, #missing do
			print("  ", missing[i])
		end
	end
end

function RMR_GenerateWrapHashes()
	return Generate("wrap", WRAP, "WRAP_BASELINE", "BASELINE_WRAP", "RMR_WRAP_BASELINE.lua")
end

function RMR_GenerateCallHashes()
	return Generate("call", CALL, "CALL_BASELINE", "BASELINE_CALL", "RMR_CALL_BASELINE.lua")
end

function RMR_TestWrapHashes()
	return Test("wrap", WRAP, WRAP_BASELINE, "WRAP")
end

function RMR_TestCallHashes()
	return Test("call", CALL, CALL_BASELINE, "CALL")
end

function RMR_TestAll()
	print("RMR TEST ALL begin")
	RMR_HashStatus()
	local w = RMR_TestWrapHashes()
	local c = RMR_TestCallHashes()
	local s = RMR_TestShape()
	print("RMR TEST ALL wrap diff", w and w.diff, "gone", w and w.gone, "call diff", c and c.diff, "gone", c and c.gone, "shape fail", s)
	print("RMR TEST ALL inspect every DIFF/GONE/FAIL in the matching file field")
	print("RMR TEST ALL hashes miss 1.1.0 design changes (research map, services). Read those wrap files even if green.")
	return w, c, s
end

function RMR_HashOne(id)
	SnapshotAll()
	local fp = SNAP.wrap[id] or SNAP.call[id]
	if not fp then
		local fn = WalkPath(id)
		if type(fn) == "function" then
			fp = Fingerprint(fn)
		end
	end
	if not fp then
		print("RMR hash one miss", id)
		return
	end
	print("RMR hash one", id, fp.hash, fp.kind, fp.source, "L" .. tostring(fp.linedefined) .. "-" .. tostring(fp.lastlinedefined), "nparams", fp.nparams, "file", fp.file)
	return fp
end

-- ---------------------------------------------------------------------------
-- Snapshot hooks: first function seen wins (vanilla, if this file loads first)
-- ---------------------------------------------------------------------------

pcall(SnapshotAll)

function OnMsg.ClassesGenerate()
	SnapshotAll()
end

function OnMsg.ClassesBuilt()
	SnapshotAll()
end

function OnMsg.ModsReloaded()
	SnapshotAll()
	local function report()
		SnapshotAll()
		local w, wt = CountSnap("wrap", WRAP)
		print("RMR Update_Test ready wrap", w, "/", wt, "RMR_HashHelp()")
		if w < wt / 2 then
			print("RMR Update_Test WARN few wrap snapshots. Load this file first, or generate in-game after ClassesBuilt.")
		end
	end
	local make_thread = rawget(_G, "CreateRealTimeThread")
	if type(make_thread) == "function" then
		make_thread(function()
			local sleep = rawget(_G, "Sleep")
			if type(sleep) == "function" then
				sleep(1)
			end
			report()
		end)
	else
		report()
	end
end

function OnMsg.NewMapLoaded()
	SnapshotAll()
end

function OnMsg.LoadGame()
	SnapshotAll()
end

function OnMsg.CityStart()
	SnapshotAll()
end

-- [[BASELINE_WRAP]]
WRAP_BASELINE = {
	["Asteroids.GetMaxAsteroids"] = { hash = "0959e46f", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "wrap" },
	["CarbonateProcessor.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CarbonateProcessor.GetWorkNotPossibleReason"] = { hash = "d28738df", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CarbonateProcessorBase.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CarbonateProcessorBase.GetWorkNotPossibleReason"] = { hash = "e06138ed", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CargoRequestNew.GetTransportableCargo"] = { hash = "fe5367cd", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["CargoTransporterNew.GetTransportablePrefabs"] = { hash = "bf5c6bb9", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["Colonist.DailyUpdate"] = { hash = "4c49a46e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "BB Rebalance.lua", wrap_kind = "wrap" },
	["Colonist.GetMoraleAdjustment"] = { hash = "1655c6b1", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "BB Rebalance.lua", wrap_kind = "wrap" },
	["Colonist.WorkCycle"] = { hash = "af6be13e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvector.BuildingUpdate"] = { hash = "9483e17a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvector.Done"] = { hash = "1e9d6151", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvector.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvector.GetWorkNotPossibleReason"] = { hash = "4e0cb4ed", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvector.SetWorking"] = { hash = "3e5451de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvectorBase.BuildingUpdate"] = { hash = "9483e17a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvectorBase.Done"] = { hash = "1e9d6151", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
							
	["CoreHeatConvectorBase.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvectorBase.GetWorkNotPossibleReason"] = { hash = "4e0cb4ed", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CoreHeatConvectorBase.SetWorking"] = { hash = "3e5451de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["CreateNegotiationStateFromGroup"] = { hash = "d16e6b0f", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rivals UI.lua", wrap_kind = "wrap" },
	["DumbAIDef.Standing.Run"] = { hash = "bb331cdc", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["DumbAIPlayer.DistressCallForResource"] = { hash = "64d72056", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlant.GetTerraformingBoost"] = { hash = "3267503e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlant.GetTerraformingBoostSol"] = { hash = "9bb230ca", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlant.GetWorkNotPossibleReason"] = { hash = "d28738df", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlant.TryPlantVegetation"] = { hash = "5ed0f466", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlantBase.GetTerraformingBoost"] = { hash = "3267503e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlantBase.GetTerraformingBoostSol"] = { hash = "9bb230ca", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlantBase.GetWorkNotPossibleReason"] = { hash = "e06138ed", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["ForestationPlantBase.TryPlantVegetation"] = { hash = "5ed0f466", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["GHGFactory.GetTerraformingBoostSol"] = { hash = "ec2e32b1", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["GHGFactory.GetWorkNotPossibleReason"] = { hash = "d28738df", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["GHGFactoryBase.GetTerraformingBoostSol"] = { hash = "ec2e32b1", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["GHGFactoryBase.GetWorkNotPossibleReason"] = { hash = "e06138ed", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["GetAdditionalBuildingLock"] = { hash = "652cfbb6", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["GetAtmosphereBreathable"] = { hash = "b4dbe251", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "BB Rebalance.lua", wrap_kind = "wrap" },
	["GetConstructionDescription"] = { hash = "d354cb06", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["LandingSiteObject.GetAILog"] = { hash = "44908884", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "replace" },
	["LandingSiteObject.RivalSelectedHasLog"] = { hash = "4e62230b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "replace" },
	["LandingSiteObject.SetUIProjectParams"] = { hash = "1637ca3c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "wrap" },
	["LandingSiteObject.SetUIResourceValues"] = { hash = "8747ee04", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "wrap" },
	["LandingSiteObject.ShowContent"] = { hash = "bc1e449d", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "wrap" },
	["MOXIE.GetTerraformingBoost"] = { hash = "3267503e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["MOXIE.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["MagneticFieldGenerator.BuildingUpdate"] = { hash = "9483e17a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGenerator.GetAtmosphereLossReductionSum"] = { hash = "cd941f22", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGenerator.GetWorkNotPossibleReason"] = { hash = "d28738df", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGenerator.SetWorking"] = { hash = "3e5451de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGeneratorBase.BuildingUpdate"] = { hash = "fd5398e5", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGeneratorBase.GetAtmosphereLossReductionSum"] = { hash = "cd941f22", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MagneticFieldGeneratorBase.SetWorking"] = { hash = "3e5451de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["MoholeMine.UpdatePerformance"] = { hash = "6fb6e8d7", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "wrap" },
	["MoistureVaporator.GetTerraformingBoost"] = { hash = "3267503e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["MoistureVaporator.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
							
	["POIAdditionalContent.Open"] = { hash = "8c9801dd", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "wrap" },
	["PlanetaryViewResources.Open"] = { hash = "8c9801dd", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "wrap" },
	["RegolithExtractor.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["RegolithExtractorBase.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["RivalCallHelpRocket.Execute"] = { hash = "e6146f6a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["RivalChangeStending.Execute"] = { hash = "e6146f6a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["RivalIsStanding.__eval"] = { hash = "140faf22", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rivals UI.lua", wrap_kind = "wrap" },
	["RivalIsStanding2.__eval"] = { hash = "b7a2eda5", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rivals UI.lua", wrap_kind = "wrap" },
	["RocketExpeditionBase.__InternalExpeditionBegin"] = { hash = "38fe589c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "wrap" },
	["RocketPayloadObject.IsBlacklisted"] = { hash = "d86a79d4", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["RocketPayloadObject.IsHidden"] = { hash = "4ac42491", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["RocketPayloadObject.IsImportLocked"] = { hash = "758b85e1", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["RocketPayloadObject.IsLocked"] = { hash = "29c3f633", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["SolarPanelBase.UpdateProduction"] = { hash = "e3fa5a08", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Solar Rebalance.lua", wrap_kind = "replace" },
	["TFormat.terraform_resource"] = { hash = "6f730a95", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "wrap" },
	["TechDef.GlobalSupport.OnResearched"] = { hash = "173a9be7", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "wrap" },
	["TheExcavator.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["TheExcavatorBase.GetTerraformingBoostSol"] = { hash = "1a519cfa", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "replace" },
	["UIColony.GetMaxAsteroids"] = { hash = "d7707bda", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "wrap" },
	["UniversalRocket.CmdLoad"] = { hash = "17a63d5a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "wrap" },
	["UniversalRocket.SetFlightData"] = { hash = "5bfa0509", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "wrap" },
	["UniversalRocketBase.CmdLoad"] = { hash = "17a63d5a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "wrap" },
	["UniversalRocketBase.SetFlightData"] = { hash = "5bfa0509", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "wrap" },
	["WindTurbineBase.CalcProduction"] = { hash = "ba035a7a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "replace" },
}
-- [[END_BASELINE_WRAP]]
---------- END WRAP_BASELINE ----------


-- [[BASELINE_CALL]]
CALL_BASELINE = {
	["AsyncRand"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["Building.DoesHaveConsumption"] = { hash = "63bd0409", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["Building.GetClassValue"] = { hash = "f1c4b08e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["Building.HasMember"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["Building.HasUpgrade"] = { hash = "560c1d0e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "call" },
	["Building.SetBase"] = { hash = "10878e33", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["Building.SetProperty"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Battery Rebalance.lua", wrap_kind = "call" },
							
	["Building.SetWorking"] = { hash = "3e5451de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["ChangeTerraformParam"] = { hash = "23c6777a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["Colonist.AddTrait"] = { hash = "e0a1841a", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.Affect"] = { hash = "7a0db0cf", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "BB Rebalance.lua", wrap_kind = "call" },
	["Colonist.ChangeComfort"] = { hash = "e262bd01", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.ChangeSanity"] = { hash = "040dd238", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.GetDisplayName"] = { hash = "47a3e513", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.PopAndCallDestructor"] = { hash = "d6cc4890", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.PushDestructor"] = { hash = "4972b048", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.Random"] = { hash = "90c1c55c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.RecalcFactionSupport"] = { hash = "3132aa28", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.RemoveTrait"] = { hash = "962f8c6d", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["Colonist.SetModifier"] = { hash = "3c5a1b78", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["CreateGameTimeThread"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["CreateNegotiationState"] = { hash = "1ac16d46", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rivals UI.lua", wrap_kind = "call" },
	["CreateRealTimeThread"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["DestroyBuildingImmediate"] = { hash = "7038a40b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["DetermineMarsquakeParams"] = { hash = "0f25d459", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["DisableInEnvironment"] = { hash = "cf392e7f", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "call" },
							
	["Effect_UnlockResupplyItem.OnApplyEffect"] = { hash = "2278b085", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["FormatResource"] = { hash = "1f6a22e5", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["GetCargoType"] = { hash = "07ae4455", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Prefab Rebalance.lua", wrap_kind = "call" },
	["GetCommanderProfile"] = { hash = "3bd24daf", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["GetDialog"] = { hash = "db2ed81c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "call" },
	["GetMissionSponsor"] = { hash = "d0b098cc", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["GetRandomPassable"] = { hash = "50fa77de", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["GetResupplyItem"] = { hash = "30d272df", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["GetRocketClass"] = { hash = "4d6b9a0b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["GetStandingText"] = { hash = "6055fb5d", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["InteractionRand"] = { hash = "d57d752c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["IsKindOf"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "call" },
	["IsValid"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["IsValidThread"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["ObjModified"] = { hash = "d8c0a78c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Prefab Rebalance.lua", wrap_kind = "call" },
	["ObjectIsInEnvironment"] = { hash = "fbac4ebf", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "BB Rebalance.lua", wrap_kind = "call" },
	["PlaceObj"] = { hash = "f0515010", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["PlaceObjectIn"] = { hash = "b7d328f2", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["Random"] = { hash = "baf6ddf9", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "several", wrap_kind = "call" },
	["RebuildInfopanel"] = { hash = "085c8e4c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Solar Rebalance.lua", wrap_kind = "call" },
	["RefreshXBuildMenu"] = { hash = "cb5bf2f6", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "call" },
	["ResupplyItemsInit"] = { hash = "65615070", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["SolarPanelBase.CanBeOpened"] = { hash = "941fd3a7", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Solar Rebalance.lua", wrap_kind = "call" },
	["SolarPanelBase.GetClassValue"] = { hash = "77fa6bbc", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Solar Rebalance.lua", wrap_kind = "call" },
	["SolarPanelBase.UpdateCounterAtmosphereModifier"] = { hash = "a0af53c0", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Solar Rebalance.lua", wrap_kind = "call" },
	["SpawnSpecialProject"] = { hash = "face0868", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["TList"] = { hash = "65dd07e7", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "rivalPOI.lua", wrap_kind = "call" },
	["TriggerMarsquake"] = { hash = "59a0199e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
							
	["UIColony.ChangeTechRepeatable"] = { hash = "4701a002", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["UndisableInEnvironment"] = { hash = "1358af42", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wonder Rebalance.lua", wrap_kind = "call" },
	["UniversalRocket.GetCurrentCargoAsRequest"] = { hash = "3504b2c2", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["UniversalRocket.SetCargoRequest"] = { hash = "18dbef8c", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["UnlockImport"] = { hash = "a5945897", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Global Support Rebalance.lua", wrap_kind = "call" },
	["WaitPopupNotification"] = { hash = "f6d63565", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Projects.lua", wrap_kind = "call" },
	["WindTurbineBase.GetClassValue"] = { hash = "f1c4b08e", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["WindTurbineBase.GetElevationBonus"] = { hash = "023e334f", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["WindTurbineBase.SetAnimSpeedModifier"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["WindTurbineBase.SetBase"] = { hash = "10878e33", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["WindTurbineBase.UpdateWorking"] = { hash = "5d5127b8", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Wind Rebalance.lua", wrap_kind = "call" },
	["Workplace.GetWorkNotPossibleReason"] = { hash = "0addb545", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["Workplace.Init"] = { hash = "0c662d41", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Terraforming Rebalance.lua", wrap_kind = "call" },
	["g_FactionsHolder.GetFactionLikeData"] = { hash = "1a85552b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["g_FactionsHolder.RecalcFactionsApproval"] = { hash = "9bbf2cb8", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Rival Rebalance.lua", wrap_kind = "call" },
	["quit"] = { hash = "d8dae75b", kind = "?", source = "", linedefined = 0, lastlinedefined = 0, nparams = -1, nups = -1, isvararg = false, src_hash = "", file = "Messages.lua", wrap_kind = "call" },
}
-- [[END_BASELINE_CALL]]
---------- END CALL_BASELINE ----------
