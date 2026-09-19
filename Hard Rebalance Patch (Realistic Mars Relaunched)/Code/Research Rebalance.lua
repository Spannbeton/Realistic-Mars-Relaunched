local ToggleResearch = true

local RESEARCH_IDS = {
    "ScienceInstitute",
    "ResearchLab",
    "NetworkNode",
    "LowGLab",
}

local UG_COPY = {
    "ScienceInstitute",
    "ResearchLab",
    "NetworkNode",
}

local ResearchDescOff = {
    ScienceInstitute = T{"Generates Research."},
    ResearchLab = T{"Generates Research."},
    NetworkNode = T{"Increases the Research output of all Research buildings in its Dome."},
    LowGLab = T{"Generates Research."},
    RMR_Micro_G_Lab = T{"Radiation hardened micro-G research lab."},
}

local ResearchDescOn = {
    ScienceInstitute = T{"Generates Research. One per colony on the surface, one underground. Extra capacity belongs underground or in micro-G."},
    ResearchLab = T{"Generates Research. One per colony on the surface, one underground. Extra labs belong underground or in micro-G."},
    NetworkNode = T{"Increases Research output of all Research buildings in its Dome. One per colony on the surface, one underground."},
    LowGLab = T{"Generates Research. One per colony. Further labs belong in micro-G on asteroids."},
    RMR_Micro_G_Lab = T{"Radiation hardened micro-G research lab. Near-zero gravity makes asteroid research highly sought after and funded. This is where additional labs belong."},
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

local function SetEnv(id, env, once)
    local bt = BuildingTemplates and BuildingTemplates[id]
    local cls = rawget(_G, id)
    if bt then
        bt.disabled_in_environment = env
        bt.build_once = once
    end
    if cls then
        cls.disabled_in_environment = env
        cls.build_once = once
    end
end

local function UGName(src, src_id)
    local shown = src and src.display_name
    if _InternalTranslate and shown then
        shown = _InternalTranslate(shown)
    else
        shown = tostring(shown or src_id)
    end
    return T{shown .. " (Underground)"}
end

local function EnsureUGCopy(src_id)
    local dst_id = "RMR_" .. src_id
    local src = BuildingTemplates and BuildingTemplates[src_id]
    if not src then
        return
    end
    local dst = BuildingTemplates[dst_id]
    if not dst then
        dst = {}
        for k, v in pairs(src) do
            dst[k] = v
        end
        dst.id = dst_id
        dst.encyclopedia_id = dst_id
        dst.upgrade1_mod_label_1 = dst_id
        dst.upgrade2_mod_label_1 = dst_id
        dst.upgrade2_mod_label_2 = dst_id
        BuildingTemplates[dst_id] = dst
        rawset(_G, dst_id, dst)
    end
    local name = UGName(src, src_id)
    dst.display_name = name
    dst.display_name_pl = name
    dst.display_name_twolines = name
    dst.description = T{"Underground copy. One per colony."}
    dst.build_once = true
    dst.disabled_in_environment = set("Asteroid", "Surface")
end

local function ApplyResearchDesc()
    if not BuildingTemplates then
        return
    end
    for _, id in ipairs(RESEARCH_IDS) do
        if ToggleResearch then
            SetBldDesc(id, ResearchDescOn[id])
        else
            SetBldDesc(id, ResearchDescOff[id])
        end
    end
    if ToggleResearch then
        SetBldDesc("RMR_Micro_G_Lab", ResearchDescOn.RMR_Micro_G_Lab)
    else
        SetBldDesc("RMR_Micro_G_Lab", ResearchDescOff.RMR_Micro_G_Lab)
    end
end

local function ApplyResearchOnce()
    if not BuildingTemplates then
        return
    end
    for _, id in ipairs(RESEARCH_IDS) do
        local bt = BuildingTemplates[id]
        if bt then
            bt.build_once = ToggleResearch and true or false
        end
    end
    if ToggleResearch then
        SetEnv("ScienceInstitute", set("Asteroid", "Underground"), true)
        SetEnv("ResearchLab", set("Asteroid", "Underground"), true)
        SetEnv("NetworkNode", set("Asteroid", "Underground"), true)
        for _, id in ipairs(UG_COPY) do
            EnsureUGCopy(id)
        end
    else
        SetEnv("ScienceInstitute", set("Asteroid"), false)
        SetEnv("ResearchLab", set("Asteroid"), false)
        SetEnv("NetworkNode", set("Asteroid"), false)
        SetEnv("RMR_ScienceInstitute", set("Asteroid", "Surface", "Underground"), false)
        SetEnv("RMR_ResearchLab", set("Asteroid", "Surface", "Underground"), false)
        SetEnv("RMR_NetworkNode", set("Asteroid", "Surface", "Underground"), false)
    end
    ApplyResearchDesc()
end

function OnMsg.ModsReloaded()
    if CurrentModOptions then
        ToggleResearch = CurrentModOptions:GetProperty("Research_Rebalance")
    end
    ApplyResearchOnce()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        Msg("ModsReloaded")
    end
end

function OnMsg.LoadGame()
    Msg("ModsReloaded")
end

function OnMsg.NewMapLoaded()
    Msg("ModsReloaded")
end