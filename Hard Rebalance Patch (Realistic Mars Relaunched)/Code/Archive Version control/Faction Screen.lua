print("RMR faction screen lua loaded")

local KeepSponsorInAssembly = {
    ChurchOfTheNewArk = true,
    InterplanetaryCodex = true,
    AssemblyOfPlanets = true,
}

local function EnsureCardClass()
    if rawget(_G, "RMRFactionCard") then
        return
    end
    local define = rawget(_G, "DefineClass")
    if not define or not FactionCard then
        return
    end
    define("RMRFactionCard", {
        __parents = { "FactionCard" },
    })
    print("RMR faction screen card class")
end

local function FactionSortName(id)
    local def = FactionDefs and FactionDefs[id]
    if not def then
        return tostring(id)
    end
    local name = def.display_name
    if _InternalTranslate and name then
        return _InternalTranslate(name)
    end
    return tostring(name or id)
end

local function CollectFactionIds(kind)
    local ids = {}
    if not ForEachPreset then
        print("RMR faction screen miss ForEachPreset")
        return ids
    end
    ForEachPreset("FactionDef", function(faction)
        if not faction or not faction.id then
            return
        end
        if kind == "mars" then
            if faction.is_sponsor and not KeepSponsorInAssembly[faction.id] then
                return
            end
        elseif kind == "earth" then
            if not faction.is_sponsor then
                return
            end
        end
        local ok, allowed = true, true
        if faction.filter then
            ok, allowed = pcall(function()
                return faction:filter()
            end)
            if not ok then
                print("RMR faction screen filter err", faction.id, allowed)
                allowed = true
            end
        end
        if allowed then
            ids[#ids + 1] = faction.id
        end
    end)
    table.sort(ids, function(a, b)
        local na, nb = FactionSortName(a), FactionSortName(b)
        if na ~= nb then
            return na < nb
        end
        return tostring(a) < tostring(b)
    end)
    print("RMR faction screen ids", kind, #ids)
    return ids
end

local function FillCard(child, item, holder, counts)
    local def = FactionDefs[item]
    if not def then
        print("RMR faction screen miss def", item)
        return
    end
    child.idName:SetText(def.display_name)
    if def.icon then
        child.idImage:SetImage(def.icon)
    end
    if holder and holder.GetFactionApprovalText then
        local status_text, color = holder:GetFactionApprovalText(item)
        if status_text then
            child.idStatusText:SetText(status_text)
        end
        if color then
            child.idStatusText:SetTextColor(color)
        end
    end
    local disaster = holder and holder.factions_disaster and holder.factions_disaster[item]
    disaster = disaster and not IsKindOf(disaster, "FactionDisaster_None")
    child.idStatusImage:SetVisible(not not disaster)
    local n = counts and counts[item] or 0
    child.idSeatsNumber:SetText(n)
    local label = child.idSeatsNumber.parent and child.idSeatsNumber.parent[2]
    if label and label.SetText then
        label:SetText(Untranslated("SUPPORTERS"))
    end
end

local function SelectCustomTab(dlg, mode)
    if not dlg or not dlg.idContent then
        print("RMR faction screen select miss dlg")
        return
    end
    local first = dlg.idContent:ResolveId("idTitle")
    local second = dlg.idContent:ResolveId("idSubTitle")
    local mars = dlg.idContent:ResolveId("idRMRAllFactions")
    local earth = dlg.idContent:ResolveId("idRMREarthFactions")
    local on_mars = mode == "allfactions"
    local on_earth = mode == "earthfactions"
    print("RMR faction screen select", mode, not not first, not not mars, not not earth)
    local function style_tab(tab, on)
        if not tab then
            return
        end
        if tab.idSelected then
            tab.idSelected:SetVisible(on)
        end
        if tab.idTextButton then
            tab.idTextButton:SetTextStyle(on and "FactionsTitle2Selected" or "FactionsTitle2")
        end
        tab:SetRolloverActive(not on)
    end
    style_tab(mars, on_mars)
    style_tab(earth, on_earth)
    if on_mars or on_earth then
        style_tab(first, false)
        style_tab(second, false)
    end
end

local function EnsureAllFactionsMode(dlg)
    if not dlg then
        print("RMR faction screen ensure miss dlg")
        return
    end
    dlg.InternalModes = "overview,laws,allfactions,earthfactions"
    if PoliticsDlg then
        PoliticsDlg.InternalModes = "overview,laws,allfactions,earthfactions"
    end
    print("RMR faction screen modes", dlg.InternalModes, dlg.Mode)
end

local function ModeContent(dlg)
    return dlg and dlg.idContent and dlg.idContent:ResolveId("idModeContent")
end

local function FindById(win, id)
    if not win then
        return
    end
    if win.Id == id then
        return win
    end
    for _, child in ipairs(win) do
        local found = FindById(child, id)
        if found then
            return found
        end
    end
end

local function FindNamedPage(dlg, id)
    if not dlg then
        return
    end
    if dlg.ResolveId then
        local page = dlg:ResolveId(id)
        if page then
            return page
        end
    end
    local content = ModeContent(dlg)
    if content then
        if content.ResolveId then
            local page = content:ResolveId(id)
            if page then
                return page
            end
        end
        local page = FindById(content, id)
        if page then
            return page
        end
        if content.parent then
            return FindById(content.parent, id)
        end
    end
end

local function DeleteCustomPages(dlg)
    local mars = FindNamedPage(dlg, "idRMRAllFactionsPage")
    if mars then
        print("RMR faction screen delete mars")
        mars:delete()
    end
    local earth = FindNamedPage(dlg, "idRMREarthFactionsPage")
    if earth then
        print("RMR faction screen delete earth")
        earth:delete()
    end
end

local function OpenIfNeeded(win)
    if not win then
        return
    end
    local state = rawget(win, "window_state")
    if state ~= "open" and win.Open then
        win:Open()
    end
end

local function SpawnFactionGrid(dlg, opts)
    print("RMR faction screen spawn begin", opts.id, dlg and dlg.Mode)
    if not dlg then
        return
    end
    if FindNamedPage(dlg, opts.id) then
        print("RMR faction screen spawn exists", opts.id)
        return
    end
    local content = ModeContent(dlg)
    local parent = content and content.parent
    if not parent then
        print("RMR faction screen spawn miss parent")
        return
    end
    EnsureCardClass()
    local card_class = rawget(_G, "RMRFactionCard") or FactionCard
    if not card_class then
        print("RMR faction screen miss FactionCard")
        return
    end
    local ids = CollectFactionIds(opts.kind)
    local n = #ids
    local cols = opts.cols
    local per = opts.per
    local cap = cols * per
    if n > cap then
        n = cap
    end
    local holder = rawget(_G, "g_FactionsHolder")
    local counts = {}
    if holder and holder.GetColonyFactionsSupport then
        local _, support = holder:GetColonyFactionsSupport()
        counts = support or {}
    end
    print("RMR faction screen holder", not not holder, "per", per, "n", n, "cols", cols)
    local width = cols * 518 + (cols - 1) * 12
    local row = XWindow:new({
        Id = opts.id,
        IdNode = true,
        Dock = "box",
        HAlign = "center",
        VAlign = "center",
        MinWidth = width,
        MinHeight = 600,
        LayoutMethod = "HPanel",
    }, parent, dlg.context)
    OpenIfNeeded(row)
    local spawned = 0
    for c = 1, cols do
        local list = XWindow:new({
            Id = opts.col_id .. c,
            Dock = "left",
            MinWidth = 518,
            MaxWidth = 518,
            MinHeight = 600,
            Margins = box(0, 0, c < cols and 12 or 0, 0),
            LayoutMethod = "VList",
            OnDelete = function()
                if CloseFactionCardInfo then
                    CloseFactionCardInfo()
                end
            end,
        }, row, dlg.context)
        OpenIfNeeded(list)
        local first = (c - 1) * per + 1
        local last = Min(c * per, n)
        print("RMR faction screen col", opts.kind, c, first, last)
        for i = first, last do
            local item = ids[i]
            local ok, err = pcall(function()
                local child = card_class:new({
                    MinWidth = 518,
                    MaxWidth = 518,
                    MinHeight = 124,
                }, list, item)
                OpenIfNeeded(child)
                FillCard(child, item, holder, counts)
            end)
            if ok then
                spawned = spawned + 1
            else
                print("RMR faction screen card err", item, err)
            end
        end
    end
    if parent.InvalidateMeasure then
        parent:InvalidateMeasure()
    end
    if parent.InvalidateLayout then
        parent:InvalidateLayout()
    end
    print("RMR faction screen page", opts.kind, n, "cards", spawned)
end

local function SetModeActions(dlg, on)
    if not dlg then
        return
    end
    local function apply(action)
        if not action then
            return
        end
        local id = action.ActionId
        if id ~= "close" and id ~= "choose law" then
            return
        end
        if on then
            if not action.RMR_SavedActionState then
                action.RMR_SavedActionState = action.ActionState
            end
            action.ActionState = function()
                return "hidden"
            end
        elseif action.RMR_SavedActionState ~= nil then
            action.ActionState = action.RMR_SavedActionState
            action.RMR_SavedActionState = nil
        end
    end
    if dlg.actions then
        for _, action in ipairs(dlg.actions) do
            apply(action)
        end
    end
    for _, child in ipairs(dlg) do
        apply(child)
    end
    if dlg.GetActions then
        local list = dlg:GetActions()
        if list then
            for _, action in ipairs(list) do
                apply(action)
            end
        end
    end
    if dlg.UpdateActionViews and dlg.idActionBar then
        dlg:UpdateActionViews(dlg.idActionBar)
    end
    local bar = dlg.idActionBar
    if bar then
        for _, btn in ipairs(bar) do
            local action = btn.action or rawget(btn, "Action")
            local id = btn.ActionId or (action and action.ActionId)
            if on and (id == "close" or id == "choose law") then
                btn:SetVisible(false)
            end
        end
    end
    print("RMR faction screen mode actions", on)
end

local function SetCustomLayout(dlg, on)
    local header = dlg and dlg:ResolveId("idCouncilHeader")
    local right = header and header.parent
    print("RMR faction screen layout", on, right and right.class)
    if header then
        header:SetVisible(not on)
    end
    if right then
        right.FoldWhenHidden = true
        right:SetVisible(not on)
        right.Dock = on and false or "right"
        right.HAlign = on and "right" or "left"
        right.VAlign = "top"
        right.DrawOnTop = false
    end
    if dlg.idRightWindow then
        dlg.idRightWindow:SetVisible(not on)
    end
    local content = ModeContent(dlg)
    if content then
        content:SetVisible(not on)
        content.FoldWhenHidden = true
    end
    local left = content and content.parent
    if left then
        left.MinWidth = on and 1600 or 1100
    end
    SetModeActions(dlg, on)
end

local function InjectCloseAction(dlg)
    if not dlg then
        return
    end
    for _, child in ipairs(dlg) do
        if child.ActionId == "RMR_AllFactionsClose" then
            return
        end
    end
    XAction:new({
        ActionId = "RMR_AllFactionsClose",
        ActionName = T{"CLOSE"},
        ActionToolbar = "ActionBar",
        ActionShortcut = "Escape",
        ActionGamepad = "ButtonB",
        ActionState = function(self, host)
            return (host.Mode == "allfactions" or host.Mode == "earthfactions") and "enabled" or "hidden"
        end,
        OnActionEffect = "close",
        FXPress = "PoliticsUI_Close",
    }, dlg, dlg.context)
end

local function InjectTab(dlg, spec)
    if dlg.idContent:ResolveId(spec.id) or dlg:ResolveId(spec.id) then
        print("RMR faction screen tab exists", spec.id)
        return
    end
    if not TitlePartButton then
        print("RMR faction screen miss TitlePartButton")
        return
    end
    local sub = dlg.idContent:ResolveId("idSubTitle")
    if not sub or not sub.parent then
        print("RMR faction screen miss title")
        return
    end
    local row = sub.parent
    TitlePartButton:new({
        Id = spec.id,
        Dock = false,
        Title = spec.title,
        OnPress = function(self)
            TitlePartButton.OnPress(self)
            PlayFX("PoliticsUI_Select_LawPolicy", "start")
            local host = GetDialog(self)
            EnsureAllFactionsMode(host)
            if host then
                host:SetMode(spec.mode)
            end
        end,
    }, row, dlg.context)
    sub:SetParent(nil)
    sub:SetParent(row)
    print("RMR faction screen tab", spec.id)
end

local function InjectAllFactionsTab(dlg)
    if not dlg or not dlg.idContent then
        print("RMR faction screen miss PoliticsDlg")
        return
    end
    EnsureAllFactionsMode(dlg)
    InjectCloseAction(dlg)
    local first = dlg.idContent:ResolveId("idTitle")
    if first then
        if first.SetTitle then
            first:SetTitle(T{"GOVERNMENT"})
        else
            first.Title = T{"GOVERNMENT"}
        end
        if first.idTextButton and first.idTextButton.SetText then
            first.idTextButton:SetText(T{"GOVERNMENT"})
        end
    end
    InjectTab(dlg, {
        id = "idRMRAllFactions",
        title = T{"MARS FACTIONS"},
        mode = "allfactions",
    })
    InjectTab(dlg, {
        id = "idRMREarthFactions",
        title = T{"EARTH FACTIONS"},
        mode = "earthfactions",
    })
end

local OrigModeChange
local WrappedModeChange

local function WrapPoliticsDlg()
    if not PoliticsDlg then
        print("RMR faction screen miss PoliticsDlg class")
        return
    end
    EnsureCardClass()
    EnsureAllFactionsMode(PoliticsDlg)
    if PoliticsDlg.OnDialogModeChange ~= WrappedModeChange then
        OrigModeChange = PoliticsDlg.OnDialogModeChange
        WrappedModeChange = function(self, mode, dialog)
            print("RMR faction screen mode change", mode)
            if CloseFactionCardInfo then
                CloseFactionCardInfo()
            end
            DeleteCustomPages(self)
            local ok_orig, err_orig = pcall(OrigModeChange, self, mode, dialog)
            if not ok_orig then
                print("RMR faction screen orig err", err_orig)
            end
            local on = mode == "allfactions" or mode == "earthfactions"
            SelectCustomTab(self, mode)
            pcall(SetCustomLayout, self, on)
            if mode == "allfactions" then
                pcall(SpawnFactionGrid, self, {
                    id = "idRMRAllFactionsPage",
                    col_id = "idRMRFactionCol",
                    kind = "mars",
                    cols = 3,
                    per = 6,
                })
            elseif mode == "earthfactions" then
                pcall(SpawnFactionGrid, self, {
                    id = "idRMREarthFactionsPage",
                    col_id = "idRMREarthCol",
                    kind = "earth",
                    cols = 2,
                    per = 7,
                })
            end
            if on and CreateRealTimeThread then
                CreateRealTimeThread(function()
                    if self.Mode == "allfactions" then
                        pcall(SpawnFactionGrid, self, {
                            id = "idRMRAllFactionsPage",
                            col_id = "idRMRFactionCol",
                            kind = "mars",
                            cols = 3,
                            per = 6,
                        })
                    elseif self.Mode == "earthfactions" then
                        pcall(SpawnFactionGrid, self, {
                            id = "idRMREarthFactionsPage",
                            col_id = "idRMREarthCol",
                            kind = "earth",
                            cols = 2,
                            per = 7,
                        })
                    end
                    if self.UpdateActionViews and self.idActionBar then
                        self:UpdateActionViews(self.idActionBar)
                    end
                end)
            end
        end
        PoliticsDlg.OnDialogModeChange = WrappedModeChange
        print("RMR faction screen wrap mode")
    end
end

function OpenRMRAllFactions()
    WrapPoliticsDlg()
    local dlg = GetDialog("PoliticsDlg")
    if dlg then
        EnsureAllFactionsMode(dlg)
        dlg:SetMode("allfactions")
        return dlg
    end
    if not OpenElections then
        return
    end
    return OpenElections(nil, "allfactions")
end

function OnMsg.ModsReloaded()
    WrapPoliticsDlg()
end

function OnMsg.ClassesBuilt()
    WrapPoliticsDlg()
end

function OnMsg.OpenPoliticsDlg()
    WrapPoliticsDlg()
    InjectAllFactionsTab(GetDialog("PoliticsDlg"))
end