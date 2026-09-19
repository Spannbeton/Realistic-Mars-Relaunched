local ToggleSPD = true
local BaseMultiplier = 100
local DustPercent = 50

local SolarIds = { "SolarPanel", "SolarPanelBig", "SolarArray" }

local SolarDescOff = {
    SolarPanel = T{"Generates Power during daytime. Closes during Dust Storms. Protected from dust while turned off."},
    SolarPanelBig = T{"Generates Power during daytime. Closes during Dust Storms. Protected from dust while turned off."},
    SolarArray = T{"An advanced solar array that generates Power during daytime. Does not produce Power during Dust Storms. Requires less maintenance than regular Solar Panels, but can't be closed."},
}

local SolarDescOn = {
    SolarPanel = T{"Generates Power during daytime. Closes during Dust Storms. Protected from dust while turned off. Dust buildup reduces Power output."},
    SolarPanelBig = T{"Generates Power during daytime. Closes during Dust Storms. Protected from dust while turned off. Dust buildup reduces Power output."},
    SolarArray = T{"An advanced solar array that generates Power during daytime. Does not produce Power during Dust Storms. Requires less maintenance than regular Solar Panels, but can't be closed. Dust buildup reduces Power output."},
}

local function SetBldDesc(id, desc)
    local bt = BuildingTemplates and BuildingTemplates[id]
    local cls = rawget(_G, id)
    if bt and desc then
        bt.description = desc
    end
    if cls and desc then
        cls.description = desc
    end
end

local function ApplySolarDesc()
    if not BuildingTemplates then
        return
    end
    for _, id in ipairs(SolarIds) do
        if ToggleSPD then
            SetBldDesc(id, SolarDescOn[id])
        else
            SetBldDesc(id, SolarDescOff[id])
        end
    end
end

local function Kind(context, name)
    local fn = rawget(_G, "IsContextOfKind")
    if type(fn) == "function" then
        return fn(context, name)
    end
    return IsKindOf(context, name)
end

local function EnsurePowerSectionWrap()
    local cls = rawget(_G, "sectionPowerProduction")
    if type(cls) ~= "table" or type(cls.Init) ~= "function" then
        print("RMR UI solar wrap skip, no sectionPowerProduction")
        return
    end

    RMR_PowerUI = rawget(_G, "RMR_PowerUI") or {}
    RMR_PowerUI.hooks = RMR_PowerUI.hooks or {}

    RMR_PowerUI.hooks.solar = function(section, context, content)
        if not ToggleSPD then
            return
        end
        if not Kind(context, "SolarPanelCommon") and not Kind(context, "SolarPanelBase") then
            return
        end
        InfopanelText:new({
            Text = T{"Dust Penalty<right>-<percent(RMRDustPenalty)>"},
        }, content, context)
    end

    if RMR_PowerUI.wrapped then
        print("RMR UI solar wrap callback refreshed")
        return
    end

    RMR_PowerUI.orig_init = cls.Init
    function cls:Init(parent, context)
        RMR_PowerUI.orig_init(self, parent, context)
        if not context then
            return
        end
        local content = InfopanelSection.__content(self, context)
        if not content then
            return
        end
        local hooks = RMR_PowerUI.hooks
        if hooks.solar then
            hooks.solar(self, context, content)
        end
        if hooks.wind then
            hooks.wind(self, context, content)
        end
    end
    RMR_PowerUI.wrapped = true
    print("RMR UI solar wrapped sectionPowerProduction.Init")
end

function OnMsg.ClassesGenerate()
    ApplySolarDesc()
end

function OnMsg.ClassesPostprocess()
    EnsurePowerSectionWrap()
end

function OnMsg.ModsReloaded()
    if CurrentModOptions then
        ToggleSPD = CurrentModOptions:GetProperty("Solar_Rebalance")
        local bm = CurrentModOptions:GetProperty("Solar_BaseMult")
        local dp = CurrentModOptions:GetProperty("Power_Loss")
        if bm ~= nil then
            BaseMultiplier = bm
        end
        if dp ~= nil then
            DustPercent = dp
        end
    end
    ApplySolarDesc()
    EnsurePowerSectionWrap()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        Msg("ModsReloaded")
    end
end

function OnMsg.NewMapLoaded()
    ApplySolarDesc()
end

function OnMsg.LoadGame()
    ApplySolarDesc()
end

function SolarPanelBase:UpdateProduction(...)
    local new_base_production = self:CanBeOpened() and self:GetClassValue("electricity_production") or 0
    if ToggleSPD then
        local th = self.maintenance_threshold_current or 0
        local acc = self.accumulated_maintenance_points or 0
        local loss = 0
        if th > 0 and DustPercent > 0 then
            loss = MulDivRound(acc, DustPercent, th)
            if loss > DustPercent then
                loss = DustPercent
            end
        end
        local DustPenaltyMultiplier = 1000 - loss * 10
        local produced = MulDivRound(new_base_production, BaseMultiplier, 100)
        produced = MulDivRound(produced, DustPenaltyMultiplier, 1000)
        self:UpdateCounterAtmosphereModifier()
        if self.base_electricity_production ~= produced then
            self:SetBase("electricity_production", produced)
            RebuildInfopanel(self)
        end
    else
        self:UpdateCounterAtmosphereModifier()
        if self.base_electricity_production ~= new_base_production then
            self:SetBase("electricity_production", new_base_production)
            RebuildInfopanel(self)
        end
    end
end

function SolarPanelBase:GetRMRDustPenalty()
    if not ToggleSPD then
        return 0
    end
    local th = self.maintenance_threshold_current
    if not th or th <= 0 then
        return 0
    end
    local loss = MulDivRound(self.accumulated_maintenance_points or 0, DustPercent, th)
    if loss > DustPercent then
        loss = DustPercent
    end
    return loss
end