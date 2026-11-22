-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

FoA = {
  Animations = {
    butterflyMid1 = Animations["Animation_9"],
    butterflyMid2 = Animations["Animation_10"],
    butterflyWest = Animations["Animation_11"],
    birdNorth = Animations["Animation_12"],
  }
}

FoB = {
  Animations = {
    butterflyNorthEast1 = Animations["Animation_8"],
    butterflyNorthEast2 = Animations["Animation_9"],
    butterflySouth1 = Animations["Animation_10"],
    butterflySouth2 = Animations["Animation_11"],
    butterflySouth3 = Animations["Animation_12"],
    butterflyWest1 = Animations["Animation_13"],
    butterflyWest2 = Animations["Animation_14"],
  }
}

FoC = {
  Animations = {
    butterflyNorth = Animations["Animation_11"],
    butterflyMid1 = Animations["Animation_12"],
    butterflyMid2 = Animations["Animation_13"],
    birdNorth = Animations["Animation_14"],
  }
}

local vocal = false
local function printIf(message)
  if vocal then
    print(message)
  end
end

---comment Inicializes placeholders of PCs who could be under leaves.
---@param placeholder Actor The placeholder.
---@param patch Patch The patch that would be applied when the PC stands up from leaves
function PreparePlaceholderForAmbush(placeholder, patch)
  if placeholder == nil then
    patch:SetAnimationActive(false)
  end
end

---comment Creates an actor object for a PC under the leaves.
---@param patchName string The patch to apply when the pc stands up from the leaves.
---@return ActorScriptEvents # The actor object.
function PcUnderLeavesActor(patchName)
  local g = "pcUnderLeaves_" .. patchName
  return {
    Initialize = function()
      Globals[g] = false
    end,

    ActionChange = function(action, oldAction)
      if not Globals[g] then
        if action == ActorAction.hidden_to_waiting then
          Globals[g] = true
          Patches[patchName]:Apply()
        end
      end
    end,
  }
end

---comment Creates a zone object for a ground(hole) trap.
---@param zoneName string The name of the whole zone of the ground trap.
---@param middlePointName string The name of middle point of the ground trap.
---@param patchName integer The patch triggered when someone falls into the trap.
---@return ZoneScriptEvents # The zone object of a ground trap. 
function GroundTrapZone(zoneName, middlePointName, patchName)
  local g = "groundTrap_" .. zoneName .. "_" .. patchName
  return {
    Initialize = function()
      printIf("ground trap init start " .. zoneName)
      Globals[g] = false
      Locations[middlePointName]:AddRepulsivePoint(30, 10, 1)
      printIf("ground trap init end " .. zoneName)
    end,

    Enter = function(actor)
      if not Globals[g] then
        if not actor.is_rider then
          if not actor.is_hero then
            if actor.attitude == AiAttitude.hostile then
              Globals[g] = true
              Patches[patchName]:Apply()
              DeactivateInside(actor)
              actor:ConfiscateMoney()
              actor:SetActorLocation(NoWhere())
              Locations[middlePointName]:AddRepulsivePoint(30, 10, 2 | 4)
            end
          end
        end
      end
    end,
  }
end

---@class TreeMerryman
---@field man string The name of the merry man actor.
---@field rope string The name of the target actor that plays the animation of climbing down a rope.
---@field location string The name of the location to put the merry man to.

---comment Creates a target object which makes three men climb ropes down from a tree when triggered.
---@param targetName string The name of the target actor.
---@param men TreeMerryman[] The merry men representation.
---@return TargetScriptEvents # The target script object.
function TreeMerrymenTarget(targetName, men)
  local g = "treeMen_" .. targetName
  local timers = {
    { init = 6, climb = 129, },
    { init = 1, climb = 124, },
    { init = 9, climb = 132, },
  }
  return {
    Initialize = function()
      printIf("tree men init start " .. targetName)
      for _, m in ipairs(men) do
        InitMerryMan(Actors[m.man])
      end
      Globals[g] = false
      printIf("tree men init end " .. targetName)
    end,

    ActivatedByArrow = function(actorSource)
      if not Globals[g] then
        Globals[g] = true
        Sequence()
          :PlayAnimFreeze(Actors[targetName], ActorAction.target_1)
          :Start()
  
        for i, m in ipairs(men) do
          Sequence()
            :Wait(timers[((i - 1) % 3) + 1].init)
            :Then()
            :PlayAnimFreeze(Actors[m.rope], ActorAction.target_1)
            :Start()
        end

        for i, m in ipairs(men) do
          Sequence()
            :Wait(timers[((i - 1) % 3) + 1].climb)
            :Then()
            :PlayAnimFreeze(Actors[m.rope], ActorAction.target_2)
            :Then()
            :Call(function ()
              Actors[m.man].location = Locations[m.location]
              Actors[m.man]:UnlockAi()
            end)
            :Start()
        end
      end
    end,
  }
end

---@class HiddenArcher
---@field man string The name of the archer actor.
---@field location string The location to place the archer at.

---comment Creates a target object for three hidden archers to appear.
---@param targetName string The name of the target actor.
---@param patchVisualName string The visual patch to apply when the target is hit. 
---@param patchMotionName string The motion patch to apply when the target is hit.
---@param archers HiddenArcher[] The representation of the archers.
---@return TargetScriptEvents # The target script object.
function HiddenArchersTarget(targetName, patchVisualName, patchMotionName, archers)
  local g = "hiddenArchers_" .. targetName
  return {
    Initialize = function()
      printIf("hidden archers init start " .. targetName)
      for _, a in ipairs(archers) do
        InitMerryMan(Actors[a.man])
      end
      Globals[g] = false
      printIf("hidden archers init end " .. targetName)
    end,

    ActivatedByArrow = function(actorSource)
      if not Globals[g] then
        Globals[g] = true
  
        Patches[patchVisualName]:Apply()
        Patches[patchMotionName]:Apply()
  
        for _, a in ipairs(archers) do
          Actors[a.man].location = Locations[a.location]
        end
  
        Sequence()
          :PlayAnimFreeze(Actors[targetName], ActorAction.target_1)
          :Start()
  
        Sequence()
          :Wait(10)
          :Then()
          :Call(function ()
            for _, a in ipairs(archers) do
              ShowPersonInside(Actors[a.man])
            end
          end)
          :Start()
      end
    end,
  }
end

---comment Crates a target object for pushable logs.
---@param mainTarget string The name of the target actor.
---@param target2 string The second target actor (only for animation).
---@param target3 string The third target actor (only for animation).
---@param visualPatch string The persistent visual patch showing the fallen logs.
---@param motionPatch string The motion patch which makes the fallen logs unpassable.
---@param noiseLoc string? The location where the falling locs make a sound
---@param killZone1 string The first killing zone.
---@param killZone2 string The second killing zone.
---@param otherKillZones [string] The rest of the killing zones.
---@param riderEscapeLocs [string] The position that any rider character escapes to.
---@return TargetScriptEvents # The target object for logs.
function PushedLogsTarget(mainTarget, target2, target3, visualPatch, motionPatch, noiseLoc, killZone1, killZone2, otherKillZones, riderEscapeLocs)
  local g = "LogsPushed_" .. mainTarget
  return {
    Initialize = function()
      printIf("logs init start " .. mainTarget)
      Globals[g] = false
      Actors[target2]:Deactivate()
      Actors[target3]:Deactivate()
      printIf("logs init end " .. mainTarget)
    end,

    ActivatedByLever = function(actorSource)
      if not Globals[g] then
        Globals[g] = true
        Actors[target2]:Activate()
        Actors[target3]:Activate()
        Sequence()
          :PlayAnimFreeze(Actors[mainTarget], ActorAction.getting_up_from_sitting)
          :PlayAnimFreeze(Actors[target2], ActorAction.getting_up_from_sitting)
          :PlayAnimFreeze(Actors[target3], ActorAction.getting_up_from_sitting)
          :Then()
          :Call(function ()
            Patches[visualPatch]:Apply()
          end)
          :Start()

        Sequence()
          :Wait(60)
          :Then()
          :Call(function ()
            Patches[motionPatch]:Apply()
          end)
          :Start()

        local s = Sequence()
          :Wait(15)
          :Then()
          :Call(function ()
            KillActorsInZone(Locations[killZone1])
            if not (noiseLoc == nil) then
              Locations[noiseLoc]:MakeNoise(NoiseType.logs)
            end
          end)
          :Then()
          :Wait(15)
          :Then()
          :Call(function ()
            KillActorsInZone(Locations[killZone2])
          end)
        for _, zone in ipairs(otherKillZones) do
          s = s
            :Then()
            :Wait(10)
            :Then()
            :Call(function ()
            KillActorsInZone(Locations[zone])
          end)
        end
          s
          :Then()
          :Call(function ()
            Actors[mainTarget]:Deactivate()
            Actors[target2]:Deactivate()
          end)
          :Start()

        EscapeWithRiders(riderEscapeLocs, ConcatInNew({killZone1, killZone2}, otherKillZones))
      end
    end,
  }
end

---@class TargetAndZone
---@field Target TargetScriptEvents The Target script object.
---@field Zone ZoneScriptEvents The Zone script object.

---comment Creates both zone and target object for an eject swing trap.
---@param zone string The name of the whole zone of the trap.
---@param target string? The name of the target actor.
---@param trap string The name of the trap actor that makes the eject animation.
---@param fullTrapPatch string The patch that is applied if someone was caught by the trap.
---@param emptyTrapPatch string The patch that is applied if noone was caught by the trap.
---@param leavesPatch string The patch that makes the falling leaves when the trap is triggered.
---@return TargetAndZone # A table that includes both the Zone and the Target.
function EjectSwingTrapTargetAndZone(zone, target, trap, fullTrapPatch, emptyTrapPatch, leavesPatch)
  local g = "ejectTrapCounter_" .. trap
  return {
    Target = {
      Initialize = function()
        printIf("eject trap init start " .. zone)
        Globals[g] = #GetAllActorsInZone(Locations[zone])
        printIf("eject trap init end " .. zone)
      end,

      ActivatedByArrow = function(actorSource)
        local s = Sequence()
          :PlayAnimFreeze(Actors[trap], ActorAction.getting_up_from_sitting)
        if not (target == nil) then
          s = s
            :PlayAnimFreeze(Actors[target], ActorAction.target_1)
        end
        s:Start()
        if Globals[g] > 0 then
          Patches[fullTrapPatch]:Apply()
          TrapVanishNPCs(Locations[zone])
        else
          Patches[emptyTrapPatch]:Apply()
        end
        Patches[leavesPatch]:Apply()
      end,
    },
    Zone = {
      Enter = function(actor)
        Globals[g] = Globals[g] + 1
      end,
    
      Exit = function(actor)
        Globals[g] = Globals[g] - 1
      end,
    }
  }
end

---comment Creates a target object for a falling rock.
---@param rockTarget string The name of the target actor.
---@param rockTargetAnim string The name of the actor that actually does the rock animation.
---@param killZone string The name of the zone where everyone is killed by the falling rock.
---@param noiseLoc string? The name of the location at which a noise is created.
---@param walkPatchOrigPos string The patch that makes the original location of the rock passable.
---@param walkPatchNewPos string The patch that makes the new location of the rock non-passable.
---@param previousStoneLocPatch string The patch that makes the original location of the rock look pretty.
---@param riderEscapeLocs string[] List of locations a potential rider inside the impact area can run to.
---@return TargetScriptEvents # The target script object of the falling rock.
function FallingRockTarget(rockTarget, rockTargetAnim, killZone, noiseLoc, walkPatchOrigPos, walkPatchNewPos, previousStoneLocPatch, riderEscapeLocs)
  local g = "fallingRock_" .. rockTarget
  return {
    Initialize = function()
      Globals[g] = false
    end,

    ActivatedByLever = function(actorSource)
      if not Globals[g] then
        Globals[g] = true
        Actors[rockTarget]:Deactivate()
  
        Sequence()
          :PlayAnimFreeze(Actors[rockTargetAnim], ActorAction.getting_up_from_sitting)
          :Then()
          :Call(function ()
            Patches[previousStoneLocPatch]:Apply()
          end)
          :Start()
  
        Sequence()
          :Wait(60)
          :Then()
          :Call(function ()
          Patches[walkPatchOrigPos]:Apply()
          Patches[walkPatchNewPos]:Apply()
          if not (noiseLoc == nil) then
            Locations[noiseLoc]:MakeNoise(NoiseType.logs)
          end
        end)
          :Start()
  
        Sequence()
          :Wait(30)
          :Then()
          :Call(function ()
            KillActorsInZone(Locations[killZone])
          end)
          :Start()

        EscapeWithRiders(riderEscapeLocs, {killZone})
      end
    end,
  }
end

---comment Makes all actors in a given zone vanish. Used for traps.
---@param zone Location The zone to vanish actors in.
function TrapVanishNPCs(zone)
  for _, a in pairs(Actors) do
    if a ~= nil then
      if a:IsInside(zone) then
        if not a.is_rider then
          if a.is_hero then
            a:Deactivate()
          else
            if a.attitude == 1 then
              DeactivateInside(a)
              a:ConfiscateMoney()
              a.location = NoWhere()
            end
          end
        end
      end
    end
  end
end

---comment Kills all actors in a given zone. Used for traps.
---@param zone Location The zone to kill everyone in.
function KillActorsInZone(zone)
  for _, a in pairs(Actors) do
    if (a ~= nil) and a:IsInside(zone) then
      if a.is_hero then
        a:Deactivate()
      else
        a:Damage(10, true)
      end
    end
  end
end

function tuage(zone)
  for _, a in pairs(Actors) do
    if (a ~= nil) and a:IsInside(zone) then
      if a.is_hero then
        a:Deactivate()
      else
        a:ConfiscateMoney()
        a:Damage(10, true)
      end
    end
  end
end

---comment Initializes an AI merry man (in trres or archer).
---@param merryman Actor The merry man actor.
function InitMerryMan(merryman)
  print("initializing merry man: " .. merryman.name)
  merryman.location = NoWhere()
  DeactivateInside(merryman)
end

---comment
---@param riderEscapeLocs string[] The names of locations the rider may escape to.
---@param killZones string[] The names of locations where the actors get killed.
function EscapeWithRiders(riderEscapeLocs, killZones)
  if #riderEscapeLocs > 0 then
    for _, a in pairs(Actors) do
      if a.is_rider then
        local isIn = false
        for _, zone in ipairs(killZones) do
          if a:IsInside(Locations[zone]) then
            isIn = true
            break
          end
        end
        if isIn then
          local aPos = a.location
          local loc = aPos
          if(aPos ~= nil and loc ~= nil) then
            local dist = 1000000
            for _, v in ipairs(riderEscapeLocs) do
              local d = aPos:DistanceTo(Locations[v])
              if d < dist then
                dist = d
                loc = Locations[v]
              end
            end
            Sequence()
              :LockAi(a)
              :Then()
              :MoveNear(a, loc, MovementStyle.running, 20)
              :Then()
              :UnlockAi(a)
              :Start()
          end
        end
      end
    end
  end
end

function ActivateAllPCs()
  for i = 0,(GetNumberOfPcs() - 1) do
    local pc = GetPc(i)
    if (pc ~= nil) then
      pc:Activate()
    end
  end
end

function DeactivateAllPCs()
  for i = 0,(GetNumberOfPcs() - 1) do
    local pc = GetPc(i)
    if (pc ~= nil) then
      pc:Deactivate()
    end
  end
end