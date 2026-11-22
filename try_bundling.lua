require("lib.seemless.lincolnSeemless")

function Initialize(seed)
    InitH01()
end

---@type ZoneScriptEvents
TestZone = {}

TestZone.Enter = function(actor)
    actor:Stop()
end

--    python luajoiner.py try_bundling.lua bundleTry2.lua