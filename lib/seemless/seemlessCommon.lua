-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

local verbose = true

---@type {[string]: HiddenSpace}
HiddenSpaces = {}

---@return {[string]: Actor}
local GetAllNPCs = function()
  local NPCs = {}
  for key, a in pairs(Actors) do
    if a.is_npc then
      NPCs[key] = a
    end
  end
  return NPCs
end

---Finds out whether all of the supplied doors can theoretically be passed by the player.
---@param doorNames string[]
---@return boolean
local AreDoorsUnlockedOrUnlockable = function (doorNames)
  for _, name in pairs(doorNames) do
    local door = Doors[name]
    if (door.locked_for_pcs) and (not door.unlockable) then
      return false
    end
  end
  return true
end

---@return {[string]: Actor}
local GetAllTargets = function()
  local targets = {}
  -- for key, a in pairs(Actors) do
  --   if a.is_target then
  --     targets[key] = a
  --   end
  -- end
  return targets
end

local Concat = function (table1, table2)
  local result = {}
  for key, value in pairs(table1) do
    result[key] = value
  end
  for key, value in pairs(table2) do
    result[key] = value
  end
  return result
end

local ConcatTable = function(tableOfTables)
  local result = {}
  for k, tab in pairs(tableOfTables) do
    result = Concat(result, tab)
  end
  return result
end

---@return {[string]: Actor}
local GetDeactivatableObjects = function()
  local scrolls = {}
  for key, val in pairs(Scrolls) do
    if val.state > ScrollState.invisible then
      scrolls[key] = val
    end
  end
  return ConcatTable({GetAllNPCs(), GetAllTargets(), Items, scrolls})
end

---comment
---@param actor Actor
---@param name string
---@param isActive boolean
local SetActive = function(actor, name, isActive)
  if isActive then
    if verbose then
      print("Activating " .. name)
    end
    actor:Activate()
    if actor.is_npc then
      actor:SetCustomValue(NPCValueIndices.UnlockableAI, 0)
      actor:UnlockAi()
    end
  else
    if verbose then
      print("Deactivating " .. name)
    end
    actor:Deactivate()
    if actor.is_npc then
      actor:LockAi(false)
      actor:SetCustomValue(NPCValueIndices.UnlockableAI, 1)
    end
  end
end

---comment
---@param where HiddenSpace
---@param isActive boolean
local SetActiveIn = function(where, isActive)
  for key, a in pairs(where.Objects) do
    SetActive(a, key, isActive)
  end
end

---comment
---@param locations Location[]
---@param potentialObjects {[string]: Actor}
---@return {[string]: Actor}
local GetObjectsInLocations = function (locations, potentialObjects)
  local result = {}
  for key, a in pairs(potentialObjects) do
    for k2, loc in pairs(locations) do
      if a:IsInside(loc) then
        result[key] = a
      end
    end
  end
  return result
end

---@param where HiddenSpace
local RevealIfAnyPCSeesOtherwiseHide = function(where)
  if not where.CanHideAtStart then
    if not where:Reveal({}) then
      error("A space cannot be hidden during Initialize but it can also not be revealed.")
    end
    return
  end
  for i = 0,(GetNumberOfPcs()-1) do
    local pc = GetPc(i)
    if pc.active then
      local potential = GetObjectsInLocations(where.Interrior, {pc})
      if #potential > 0 then
        if where:Reveal({}) then
          return
        end
      end
      for _, value in pairs(where.Exterrior) do
        if pc:IsInside(Locations[value.Zone]) then
          if(where:Reveal(value.Doors)) then
            return
          end
        end
      end
    end
  end
  SetActiveIn(where, false)
end

---@param spaceObj HiddenSpace
local function RevealSpace(spaceObj)
  SetActiveIn(spaceObj, true)
  if spaceObj.RevealNPCs then
    for key, a in pairs(spaceObj.Objects) do
      if a.is_npc then
        a:Reveal()
      end
    end
  end
  for _, f in pairs(spaceObj.OnRevealFuncs) do
    f()
  end
end

---@param hiddens {[string]: HiddenSpace}
InitSeemless = function (hiddens)
  local all = GetDeactivatableObjects()
  for key, obj in pairs(hiddens) do
    obj.Objects = GetObjectsInLocations(obj.Interrior, all)
  end
end

---comment This reveals all places, which no playable character can see into and hides the rest.
RevealAnySeenByPCHideOthers = function()
  for key, obj in pairs(HiddenSpaces) do
    RevealIfAnyPCSeesOtherwiseHide(obj)
  end
  if verbose then
    print("")
  end
end

---comment
---@param names string[]
---@return Location[]
function LocationsFromNames(names)
  local result = {}
  for key, value in pairs(names) do
    result[key] = Locations[value]
  end
  return result
end

---@return Exterrior
---@param data ExterriorData
function ExterriorDataToExterrrior(data)
  return {
    Zone = Locations[data.Zone],
    Doors = data.Doors
  }
end

---@return Exterrior[]
---@param datas ExterriorData[]
function ExterriorDatasToExterrriors(datas)
  local result = {}
  for key, value in pairs(datas) do
    result[key] = ExterriorDataToExterrrior(value)
  end
  return result
end

---@return HiddenSpace
---@param interrior string[] The names of locations inside the hidden space.
---@param exterrior ExterriorData[] The names of locations from which we can see in the hidden space.
---@param mainObj RevealingController
function GetBaseObject(interrior, exterrior, mainObj)
  return {
    Interrior = LocationsFromNames(interrior),
    Exterrior = ExterriorDatasToExterrriors(exterrior),
    MainObj = mainObj,
    Objects = {},
    OnRevealFuncs = {},
    Condition = function () return true end,
    RevealNPCs = false,
    CanHideAtStart = true,

    Reveal = function(self, doors)
      if not self.MainObj.patch.applied then
        if AreDoorsUnlockedOrUnlockable(doors) then
          if self.Condition() then
            self.MainObj:Reveal()
            RevealSpace(self)
            return true
          end
        end
      end
      return false
    end
  }
end