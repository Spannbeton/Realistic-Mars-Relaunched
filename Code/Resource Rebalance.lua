-- Code/Resource Rebalance.lua
-- Exact normal / deep / concrete counts. Volumes 80–100% of cap.
-- Slider 0 = none. Vanilla only via Resource_Rebalance toggle.
-- Grade weights stay vanilla.

local ToggleRes = true

local RES_CFG = {
    Metals = {
        normal = 2,
        deep = 1,
        amount = 10000,
    },
    Water = {
        normal = 3,
        deep = 2,
        amount = 40000,
    },
    PreciousMetals = {
        normal = 2,
        deep = 1,
        amount = 5000,
    },
    Concrete = {
        patches = 12,
        amount = 800,
    },
}

local saved = {}

local function IsConcreteId(id)
    return tostring(id or ""):find("^Concrete_") and true or false
end

local function IsAsteroidId(id)
    return tostring(id or ""):find("Asteroid") and true or false
end

local function IsUndergroundId(id)
    return tostring(id or ""):find("Underground") and true or false
end

local function SkipPreset(id, p)
    if not p then
        return true
    end
    if IsAsteroidId(id) or IsUndergroundId(id) then
        return true
    end
    if IsConcreteId(id) then
        return false
    end
    return not RES_CFG[p.resource]
end

local function NumOpt(key)
    if not CurrentModOptions then
        return nil
    end
    local raw = CurrentModOptions:GetProperty(key)
    if raw == nil or raw == false then
        return nil
    end
    return tonumber(raw)
end

local function ReadOpts()
    if not CurrentModOptions then
        return
    end
    local t = CurrentModOptions:GetProperty("Resource_Rebalance")
    if t ~= nil then
        ToggleRes = t
    end
    for res, cfg in pairs(RES_CFG) do
        local n = NumOpt("Resource_" .. res .. "_NormalDeposits")
        local d = NumOpt("Resource_" .. res .. "_DeepDeposits")
        local p = NumOpt("Resource_" .. res .. "_Patches")
        local a = NumOpt("Resource_" .. res .. "_MaxAmount")
        if n then cfg.normal = Max(0, floatfloor(n)) end
        if d then cfg.deep = Max(0, floatfloor(d)) end
        if p then cfg.patches = Max(0, floatfloor(p)) end
        if a then cfg.amount = Max(0, floatfloor(a)) end
    end
end

local function Parts(r)
    if type(r) ~= "table" then
        return 0, 0
    end
    return r.from or r[1] or 0, r.to or r[2] or 0
end

local function CopyRange(r)
    local a, b = Parts(r)
    return range(a, b)
end

local function CountRange(n)
    n = Max(0, floatfloor(tonumber(n) or 0))
    return range(n, n)
end

local function VolRange(max_amt)
    max_amt = Max(0, floatfloor(tonumber(max_amt) or 0))
    if max_amt == 0 then
        return range(0, 0)
    end
    local min_amt = Max(1, floatfloor(max_amt * 80 / 100))
    return range(min_amt, max_amt)
end

local function Mid(r)
    local a, b = Parts(r)
    return (a + b) / 2
end

local function SplitTerr(total, snap)
    local m1 = Mid(snap.TerrSizeCount1)
    local m2 = Mid(snap.TerrSizeCount2)
    local m3 = Mid(snap.TerrSizeCount3)
    local s = m1 + m2 + m3
    if s < 1 then
        s = 1
    end
    total = Max(0, floatfloor(total))
    local n1 = Max(0, floatfloor(total * m1 / s + 0.5))
    local n2 = Max(0, floatfloor(total * m2 / s + 0.5))
    local n3 = Max(0, total - n1 - n2)
    if n3 < 0 then
        n3 = 0
    end
    return CountRange(n1), CountRange(n2), CountRange(n3)
end

local function Snapshot()
    if next(saved) then
        return
    end
    if not ResourcePresets then
        return
    end
    for id, p in pairs(ResourcePresets) do
        if type(p) == "table" and not SkipPreset(id, p) then
            saved[id] = {
                resource = p.resource,
                Subs1Count = CopyRange(p.Subs1Count),
                Subs2Count = CopyRange(p.Subs2Count),
                Subs1Volume = CopyRange(p.Subs1Volume),
                Subs2Volume = CopyRange(p.Subs2Volume),
                TerrSizeCount1 = CopyRange(p.TerrSizeCount1),
                TerrSizeCount2 = CopyRange(p.TerrSizeCount2),
                TerrSizeCount3 = CopyRange(p.TerrSizeCount3),
                TerrSizeVol1 = CopyRange(p.TerrSizeVol1),
                TerrSizeVol2 = CopyRange(p.TerrSizeVol2),
                TerrSizeVol3 = CopyRange(p.TerrSizeVol3),
            }
        end
    end
end

local function Restore()
    if not ResourcePresets then
        return
    end
    for id, snap in pairs(saved) do
        local p = ResourcePresets[id]
        if p then
            p.Subs1Count = CopyRange(snap.Subs1Count)
            p.Subs2Count = CopyRange(snap.Subs2Count)
            p.Subs1Volume = CopyRange(snap.Subs1Volume)
            p.Subs2Volume = CopyRange(snap.Subs2Volume)
            p.TerrSizeCount1 = CopyRange(snap.TerrSizeCount1)
            p.TerrSizeCount2 = CopyRange(snap.TerrSizeCount2)
            p.TerrSizeCount3 = CopyRange(snap.TerrSizeCount3)
            p.TerrSizeVol1 = CopyRange(snap.TerrSizeVol1)
            p.TerrSizeVol2 = CopyRange(snap.TerrSizeVol2)
            p.TerrSizeVol3 = CopyRange(snap.TerrSizeVol3)
        end
    end
end

local function ApplyAll()
    Snapshot()
    if not ResourcePresets or not next(saved) then
        print("RMR: no ResourcePresets")
        return
    end
    Restore()
    if not ToggleRes then
        return
    end
    for id, snap in pairs(saved) do
        local p = ResourcePresets[id]
        if p then
            if IsConcreteId(id) then
                local cfg = RES_CFG.Concrete
                p.TerrSizeCount1, p.TerrSizeCount2, p.TerrSizeCount3 =
                    SplitTerr(cfg.patches, snap)
                local amt = cfg.amount or 0
                p.TerrSizeVol1 = VolRange(amt)
                p.TerrSizeVol2 = VolRange(amt)
                p.TerrSizeVol3 = VolRange(amt)
            else
                local cfg = RES_CFG[snap.resource]
                if cfg then
                    p.Subs1Count = CountRange(cfg.normal)
                    p.Subs2Count = CountRange(cfg.deep)
                    local deep_amt = cfg.amount or 0
                    p.Subs1Volume = VolRange(floatfloor(deep_amt / 4))
                    p.Subs2Volume = VolRange(deep_amt)
                end
            end
        end
    end
end

function OnMsg.ModsReloaded()
    ReadOpts()
    ApplyAll()
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        ReadOpts()
        ApplyAll()
    end
end