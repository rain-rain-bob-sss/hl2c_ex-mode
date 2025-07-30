EFFECT.LifeTime = 10
local tc, tt = TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
local draw, cam = draw, cam
local dmgnums = {}
local colcvar = {}
for i, v in ipairs({"r", "g", "b"}) do
    colcvar[v] = CreateClientConVar("hl2ce_dmgnum_col_" .. v, "255", true, true, "Damage number's color", 0, 255)
end

local colcvar_fire = {}
for i, v in ipairs({"r", "g", "b"}) do
    local a = 255
    if v == "g" then
        a = 170
    elseif v == "b" then
        a = 0
    end

    colcvar_fire[v] = CreateClientConVar("hl2ce_dmgnum_colfire_" .. v, a, true, true, "Damage number's fire damage color", 0, 255)
end

local colcvar_bleed = {}
for i, v in ipairs({"r", "g", "b"}) do
    local a = 255
    if v == "g" then
        a = 0
    elseif v == "b" then
        a = 0
    end

    colcvar_bleed[v] = CreateClientConVar("hl2ce_dmgnum_colbleed_" .. v, a, true, true, "Damage number's bleed damage color", 0, 255)
end

--aifijasufsihtzsy WHAT?
local enabled = CreateClientConVar("hl2ce_dmgnum_enabled", "1", true, true, "Enable damage number", 0, 1)
local b = CreateClientConVar("hl2ce_dmgnum_bounce", "0.5", true, true, "Damage number's bounce", 0, 1)
local grav = CreateClientConVar("hl2ce_dmgnum_gravity", "-450", true, true, "Damage number's gravity", -1000, 1000)
local airres = CreateClientConVar("hl2ce_dmgnum_airres", "32", true, true, "Damage number's air resistance", 0, 1000)
local scale = CreateClientConVar("hl2ce_dmgnum_scale", "1", true, true, "Damage number's scale", 0, 5)
local zvel = CreateClientConVar("hl2ce_dmgnum_startzvel", "0.4", true, true, "Damage number's start zvel", 0.2, 1.2)
local svel = CreateClientConVar("hl2ce_dmgnum_startvel", "1", true, true, "Damage number's start vel scale", 0.2, 10)
local lifetime = CreateClientConVar("hl2ce_dmgnum_lifetime", "1", true, true, "Damage number's life time", 0.3, 8)
local norotateang = CreateClientConVar("hl2ce_dmgnum_norotateang", "1", true, true, "Disable damage number rotating", 0, 1)
local _2d = CreateClientConVar("hl2ce_dmgnum_2d", "1", true, true, "2D Damage number", 0, 1)
surface.CreateFont("dmgnum_hl2ce", {
    font = "HalfLife2", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 50,
    weight = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = true,
})

surface.CreateFont("dmgnum_hl2ce2d", {
    font = "HalfLife2", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 50,
    weight = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = true,
})


local c = 0
hook.Add("PostDrawTranslucentRenderables", "DrawDmgNumsHl2CE", function(_, _, sky)
    if not sky then
        local ct = CurTime()
        if not enabled:GetBool() then
            c = 0
            dmgnums = {}
            return
        end

        cam.IgnoreZ(true)
        local a = true
        for i, v in pairs(dmgnums) do
            if isnumber(v.dmg) and v.dmg <= 0 then v.dmg = "MISS" end
            local ang = v:GetAngles()
            if norotateang:GetBool() then
                ang = EyeAngles()
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end

            local dieon = v.dieon
            local alpha = math.Clamp(dieon - ct, 0, 1) * 220
            local glowa = math.Clamp(dieon - 1.2 - ct, 0, 1) * 255
            local col = v.Color
            local function drawtext()
                if _2d:GetBool() then
                    cam.Start3D2D(v:GetPos(), ang, math.max(0.05 * scale:GetFloat(),scale:GetFloat() * (v:GetPos():Distance(EyePos()) / 500) * 0.2))
                    draw.SimpleText(v.dmg, "dmgnum_hl2ce" .. (isnumber(v.dmg) and "" or "text"), 0, 0, ColorAlpha(col, alpha), tc, tt)
                    cam.End3D2D()
                else
                    cam.Start3D2D(v:GetPos(), ang, .05 * scale:GetFloat())
                    draw.SimpleText(v.dmg, "dmgnum_hl2ce" .. (isnumber(v.dmg) and "" or "text"), 0, 0, ColorAlpha(col, alpha), tc, tt)
                    cam.End3D2D()
                end
            end

            drawtext()
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Up(), -180)
            drawtext()
            if alpha < 2 then dmgnums[i] = nil c = c - 1 end
            a = false
        end

        cam.IgnoreZ(false)
        if a then
            c = 0
            dmgnums = {}
        end
    end
end)

function EFFECT:Init(data)
    if c > 500 then return self:Remove() end
    local pos = data:GetOrigin()
    local ang = data:GetAngles()
    local ent = data:GetEntity()
    local dmg = data:GetMagnitude()
    local type = data:GetDamageType()
    local isfire = bit.band(type, DMG_BURN) == DMG_BURN or bit.band(type, DMG_SLOWBURN) == DMG_SLOWBURN
    local isbleed = data:GetFlags() == 1

    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)


    local radvec = VectorRand()
    radvec.z = zvel:GetFloat() + math.random(-0.2, 0.2)

    local emit = ParticleEmitter(pos)
    local p = emit:Add("sprites/glow04_noz", pos)
    p:SetDieTime(1.8)
    p:SetStartAlpha(0)
    p:SetEndAlpha(0)
    p:SetStartSize(0)
    p:SetEndSize(0)
    p:SetCollide(true)
    p:SetBounce(b:GetFloat())
    p:SetAirResistance(airres:GetFloat())
    p:SetGravity(Vector(0, 0, grav:GetFloat()))
    p:SetVelocity(radvec * 30 * svel:GetFloat())
    p:SetAngles(ang)

    local col = {}
    for i, v in pairs(isbleed and colcvar_bleed or (isfire and colcvar_fire or colcvar)) do
        col[i] = v:GetFloat()
    end

    ang = ang + AngleRand(-80, 80)
    p:SetAngleVelocity(ang)
    p.Color = Color(col.r, col.g, col.b)
    p.dieon = CurTime() + lifetime:GetFloat()
    p.dmg = dmg

    p:SetCollideCallback(function(part, hitpos, hitnormal)
        local ang = hitnormal:Angle():Up():Angle()
        ang[2] = p:GetAngles()[2]
        p:SetAngles(ang)
    end)

    table.insert(dmgnums, p)
    emit:Finish() --Found from zs github
    emit = nil
    collectgarbage("step", 64)
    c = c + 1
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end