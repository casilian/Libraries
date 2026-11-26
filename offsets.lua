local Offsets = {}

local offs = httpget('https://offsets.imtheo.lol/version-2c6fd5e09aaf4cfa/offsets.json', {})

if offs ~= '' then 
    local data = game:GetService("HttpService"):JSONDecode(offs)

    if (data.Offsets) then 
        local temp = data.Offsets 



        Offsets = data.Offsets 
    end
end

_G.Offsets = Offsets