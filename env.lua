if _G.env then return end

local modules = {
    { file = "draw.lua",      key = "Draw",   alias = "draw" },
    { file = "offsets.lua",   key = "Offsets", alias = "offsets" },
    { file = "utilities.lua", key = "Utils",   alias = "utils" },
}

for _, module in ipairs(modules) do
    if _G[module.key] == nil then
        local path = module.file
        assert(isfile(path), "missing module: " .. path)

        local chunk = loadstring(readfile(path), path)
        local ok, err = pcall(chunk)
        assert(ok, err or ("chunk failed: " .. path))
        assert(_G[module.key] ~= nil, "no _G." .. module.key .. " from " .. path)
    end

    _G[module.alias] = _G[module.key]
end

_G.env = {
    draw = _G.Draw,
    utils = _G.Utils,
    offsets = _G.Offsets,

    status = function()
        return ("draw=%s utils=%s offsets=%d"):format(
            tostring(_G.Draw ~= nil),
            tostring(_G.Utils ~= nil),
            type(_G.Offsets) == "table" and next(_G.Offsets) and 1 or 0
        )
    end,

    reload = function()
        if _G.Draw and _G.Draw.Destroy then _G.Draw.Destroy() end
        _G.Draw, _G.Utils, _G.Offsets, _G.env = nil, nil, nil, nil
        loadstring(readfile("env.lua"), "env.lua")()
    end,
}
