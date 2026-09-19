local ToggleResearch = true

local RESEARCH_IDS = {
    "ScienceInstitute",
    "ResearchLab",
    "NetworkNode",
    "LowGLab",
}

local ResearchDescOff = {
    ScienceInstitute = T{"Generates Research."},
    ResearchLab = T{"Generates Research."},
    NetworkNode = T{"Increases the Research output of all Research buildings in its Dome."},
    LowGLab = T{"Generates Research."},
    RMR_Micro_G_Lab = T{"Radiation hardened micro-G research lab."},
}

local ResearchDescOn = {
    ScienceInstitute = T{"Generates Research. One per colony. The rest of the work belongs in micro-G on asteroids."},
    ResearchLab = T{"Generates Research. An early colony gets one of these. Extra labs belong in micro-G on asteroids."},
    NetworkNode = T{"Increases Research output of all Research buildings in its Dome. One per colony."},
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
    for _, id in ipairs(RESEARCH_IDS) do
        local bt = BuildingTemplates[id]
        if bt then
            bt.build_once = ToggleResearch and true or false
        end
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