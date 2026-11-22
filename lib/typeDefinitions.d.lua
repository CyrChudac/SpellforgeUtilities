---@meta _

---@class RevealingController
---@field patch? Patch The patch to check for whether it applied or not.
---@field Reveal function Reveals the interrior space to the player.
---@field Initialize function Hides the doors and animation inside the space.
local RevealingController = {}

---Initializes the animations and the interrior space as a whole.
function RevealingController:Initialize() end

---Reveals the interrior space to the player.
---It applies the patches, shows the doors and animations inside the space, hides the newly not relevant doors.
function RevealingController:Reveal() end

--- ----------------------------------------------------------------------------------------------------------------------------------------

---@class RevealingControllerWithBridge : RevealingController ---An interrior place where a bridge mechanism can be activated.
---@field drawBridge? Patch The patch to check to know if the bridge is down.
---@field ActivateDrawBridge function Actually runs the sequence of lowering the bridge.
local RevealingControllerWithBridge = {}

---Actually runs the sequence of lowering the bridge.
---@param soundLocation Location The single point location to play the bridge sound at.
function RevealingControllerWithBridge:ActivateDrawBridge(soundLocation) end

--- ----------------------------------------------------------------------------------------------------------------------------------------

---@class RevealingControllerWithFallGate : RevealingController ---An interrior place where a bridge mechanism can be activated.
---@field ActivateFallGate function Actually activates the sequence of the gate falling.
local RevealingControllerWithFallGate = {}

---Actually activates the sequence of the gate falling.
---@param soundLocation Location The single point location to play the fallgate sound at.
function RevealingControllerWithFallGate:ActivateFallGate(soundLocation) end

--- ----------------------------------------------------------------------------------------------------------------------------------------

---@class RevealingControllerWithDoor : RevealingController
---@field Door {[string]: Door} The doors inside this space.

--- ----------------------------------------------------------------------------------------------------------------------------------------

---@class HiddenSpace
---@field Interrior string[] The names of locations inside the building.
---@field Exterrior Exterrior[] The locations outside of the building. From the place where the interrior is revealed up to the entry point.
---@field MainObj RevealingController The object that encapsulates how the interrior is revealed. (what animations to run and what door to activate...)
---@field Objects {[string]: Actor} The Scrolls, Targets, Items and NPCs inside the space.
---@field OnRevealFuncs [function] The additional functions that trigger when this space is revealed.
---@field CanHideAtStart boolean Indicates whether this space can be hided at mission start. Set this to false instead of using Reveal during Initialize.
---@field Condition function A function that returns boolean representing whether the space can can be shown to the player.
---@field RevealNPCs boolean Whether the NPCs inside the space should be revealed when the space is shown.
---@field Reveal function Reveals the space.

---@class InterriorExterriorData
---@field Interrior string[] The locations inside the space.
---@field Exterrior ExterriorData[] The names of the areas outside the space.

---@class ExterriorData
---@field Zone string The name of the zone outside of the the inner space accessable via one given path.
---@field Doors string[] The names of the doors that are used to go from this outer zone inside the inner space.

---@class Exterrior
---@field Zone string The name of the zone outside of the the inner space accessable via one given path.
---@field Doors string[] The names of the doors that are used to go from this outer zone inside the inner space.