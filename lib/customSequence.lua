require("lib.common")

---A sequence being recorded (Sequence()). Each step records at once and returns the sequence.
---@class CyrSequence
---@field seqNumber integer
---@field sequence Sequence
---@field ifIndex integer
---@field ifCounter integer
---@field ifResult boolean[]
local CyrSequence = {}

---Starts recording a sequence. Add its steps with ':' and play it with Start().
---@return CyrSequence CyrSeq
function CyrSeq()
    local result = {
        seqNumber = tostring(Rand(1000000000)),
        sequence = Sequence(),
        ifCounter = 0,
        ifIndex = 0,
        ifResult = {}
    }
    for index, value in pairs(CyrSequence) do
        result[index] = value
    end
    return result
end

-------------------------- THE IF SYSTEM --------------------------------------

---Determines whether the sequence is currently inside an ifbranch it should execute.
---@return boolean
function CyrSequence:CanProceed()
    if self.ifCounter == 0 then
        return true
    end
    for i = 1,self.ifCounter do
        if not self.ifResult[i] then
            return false
        end
    end
    return true
end

---Creates a new if branch.
---@param expression boolean Beware! This is a snapshot of the value in question at the time of the code running.
---@return CyrSequence # 
function CyrSequence:If(expression)
    self.ifCounter = self.ifCounter + 1
    self.ifResult[self.ifCounter] = expression
    return self
end

---Goes to the other branch of the related if.
---@return CyrSequence #
function CyrSequence:Else()
    self.ifResult[self.ifCounter] = not self.ifResult[self.ifCounter]
    return self
end

---Ends the current if branch.
---@return CyrSequence
function CyrSequence:Endif()
    self.ifResult[self.ifCounter] = nil
    self.ifCounter = math.max(self.ifCounter - 1, 0)
    return self
end

-------------------------- THE SIMULTANEOUS SYSTEM --------------------------------------

local funcSeparator = "|"
local layerSeparator = ","
---@param sequenceOfSequenceFunctions {func: string, args: any[]}[][]
---@return any[] #
function CreateParams(sequenceOfSequenceFunctions)
    local result = {}
    for i1, layer in ipairs(sequenceOfSequenceFunctions) do
        for i2, funData in ipairs(layer) do
            table.insert(result, funData.func)
            ConcatInPlace(result, funData.args)
            table.insert(result, funcSeparator)
        end
            table.insert(result, layerSeparator)
    end
    return result
end

---@param dataList any[]
---@return {funcs: {func: string, args: any[]}[], rest: any[]} #
function ParseFunctionLayer(dataList)
    local result = {
        funcs = {},
        rest = {}
    }
    local current = {
        args = {}
    }
    local isFirst = true
    local isRest = false
    for _, d in ipairs(dataList) do
        if isRest then
            table.insert(result.rest, d)
        elseif isFirst then
            if d == layerSeparator then
                isRest = true
            else
                isFirst = false
                current.func = d
            end
        elseif d == funcSeparator then
            table.insert(result.funcs, current)
            current = {
                args = {}
            }
            isFirst = true
        else
            table.insert(current.args, d)
        end
    end
    return result
end

function WhenAllReady(num, max, ...)
    Globals[num] = Globals[num] + 1
    if(Globals[num] == max) then
        Globals[num] = nil
        local num2 = tostring(Rand(100000000))
        SimultaneousCall(num, ...)
    end
end

function SimultaneousCall(num, ...)
    local data = ParseFunctionLayer(...)
    local max = 0
    for _, _ in pairs(data.funcs) do
        max = max + 1
    end
    Globals[num] = 0
    for _, f in ipairs(data.funcs) do
        local s = CyrSeq()
        s = _G[f.func](s, table.unpack(f.args))
        s
            :Then()
            :Call("WhenAllReady", num, max, data.rest)
            :Start()
    end
end

---All functions in the same layer will be executed simultaneously and the next layer only starts when the previous one is finished.
---@param sequenceOfSequenceFunctions {func: string, args: any[]}[][] List of function layers. A function is given by its global name and the arguments to pass it. The first argument in each function will be the CyrSequence object it can use. Every function should also return a CyrSequence object.
function CyrSequence:Together(sequenceOfSequenceFunctions)
    local params = CreateParams(sequenceOfSequenceFunctions)
    local num2 = tostring(Rand(100000000))
    return self
        :Call("SimultaneousCall", self.seqNumber + "_" + num2, table.unpack(params))
end

-------------------------- CUSTOM ACTIONS -------------------------------------------------------

---Makes the actor walk through all of the given locations using the given movement style.
---@param self CyrSequence
---@param actor Actor The actor to walk through the points.
---@param locations Location[] The points to move through in order.
---@param movementStyle MovementStyle The movement style to use while moving.
---@return CyrSequence
function CyrSequence:WalkThrough(actor, locations, movementStyle)
  local seq = self
  for index, location in ipairs(locations) do
    if index > 1 then
      seq = seq:Then()
    end
    seq = seq:Move(actor, location, movementStyle)
  end
  return seq
end

---Does all of the usual stuff done at cutscene start, specifically: locks user, locks all AIs, stops all pcs.
---@return CyrSequence
function CyrSequence:BeginCutscene()
  return self
    :LockUser()
    :Then()
    :Call(LockAllAI)
    :Then()
    :Call(function()
        for i = 0, GetNumberOfPcs() - 1 do GetPc(i):Stop() end
    end)
end

---Does all of the usual stuff done at cutscene end, specifically: unlocks user, unlocks all AIs.
---@return CyrSequence
function CyrSequence:FinalizeCutscene()
  return self
    :UnlockUser()
    :Then()
    :Call(UnlockUnlockableAI)
end

---Does all of the usual stuff done at cutscene end, specifically: unlocks user, unlocks all AIs.
---@return CyrSequence
function CyrSequence:StopActor(actor)
  return self
    :Call("Actor.Stop", actor)
end

local wakeUpTimes = {
  [PcType.little_john] = {40, 10},
  [PcType.marian] = {70, 15},
  [PcType.farmer_b] = {70, 13},
}

---Makes the wakingActor move to the actorBeingWaked and play the animation of waking him up
---@param actorWaking Actor
---@param actorBeingWaked Actor
---@param movementStyle MovementStyle
---@param wakedSpeaks boolean
---@return CyrSequence
function CyrSequence:WakeUp(actorWaking, actorBeingWaked, movementStyle, wakedSpeaks)
  local times = assert(wakeUpTimes[actorWaking.pc_type], 'Unsupported wake-up actor type')
  return self
    :MoveNear(actorWaking, actorBeingWaked.location, movementStyle, 20)
    :Then()
    :TurnTo(actorWaking, actorBeingWaked.location)
    :Then()
    :Call(function(a)
        Sequence()
            :PlayAnim(a, ActorAction.waking_up)
            :Start()
    end, actorWaking)
    :Then()
    :Wait(times[1])
    :Then()
    :Call(function(a)
      a:SetProperty(PersistentProperty.concussion, 0)
      if wakedSpeaks then
        Sequence()
          :SpeakPc(a, PcRemark.recover, 0)
          :Start()
      end
    end, wakedSpeaks)
    :Then()
    :Wait(times[2])
end

-------------------------- THE ORIGINAL SEQUENCE FUNCTIONS --------------------------------------


---Starts the next step: everything recorded after Then() waits until everything recorded since the
---previous Then() has finished; steps between two Then() calls happen at the same time. Several
---Then() in a row without a step in between count as one.
---@return CyrSequence
function CyrSequence:Then()
    if self.CanProceed then
        self.sequence = self.sequence:Then()
    end
    return self
end

---Waits: what comes after the next Then() starts this much later.
---@param seconds number Time to wait in seconds (the game runs 25 frames a second, so 0.04 is the shortest wait).
---@return CyrSequence
function CyrSequence:Wait(seconds)
    if self.CanProceed then
        self.sequence = self.sequence:Wait(seconds)
    end
    return self
end

---Runs a Lua function when the sequence gets there. Call("Name", ...) calls the global function
---Name (or "Table.Name") with the arguments and survives savegames; a function value only survives a
---quickload in the same game session.
---@param callback function|string The function, or the name of a global function.
---@param ... any Arguments for a named function, saved like Globals values.
---@return CyrSequence
function CyrSequence:Call(callback, ...)
    if self.CanProceed then
        if type(callback) == "string" then
            print("adding callback: " .. callback)
            self.sequence = self.sequence:Call("print", "calling: " .. callback)
        end
        self.sequence = self.sequence:Call(callback, ...)
        if type(callback) == "string" then
            self.sequence = self.sequence:Call("print", "called: " .. callback)
        end
    end
    return self
end

---Finishes recording and plays the sequence. The script goes on at once while the sequence plays
---over time; no steps can be added afterward.
---@return boolean played true; an empty sequence is dropped (still true). False outside of played if branch.
function CyrSequence:Start()
    if self.CanProceed then
        return self.sequence:Start()
    end
    return false
end

-- ===== Sequence steps: camera and screen =======================================

---A camera scroll to a point; the step ends when the camera has arrived.
---@param location Location a point location (Locations.Name); a zone does not work here
---@return CyrSequence
function CyrSequence:ScrollCameraTo(location)
    if self.CanProceed then
        self.sequence = self.sequence:ScrollCameraTo(location)
    end
    return self
end

---An instant camera jump to a point.
---@param location Location a point location (Locations.Name); a zone does not work here
---@return CyrSequence
function CyrSequence:JumpCameraTo(location)
    if self.CanProceed then
        self.sequence = self.sequence:JumpCameraTo(location)
    end
    return self
end

---A camera scroll to a point at a constant speed; the step ends when the camera has arrived.
---@param location Location a point location (Locations.Name); a zone does not work here
---@param speed integer scroll speed in map pixels per frame (25 frames per second); 0 uses the normal accelerating scroll
---@return CyrSequence
function CyrSequence:MoveCameraTo(location, speed)
    if self.CanProceed then
        self.sequence = self.sequence:MoveCameraTo(location, speed)
    end
    return self
end

---A zoom change: the camera zooms when the sequence gets there.
---@param zoomValue ZoomLevel the zoom factor: ZoomLevel.far, ZoomLevel.default or ZoomLevel.close (other values are refused)
---@return CyrSequence
function CyrSequence:SetZoomLevel(zoomValue)
    if self.CanProceed then
        self.sequence = self.sequence:SetZoomLevel(zoomValue)
    end
    return self
end

---Opening or closing the map.
---@param display boolean true opens the map, false closes it
---@return CyrSequence
function CyrSequence:DisplayMap(display)
    if self.CanProceed then
        self.sequence = self.sequence:DisplayMap(display)
    end
    return self
end

---Graying out or re-enabling one of a hero's action buttons on the portrait bar.
---@param actor Actor a hero (PC); nil is refused with a warning
---@param action integer action slot on the hero's portrait, 0-2
---@param available boolean true enables the button, false grays it out
---@return CyrSequence
function CyrSequence:ActionAvailable(actor, action, available)
    if self.CanProceed then
        self.sequence = self.sequence:ActionAvailable(actor, action, available)
    end
    return self
end

---Making a hero playable or unplayable: an unplayable hero cannot be selected or controlled but
---stays in the world.
---@param actor Actor a hero (PC); other characters are not supported and nil is refused with a warning
---@param available boolean true makes the hero playable, false takes control away
---@return CyrSequence
function CyrSequence:CharacterAvailable(actor, available)
    if self.CanProceed then
        self.sequence = self.sequence:CharacterAvailable(actor, available)
    end
    return self
end

---Locking the camera on an actor: it follows that actor until Sequence:ClearCameraLock.
---@param actor Actor an actor (Actors.Name, ThisActor(), GetPc(i), ...); nil is refused with a warning
---@return CyrSequence
function CyrSequence:LockCameraOn(actor)
    if self.CanProceed then
        self.sequence = self.sequence:LockCameraOn(actor)
    end
    return self
end

---Releasing a camera lock set with Sequence:LockCameraOn.
---@return CyrSequence
function CyrSequence:ClearCameraLock()
    if self.CanProceed then
        self.sequence = self.sequence:ClearCameraLock()
    end
    return self
end

---Showing a mission dialog; the step ends when the dialog is closed.
---@param dialogId integer dialog number in the mission's dialog list, from 0
---@return CyrSequence
function CyrSequence:PlayDialog(dialogId)
    if self.CanProceed then
        self.sequence = self.sequence:PlayDialog(dialogId)
    end
    return self
end

---Freezing or unfreezing the whole level (see FreezeAll).
---@param freeze boolean true freezes, false lets everything run again
---@return CyrSequence
function CyrSequence:FreezeAll(freeze)
    if self.CanProceed then
        self.sequence = self.sequence:FreezeAll(freeze)
    end
    return self
end

---Showing a popup text scroll; the step ends when the player closes it.
---@param popupTextId integer popup text ID of the mission
---@return CyrSequence
function CyrSequence:DisplayPopupText(popupTextId)
    if self.CanProceed then
        self.sequence = self.sequence:DisplayPopupText(popupTextId)
    end
    return self
end

-- ===== Sequence steps: characters ==============================================

---Sending a message: when the sequence gets there, the ProcessMessage function of the actor's
---script class runs with (messageCode, 0, 0); with God() the level script's ProcessMessage runs.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
---@return CyrSequence
function CyrSequence:SendMessage(actor, messageCode)
    if self.CanProceed then
        self.sequence = self.sequence:SendMessage(actor, messageCode)
    end
    return self
end

---Like Sequence:SendMessage, but ProcessMessage receives two extra numbers.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
---@param argument1 integer first number passed to ProcessMessage
---@param argument2 integer second number passed to ProcessMessage
---@return CyrSequence
function CyrSequence:SendMessageWithArguments(actor, messageCode, argument1, argument2)
    if self.CanProceed then
        self.sequence = self.sequence:SendMessageWithArguments(actor, messageCode, argument1, argument2)
    end
    return self
end

---A character walking or running to a point along a computed path; the step ends on arrival. The
---path is planned when you record it, starting from where the character is, or from where an
---earlier move of this sequence left it.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@return CyrSequence
function CyrSequence:Move(actor, location, style)
    if self.CanProceed then
        self.sequence = self.sequence:Move(actor, location, style)
    end
    return self
end

---A character walking or running to a point, stopping as soon as it is within the given distance of
---it; otherwise like Sequence:Move.
---@param actor Actor a character (human or animal); nil is refused with a warning
---@param location Location a point location (Locations.Name); a zone does not work here
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@param tolerance integer distance in map pixels at which the character may stop
---@return CyrSequence
function CyrSequence:MoveNear(actor, location, style, tolerance)
    if self.CanProceed then
        self.sequence = self.sequence:MoveNear(actor, location, style, tolerance)
    end
    return self
end

---A character entering the map from its edge: the character is placed outside the map behind the
---point and walks in to it. Also brings back a character that was sent away with actor.location =
---nil.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here (nil is refused with a warning)
---@param direction ActorDirection direction the character walks in, 0-15 (ActorDirection), or -1 for the way it currently faces
---@param style MovementStyle 0 walk, 1 run
---@return CyrSequence
function CyrSequence:EnterLevel(actor, location, direction, style)
    if self.CanProceed then
        self.sequence = self.sequence:EnterLevel(actor, location, direction, style)
    end
    return self
end

---A character walking to a point and then on in a direction until it has left the map.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here, the last point before the exit (nil is refused with a warning)
---@param direction ActorDirection direction in which the character leaves, 0-15 (ActorDirection), or -1 for the way it currently faces
---@param style MovementStyle 0 walk, 1 run
---@return CyrSequence
function CyrSequence:LeaveLevel(actor, location, direction, style)
    if self.CanProceed then
        self.sequence = self.sequence:LeaveLevel(actor, location, direction, style)
    end
    return self
end

---A character turning to face a point.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here
---@return CyrSequence
function CyrSequence:TurnTo(actor, location)
    if self.CanProceed then
        self.sequence = self.sequence:TurnTo(actor, location)
    end
    return self
end

---A character or target playing one of its animations once.
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return CyrSequence
function CyrSequence:PlayAnim(actor, id)
    if self.CanProceed then
        self.sequence = self.sequence:PlayAnim(actor, id)
    end
    return self
end

---A character or target playing an animation once and then holding its last frame (for example
---lying down or sitting).
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return CyrSequence
function CyrSequence:PlayAnimFreeze(actor, id)
    if self.CanProceed then
       self.sequence = self.sequence:PlayAnimFreeze(actor, id)
    end
    return self
end

---A character or target playing one of its animations over and over.
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return CyrSequence
function CyrSequence:PlayAnimLoop(actor, id)
    if self.CanProceed then
        self.sequence = self.sequence:PlayAnimLoop(actor, id)
    end
    return self
end

---Switching off a character's AI (like Actor:LockAi without remembering events): an NPC stops
---reacting to what it sees and hears so the sequence can move it freely.
---@param actor Actor an NPC or an animal
---@return CyrSequence
function CyrSequence:LockAi(actor)
    if self.CanProceed then
        self.sequence = self.sequence:LockAi(actor)
    end
    return self
end

---Switching a character's AI back on; an NPC then returns to its duty.
---@param actor Actor an NPC or an animal
---@return CyrSequence
function CyrSequence:UnlockAi(actor)
    if self.CanProceed then
        self.sequence = self.sequence:UnlockAi(actor)
    end
    return self
end

---Taking control away from the player: mouse and interface stop reacting and the heroes are
---deselected. Always record Sequence:UnlockUser at the end.
---@return CyrSequence
function CyrSequence:LockUser()
    if self.CanProceed then
        self.sequence = self.sequence:LockUser()
    end
    return self
end

---Giving control back to the player after Sequence:LockUser.
---@return CyrSequence
function CyrSequence:UnlockUser()
    if self.CanProceed then
        self.sequence = self.sequence:UnlockUser()
    end
    return self
end

---A character going after another (possibly moving) actor until it is within the given distance.
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style SeekStyle 1 walk, any other value run (the reverse of MovementStyle!)
---@param distance number distance in map pixels at which the character stops
---@return CyrSequence
function CyrSequence:SeekActor(actor, target, style, distance)
    if self.CanProceed then
        self.sequence = self.sequence:SeekActor(actor, target, style, distance)
    end
    return self
end

---A character performing a scripted action such as turning, aiming, shooting, sword fighting or
---looking around.
---@param actor Actor a character
---@param id ScriptCommand action: 0 wait, 1 turn to direction number, 2 aim bow, 3 aim bow upwards, 4 shoot at actor number, 5 start a sword fight with actor number, 6 leave the sword fight, 7 parry, 8-16 sword thrusts A-I against actor number, 17 look left (soldiers only), 18 look right (soldiers only), 19 put the bow away, 20 crouch
---@param number integer for 1: direction 0-15; for 4, 5 and 8-16: the index of the target actor (Actor.index); ignored otherwise
---@return CyrSequence
function CyrSequence:Action(actor, id, number)
    if self.CanProceed then
        self.sequence = self.sequence:Action(actor, id, number)
    end
    return self
end

---Replacing one of a character's animations with another (for example walking with a limp instead
---of walking) until Sequence:RestoreAnim.
---@param actor Actor a character
---@param oldAnim ActorAction animation ID to replace
---@param newAnim ActorAction animation ID to play instead
---@return CyrSequence
function CyrSequence:ReplaceAnim(actor, oldAnim, newAnim)
    if self.CanProceed then
        self.sequence = self.sequence:ReplaceAnim(actor, oldAnim, newAnim)
    end
    return self
end

---Undoing a Sequence:ReplaceAnim for one animation.
---@param actor Actor a character
---@param oldAnim ActorAction the animation ID that was replaced
---@return CyrSequence
function CyrSequence:RestoreAnim(actor, oldAnim)
    if self.CanProceed then
        self.sequence = self.sequence:RestoreAnim(actor, oldAnim)
    end
    return self
end

---A hero saying one of the hero remarks, in a chosen variant.
---@param actor Actor a hero (PC); nil is refused with a warning
---@param id PcRemark hero remark ID
---@param variant integer variant of the remark (which recording)
---@return CyrSequence
function CyrSequence:SpeakPc(actor, id, variant)
    if self.CanProceed then
        self.sequence = self.sequence:SpeakPc(actor, id, variant)
    end
    return self
end

---A character walking into a building: the door nearest to the point (within 300 map pixels) is
---used, and the character walks through it.
---@param actor Actor a character
---@param location Location a point location (Locations.Name); a zone does not work here near the building's door (nil is refused with a warning)
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@return CyrSequence
function CyrSequence:MoveIntoBuilding(actor, location, style)
    if self.CanProceed then
        self.sequence = self.sequence:MoveIntoBuilding(actor, location, style)
    end
    return self
end

---A hero who can carry bodies (Little John or a merry man) going to a body and picking it up.
---@param taker Actor a hero with the carry action
---@param corpse Actor the knocked-out, tied or dead character to carry
---@param style MovementStyle 0 walk, any other value run
---@return CyrSequence
function CyrSequence:TakeCorpse(taker, corpse, style)
    if self.CanProceed then
        self.sequence = self.sequence:TakeCorpse(taker, corpse, style)
    end
    return self
end

---A hero putting down the body he is carrying.
---@param actor Actor a hero with the carry action (Little John or a merry man)
---@return CyrSequence
function CyrSequence:LeaveCorpse(actor)
    if self.CanProceed then
        self.sequence = self.sequence:LeaveCorpse(actor)
    end
    return self
end

---Starting a cart (a mobile element) moving along its path.
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return CyrSequence
function CyrSequence:StartMobileElement(mobileElement)
    if self.CanProceed then
        self.sequence = self.sequence:StartMobileElement(mobileElement)
    end
    return self
end

---Stopping a cart (a mobile element).
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return CyrSequence
function CyrSequence:StopMobileElement(mobileElement)
    if self.CanProceed then
        self.sequence = self.sequence:StopMobileElement(mobileElement)
    end
    return self
end

---A character saying a remark: an NPC says an NPC remark, a hero says the hero remark with that ID
---(first variant). The remark is always spoken.
---@param actor Actor a human (NPC or hero); nil is refused with a warning
---@param id NpcRemark remark ID, below the number of NPC remarks
---@return CyrSequence
function CyrSequence:Speak(actor, id)
    if self.CanProceed then
        self.sequence = self.sequence:Speak(actor, id)
    end
    return self
end

---A character going after another actor until it is within the given distance, then sending a
---message to a script (as Sequence:SendMessage does).
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style MovementStyle 0 walk, any other value run
---@param distance number distance in map pixels at which the character stops
---@param actorEvent Actor receiver of the message: an actor with a script class, or God() for the level script
---@param id integer message number passed to ProcessMessage
---@return CyrSequence
function CyrSequence:SeekActorMessage(actor, target, style, distance, actorEvent, id)
    if self.CanProceed then
        self.sequence = self.sequence:SeekActorMessage(actor, target, style, distance, actorEvent, id)
    end
    return self
end

---Like Sequence:SeekActorMessage, with two extra numbers passed to ProcessMessage.
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style MovementStyle 0 walk, any other value run
---@param distance number distance in map pixels at which the character stops
---@param actorEvent Actor receiver of the message: an actor with a script class, or God() for the level script
---@param id integer message number, 1000 or more (up to 10000; RhMod uses 10001 and above)
---@param arg1 integer first number passed to ProcessMessage
---@param arg2 integer second number passed to ProcessMessage
---@return CyrSequence
function CyrSequence:SeekActorMessageWithArguments(actor, target, style, distance, actorEvent, id, arg1, arg2)
    if self.CanProceed then
        self.sequence = self.sequence:SeekActorMessageWithArguments(actor, target, style, distance, actorEvent, id, arg1, arg2)
    end
    return self
end

---Making a cart (a mobile element) appear and take part in the game again.
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return CyrSequence
function CyrSequence:ActivateMobileElement(mobileElement)
    if self.CanProceed then
        self.sequence = self.sequence:ActivateMobileElement(mobileElement)
    end
    return self
end

---Removing a cart (a mobile element) from the game (hidden and inactive).
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return CyrSequence
function CyrSequence:DeactivateMobileElement(mobileElement)
    if self.CanProceed then
        self.sequence = self.sequence:DeactivateMobileElement(mobileElement)
    end
    return self
end

---Revealing a 'blipped' character (see Actor:Reveal).
---@param actor Actor a character
---@return CyrSequence
function CyrSequence:Reveal(actor)
    if self.CanProceed then
        self.sequence = self.sequence:Reveal(actor)
    end
    return self
end

-------------------------- THE ORIGINAL SEQUENCE FUNCTIONS AS GLOBAL FUNCTIONS --------------------------------------

---@param sequence CyrSequence
---@param actor Actor
---@param location Location
---@param movementStyle MovementStyle
---@return CyrSequence
function CyrSequenceMove(sequence, actor, location, movementStyle)
    return sequence
        :Move(actor, location, movementStyle)
end

---@param sequence CyrSequence
---@param actor Actor
---@param location Location
---@return CyrSequence
function CyrSequenceTurnTo(sequence, actor, location)
    return sequence
        :TurnTo(actor, location)
end

---@param sequence CyrSequence
---@param location Location
---@return CyrSequence
function CyrSequenceMoveCameraTo(sequence, location, speed)
    return sequence
        :MoveCameraTo(location, speed)
end

function SetProperty(object, propertyName, value)
    object[propertyName] = value
end