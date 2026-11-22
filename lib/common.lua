-- Migrated to RhMod's object API. See MIGRATION_NOTES.md for marked differences.
-- These sources must be bundled into mission scripts (RhMod does not support require).
require("lib.enums")

function RevealAll()
  for _, actor in pairs(Actors) do actor:Reveal() end
end

function RevealNPCsInSector(locationName)
  local location = Locations[locationName]
  for _, actor in ipairs(location.actors_inside) do
    if actor.is_npc then actor:Reveal() end
  end
end

function RevealActors(actors)
  for _, actor in pairs(actors) do
    if actor.is_npc then actor:Reveal() end
  end
end

---@param zone Location
---@return Actor[]
function GetAllActorsInZone(zone)
  local result = {}
  for _, actor in ipairs(zone.actors_inside) do
    if actor.is_npc then result[#result + 1] = actor end
  end
  return result
end

function HandleScrollCameraSequence(actorSource, targetLocation)
  Sequence():SetZoomLevel(ZoomLevel.default):Then()
    :LockUser():FreezeAll(true):Then()
    :ScrollCameraTo(Locations[targetLocation]):Then()
    :Wait(55 / 25):Then() -- MIGRATION: frames -> seconds (same duration at 25 fps)
    :JumpCameraTo(actorSource.location):Then()
    :UnlockUser():FreezeAll(false):Start()
end

function IsInsideAnyBuilding(actor)
  return actor:IsInsideBuilding(nil)
end


function RemoveScrollFromNPC(npc)
  if npc.is_npc then npc:AttachScroll(nil) end
end

-- MIGRATION: ScrollState's meaning has changed between APIs. Old 'collected' means
-- new 'taken'; old 'default' means new 'visible'. Verify old 'persistent' behavior.
function UpdateScrollIfShownElseCollected(scroll, ifShown)
  if scroll.state == ScrollState.invisible then
    UpdateScrollState(scroll, ScrollState.taken)
  else
    UpdateScrollState(scroll, ifShown)
  end
end

function UpdateScrollState(scroll, state)
  local oldState = scroll.state
  if oldState < state then
    if oldState <= ScrollState.visible then scroll.state = state end
  elseif oldState == ScrollState.opened and state == ScrollState.taken then
    scroll.state = state
  end
end

function ActivateActors(actors)
  for _, actor in pairs(actors) do actor:Activate(); actor:UnlockAi() end
end
function DeactivateActors(actors)
  for _, actor in pairs(actors) do actor:Deactivate(); actor:LockAi(false) end
end
function ActivateNPC(actor, value)
  if value == false then actor:LockAi(false); actor:Deactivate()
  else actor:UnlockAi(); actor:Activate() end
end
function ActivateItems(items)
  for _, item in pairs(items) do item:Activate() end
end
function DeactivateItems(items)
  for _, item in pairs(items) do item:Deactivate() end
end
function DeactivateScrolls(scrolls)
  for _, scroll in pairs(scrolls) do scroll.state = ScrollState.invisible end
end
function ActivateScrolls(scrolls)
  for _, scroll in pairs(scrolls) do scroll.state = ScrollState.visible end
end
function SetCurrentActorPost(actor)
  actor:AssignPost(actor.location, actor.direction)
end

-- MIGRATION: SIGNATURE CHANGE: accept Door objects, not numeric indices.
function ActivateDoors(doors)
  for _, door in pairs(doors) do door:SetClickable(true) end
end
function DeactivateDoors(doors)
  for _, door in pairs(doors) do door:SetClickable(false) end
end
-- MIGRATION: SIGNATURE CHANGE: accept Animation objects, not numeric indices.
function ActivateAnimations(animations)
  for _, animation in pairs(animations) do animation:Activate() end
end
function DeactivateAnimations(animations)
  for _, animation in pairs(animations) do animation:Deactivate() end
end
function ActivateSherwoodSigns()
  for name, actor in pairs(Actors) do
    if name:find('Panneau_') then actor:Activate() end
  end
end
function DeactivateSherwoodSigns()
  for name, actor in pairs(Actors) do
    if name:find('Panneau_') then actor:Deactivate() end
  end
end
function PrintAll()
  for name, actor in pairs(Actors) do print(actor.index, ':', name) end
end
function IsPCSafe(actor, exitLocations)
  for _, location in pairs(exitLocations) do
    if actor:IsInside(Locations[location]) then return true end
  end
  return false
end

function LockAllAI()
  for _, actor in pairs(Actors) do if actor.is_npc then actor:LockAi(true) end end
end
function UnlockAllAI()
  for _, actor in pairs(Actors) do if actor.is_npc then actor:UnlockAi() end end
end

function UnlockUnlockableAI()
  for _, actor in pairs(Actors) do
    if actor.is_npc and actor:GetCustomValue(NPCValueIndices.UnlockableAI) ~= 1 then
      actor:UnlockAi()
    end
  end
end
function DeactivateInside(actor) DeactivateInsideCustom(actor, false) end
function DeactivateInsideCustom(actor, aiRememberEvents)
  actor:Deactivate(); LockOnPlaceCustom(actor, aiRememberEvents)
end
function LockOnPlace(actor) LockOnPlaceCustom(actor, false) end
function LockOnPlaceCustom(actor, aiRememberEvents)
  actor:LockAi(aiRememberEvents)
  actor:SetCustomValue(NPCValueIndices.UnlockableAI, 1)
end
function UnlockFromPlace(actor)
  actor:UnlockAi()
  actor:SetCustomValue(NPCValueIndices.UnlockableAI, 0)
end
function ShowPersonInside(actor) actor:Activate(); UnlockFromPlace(actor) end

-- MIGRATION: SIGNATURE CHANGE: pass a Door object rather than its numeric index.
function LockDoorForAll(door) SetLockDoorForAll(door, true) end
function SetLockDoorForAll(door, value)
  door.locked_for_pcs = value
  door.locked_for_villains = value
  door.locked_for_civilians = value
end
function DoorLockedButUnlockable(door)
  door.locked_for_pcs = true
  door.unlockable = true
end

function ConcatInPlace(into, other)
  for _, value in pairs(other) do table.insert(into, value) end
  return into
end
function ConcatInNew(first, second)
  return ConcatInPlace(ConcatInPlace({}, first), second)
end

local debugNamesVisible = false
function DebugFunc(name, f)
  if debugNamesVisible then
    print(name .. ' start')
    local result = f()
    print(name .. ' end')
    return result
  end
  return f()
end

function PercentOfEnemiesDeadExcept(exceptSet)
  local all, dead = 0, 0
  for _, actor in pairs(Actors) do
    if actor.is_soldier and actor.attitude == AiAttitude.hostile
       and not IsSameAsAnyOf(actor, exceptSet) then
      all = all + 1
      if actor.dead then dead = dead + 1 end
    end
  end
  print('percents computed')
  if all == 0 then return {isOk = false, percents = 0} end
  return {isOk = true, percents = dead * 100 / all}
end
function IsSameAsAnyOf(actor, setOfActors)
  for _, other in ipairs(setOfActors) do
    if other == actor then return true end
  end
  return false
end
function KillActor(actor) actor:Damage(10000, true) end
function KillPercentOf(percent, actors)
  if #actors == 0 then return end
  local part, currPercent = 100 / #actors, 0
  for _, actor in pairs(actors) do
    local nextPercent = currPercent + part
    if nextPercent <= percent then
      KillActor(actor)
    else
      if currPercent < percent and (percent - currPercent) * 100 / part > 50 then
        KillActor(actor)
      end
      break
    end
    currPercent = nextPercent
  end
end
function FinalizeUnkillableActors(actors)
  local percentObj = PercentOfEnemiesDeadExcept(actors)
  if percentObj.isOk then KillPercentOf(percentObj.percents, actors) end
end

function IsOutOfActionIfEnemy(actor)
  return actor == nil or not actor.is_soldier or
    actor.attitude ~= AiAttitude.hostile or actor.out_of_action or not actor.active
end
function StoreAndInjectRansomMoney(newValue)
  SetCustomCampaignValue(CampaignValueIndices.InterMissionMoney, GetRansomMoney())
  SetRansomMoney(newValue)
end
function RestoreRansomMoney()
  SetRansomMoney(GetCustomCampaignValue(CampaignValueIndices.InterMissionMoney))
end

---Makes the actor unconscious with the specified concussion.
---@param actor Actor The actor to make unconscious.
---@param concussion? integer The concussion to apply. Default is 32.
function MakeActorUnconscious(actor, concussion)
  if concussion == nil then
    concussion = 32
  end
  actor:Damage(0, true)
  actor:SetProperty(PersistentProperty.concussion, concussion)
end