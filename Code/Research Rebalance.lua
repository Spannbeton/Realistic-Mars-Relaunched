local ToggleResearch = true

local RESEARCH_IDS = {
    "ScienceInstitute",
    "ResearchLab",
    "NetworkNode",
    "LowGLab",
}

local UG_COPY = {
    ScienceInstitute = "RMR_BaseScienceInstitute",
    ResearchLab = "RMR_BaseResearchLab",
    NetworkNode = "RMR_NetworkNodeBase",
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

local function UGName(src, src_id)
    local shown = src_id
    local n = src and src.display_name
    if type(n) == "string" then
        shown = n
    elseif type(n) == "table" then
        if type(n[1]) == "string" then
            shown = n[1]
        elseif type(n[2]) == "string" then
            shown = n[2]
        end
    end
    return T{shown .. " (Underground)"}
end

local function CopyClassDef(src, base)
    local dst = {}
    for k, v in pairs(src) do
        dst[k] = v
    end
    dst.__parents = { base }
    dst.object_class = base
    dst.persist_baseclass = base
    dst.__generated_by_class = "BuildingTemplate"
    dst.build_once = true
    dst.disabled_in_environment = set("Asteroid", "Surface")
    return dst
end

local function RegisterUGTemplates()
    if not BuildingTemplates then
        return
    end
    for src_id, _ in pairs(UG_COPY) do
        local dst_id = "RMR_" .. src_id
        local cls = rawget(_G, dst_id)
        if cls then
            BuildingTemplates[dst_id] = cls
            if BuildingTemplatesPresets and BuildingTemplatesPresets[src_id] then
                BuildingTemplatesPresets[dst_id] = BuildingTemplatesPresets[src_id]
            end
            if BuildingTechRequirements and BuildingTechRequirements[src_id] then
                BuildingTechRequirements[dst_id] = BuildingTechRequirements[src_id]
            end
            print("RMR research register", dst_id, cls.build_category, BuildingTechRequirements and BuildingTechRequirements[dst_id] and true)
        end
    end
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
        for src_id, _ in pairs(UG_COPY) do
            local dst_id = "RMR_" .. src_id
            local src = BuildingTemplates[src_id]
            local dst = BuildingTemplates[dst_id]
            if dst then
                local name = UGName(src, src_id)
                dst.display_name = name
                dst.display_name_pl = name
                dst.display_name_twolines = name
                dst.description = T{"Underground copy. One per colony."}
            end
        end
    else
        SetBldDesc("RMR_Micro_G_Lab", ResearchDescOff.RMR_Micro_G_Lab)
    end
end

local function ApplyResearchOnce()
    if not BuildingTemplates then
        return
    end
    RegisterUGTemplates()
    for _, id in ipairs(RESEARCH_IDS) do
        local bt = BuildingTemplates[id]
        if bt then
            bt.build_once = ToggleResearch and true or false
        end
    end
    if type(DisabledInEnvironment) == "table" then
        if ToggleResearch then
            DisableInEnvironment("ScienceInstitute", "Underground", "Asteroid")
            DisableInEnvironment("ResearchLab", "Underground", "Asteroid")
            DisableInEnvironment("NetworkNode", "Underground", "Asteroid")
            DisableInEnvironment("RMR_ScienceInstitute", "Surface", "Asteroid")
            DisableInEnvironment("RMR_ResearchLab", "Surface", "Asteroid")
            DisableInEnvironment("RMR_NetworkNode", "Surface", "Asteroid")
        else
            UndisableInEnvironment("ScienceInstitute", "Underground", "Asteroid")
            UndisableInEnvironment("ResearchLab", "Underground", "Asteroid")
            UndisableInEnvironment("NetworkNode", "Underground", "Asteroid")
            UndisableInEnvironment("RMR_ScienceInstitute", "Surface", "Asteroid")
            UndisableInEnvironment("RMR_ResearchLab", "Surface", "Asteroid")
            UndisableInEnvironment("RMR_NetworkNode", "Surface", "Asteroid")
        end
    end
    ApplyResearchDesc()
end

function OnMsg.ClassesGenerate(classdefs)
    if not classdefs then
        return
    end
    if not classdefs.RMR_BaseResearchLab then
        classdefs.RMR_BaseResearchLab = { __parents = { "BaseResearchLab" } }
    end
    if not classdefs.RMR_BaseScienceInstitute then
        classdefs.RMR_BaseScienceInstitute = { __parents = { "BaseResearchLab" } }
    end
    if not classdefs.RMR_NetworkNodeBase then
        classdefs.RMR_NetworkNodeBase = { __parents = { "NetworkNodeBase" } }
    end
    for src_id, base in pairs(UG_COPY) do
        local dst_id = "RMR_" .. src_id
        if not classdefs[dst_id] and classdefs[src_id] then
            classdefs[dst_id] = CopyClassDef(classdefs[src_id], base)
            print("RMR research classdef", dst_id, base)
        elseif not classdefs[src_id] then
            print("RMR research classdef miss", src_id)
        end
    end
end

function OnMsg.ClassesBuilt()
    RegisterUGTemplates()
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