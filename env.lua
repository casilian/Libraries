if _G.env then return end

local ENV_URL = "https://raw.githubusercontent.com/casilian/Libraries/refs/heads/main/env.lua"

local modules = {
    { file = "https://raw.githubusercontent.com/casilian/Libraries/refs/heads/main/drawing.lua",   key = "Draw",    alias = "draw" },
    { file = "https://raw.githubusercontent.com/casilian/Libraries/refs/heads/main/offsets.lua",   key = "Offsets", alias = "offsets" },
    { file = "https://raw.githubusercontent.com/casilian/Libraries/refs/heads/main/utilities.lua", key = "Utils",   alias = "utils" },
}

for _, module in ipairs(modules) do
    if _G[module.key] == nil then
        local body = httpget(module.file)
        assert(body ~= "", "fetch failed: " .. module.file)
        local chunk = loadstring(body, module.file)
        local ok, err = pcall(chunk)
        assert(ok, err or ("chunk failed: " .. module.file))
        assert(_G[module.key] ~= nil, "no _G." .. module.key .. " from " .. module.file)
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
        local body = httpget(ENV_URL)
        assert(body ~= "", "fetch failed: " .. ENV_URL)
        loadstring(body, "env.lua")()
    end,
}
