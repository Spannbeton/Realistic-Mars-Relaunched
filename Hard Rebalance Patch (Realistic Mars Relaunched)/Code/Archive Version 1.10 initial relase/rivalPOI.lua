local Wrapped = {}

local function FormatStanding(id)
	local rival = RivalAIs and RivalAIs[id]
	local cur = rival and rival.resources and rival.resources.standing
	if type(cur) ~= "number" then
		return
	end
	cur = floatfloor(cur)
	local fn = rawget(_G, "RMR_TargetStanding")
	if not fn then
		print("RMR poi target miss fn", id, "cur", cur)
		return T{"<name> (<cur>) Target (?)", name = (rawget(_G, "GetStandingText") and GetStandingText(cur) or ""), cur = cur}
	end
	local tgt, appr, rel, extra = fn(id)
	if type(tgt) ~= "number" then
		print("RMR poi target miss num", id, tgt)
		return
	end
	tgt = floatfloor(tgt)
	print("RMR poi target", id, "cur", cur, "target", tgt, "appr", appr, "rel", rel, "gift", extra)
	local stfn = rawget(_G, "GetStandingText")
	local name = stfn and stfn(cur) or ""
	return T{"<name> (<cur>) Target (<tgt>)", name = name, cur = cur, tgt = tgt}
end

local function ApplyStandingUI(context)
	local spot = context and context.selected_spot
	if not spot or spot.spot_type ~= "rival" then
		return
	end
	local text = FormatStanding(spot.id)
	if not text then
		return
	end
	local dlg = GetDialog("PlanetaryView")
	local txt = dlg and dlg:ResolveId("idStanding")
	if txt and txt.SetText then
		txt:SetText(text)
	else
		print("RMR poi standing miss control", spot.id)
	end
end

local function Walk(win, fn)
	if type(win) ~= "table" then
		return
	end
	fn(win)
	if win.GetChildCount and win.GetChild then
		for i = 1, win:GetChildCount() do
			Walk(win:GetChild(i), fn)
		end
		return
	end
	for _, child in ipairs(win) do
		Walk(child, fn)
	end
end

local function RenameRecentActions(root)
	if not root then
		return
	end
	Walk(root, function(win)
		if IsKindOf(win, "DialogTitleSmall") then
			if win.SetFoldWhenHidden then
				win:SetFoldWhenHidden(true)
			end
			if win.SetVisible then
				win:SetVisible(false)
			end
			if win.SetMaxHeight then
				win:SetMaxHeight(0)
			end
			print("RMR poi title hide")
		end
		if win.Id == "idActionsArea" or (win.GetId and win:GetId() == "idActionsArea") then
			if win.SetMargins then
				win:SetMargins(box(0, 0, 0, 0))
			end
			if win.SetPadding then
				win:SetPadding(box(0, 0, 0, 0))
			end
			local parent = win.parent or (win.GetParent and win:GetParent())
			if parent and parent.SetMargins then
				parent:SetMargins(box(30, 0, 0, 0))
				if parent.SetPadding then
					parent:SetPadding(box(0, 0, 0, 0))
				end
			end
			Walk(win, function(child)
				if IsKindOf(child, "XText") then
					if child.SetPadding then
						child:SetPadding(box(0, 0, 0, 0))
					end
					if child.SetMargins then
						child:SetMargins(box(0, 0, 0, 0))
					end
					if child.SetTextHAlign then
						child:SetTextHAlign("left")
					end
				end
			end)
			print("RMR poi politics align")
		end
	end)
end

local function PatchPOIPanel(context)
	ApplyStandingUI(context)
	local dlg = GetDialog("PlanetaryView")
	local poi = dlg and dlg:ResolveId("idPOIAdditionalContent")
	RenameRecentActions(poi or dlg)
end

local function PoliticsLog(context)
	local spot = context and context.selected_spot
	if not spot or spot.spot_type ~= "rival" then
		return T{""}
	end
	local fac_fn = rawget(_G, "RMR_RivalFaction")
	local fid = fac_fn and fac_fn(spot.id)
	if not fid then
		print("RMR poi politics miss faction", spot.id)
		return T{""}
	end
	local holder = rawget(_G, "g_FactionsHolder")
	local data = holder and holder.GetFactionLikeData and holder:GetFactionLikeData(fid)
	if not data then
		print("RMR poi politics miss likes", spot.id, fid)
		return T{""}
	end
	local green = {}
	local red = {}
	for _, e in ipairs(data) do
		if e.how_to then
			green[#green + 1] = e.how_to
		elseif type(e.value) == "number" and e.value < 0 then
			red[#red + 1] = e
		end
	end
	table.sort(red, function(a, b)
		return a.value < b.value
	end)
	local lines = {}
	lines[#lines + 1] = T{"<style PGSponsorInfo>Approves/Disapproves</style>"}
	for _, text in ipairs(green) do
		if text then
			lines[#lines + 1] = T{"<color 80 180 80><text></color>", text = text}
		end
	end
	lines[#lines + 1] = T{"<color 80 180 80>Gift Resources</color>"}
	if #red > 0 then
		for _, e in ipairs(red) do
			if e.text then
				lines[#lines + 1] = T{"<color 200 80 80><text></color>", text = e.text}
			end
		end
	end
	print("RMR poi politics", spot.id, fid, "green", #green, "red", #red)
	local tlist = rawget(_G, "TList")
	if tlist then
		return tlist(lines, "\n")
	end
	return lines[1] or T{""}
end

local function WrapClass(name)
	local cls = rawget(_G, name)
	if not cls then
		print("RMR poi wrap miss class", name)
		return
	end
	if cls.SetUIResourceValues and not Wrapped[name .. ".SetUIResourceValues"] then
		local old = cls.SetUIResourceValues
		function cls:SetUIResourceValues(...)
			local result = old(self, ...)
			PatchPOIPanel(self)
			return result
		end
		Wrapped[name .. ".SetUIResourceValues"] = true
		print("RMR poi wrap", name, "SetUIResourceValues")
	end
	if cls.ShowContent and not Wrapped[name .. ".ShowContent"] then
		local old = cls.ShowContent
		function cls:ShowContent(...)
			local result = old(self, ...)
			PatchPOIPanel(self)
			return result
		end
		Wrapped[name .. ".ShowContent"] = true
		print("RMR poi wrap", name, "ShowContent")
	end
	if cls.Open and not Wrapped[name .. ".Open"] then
		local old = cls.Open
		function cls:Open(...)
			local result = old(self, ...)
			PatchPOIPanel(self)
			RenameRecentActions(self)
			return result
		end
		Wrapped[name .. ".Open"] = true
		print("RMR poi wrap", name, "Open")
	end
	if cls.GetAILog and not Wrapped[name .. ".GetAILog"] then
		function cls:GetAILog()
			return PoliticsLog(self)
		end
		Wrapped[name .. ".GetAILog"] = true
		print("RMR poi wrap", name, "GetAILog")
	end
	if cls.RivalSelectedHasLog and not Wrapped[name .. ".RivalSelectedHasLog"] then
		function cls:RivalSelectedHasLog()
			local spot = self.selected_spot
			return spot and spot.spot_type == "rival"
		end
		Wrapped[name .. ".RivalSelectedHasLog"] = true
		print("RMR poi wrap", name, "RivalSelectedHasLog")
	end
end

function WrapPOI()
	WrapClass("LandingSiteObject")
	WrapClass("POIAdditionalContent")
	WrapClass("PlanetaryViewResources")
end

function OnMsg.ModsReloaded()
	WrapPOI()
end

function OnMsg.NewMapLoaded()
	WrapPOI()
end

function OnMsg.LoadGame()
	WrapPOI()
end
