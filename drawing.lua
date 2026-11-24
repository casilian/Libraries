local RunService = game:GetService("RunService")

local TRIM_AFTER = 300

local draw = {}
local pools = {}
local frame = 0

for _, kind in next, { "Text", "Line", "Square", "Circle", "Triangle", "Image" } do
    pools[kind] = { list = {}, n = 0 }
end

local function acquire(kind)
    local pool = pools[kind]
    pool.n = pool.n + 1
    local e = pool.list[pool.n]
    if not e then
        e = { obj = Drawing.new(kind), shown = false }
        pool.list[pool.n] = e
    end
    e.last = frame
    if not e.shown then
        e.obj.Visible = true
        e.shown = true
    end
    return e.obj, e
end

local function trySet(obj, prop, value)
    pcall(function() obj[prop] = value end)
end

local WHITE = Color3.new(1, 1, 1)

function draw.Text(x, y, text, color, center, outline, font, transparency)
    local o = acquire("Text")
    o.Position = Vector2.new(x, y)
    o.Text = tostring(text)
    o.Color = color or WHITE
    o.Center = center ~= false    
    o.Outline = outline ~= false  
    o.Font = font or Drawing.Fonts.UI
    o.Transparency = transparency or 1
    return o
end

function draw.Line(x1, y1, x2, y2, color, thickness, transparency)
    local o = acquire("Line")
    o.From = Vector2.new(x1, y1)
    o.To = Vector2.new(x2, y2)
    o.Color = color or WHITE
    o.Thickness = thickness or 1
    o.Transparency = transparency or 1
    return o
end

function draw.Square(x, y, w, h, color, filled, corner, transparency)
    local o = acquire("Square")
    o.Position = Vector2.new(x, y)
    o.Size = Vector2.new(w, h)
    o.Color = color or WHITE
    o.Filled = filled == true
    o.Transparency = transparency or 1
    trySet(o, "Corner", corner or 0)
    return o
end

function draw.Circle(x, y, radius, color, filled, numSides, thickness, transparency)
    local o = acquire("Circle")
    o.Position = Vector2.new(x, y)
    o.Radius = radius or 10
    o.Color = color or WHITE
    o.NumSides = numSides or 32
    o.Thickness = thickness or 1
    o.Transparency = transparency or 1
    trySet(o, "Filled", filled == true)
    return o
end

function draw.Triangle(ax, ay, bx, by, cx, cy, color, filled, thickness, transparency)
    local o = acquire("Triangle")
    o.PointA = Vector2.new(ax, ay)
    o.PointB = Vector2.new(bx, by)
    o.PointC = Vector2.new(cx, cy)
    o.Color = color or WHITE
    o.Transparency = transparency or 1
    trySet(o, "Filled", filled == true)
    trySet(o, "Thickness", thickness or 1)
    return o
end

function draw.Image(x, y, w, h, data, rounding, transparency)
    local o, e = acquire("Image")
    o.Position = Vector2.new(x, y)
    o.Size = Vector2.new(w or 50, h or 50)
    o.Rounding = rounding or 0
    o.Transparency = transparency or 1
    if e.data ~= data then 
        o.Data = data
        e.data = data
    end
    return o
end

local function endFrame()
    frame = frame + 1
    for _, pool in next, pools do
        local list = pool.list
        for i = pool.n + 1, #list do
            local e = list[i]
            if e.shown then
                e.obj.Visible = false
                e.shown = false
            end
        end
        while #list > pool.n and frame - list[#list].last > TRIM_AFTER do
            list[#list].obj:Remove()
            list[#list] = nil
        end
        pool.n = 0
    end
end

local connection = RunService.Heartbeat:Connect(endFrame)

function draw.Destroy()
    connection:Disconnect()
    for _, pool in next, pools do
        for _, e in next, pool.list do e.obj:Remove() end
        pool.list, pool.n = {}, 0
    end
end

_G.Draw = draw

