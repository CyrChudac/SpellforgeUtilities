require("lib.seemless.lincolnSeemless")

function Initialize(seed)
    InitH01()
end

---@type ZoneScriptEvents
TestZone = {}

TestZone.Enter = function(actor)
    actor:Stop()

    CyrSeq()
        :BeginCutscene()
        :Then()
        :Together({
            {
                {
                    func = "CyrSequence.Move",
                    args = {Heroes.Robin, Locations[""], MovementStyle.running}
                },
                {
                    func = "CyrSequence.MoveCameraTo",
                    args = {Locations[""], 4}
                },
            },
            {
                {
                    func = "CyrSequence.FinalizeCutscene",
                    args = {}
                }
            }
        })
        :Start()
end

--    python luajoiner.py try_bundling.lua bundleTry2.lua
