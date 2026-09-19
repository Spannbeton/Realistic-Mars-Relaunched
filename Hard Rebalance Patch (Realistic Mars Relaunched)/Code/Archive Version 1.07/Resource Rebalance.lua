local ToggleRes = true

local RES_CFG = {
    Metals = { deposits = 3, amount = 5000 },
    Water = { deposits = 3, amount = 5000 },
    PreciousMetals = { deposits = 2, amount = 5000 },
}

local saved = {}

local function ReadOpts()
    if not CurrentModOptions then
        return
    end
    local t = CurrentModOptions:GetProperty("Resource_Rebalance")
    if t ~= nil then
        ToggleRes = t
    end
    for res, cfg in pairs(RES_CFG) do
        local d = tonumber(CurrentModOptions:GetProperty("Resource_" .. res .. "_MaxDeposits"))
        local a = tonumber(CurrentModOptions:GetProperty("Resource_" .. res .. "_MaxAmount"))
        if d then cfg.deposits = Max(1, floatfloor(d)) end
        if a then cfg.amount = Max(1000, floatfloor(a)) end
    end
end

local function SkipPreset(id, p)
    if not p or not RES_CFG[p.resource] then
        return true
    end
    return tostring(id or ""):find("Asteroid") and true or false
end

local function Parts(r)
    if type(r) ~= "table" then
        return 0, 0
    end
    return r.from or r[1] or 0, r.to or r[2] or 0
end

local function VolRange(max_amt)
    max_amt = Max(1, floatfloor(max_amt))
    local min_amt = Max(1, floatfloor(max_amt * 70 / 100))
    return range(min_amt, max_amt)
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
                Subs1Count = p.Subs1Count,
                Subs2Count = p.Subs2Count,
                Subs1Volume = p.Subs1Volume,
                Subs2Volume = p.Subs2Volume,
            }
        end
    end
end

local function Restore()
    for id, snap in pairs(saved) do
        local p = ResourcePresets[id]
        if p then
            p.Subs1Count = snap.Subs1Count
            p.Subs2Count = snap.Subs2Count
            p.Subs1Volume = snap.Subs1Volume
            p.Subs2Volume = snap.Subs2Volume
        end
    end
end

local function SplitCount(from1, to1, from2, to2, total)
    total = Max(1, total)
    local vmax = to1 + to2
    if vmax <= 0 then
        return range(1, total), range(0, 0)
    end
    local deep = floatfloor(to2 * total / vmax + 0.5)
    if deep < 0 then deep = 0 end
    if deep > total - 1 then deep = Max(0, total - 1) end
    local norm = total - deep
    if norm < 1 then
        norm = 1
        deep = total - 1
    end
    return range(norm, norm), range(deep, deep)
end

local function ApplyAll()
    Snapshot()
    if not ResourcePresets or not next(saved) then
        print("RMR: no ResourcePresets")
        return
    end
    Restore()
    if not ToggleRes then
        --print("RMR deposits vanilla")
        return
    end
    for id, snap in pairs(saved) do
        local p = ResourcePresets[id]
        local cfg = p and RES_CFG[snap.resource]
        if p and cfg then
            local a1, b1 = Parts(snap.Subs1Count)
            local a2, b2 = Parts(snap.Subs2Count)
            p.Subs1Count, p.Subs2Count = SplitCount(a1, b1, a2, b2, cfg.deposits)
            local deep_amt = cfg.amount
            local shallow_amt = Max(1, floatfloor(deep_amt / 4))
            p.Subs1Volume = VolRange(shallow_amt)
            p.Subs2Volume = VolRange(deep_amt)
            --print("RMR dep", id, snap.resource, cfg.deposits, p.Subs1Volume, p.Subs2Volume)
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