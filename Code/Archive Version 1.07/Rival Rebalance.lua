local ToggleRival = true
local ToggleSabotage = true
local THR_ADD = -40
local THR_MALF = -60
local THR_WRECK = -80
local GIFT_STANDING_PER = 25000000

GameVar("RMR_GiftBias", {})

-- Anfassverbot: Keys und Zahlen nur nach Auftrag.
local PERSONALITY = {
	NASA = { drift_rate = 4, recruit_permille = 35, dangerousness = 2, faction = "NASA" },
	IMM = { drift_rate = 5, recruit_permille = 40, dangerousness = 1, faction = "IMM" },
	SpaceY = { drift_rate = 7, recruit_permille = 50, dangerousness = 1, faction = "SpaceY" },
	CNSA = { drift_rate = 2, recruit_permille = 14, dangerousness = 2, faction = "China" },
	ESA = { drift_rate = 4, recruit_permille = 34, dangerousness = 1, faction = "Europe" },
	Roscosmos = { drift_rate = 2, recruit_permille = 12, dangerousness = 5, faction = "Russia" },
	ISRO = { drift_rate = 3, recruit_permille = 32, dangerousness = 1, faction = "India" },
	BlueSun = { drift_rate = 7, recruit_permille = 48, dangerousness = 1, faction = "BlueSun" },
	NewArk = { drift_rate = 1, recruit_permille = 24, dangerousness = 4, faction = "ChurchOfTheNewArk" },
	Brazil = { drift_rate = 3, recruit_permille = 30, dangerousness = 2, faction = "Brazil" },
	Japan = { drift_rate = 4, recruit_permille = 36, dangerousness = 1, faction = "Japan" },
	TerraInitiative = { drift_rate = 5, recruit_permille = 38, dangerousness = 1, faction = "TerraformingInitiative" },
	paradox = { drift_rate = 6, recruit_permille = 42, dangerousness = 1, faction = "Paradox" },
	Independent = { drift_rate = 2, recruit_permille = 18, dangerousness = 2, faction = false },
}

-- Anfassverbot analog PERSONALITY.
local REL = {
	NASA = { CNSA = -55, ESA = 12, Roscosmos = -20, ISRO = 5, Japan = 18, Brazil = 5, IMM = 10, SpaceY = 12, BlueSun = 0, NewArk = -8, TerraInitiative = 5, paradox = 0 },
	CNSA = { NASA = -55, ESA = -8, Roscosmos = 18, ISRO = -15, Japan = -8, Brazil = 0, IMM = 0, SpaceY = 0, BlueSun = 5, NewArk = 0, TerraInitiative = -12, paradox = 0 },
	ESA = { NASA = 12, CNSA = -8, Roscosmos = -65, ISRO = 5, Japan = 12, Brazil = 5, IMM = 5, SpaceY = 5, BlueSun = -8, NewArk = -20, TerraInitiative = 15, paradox = 5 },
	Roscosmos = { NASA = -20, CNSA = 18, ESA = -65, ISRO = 0, Japan = 0, Brazil = 0, IMM = 0, SpaceY = -5, BlueSun = 0, NewArk = 0, TerraInitiative = -15, paradox = 0 },
	ISRO = { NASA = 5, CNSA = -15, ESA = 5, Roscosmos = 0, Japan = 5, Brazil = 5, IMM = 5, SpaceY = 5, BlueSun = -10, NewArk = 12, TerraInitiative = 8, paradox = 0 },
	Japan = { NASA = 18, CNSA = -8, ESA = 12, Roscosmos = 0, ISRO = 5, Brazil = 0, IMM = 5, SpaceY = 15, BlueSun = 5, NewArk = 0, TerraInitiative = 5, paradox = 0 },
	Brazil = { NASA = 5, CNSA = 0, ESA = 5, Roscosmos = 0, ISRO = 5, Japan = 0, IMM = 5, SpaceY = 0, BlueSun = -5, NewArk = 10, TerraInitiative = 12, paradox = 0 },
	IMM = { NASA = 10, CNSA = 0, ESA = 5, Roscosmos = 0, ISRO = 5, Japan = 5, Brazil = 5, SpaceY = 5, BlueSun = 0, NewArk = -12, TerraInitiative = -5, paradox = 0 },
	SpaceY = { NASA = 12, CNSA = 0, ESA = 5, Roscosmos = -5, ISRO = 5, Japan = 15, Brazil = 0, IMM = 5, BlueSun = 10, NewArk = -18, TerraInitiative = -20, paradox = 5 },
	BlueSun = { NASA = 0, CNSA = 5, ESA = -8, Roscosmos = 0, ISRO = -10, Japan = 5, Brazil = -5, IMM = 0, SpaceY = 10, NewArk = -25, TerraInitiative = -30, paradox = 5 },
	NewArk = { NASA = -8, CNSA = 0, ESA = -20, Roscosmos = 0, ISRO = 12, Japan = 0, Brazil = 10, IMM = -12, SpaceY = -18, BlueSun = -25, TerraInitiative = -5, paradox = -10 },
	TerraInitiative = { NASA = 5, CNSA = -12, ESA = 15, Roscosmos = -15, ISRO = 8, Japan = 5, Brazil = 12, IMM = -5, SpaceY = -20, BlueSun = -30, NewArk = -5, paradox = 0 },
	paradox = { NASA = 0, CNSA = 0, ESA = 5, Roscosmos = 0, ISRO = 0, Japan = 0, Brazil = 0, IMM = 0, SpaceY = 5, BlueSun = 5, NewArk = -10, TerraInitiative = 0 },
}

local RMR_SYMP_NAME = {
	NASA = "NASA sympathizer",
	IMM = "IMM sympathizer",
	SpaceY = "SpaceY sympathizer",
	CNSA = "China sympathizer",
	ESA = "Europe sympathizer",
	Roscosmos = "Russia sympathizer",
	ISRO = "India sympathizer",
	BlueSun = "Blue Sun sympathizer",
	NewArk = "New Ark sympathizer",
	Brazil = "Brazil sympathizer",
	Japan = "Japan sympathizer",
	TerraInitiative = "Terra Initiative sympathizer",
	paradox = "Paradox sympathizer",
	Independent = "Independent sympathizer",
}

local COVER_IMG = {
	NASA = "UI/Messages/covert_ops_NASA.tga",
	IMM = "UI/Messages/covert_ops_IMM.tga",
	SpaceY = "UI/Messages/covert_ops_SpaceY.tga",
	CNSA = "UI/Messages/covert_ops_CNSA.tga",
	ESA = "UI/Messages/covert_ops_ESA.tga",
	Roscosmos = "UI/Messages/covert_ops_Roscosmos.tga",
	ISRO = "UI/Messages/covert_ops_ISRO.tga",
	BlueSun = "UI/Messages/covert_ops_BlueSun.tga",
	NewArk = "UI/Messages/covert_ops_NewArk.tga",
	Brazil = "UI/Messages/covert_ops_Brazil.tga",
	Japan = "UI/Messages/covert_ops_Japan.tga",
	TerraInitiative = "UI/Messages/covert_ops_TerraInitiative.tga",
	paradox = "UI/Messages/covert_ops_paradox.tga",
	Independent = "UI/Messages/covert_ops_Independent.tga",
}

local function ReadToggle()
	if not CurrentModOptions then
		return
	end
	local v = CurrentModOptions:GetProperty("Rival_Rebalance")
	if v ~= nil then
		ToggleRival = v
	end
	local s = CurrentModOptions:GetProperty("Rival_Sabotage")
	if s ~= nil then
		ToggleSabotage = s
	end
end

local function TraitId(sponsor)
	return "RMR_Symp_" .. tostring(sponsor)
end

local function EnableSponsorFactions()
	for _, pers in pairs(PERSONALITY) do
		local fid = pers.faction
		local def = fid and FactionDefs and FactionDefs[fid]
		if def then
			def.is_martian = true
		end
	end
end

local function PlayerSponsor()
	local s = GetMissionSponsor and GetMissionSponsor()
	return s and (s.id or s.name)
end

local function RivalStanding(id)
	local r = RivalAIs and RivalAIs[id]
	return r and r.resources and r.resources.standing
end

local function SetStanding(id, value)
	local r = RivalAIs and RivalAIs[id]
	if not r or not r.resources then
		print("RMR rival missing", id)
		return
	end
	r.resources.standing = Clamp(value, -100, 100)
	print("RMR rival standing", id, r.resources.standing)
end

local function RelDelta(player, rival)
	local row = REL[player]
	return (row and row[rival]) or 0
end

local function GiftSum(id)
	RMR_GiftBias = RMR_GiftBias or {}
	local pack = RMR_GiftBias[id]
	if not pack or not pack.slices then
		return 0
	end
	local n = 0
	for i = 1, #pack.slices do
		n = n + (pack.slices[i].amount or 0)
	end
	return n
end

local function AddGiftBias(sponsor, amount)
	if not sponsor or not amount or amount == 0 then
		return 0, 0, 0
	end
	RMR_GiftBias = RMR_GiftBias or {}
	local pack = RMR_GiftBias[sponsor] or { slices = {} }
	pack.slices = pack.slices or {}
	local durs = { 25, 50, 100 }
	local sign = amount > 0 and 1 or -1
	local n = abs(amount)
	local n25, n50, n100 = 0, 0, 0
	for i = 1, n do
		local sols = durs[((i - 1) % 3) + 1]
		pack.slices[#pack.slices + 1] = { amount = sign, sols = sols }
		if sols == 25 then
			n25 = n25 + 1
		elseif sols == 50 then
			n50 = n50 + 1
		else
			n100 = n100 + 1
		end
	end
	RMR_GiftBias[sponsor] = pack
	print("RMR gift slices", sponsor, "pts", amount, "sum", GiftSum(sponsor), "n", #pack.slices)
	return n25, n50, n100
end

local function TickGiftBias()
	RMR_GiftBias = RMR_GiftBias or {}
	for id, pack in pairs(RMR_GiftBias) do
		local keep = {}
		for _, sl in ipairs(pack.slices or empty_table) do
			sl.sols = (sl.sols or 0) - 1
			if sl.sols > 0 and sl.amount and sl.amount ~= 0 then
				keep[#keep + 1] = sl
			else
				print("RMR gift drop", id, sl.amount)
			end
		end
		if #keep == 0 then
			RMR_GiftBias[id] = nil
			print("RMR gift end", id)
		else
			pack.slices = keep
			print("RMR gift tick", id, "sum", GiftSum(id), "n", #keep)
		end
	end
end

local function RunRecalcApproval()
	if g_FactionsHolder and g_FactionsHolder.RecalcFactionsApproval then
		g_FactionsHolder:RecalcFactionsApproval()
		return
	end
	if RecalcFactionsApproval then
		RecalcFactionsApproval()
	end
end

local function RawApproval(faction)
	if not faction then
		return 0
	end
	RunRecalcApproval()
	local map = g_FactionsHolder and g_FactionsHolder.factions_approval
	local raw = map and map[faction]
	if type(raw) == "table" then
		raw = raw.value or raw.approval or raw[1] or 0
	end
	if type(raw) ~= "number" then
		raw = 0
	end
	return raw
end

local function ApprovalScore(faction)
	local raw = RawApproval(faction)
	local score = raw
	if abs(score) > 100 then
		score = floatfloor(score / 100)
	end
	return Clamp(score, -100, 100), raw
end

local function TargetStanding(rival_id)
	local player = PlayerSponsor()
	local pers = PERSONALITY[rival_id] or { faction = false }
	local appr, raw = ApprovalScore(pers.faction)
	local rel = RelDelta(player, rival_id)
	if player == "Independent" then
		rel = rel - 10
	end
	local extra = GiftSum(rival_id)
	print("RMR appr", rival_id, pers.faction, "score", appr, "raw", raw, "rel", rel, "gift", extra)
	return Clamp(appr + rel + extra, -100, 100), appr, rel, extra
end

function RMR_TargetStanding(id)
	return TargetStanding(id)
end

function RMR_RivalFaction(id)
	local p = PERSONALITY[id]
	return p and p.faction
end

local function DriftOne(id, rival)
	local pers = PERSONALITY[id] or { drift_rate = 3 }
	local cur = rival.resources and rival.resources.standing
	if type(cur) ~= "number" then
		return
	end
	local target, appr, rel, extra = TargetStanding(id)
	if cur ~= target then
		local step = pers.drift_rate or 3
		if cur < target then
			rival.resources.standing = Min(cur + step, target)
		else
			rival.resources.standing = Max(cur - step, target)
		end
	end
	print("RMR rival drift", id, "from", cur, "now", rival.resources.standing, "target", target, "appr", appr, "rel", rel, "gift", extra)
end

local function DriftAll()
	if not ToggleRival or not RivalAIs then
		return
	end
	for id, rival in pairs(RivalAIs) do
		DriftOne(id, rival)
	end
end

local StandingWrapped
local function WrapStanding()
	if StandingWrapped then
		return
	end
	local def = Presets.DumbAIDef and Presets.DumbAIDef.Default and Presets.DumbAIDef.Default.default
	if not def or not def.production_rules then
		print("RMR rival wrap skip, no default AI")
		return
	end
	for _, rule in ipairs(def.production_rules) do
		if rule.rule_id == "Standing" and rule.Run and not rule.RMR_Wrapped then
			local old = rule.Run
			rule.Run = function(self, resources, ai_player)
				if ToggleRival then
					return
				end
				return old(self, resources, ai_player)
			end
			rule.RMR_Wrapped = true
			StandingWrapped = true
			print("RMR rival wrap Standing")
			return
		end
	end
	print("RMR rival wrap miss Standing")
end

local function SeedStanding()
	if not ToggleRival or not RivalAIs then
		return
	end
	for id, rival in pairs(RivalAIs) do
		if rival.resources then
			rival.resources.standing = TargetStanding(id)
			print("RMR rival seed", id, rival.resources.standing)
		end
	end
end

local function LockTraits()
	local ids = {}
	for sponsor in pairs(RMR_SYMP_NAME) do
		ids[#ids + 1] = TraitId(sponsor)
	end
	for _, id in ipairs(ids) do
		local t = TraitPresets[id]
		if t then
			t.incompatible = t.incompatible or {}
			for _, other in ipairs(ids) do
				if other ~= id then
					t.incompatible[other] = true
				end
			end
			t.description = Untranslated("Loyalty to a rival colony. Supports their faction. Work suffers at poor standing. May sabotage.")
			t.group = "Negative"
			t.hidden = false
			t.modify_property = "performance"
			t.modify_amount = 0
		end
	end
end

local function EnsureTraits()
	for sponsor, title in pairs(RMR_SYMP_NAME) do
		local id = TraitId(sponsor)
		if not TraitPresets[id] then
			PlaceObj("TraitPreset", {
				id = id,
				display_name = Untranslated(title),
				description = Untranslated("Loyalty to a rival colony. Supports their faction. Work suffers at poor standing. May sabotage."),
				group = "Negative",
				hidden = false,
				weight = 0,
				incompatible = {},
				modify_property = "performance",
				modify_amount = 0,
			})
			print("RMR rival trait", id)
		end
	end
	LockTraits()
end

local function HasAnySymp(c)
	if not c or not c.traits then
		return
	end
	for sponsor in pairs(RMR_SYMP_NAME) do
		if c.traits[TraitId(sponsor)] then
			return sponsor
		end
	end
end

local function ApplyWorkPen(c, standing)
	if not c or not c.SetModifier then
		return
	end
	local pen = 0
	if standing and standing < 0 then
		pen = floatfloor(standing / 3)
	end
	local sponsor = HasAnySymp(c)
	local reason
	if pen ~= 0 then
		local name = (sponsor and RMR_SYMP_NAME[sponsor]) or "Rival sympathizer"
		reason = T{"<red><name> <amount></red>", name = Untranslated(name)}
	end
	c:SetModifier("performance", "RMR_SympWork", pen, 0, reason)
	if c.UpdatePerformance then
		c:UpdatePerformance()
	end
	if ObjModified then
		ObjModified(c)
		if c.workplace then
			ObjModified(c.workplace)
		end
	end
end

local function ClearWorkPen(c)
	if c and c.SetModifier then
		c:SetModifier("performance", "RMR_SympWork", 0, 0)
		if c.UpdatePerformance then
			c:UpdatePerformance()
		end
	end
end

local function BindFaction(c, sponsor)
	local faction = PERSONALITY[sponsor] and PERSONALITY[sponsor].faction
	if not faction or not c then
		return
	end
	c.faction_standings = c.faction_standings or {}
	if (c.faction_standings[faction] or 0) < 2 then
		c.faction_standings[faction] = 2
	end
	if c.RecalcFactionSupport then
		c:RecalcFactionSupport()
	else
		c.faction_supported = faction
	end
	if ObjModified then
		ObjModified(c)
	end
end

local function Eligible(c)
	return c and IsValid(c) and not (c.traits and (c.traits.Android or c.traits.Child or c.traits.Tourist))
end

local function PulseAdd(sponsor, force)
	local rival = RivalAIs and RivalAIs[sponsor]
	local standing = rival and rival.resources and rival.resources.standing
	if not force and (not standing or standing > THR_ADD) then
		return 0
	end
	local pers = PERSONALITY[sponsor] or { recruit_permille = 20 }
	local city = UIColony or MainCity
	local list = city and city.labels and city.labels.Colonist or empty_table
	local rolls, hits = 0, 0
	local tid = TraitId(sponsor)
	for _, c in ipairs(list) do
		if Eligible(c) and not HasAnySymp(c) then
			rolls = rolls + 1
			local roll = (c.Random and c:Random(1000)) or 1000
			if force or roll < (pers.recruit_permille or 20) then
				if c.AddTrait and TraitPresets[tid] then
					c:AddTrait(tid)
					BindFaction(c, sponsor)
					ApplyWorkPen(c, standing or THR_ADD)
					hits = hits + 1
				end
			end
		end
	end
	print("RMR rival pulse", sponsor, "standing", standing, "recruit", pers.recruit_permille, "rolls", rolls, "hits", hits, "force", not not force)
	return hits
end

local function PulseRemove(good)
	local city = UIColony or MainCity
	local list = city and city.labels and city.labels.Colonist or empty_table
	local removed = 0
	for _, c in ipairs(list) do
		local sponsor = HasAnySymp(c)
		if sponsor then
			local standing = RivalStanding(sponsor) or 0
			local drop
			if standing >= 40 then
				drop = true
			elseif standing >= 0 then
				drop = good or ((c.Random and c:Random(100)) or 100) < 50
			end
			if drop and c.RemoveTrait then
				c:RemoveTrait(TraitId(sponsor))
				ClearWorkPen(c)
				removed = removed + 1
			else
				ApplyWorkPen(c, standing)
				BindFaction(c, sponsor)
			end
		end
	end
	print("RMR rival remove", removed, "good", not not good)
end

local function DailySymp()
	if not ToggleRival then
		return
	end
	EnsureTraits()
	EnableSponsorFactions()
	PulseRemove(false)
	if not RivalAIs then
		return
	end
	for id in pairs(RivalAIs) do
		if PERSONALITY[id] then
			PulseAdd(id, false)
		end
	end
end

local function TellSymp(kind, c, bld, sponsor)
	local who = "A colonist"
	if c and c.GetDisplayName and _InternalTranslate then
		who = _InternalTranslate(c:GetDisplayName()) or who
	end
	local place = "a workplace"
	if bld and bld.GetDisplayName and _InternalTranslate then
		place = _InternalTranslate(bld:GetDisplayName()) or place
	end
	local rival = RMR_SYMP_NAME[sponsor] or tostring(sponsor)
	local id = kind == "wreck" and "RMR_SympWreck" or "RMR_SympMalf"
	local title = kind == "wreck" and "Terror Attack" or "Sabotage"
	local body
	if kind == "wreck" then
		body ="A " .. place .. " has just blown up. An internal investigation hints at a full-blown terror attack. The trail leads to " .. who .. ", a " .. rival .. ". The building is destroyed."
	else
		body = "Safety systems triggered a total shutdown at a " .. place .. ". It looks like intentional sabotage. Internal investigations hint at " .. who .. ". " .. who .. " is a sympathizer of " .. rival .. ". The building needs emergency maintenance."
	end
	PlaceObj("PopupNotificationPreset", {
		group = "Default",
		id = id,
		title = Untranslated(title),
		text = Untranslated(body),
		image = COVER_IMG[sponsor] or "UI/Messages/events.tga",
	})
	CreateRealTimeThread(function()
		if ShowPopupNotification then
			ShowPopupNotification(id)
		end
	end)
end

local function SympShiftEnd(c, workplace, force_kind)
	if not ToggleRival or not IsValid(c) then
		return
	end
	local sponsor = HasAnySymp(c)
	if not sponsor then
		ClearWorkPen(c)
		return
	end
	local standing = RivalStanding(sponsor)
	ApplyWorkPen(c, standing)
	if not ToggleSabotage or not IsValid(workplace) then
		return
	end
	local dang = (PERSONALITY[sponsor] and PERSONALITY[sponsor].dangerousness) or 2
	local bad = standing and -standing or 0
	if bad < 0 then
		bad = 0
	end
	local wreck_thr = MulDivRound(bad * dang, 100, 300)
	local malf_thr = MulDivRound(bad * dang, 100, 30)
	if force_kind == "wreck" or (not force_kind and standing and standing <= THR_WRECK) then
		local roll = force_kind and 0 or ((c.Random and c:Random(10000)) or 10000)
		print("RMR wreck roll", sponsor, "thr", wreck_thr, "roll", roll)
		if force_kind == "wreck" or roll < wreck_thr then
			print("RMR wreck hit", sponsor)
			TellSymp("wreck", c, workplace, sponsor)
			if DestroyBuildingImmediate then
				DestroyBuildingImmediate(workplace, {})
			end
			return
		end
	end
	if force_kind == "malf" or (not force_kind and standing and standing <= THR_MALF) then
		local roll = force_kind and 0 or ((c.Random and c:Random(10000)) or 10000)
		print("RMR malf roll", sponsor, "thr", malf_thr, "roll", roll)
		if force_kind == "malf" or (workplace.SetMalfunction and roll < malf_thr) then
			print("RMR malf hit", sponsor)
			if workplace.SetMalfunction then
				workplace:SetMalfunction()
			end
			TellSymp("malf", c, workplace, sponsor)
		end
	end
end

local function WrapWorkCycle()
	if rawget(_G, "RMR_WorkCycleWrapped") then
		return
	end
	if not Colonist or not Colonist.WorkCycle then
		print("RMR wrap miss WorkCycle")
		return
	end
	rawset(_G, "RMR_WorkCycleWrapped", true)
	local old = Colonist.WorkCycle
	function Colonist:WorkCycle(...)
		local workplace = self.workplace
		self:PushDestructor(function(col)
			SympShiftEnd(col, workplace)
		end)
		old(self, ...)
		self:PopAndCallDestructor()
	end
	print("RMR rival wrap WorkCycle")
end
WrapWorkCycle()

local function CargoValue(res, amount)
	if not res or not amount or amount <= 0 then
		return 0
	end
	local units = amount / (const.ResourceScale or 1000)
	local preset = CargoPreset and CargoPreset[res]
	local price = preset and preset.price
	if type(price) ~= "number" then
		print("RMR gift no price", res)
		return 0
	end
	return price * units
end

local function RemoveSymps(sponsor, n)
	if n <= 0 then
		return 0
	end
	local tid = TraitId(sponsor)
	local city = UIColony or MainCity
	local list = city and city.labels and city.labels.Colonist or empty_table
	local removed = 0
	for _, c in ipairs(list) do
		if removed >= n then
			break
		end
		if c and c.traits and c.traits[tid] and c.RemoveTrait then
			c:RemoveTrait(tid)
			ClearWorkPen(c)
			removed = removed + 1
		end
	end
	print("RMR gift strip", sponsor, "want", n, "did", removed)
	return removed
end

local function PolCommander()
	local fn = rawget(_G, "GetCommanderProfile")
	local profile = fn and fn()
	return profile and profile.id == "politician"
end

local function ApplyGift(sponsor, value, pol, kind)
	local pts
	if kind == "doctor" then
		pts = 20
		if pol then
			pts = pts * 2
		end
	elseif kind == "distress" then
		pts = floatfloor((value or 0) / GIFT_STANDING_PER)
		if pts < 1 and (value or 0) > 0 then
			pts = 1
		end
		pts = -pts * 3
		if pol then
			pts = floatfloor(pts / 2)
		end
	else
		pts = floatfloor((value or 0) / GIFT_STANDING_PER)
		if pts < 1 and (value or 0) > 0 then
			pts = 1
		end
		if pol then
			pts = pts * 2
		end
		if kind == "trade" then
			pts = floatfloor(pts / 5)
		end
	end
	if not pts or pts == 0 then
		print("RMR gift apply", sponsor, kind, "value", value, "pts", 0, "pol", not not pol)
		return 0, 0
	end
	local n = 0
	local did = 0
	if pts > 0 then
		n = floatfloor(pts / 4)
		did = RemoveSymps(sponsor, n)
	end
	local n25, n50, n100 = AddGiftBias(sponsor, pts)
	print("RMR gift apply", sponsor, kind, "value", value, "pts", pts, "25", n25, "50", n50, "100", n100, "symp", did, "pol", not not pol)
	return pts, did
end

local function OfferValue(rival)
	local offer = rival and (rival.help_offer or rival.offer)
	if type(offer) == "table" then
		local res = offer.game_res or offer.resource
		local amt = offer.help or offer.amount
		print("RMR gift offer", res, amt)
		return CargoValue(res, amt)
	end
	print("RMR gift offer missing")
	return 0
end

local GiftWrapped
local RocketWrapped
local DistressWrapped
local function WrapGift()
	if not GiftWrapped then
		local help = rawget(_G, "RivalCallHelpRocket")
		if help and help.Execute then
			local old = help.Execute
			function help:Execute(map, object, state, outcome)
				local saved = self.standing_change
				self.standing_change = 0
				old(self, map, object, state, outcome)
				self.standing_change = saved
				if ToggleRival then
					ApplyGift(object and (object.sponsor or object.id), OfferValue(object), PolCommander(), "cargo")
				end
			end
			print("RMR wrap RivalCallHelpRocket")
		else
			print("RMR wrap miss RivalCallHelpRocket")
		end
		local doc = rawget(_G, "RivalChangeStending")
		if doc and doc.Execute then
			local old = doc.Execute
			function doc:Execute(map, object, state, outcome)
				local saved = self.Standing
				if ToggleRival then
					self.Standing = 0
				end
				old(self, map, object, state, outcome)
				if ToggleRival then
					self.Standing = saved
					if saved == 20 then
						ApplyGift(object and (object.sponsor or object.id), 0, false, "doctor")
						print("RMR doctor")
					end
				end
			end
			print("RMR wrap RivalChangeStending")
		else
			print("RMR wrap miss RivalChangeStending")
		end
		local cd = rawget(_G, "RivalActionCooldowns")
		if cd then
			cd["Send Distress Call"] = 0
			print("RMR distress cooldown 0")
		else
			print("RMR wrap miss RivalActionCooldowns")
		end
		GiftWrapped = true
	end
	if not DistressWrapped then
		local ai = rawget(_G, "DumbAIPlayer")
		if ai and ai.DistressCallForResource then
			local old = ai.DistressCallForResource
			function ai:DistressCallForResource(cargo)
				local ok, result = old(self, cargo)
				if ToggleRival and ok then
					local value = 0
					local bag = result or cargo or empty_table
					for _, item in pairs(bag) do
						if type(item) == "table" and item.class and item.amount then
							value = value + CargoValue(item.class, item.amount)
						end
					end
					ApplyGift(self.sponsor, value, PolCommander(), "distress")
				end
				return ok, result
			end
			DistressWrapped = true
			print("RMR wrap DistressCallForResource")
		else
			print("RMR wrap miss DistressCallForResource")
		end
	end
	if not RocketWrapped then
		local reb = rawget(_G, "RocketExpeditionBase")
		if reb and reb.__InternalExpeditionBegin then
			local old = reb.__InternalExpeditionBegin
			function reb:__InternalExpeditionBegin(orig_rocket, params)
				local result = old(self, orig_rocket, params)
				if ToggleRival and params and params.route then
					local route = params.route
					local amount = self.TradeAmount or 0
					local res = route.import
					local sponsor = route.sponsor
					ApplyGift(sponsor, CargoValue(res, amount), PolCommander(), "trade")
					route.standing_bonus = 0
				end
				return result
			end
			RocketWrapped = true
			print("RMR wrap InternalExpeditionBegin")
		else
			print("RMR wrap miss RocketExpeditionBase")
		end
	end
end
local function CheatPick(sponsor)
	local tid = TraitId(sponsor)
	local city = UIColony or MainCity
	local list = city and city.labels and city.labels.Colonist or empty_table
	for _, col in ipairs(list) do
		if col and col.traits and col.traits[tid] and IsValid(col.workplace) then
			return col, col.workplace
		end
	end
end

function RMR_CheatStanding(sponsor, value)
	SetStanding(sponsor or "Japan", value or -50)
end

function RMR_CheatSymp(sponsor)
	EnsureTraits()
	EnableSponsorFactions()
	PulseAdd(sponsor or "Japan", true)
end

function RMR_CheatGift(sponsor, millions)
	sponsor = sponsor or "Japan"
	ApplyGift(sponsor, (millions or 25) * 1000000, false, "cargo")
end

function RMR_CheatGiftPol(sponsor, millions)
	sponsor = sponsor or "Japan"
	ApplyGift(sponsor, (millions or 25) * 1000000, true, "cargo")
end

function RMR_CheatGiftDoc(sponsor)
	ApplyGift(sponsor or "Japan", 0, false, "doctor")
end

function RMR_CheatGiftDocPol(sponsor)
	ApplyGift(sponsor or "Japan", 0, true, "doctor")
end

function RMR_CheatPOI(sponsor)
	sponsor = sponsor or "Japan"
	local rival = RivalAIs and RivalAIs[sponsor]
	if not rival then
		print("RMR poi miss", sponsor)
		return
	end
	print("RMR poi resources", sponsor)
	local res = rival.resources or empty_table
	local stfn = rawget(_G, "GetStandingText")
	print("standing", res.standing, stfn and stfn(res.standing))
	for k, v in pairs(res) do
		print(k, v)
	end
	print("RMR poi log", sponsor)
	local dumped
	if type(rival.log) == "table" then
		for i, e in ipairs(rival.log) do
			print(i, type(e) == "table" and (e.log_entry or e.text) or e)
			dumped = true
		end
	end
	if not dumped then
		print("RMR poi log miss")
	end
	local pers = PERSONALITY[sponsor]
	RMR_CheatLikes(pers and pers.faction)
end

local function RMR_DumpVal(v)
	if v == nil then
		return "nil"
	end
	if type(v) == "table" and _InternalTranslate then
		local t = _InternalTranslate(v)
		if t and t ~= "" then
			return t
		end
	end
	return tostring(v)
end

function RMR_CheatLikes(faction_id)
	faction_id = faction_id or "Utopia"
	print("RMR likes dump", faction_id)
	local defs = rawget(_G, "FactionDefs")
	local preset = defs and defs[faction_id]
	if preset and preset.likes then
		print("RMR likes defs", #preset.likes)
		for i, like in ipairs(preset.likes) do
			print("RMR like def", i)
			for k, v in pairs(like) do
				print(" ", k, RMR_DumpVal(v))
			end
		end
	else
		print("RMR likes defs miss", faction_id)
	end
	local holder = rawget(_G, "g_FactionsHolder")
	local pack = holder and holder.factions_approval and holder.factions_approval[faction_id]
	if pack and pack.likes_data then
		print("RMR likes raw", #pack.likes_data)
		for i, e in ipairs(pack.likes_data) do
			print("RMR like raw", i)
			for k, v in pairs(e) do
				print(" ", k, RMR_DumpVal(v))
			end
		end
	else
		print("RMR likes raw miss")
	end
	local data = holder and holder.GetFactionLikeData and holder:GetFactionLikeData(faction_id)
	if not data then
		print("RMR likes ui miss", faction_id)
		return
	end
	print("RMR likes ui", #data)
	for i, e in ipairs(data) do
		if e.separator then
			print("RMR like ui", i, "---")
		else
			print("RMR like ui", i)
			for k, v in pairs(e) do
				print(" ", k, RMR_DumpVal(v))
			end
		end
	end
end

function RMR_CheatSympMalf(sponsor)
	sponsor = sponsor or "Japan"
	SetStanding(sponsor, -70)
	local col, bld = CheatPick(sponsor)
	if col then
		SympShiftEnd(col, bld, "malf")
	else
		print("RMR cheat malf miss", sponsor)
	end
end

function RMR_CheatSympWreck(sponsor)
	sponsor = sponsor or "Japan"
	SetStanding(sponsor, -100)
	local col, bld = CheatPick(sponsor)
	if col then
		SympShiftEnd(col, bld, "wreck")
	else
		print("RMR cheat wreck miss", sponsor)
	end
end

function OnMsg.ModsReloaded()
	ReadToggle()
	EnableSponsorFactions()
	EnsureTraits()
	WrapStanding()
	WrapWorkCycle()
	WrapGift()
end

function OnMsg.ApplyModOptions(id)
	if id == CurrentModId then
		ReadToggle()
	end
end

function OnMsg.NewMapLoaded()
	ReadToggle()
	EnableSponsorFactions()
	EnsureTraits()
	WrapStanding()
	WrapWorkCycle()
	WrapGift()
end

function OnMsg.LoadGame()
	ReadToggle()
	EnableSponsorFactions()
	EnsureTraits()
	WrapStanding()
	WrapWorkCycle()
	WrapGift()
end

function OnMsg.RivalsSpawned()
	ReadToggle()
	EnableSponsorFactions()
	SeedStanding()
end

function OnMsg.CityStart()
	ReadToggle()
	EnableSponsorFactions()
	SeedStanding()
end

function OnMsg.NewDay()
	TickGiftBias()
	DriftAll()
	DailySymp()
end
