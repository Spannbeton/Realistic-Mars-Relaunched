local function Txt(v)
	if v == nil then
		return ""
	end
	if type(v) == "string" then
		return v
	end
	if _InternalTranslate then
		return _InternalTranslate(v) or tostring(v)
	end
	return tostring(v)
end

local function PatchGiftTexts()
	local rule = "\n\n<effect>25M cargo value is one point of standing target. Every four points one sympathizer stands down.\nStanding-target points stack but fade over time."
	local bribe = T{"We accept your outright bribe, reluctantly. A few of our people inside your domes have been told to lie low. Do not call that trust. Call it a pause." .. rule}
	local kind = T{"Thank you. You have bought yourselves friends here, at least until the next news cycle buries the story. As a sign of good will we have told our outlets to speak more kindly of your colony." .. rule}
	local N = rawget(_G, "Negotiations")
	if N and N.HelpOffer_Accepted_1 then
		N.HelpOffer_Accepted_1.Text = bribe
	end
	if N and N.HelpOffer_Accepted_2 then
		N.HelpOffer_Accepted_2.Text = bribe
	end
	if N and N.HelpOffer_Accepted_Hostile then
		N.HelpOffer_Accepted_Hostile.Text = kind
	end
	local fn = rawget(_G, "GetCommanderProfile")
	local profile = fn and fn()
	local is_pol = profile and profile.id == "politician"
	local replies = N and N.RepliesHelpOfferAccepted
	if replies then
		for _, v in ipairs(replies) do
			if IsKindOf(v, "NegotiationReply") then
				local spec
				for _, cond in ipairs(v.Prerequisites or empty_table) do
					if cond.CommanderProfile then
						spec = cond.CommanderProfile
						break
					end
				end
				if spec == "politician" or spec == "rmr_hidden" then
					v.HideIfDisabled = true
					for _, cond in ipairs(v.Prerequisites or empty_table) do
						if cond.CommanderProfile then
							cond.CommanderProfile = "rmr_hidden"
						end
					end
					print("RMR gift hide politician reply")
				elseif spec == "doctor" then
					v.CustomOutcomeText = T{"+20 standing-target points. Five sympathizers stand down. Once per 100 Sols."}
					print("RMR gift reply doctor")
				elseif not v.DefaultCloseAction then
					if is_pol then
						v.CustomOutcomeText = T{"Political contacts double standing-target points from cargo"}
					else
						v.CustomOutcomeText = T{"Standing-target points from cargo (25M = 1 point). One sympathizer per four points. Aid rocket."}
					end
					print("RMR gift reply cargo", is_pol and "pol" or "base")
				end
			end
		end
	end
	local drule = "\n\n<effect>25M of aid is three negative standing-target points. Points stack but fade over time."
	if is_pol then
		drule = "\n\n<effect>25M of aid is three negative standing-target points. Political contacts halve the loss. Points stack but fade over time."
	end
	local accepted = {
		"DistressCall_Accepted_Excellent_1",
		"DistressCall_Accepted_Excellent_2",
		"DistressCall_Accepted_NeutralGood_1",
		"DistressCall_Accepted_NeutralGood_2",
	}
	for _, id in ipairs(accepted) do
		local n = N and N[id]
		if n and n.Text then
			local s = Txt(n.Text)
			if not s:find("standing%-target") then
				n.Text = T{s .. drule}
			end
		end
	end
	local drep = N and N.RepliesDistressCallAccepted
	if drep then
		for _, v in ipairs(drep) do
			if IsKindOf(v, "NegotiationReply") then
				local spec
				for _, cond in ipairs(v.Prerequisites or empty_table) do
					if cond.CommanderProfile then
						spec = cond.CommanderProfile
						break
					end
				end
				if spec == "rocketscientist" then
					if is_pol then
						v.CustomOutcomeText = T{"Political contacts halve the standing-target loss from aid (25M = 3 negative points, halved). Two Shuttle Hub prefabs. Rival aid rocket."}
					else
						v.CustomOutcomeText = T{"Standing-target loss from aid (25M = 3 negative points). Two Shuttle Hub prefabs. Rival aid rocket."}
					end
					print("RMR distress reply shuttle")
				elseif v.DefaultCloseAction then
					if is_pol then
						v.CustomOutcomeText = T{"Political contacts halve the standing-target loss from aid (25M = 3 negative points, halved). Rival aid rocket."}
					else
						v.CustomOutcomeText = T{"Standing-target loss from aid (25M = 3 negative points). Rival aid rocket."}
					end
					print("RMR distress reply accept")
				end
			end
		end
	end
	for _, id in ipairs({
		"DistressCall_Accepted_NeutralGood_1",
		"DistressCall_Accepted_NeutralGood_2",
	}) do
		local n = N and N[id]
		for _, cond in ipairs(n and n.Prerequisites or empty_table) do
			if cond.Standing1 == "neutral" or cond.Standing2 == "good" then
				cond.Standing1 = "excellent"
				cond.Standing2 = "excellent"
				print("RMR distress gate", id, "excellent")
			end
		end
	end
	print("RMR gift texts patched", not not replies, not not drep)
end

local standing_wrapped = {}
local function WrapDistressStanding()
	local function over60(obj)
		local s = obj and obj.resources and obj.resources.standing
		return type(s) == "number" and s > 60
	end
	local function wrap_cls(name)
		if standing_wrapped[name] then
			return true
		end
		local cls = rawget(_G, name)
		if not cls then
			print("RMR wrap miss", name)
			return false
		end
		local old = cls.__eval
		if not old then
			print("RMR wrap miss", name, "__eval")
			return false
		end
		function cls:__eval(map, obj, context)
			if self.Standing == "excellent" or (self.Standing1 == "excellent" and self.Standing2 == "excellent") then
				return over60(obj)
			end
			return old(self, map, obj, context)
		end
		standing_wrapped[name] = true
		print("RMR wrap", name, "excellent>60")
		return true
	end
	wrap_cls("RivalIsStanding")
	wrap_cls("RivalIsStanding2")
end

local DistressGroupWrapped
local function WrapDistressGroup()
	if DistressGroupWrapped then
		return
	end
	local fn = rawget(_G, "CreateNegotiationStateFromGroup")
	if not fn then
		print("RMR wrap miss CreateNegotiationStateFromGroup")
		return
	end
	function CreateNegotiationStateFromGroup(group, object)
		local standing = object and object.resources and object.resources.standing
		if group == "Distress Calls (Accepted)" and type(standing) == "number" and standing <= 60 then
			print("RMR distress reject group", object.sponsor, standing)
			group = "Distress Calls (Rejected)"
		end
		local state = fn(group, object)
		if not state and group == "Distress Calls (Rejected)" then
			local make = rawget(_G, "CreateNegotiationState")
			state = make and make("DistressCall_Rejected_NeutralGood_1", object)
			print("RMR distress reject fallback", object and object.sponsor, standing)
		end
		return state
	end
	DistressGroupWrapped = true
	print("RMR wrap CreateNegotiationStateFromGroup")
end

function RMR_PatchGiftTexts()
	PatchGiftTexts()
end

function OnMsg.ModsReloaded()
	PatchGiftTexts()
	WrapDistressStanding()
	WrapDistressGroup()
end

function OnMsg.NewMapLoaded()
	PatchGiftTexts()
	WrapDistressStanding()
	WrapDistressGroup()
end

function OnMsg.LoadGame()
	PatchGiftTexts()
	WrapDistressStanding()
	WrapDistressGroup()
end
