local wf_period = 32
local wf_min_prod = 40
local wf_amplitude = 60
local wf_gusts = 20
local last_hour = -1
local gust = 0
local ToggleWind = true
local wind_factor = 1.0

local WindIds = { "WindTurbine", "WindTurbine_Large", "WindTurbine_Diffuser" }

local WindDescOff = {
    WindTurbine = T{"Generates Power. Increased production during Dust Storms and at high elevations."},
    WindTurbine_Large = T{"Generates Power. Increased production during Dust Storms and at high elevations."},
    WindTurbine_Diffuser = T{"Generates Power. Increased production during Dust Storms and at high elevations."},
}

local WindDescOn = {
    WindTurbine = T{"Generates Power. Increased production during Dust Storms and at high elevations. Output varies over time with wind strength and occasional gusts."},
    WindTurbine_Large = T{"Generates Power. Increased production during Dust Storms and at high elevations. Output varies over time with wind strength and occasional gusts."},
    WindTurbine_Diffuser = T{"Generates Power. Increased production during Dust Storms and at high elevations. Output varies over time with wind strength and occasional gusts."},
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

local function ApplyWindDesc()
    if not BuildingTemplates then
        return
    end
    for _, id in ipairs(WindIds) do
        if ToggleWind then
            SetBldDesc(id, WindDescOn[id])
        else
            SetBldDesc(id, WindDescOff[id])
        end
    end
end

local function GetWindFactor()
    if not ToggleWind or wf_period == 0 then
        return 1.0
    end
    local hour = floatfloor(GameTime() / const.HourDuration)
    if hour == last_hour then
        return wind_factor
    end
    last_hour = hour
    gust = InteractionRand(wf_gusts + 1, "RMRWind")
    wind_factor = (
        ((sin((360 * 60 * GameTime()) / (wf_period * const.HourDuration)) / 4096.0) + 1)
            * wf_amplitude / 100.0
        + wf_min_prod / 100.0
    ) * (1 + gust / 100)
    return wind_factor
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
        print("RMR UI wind wrap skip, no sectionPowerProduction")
        return
    end

    RMR_PowerUI = rawget(_G, "RMR_PowerUI") or {}
    RMR_PowerUI.hooks = RMR_PowerUI.hooks or {}

    RMR_PowerUI.hooks.wind = function(section, context, content)
        if not ToggleWind then
            return
        end
        if not Kind(context, "WindTurbineBase") then
            return
        end
        InfopanelText:new({
            Text = T{"Wind Speed<right><percent(RMRWindSpeed)>"},
        }, content, context)
    end

    if RMR_PowerUI.wrapped then
        print("RMR UI wind wrap callback refreshed")
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
    print("RMR UI wind wrapped sectionPowerProduction.Init")
end

function OnMsg.ClassesGenerate()
    ApplyWindDesc()
end

function OnMsg.ClassesPostprocess()
    EnsurePowerSectionWrap()
end

function OnMsg.ModsReloaded()
    if CurrentModOptions then
        ToggleWind = CurrentModOptions:GetProperty("Wind_Rebalance")
        wf_gusts = CurrentModOptions:GetProperty("Wind_Gusts") or 20
        wf_period = CurrentModOptions:GetProperty("Wind_Periodicity") or 32
        wf_min_prod = CurrentModOptions:GetProperty("Wind_Minimum") or 30
        wf_amplitude = CurrentModOptions:GetProperty("Wind_Amplitude") or 50
    end
    ApplyWindDesc()
    EnsurePowerSectionWrap()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        Msg("ModsReloaded")
    end
end

function OnMsg.NewMapLoaded()
    ApplyWindDesc()
end

function OnMsg.LoadGame()
    ApplyWindDesc()
end

function WindTurbineBase:CalcProduction(...)
    local elevation_bonus = self:GetElevationBonus()
    local production_bonus = 100 + (elevation_bonus - 50)
    if g_DustStorm then
        if g_DustStorm.type == "great" then
            production_bonus = production_bonus + self.great_dust_storm_bonus_percent
        else
            production_bonus = production_bonus + self.dust_storm_bonus_percent
        end
    end

    local wind_fluctuation = GetWindFactor() * self:GetClassValue("electricity_production")

    if self.SetAnimSpeedModifier then
        self:SetAnimSpeedModifier(Min(floatfloor((300 + 3 * production_bonus) * wind_fluctuation), 1100))
    end
    self:SetBase("electricity_production", MulDivRound(50 + production_bonus, floatfloor(wind_fluctuation), 100))
    self:UpdateWorking()
    if SelectedObj == self then
        RebuildInfopanel(self)
    end
end

function WindTurbineBase:GetRMRWindSpeed()
    if not ToggleWind then
        return 0
    end
    return floatfloor((GetWindFactor() or 1) * 100)
end