require("customSequence")
require("seemless.H01")

local portToDebugPosition = false
local startingLocation = "Node_170"
local startingCameraLocation = "Node_159"

SeeDadState = {
  notActive = 0,
  active = 1,
  inZone = 2,
  seeTriggered = 3,
  seeDone = 4
}

Globals = {
  executionStarted = false,
  isGodwinOnPlace = 0,
  currentTargetGroup = 1,
  firstTaxCollectorSend = true,
  shiftScrollPickedUp = false,
  pursesScrollPickedUp = false,
  arrowsScrollPickedUp = false,
  canTriggerSearchPatrol = true,
  objectiveIndex = 0,
  seeDadState = SeeDadState.active,
}

local targets = {
  {"Cible00_1", "Cible01_2", "Cible02_3", "Cible03_4"},
  {"Cible04_6"},
  {"Target_7"},
  {"Target_8"},
  {"Target_9"},
  {"Target_10"},
}

local objectiveIndices = {
  1, 2, 3, 4,
}

---Events
function Initialize(seed)
  InitH01()

  --we have to define for each internal space, when it can be revealed and what the reveal triggers
  ---@diagnostic disable: duplicate-set-field
  HiddenSpaces.prison.Condition = function ()
    return false
  end
  table.insert(HiddenSpaces.dungeon_tower.OnRevealFuncs, function ()
    Items["Money_6"]:Deactivate()
  end)
  table.insert(HiddenSpaces.weapon_room.OnRevealFuncs, function ()
    if not (Globals.currentTargetGroup == 5) then
      Actors["Target_9"]:Deactivate()
    end
  end)
  ---@diagnostic enable: duplicate-set-field

  --if a playable character starts at a place, from which it can see into some building, this reveals it.
  RevealAnySeenByPCHideOthers()

  GetRobinFake().location = NoWhere()
  JumpCameraTo(Locations["Node_38"])
  DrawBridgeRoom:ActivateDrawBridge(NoWhere())

  DeactivateInside(Actors["Soldier_20"])
  DeactivateInside(Actors["Soldier_21"])
  DeactivateInside(Actors["Soldier_22"])
  DeactivateInside(Actors["Soldier_23"])
  DeactivateInside(Actors["Soldier_24"])

  DeactivateInside(Actors["Soldier_28"])
  DeactivateInside(Actors["Soldier_29"])
  DeactivateInside(Actors["Soldier_31"])

  Actors["GodwinBody_16"]:Deactivate()
  Actors["Civilian_17"]:Deactivate()
  Items["Arrows_3"]:Deactivate()
  Items["Money_5"]:Deactivate()
  Items["Purses_7"]:Deactivate()
  
  MiscAnimation.smokeOuterVillage1:Deactivate()
  MiscAnimation.smokeOuterVillage2:Deactivate()

  for i, g in ipairs(targets) do
    if not (i == Globals.currentTargetGroup) then
      for _, t in pairs(g) do
        Actors[t]:Deactivate()
      end
    end
  end

  Actors["Civilian_18"]:AttachScroll(Scrolls["Scroll_1"])

  Actors["Soldier_17"]:SetProperty(PersistentProperty.concussion, 1000000)

  GetRobinCustom():SetProperty(PersistentProperty.name, 1)

  GetRobinCustom():SetProperty(PersistentProperty.arrows, 0)

  Actors["MainVillain_5"]:ForbidRemark(NpcRemark.vip_speaks_to_himself, true)
  Actors["Soldier_11"]:ForbidRemark(NpcRemark.officer_complains, true)

  LockOnPlace(Actors["Soldier_1"])
  LockOnPlace(Actors["Soldier_3"])
  LockOnPlace(Actors["Soldier_19"])
  LockOnPlace(Actors["Soldier_27"])

  InitExecutionCharacters()
  LockDoorForAll(MiscDoor.dungeonEntranceOuter)
  LockDoorForAll(MiscDoor.WeaponRoomInnerHouse.outerNorthEast)
  LockDoorForAll(Battlement.Door.gardenDoor)
  MiscDoor.NorthBattlement.eastRampart.locked_for_pcs =  true
  MiscDoor.NorthBattlement.westRampart.locked_for_pcs =  true
  MiscDoor.NorthBattlement.top.locked_for_pcs =  true
  MiscDoor.NorthBattlement.courtyard.locked_for_pcs =  true
  
  -- GetDoorScript(BedRoom.Door.innerToTop).locked_for_pcs =  true
  -- GetDoorScript(BedRoom.Door.outerToTop).locked_for_pcs =  true
  
  Doors["Door_1"].locked_for_villains = false
  Doors["Door_4"].locked_for_villains = false
  Doors["Door_22"].locked_for_villains = false

  SetRansomMoney(37)
end

function PostInitialize()
  if not portToDebugPosition then
    HomecommingCutscene()
  else
    CyrSeq()
      :EnterLevel(GetRobinFake(), Locations["Node_39"], ActorDirection.east, MovementStyle.walking)
      :Then()
      :Call("SetProperty", GetRobinCustom(), "location", Locations[startingLocation])
      :Then()
      :JumpCameraTo(Locations[startingCameraLocation])
      :Call("Select", PcSelection.all)
      :Start()
  end
end

function HomecommingGateFirstWalk()
  HiddenSpaces.staircase:Reveal({})
  GetRobinFake():Deactivate()
  GetRobinFake():PutInBuilding(Buildings["Building_0"])

  CyrSeq()
    :Move(Actors["Soldier_27"], Locations["Node_136"], MovementStyle.walking)
    :Start()

  CyrSeq()
    :Wait(5)
    :Then()
    :Move(GetRobinCustom(), Locations["Node_136"], MovementStyle.walking)
    :Start()

  CyrSeq()
    :Move(Actors["Soldier_19"], Locations["Node_136"], MovementStyle.walking)
    :Start()

  CyrSeq()
    :Wait(20)
    :Then()
    :Move(Actors["Soldier_1"], Locations["Node_134"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_1"], Locations["Node_37"])
    :Start()
end

function HomecommingGateSoldiers1()
  CyrSeq()
    :Move(Actors["Soldier_27"], Locations["Node_135"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_27"], Locations["Node_132"])
    :Start()
end

function HomecommingGateSoldiers2()
  CyrSeq()
    :Wait(20)
    :Then()
    :Move(Actors["Soldier_19"], Locations["Node_134"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_19"], Locations["Node_133"])
    :Start()
end

function HomecommingFirstCamera()
  AddObjective(0, true)
  AddObjective(6, true)
  GetRobinCustom().invisible = true
  CyrSeq()
    :Move(GetRobinFake(), Locations["Node_129"], MovementStyle.walking)
    :Start()

  CyrSeq()
    :Wait(20)
    :Then()
    :MoveCameraTo(Locations["Node_143"], 15)
    :Then()
    :MoveCameraTo(Locations["Node_144"], 15)
    :Then()
    :MoveCameraTo(Locations["Node_145"], 15)
    :Then()
    :MoveCameraTo(Locations["Node_146"], 15)
    :Then()
    :MoveCameraTo(Locations["Node_147"], 15)
    :Then()
    :MoveCameraTo(Locations["Node_171"], 15)
    :Start()
end

function HomecommingSecondCamera()
  CyrSeq()
    :MoveCameraTo(Locations["Node_131"], 11)
    :Start()
end

function HomecommingCutscene()
  CyrSeq()
    :LockUser()
    :Then()
    :DisplayPopupText(0)
    :Then()
    :Wait(20)
    :Then()
    :EnterLevel(GetRobinFake(), Locations["Node_39"], ActorDirection.east, MovementStyle.walking)
    :Then()
    :Move(GetRobinFake(), Locations["Node_40"], MovementStyle.walking)
    :Then()
    :Wait(5)
    :Then()
    :TurnTo(GetRobinFake(), Locations["Node_41"])
    :Then()
    :Wait(8)
    :Then()
    :TurnTo(GetRobinFake(), Locations["Node_42"])
    :Then()
    :Wait(8)
    :Then()
    :Move(GetRobinFake(), Locations["Node_43"], MovementStyle.walking)
    :Then()
    :Wait(3)
    :Then()
    :DisplayPopupText(1)
    :Then()
    :Move(GetRobinFake(), Locations["Node_52"], MovementStyle.walking)
    :Then()
    :Move(GetRobinFake(), Locations["Node_53"], MovementStyle.walking)
    :Then()
    :MoveIntoBuilding(GetRobinFake(), Locations["Node_44"], MovementStyle.walking)
    :Then()
    :Move(GetRobinFake(), Locations["Node_45"], MovementStyle.walking)
    :Then()
    :Wait(3)
    :Then()
    :DisplayPopupText(2)
    :Then()
    :MoveIntoBuilding(GetRobinFake(), Locations["Node_46"], MovementStyle.walking)
    :Then()
    :MoveIntoBuilding(GetRobinFake(), Locations["Node_47"], MovementStyle.running)
    :Then()
    :Move(GetRobinFake(), Locations["Node_48"], MovementStyle.walking)
    :Then()
    :DisplayPopupText(3)
    :Then()
    :Call("LockAllAI")
    :Then()
    :Call("HomecommingFirstCamera")
    :Then()
    :Wait(70)
    :Then()
    :WalkThrough(GetRobinCustom(), {
      Locations["Node_51"],
      Locations["Node_50"],
      Locations["Node_37"],
    }, MovementStyle.walking)
    :Then()
    :TurnTo(GetRobinCustom(), Locations["Node_131"])
    :Then()
    :Wait(8)
    :Then()
    :DisplayPopupText(4)
    :Then()
    :DisplayPopupText(5)
    :Then()
    :Wait(10)
    :Then()
    :Call("HomecommingGateSoldiers1")
    :Then()
    :Wait(25)
    :Then()
    :Call("HomecommingGateSoldiers2")
    :Then()
    :Move(GetRobinCustom(), Locations["Node_133"], MovementStyle.walking)
    :Then()
    :TurnTo(GetRobinCustom(), Locations["Node_162"])
    :Then()
    :Wait(25)
    :Then()
    :TurnTo(GetRobinCustom(), Locations["Node_163"])
    :Then()
    :Wait(25)
    :Then()
    :Call("HomecommingGateFirstWalk")
    :Then()
    :Wait(45)
    :Then()
    :Call("HomecommingSecondCamera")
    :Then()
    :Wait(55)
    :Then()
    :Call("HomecommingStaircaseWalk")
    :Start()
end

function HomecommingRobinStaircaseWalk(s)
  return s
    :Move(GetRobinCustom(), Locations["Node_154"], MovementStyle.walking)
    :Then()
    :Wait(10)
    :Then()
    :Move(GetRobinCustom(), Locations["Node_141"], MovementStyle.walking)
end

function HomecommingAskOfficerWhatToDoWithRobin(s)
  return s
    :Wait(10)
    :Then()
    :Move(Actors["Soldier_27"], Locations["Node_149"], MovementStyle.walking)
    :Then()
    :Wait(4)
    :Then()
    :Reveal(Actors["Soldier_3"])
    :Then()
    :Wait(4)
    :Then()
    :TurnTo(Actors["Soldier_27"], Locations["Node_62"])
    :Then()
    :TurnTo(Actors["Soldier_3"], Locations["Node_149"])
    :Then()
    :Wait(8)
    :Then()
    :DisplayPopupText(6)
    :Then()
    :DisplayPopupText(7)
    :Then()
    :Call("SetProperty", GetRobinCustom(), "direction", ActorDirection.south_west)
    :Then()
    :DisplayPopupText(8)
end

function HomecommingRunToRobin(s)
  return s
    :Wait(15)
    :Then()
    :TurnTo(Actors["Soldier_27"], GetRobinCustom().location)
    :Then()
    :Call("Actor.SetEmoticon", Actors["Soldier_27"], ActorEmoticon.exclamation_mark, 150)
    :Then()
    :Move(Actors["Soldier_27"], Locations["Node_155"], MovementStyle.running)
    :Then()
    :Wait(5)
    :Then()
    :MoveIntoBuilding(Actors["Soldier_27"], Locations["Node_153"], MovementStyle.running)
    :Then()
    :Move(Actors["Soldier_27"], Locations["Node_150"], MovementStyle.running)
    :Then()
    :Wait(10)
    :Then()
    :TurnTo(Actors["Soldier_27"], Locations["Node_152"])
    :Then()
    :Wait(10)
    :Then()
    :TurnTo(Actors["Soldier_27"], Locations["Node_151"])
    :Then()
    :Wait(10)
    :Then()
    :MoveIntoBuilding(Actors["Soldier_27"], Locations["Node_117"], MovementStyle.running)
    :Then()
    :Wait(10)
    :Then()
    :Move(Actors["Soldier_27"], Locations["Node_161"], MovementStyle.running)
    :Then()
    :MoveIntoBuilding(Actors["Soldier_27"], Locations["Node_158"], MovementStyle.running)
    :Then()
    :Call("Actor.SetEmoticon", Actors["Soldier_19"], ActorEmoticon.none, 10)
    :Call("Actor.SetEmoticon", Actors["Soldier_27"], ActorEmoticon.none, 10)
end

function HomecommingOfficerHide(s)
  return s
    :Wait(25)
    :Then()
    :MoveIntoBuilding(Actors["Soldier_3"], Locations["Node_96"], MovementStyle.walking)
end

function HomecommingHaberdierPunchReaction(s)
  return s
    :Wait(250)
    :Then()
    :Call("Actor.SetProperty", Actors["Soldier_19"], PersistentProperty.concussion, 0)
    :Then()
    :Wait(3)
    :Then()
    :Call("Actor.SetEmoticon", Actors["Soldier_19"], ActorEmoticon.question_mark, 160)
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_19"], true)
    :Then()
    :TurnTo(Actors["Soldier_19"], Locations["Node_137"])
    :Then()
    :Wait(20 + Rand(10))
    :Then()
    :TurnTo(Actors["Soldier_19"], Locations["Node_158"])
    :Then()
    :Wait(20 + Rand(10))
    :Then()
    :TurnTo(Actors["Soldier_19"], Locations["Node_151"])
    :Then()
    :Wait(20 + Rand(10))
    :Then()
    :Call("Actor.SetAlwaysAttentive",  Actors["Soldier_19"], false)
    :Call("UnlockFromPlace", Actors["Soldier_19"])
    :Then()
    :Wait(50)
    :Then()
    :Call("Actor.SetEmoticon", Actors["Soldier_19"], ActorEmoticon.none, 10)
    :Then()
    :Call("UnlockFromPlace", Actors["Soldier_1"])
    :Then()
    :Move(Actors["Soldier_19"], Locations["Node_160"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_19"], Locations["Node_134"])
    :Then()
    :Call("UnlockFromPlace", Actors["Soldier_19"])
end

function HomecommingRobinPunchHalberdier()
  CyrSeq()
    :Wait(15)
    :Then()
    :Call("MakeActorUnconscious", Actors["Soldier_19"])
    :Start()
end

function HomecommingRobinFlee(s)
  return s
    :Move(GetRobinCustom(), Locations["Node_148"], MovementStyle.running)
    :Then()
    :Move(GetRobinCustom(), Locations[startingLocation], MovementStyle.walking)
end

function HomecommingStartMission(s)
  GetRobinCustom().invisible = false
  Scrolls["Scroll_6"].state = ScrollState.visible
  ShowPersonInside(Actors["Soldier_28"])
  ShowPersonInside(Actors["Soldier_29"])

  return s
    :DisplayPopupText(14)
    :Then()
    :FinalizeCutscene()
    :Then()
    :Call("Select", PcSelection.all)
end

function HomecommingSwordsmanEmoteRobinPunch()
  CyrSeq()
    :Wait(10)
    :Then()
    :Call("Actor.SetEmoticon", Actors["Soldier_27"], ActorEmoticon.question_mark, 150)
    :Start()
end

function HomecommingRobinSurpriseReaction(s)
  return s
    :Wait(4)
    :Then()
    :Call("HomecommingRobinPunchHalberdier")
    :Then()
    :PlayAnim(GetRobinCustom(), ActorAction.hitting)
    :Then()
    :Call("HomecommingSwordsmanEmoteRobinPunch")
    :Then()
    :Together({
      {
        {
          func = "CyrSequenceMoveCameraTo",
          args = {Locations[startingCameraLocation], 2},
        },
        {
          func = "HomecommingRobinFlee",
          args = {},
        }
      },{
        {
          func = "HomecommingStartMission",
          args = {},
        }
      }
    })
end

function HomecommingStaircaseWalk()
  Actors["Soldier_27"].location = Locations["Node_137"]
  GetRobinCustom().location = Locations["Node_138"]
  Actors["Soldier_19"].location = Locations["Node_139"]
  Actors["Soldier_27"]:AddToZoneAfterTeleport(Locations["VisionNodeIn_21"])
  GetRobinCustom():AddToZoneAfterTeleport(Locations["VisionNodeIn_21"])
  Actors["Soldier_19"]:AddToZoneAfterTeleport(Locations["VisionNodeIn_21"])

  CyrSeq()
    :Together({
      {
        {
          func = "CyrSequenceMove",
          args = {Actors["Soldier_27"], Locations["Node_142"], MovementStyle.walking},
        },
        {
          func = "HomecommingRobinStaircaseWalk",
          args = {},
        },
        {
          func = "CyrSequenceMove",
          args = {Actors["Soldier_19"], Locations["Node_140"], MovementStyle.walking},
        }
      },{
        {
          func = "CyrSequenceTurnTo",
          args = {Actors["Soldier_27"], Locations["Node_141"]},
        },
        {
          func = "CyrSequenceTurnTo",
          args = {GetRobinCustom(), Locations["Node_142"]},
        }
      },{
        {
          func = "HomecommingAskOfficerWhatToDoWithRobin",
          args = {},
        }
      },{
        {
          func = "HomecommingRunToRobin",
          args = {},
        },
        {
          func = "HomecommingOfficerHide",
          args = {},
        },
        {
          func = "HomecommingHaberdierPunchReaction",
          args = {},
        },
        {
          func = "HomecommingRobinSurpriseReaction",
          args = {},
        }
      }
    })
end

function CanStartSeeDad(showText)
  if not (GetOverallEnemyAlert() == AlertStatus.green) then
    if(showText) then
      DisplayPopupText(26)
    end
    return false
  end
  for _, z in pairs({"Node_166", "Node_167"}) do
    for i, a in ipairs(GetAllActorsInZone(Locations[z])) do
      if (a ~= nil) then

        -- print("")
        -- print(a.name)
        -- print("is_soldier")
        -- print(a.is_soldier)
        -- print("active")
        -- print(a.active)
        -- print("attitude")
        -- print(a.attitude)
        -- print("out_of_action")
        -- print(a.out_of_action)

        if (a.is_soldier)
          and (a.active)
          and (a.attitude == AiAttitude.hostile)
          and (not a.out_of_action) then
            print(a.name)
            if(showText) then
              DisplayPopupText(27)
            end
            return false
        end
      end
    end
  end
  return true
end

function Timer(seconds)
  if(Globals.seeDadState == SeeDadState.inZone) then
    if(CanStartSeeDad()) then
      TriggerSeeDadCutscene()
    end
  end
end

function CheckVictoryCondition(seconds)
  if Globals.seeDadState == SeeDadState.seeDone then
    ChooseVictoryDefeatText(0)
    return 1
  end
end

function Finalize(unk)
end

function AdvanceSpeakObjective()
  if Globals.objectiveIndex > 0 then
    CompleteObjective(Globals.objectiveIndex)
  end
  Globals.objectiveIndex = Globals.objectiveIndex + 1
  if(Globals.objectiveIndex <= #objectiveIndices) then
    AddObjective(Globals.objectiveIndex, true)
  else
    AddObjective(5, true)
    DisplayPopupText(28)
    Globals.seeDadState = SeeDadState.active
  end
end

function InitExecutionCharacters()
  DeactivateInside(Actors["Soldier_26"])
  DeactivateInside(Actors["Soldier_10"])
  DeactivateInside(Actors["Soldier_11"])
  DeactivateInside(Actors["TaxCollector_2"])
  DeactivateInside(Actors["MainVillain_5"])
  DeactivateInside(Actors["Soldier_8"])
  DeactivateInside(Actors["Soldier_4"])
  DeactivateInside(Actors["Soldier_7"])
  DeactivateInside(Actors["Soldier_6"])
  DeactivateInside(Actors["Soldier_5"])
  DeactivateInside(Actors["Godwin_3"])
  DeactivateInside(Actors["Executioner_4"])
  DeactivateInside(Actors["Soldier_25"])

  Actors["Soldier_26"]:PutInBuilding(Buildings["Building_3"])
  -- Actors["Soldier_3"]:PutInBuilding(Buildings["Building_3"])
  Actors["Godwin_3"]:PutInBuilding(Buildings["Building_3"])
  Actors["MainVillain_5"]:PutInBuilding(Buildings["Building_3"])
  Actors["TaxCollector_2"]:PutInBuilding(Buildings["Building_3"])
  Actors["Soldier_10"]:PutInBuilding(Buildings["Building_3"])
  Actors["Soldier_11"]:PutInBuilding(Buildings["Building_3"])
end

---@return Actor #
function GetRobinCustom()
  local h = GetActorForPlaceholder(0)
  if h ~= nil then
    return h
  end
  error("There has to be a custom Robin character in the mission.")
end

---@return Actor
function GetRobinFake()
  return Actors["Fake_Robin_1"]
end

--Scrolls
HiddenWoman = {
  Taken = function (actorSource)
    Actors["Civilian_18"]:AttachScroll(God())
    DisplayPopupText(18)
    AdvanceSpeakObjective()
    Items["Money_6"]:Activate()
    return 1
  end
}

EdwardScroll = {
  Taken = function (actorSource)
    Actors["ManCivilianOld_1"]:AttachScroll(God())
    AdvanceSpeakObjective()
    CompleteObjective(6)
    DisplayPopupText(20)
    return 1
  end
}

CarollSad = {
  Taken = function (actorSource)
    Actors["Civilian_8"]:AttachScroll(God())
    AdvanceSpeakObjective()
    DisplayPopupText(21)

    CyrSeq()
      :MoveIntoBuilding(Actors["Civilian_8"], Locations["Node_44"], MovementStyle.running)
      :Start()
    return 1
  end
}

ScaredKidScroll = {
  Taken = function (actorSource)
    Actors["Civilian_9"]:AttachScroll(God())
    AdvanceSpeakObjective()
    DisplayPopupText(25)

    CyrSeq()
      :Wait(10)
      :Then()
      :Move(Actors["Civilian_9"], Locations["Node_168"], MovementStyle.running)
      :Then()
      :Move(Actors["Civilian_9"], Locations["Node_169"], MovementStyle.running)
      :Then()
      :MoveIntoBuilding(Actors["Civilian_9"], Locations["Node_116"], MovementStyle.running)
      :Start()
    return 1
  end
}

ObjectivesInEscScroll = {
  Taken = function(actorSource)
    DisplayPopupText(9)
  end
}

--Waypoints

---comment
---@param locationName string
---@param movementStyle MovementStyle
---@return PatrolScriptEvents
function RummageInBuilding(locationName, movementStyle)
  return {
    ---@param actor Actor
    ReachPoint = function(actor)
      actor:LockAi(true)
      actor.ai_state = AiState.script_driven

      CyrSeq()
        :MoveIntoBuilding(actor, Locations[locationName], movementStyle)
        :Then()
        :Wait(Rand(60) + 250)
        :Then()
        :Call("Actor.UnlockAi", actor)
        :Call("SetProperty", actor, "ai_state", AiState.default)
        :Start()
    end
  }
end

RummageInBuilding5 = RummageInBuilding("Node_116", MovementStyle.walking)

RummageInBuilding6 = RummageInBuilding("Node_118", MovementStyle.walking)

SplitSearchers = {
  ReachPoint = function(actor)
    local a = Actors["Soldier_5"]
    local b = Actors["Soldier_4"]
    if actor == b then
      b = a
      a = actor
    end
    
    a:SetPatrolStyle(MovementStyle.running)
    a:RemoveAllSquadMembers()
    a:AssignPatrol(Patrols["Patrol_24"])

    b:AssignPatrol(Patrols["Patrol_20"])
  end
}

---@param a Actor
---@param b Actor
function WaitCycleStartPatrol(a, b)
  a:AddSquadMember(b)
  a:SetPatrolStyle(MovementStyle.walking)
  b:SetPatrolStyle(MovementStyle.walking)
  b:AssignPatrol(Patrols["Patrol_12"])
  a:AssignPatrol(Patrols["Patrol_12"])
end

---@param a Actor
---@param b Actor
function WaitCycle(a, b)
  if a:Sees(b) then
    CyrSeq()
      :Wait(50)
      :Then()
      :Call("WaitCycleStartPatrol", a, b)
      :Start()
  elseif b.out_of_action then
    a:AssignPatrol(Patrols["Patrol_12"])
  else
    CyrSeq()
      :Wait(5)
      :Then()
      :Call("WaitCycle", a, b)
      :Start()
  end
end

WaitForOther = {
  ReachPoint = function(actor)
    local a = Actors["Soldier_5"]
    local b = Actors["Soldier_4"]
    if actor == b then
      b = a
      a = actor
    end

    a:AssignPatrol(God())
    WaitCycle(a, b)
  end
}

TaxCollectorMakeThemGo = {
  ReachPoint = function(actor)
    local a = Actors["Soldier_5"]
    local b = Actors["Soldier_4"]
    if actor == b then
      b = a
      a = actor
    end

    if Actors["TaxCollector_2"].out_of_action or not (Actors["TaxCollector_2"]:IsInside(Locations["Node_127"])) then
      a:RemoveAllSquadMembers()
      b:RemoveAllSquadMembers()
      CyrSeq()
        :Wait(1)
        :Then()
        :Call("Actor.AssignPatrol", a, Patrols["Patrol_26"])
        :Call("Actor.AssignPatrol", b, Patrols["Patrol_25"])
        :Start()
    else
      a.ai_state = AiState.script_driven
      a:LockAi(true)
      CyrSeq()
        :If(not Globals.firstTaxCollectorSend)
          :Speak(a, NpcRemark.ends_search)
          :Wait(40)
          :Then()
          :Speak(Actors["TaxCollector_2"], NpcRemark.civilian_sees_brawl)
          :Then()
        :Endif()
        :Wait(40)
        :Then()
        :PlayAnim(Actors["TaxCollector_2"], ActorAction.pointing)
        :Then()
        :Call("Actor.UnlockAi", a)
        :Call("SetProperty", a, "ai_state", AiState.default)
        :Start()
      if(Globals.firstTaxCollectorSend) then
        Globals.firstTaxCollectorSend = false
      end
    end
  end
}

--Zones

SeeDadZone = {
  Enter = function(actor)
    if(actor == GetRobinCustom()) then
      if(Globals.seeDadState == SeeDadState.active) then
        if(CanStartSeeDad()) then
          TriggerSeeDadCutscene()
        else
          Globals.seeDadState = SeeDadState.inZone
        end
      end
    end
  end,

  Exit = function(actor)
    if(actor == GetRobinCustom()) then
      if(Globals.seeDadState == SeeDadState.inZone) then
        Globals.seeDadState = SeeDadState.active
      end
    end
  end
}

function MissionSuccessDadSeen()
  CyrSeq()
    :Wait(12)
    :Then()
    :Call("SetProperty", Globals, "seeDadState", SeeDadState.seeDone)
    :Call("ForceCheckVictory")
    :Start()
end

function TriggerSeeDadCutscene()
  Globals.seeDadState = SeeDadState.seeTriggered

  CyrSeq()
    :BeginCutscene()
    :Then()
    :DisplayMap(false)
    :Then()
    :SetZoomLevel(ZoomLevel.close)
    :Then()
    :ScrollCameraTo(Actors["GodwinBody_16"].location)
    :Then()
    :MoveNear(GetRobinCustom(), Actors["GodwinBody_16"].location, MovementStyle.walking, 15)
    :Then()
    :Call("SetProperty", GetRobinCustom(), "posture", Posture.crouched)
    :Then()
    :Wait(30)
    :Then()
    :SetZoomLevel(ZoomLevel.default)
    :Then()
    :Wait(15)
    :Then()
    :SetZoomLevel(ZoomLevel.default)
    :Then()
    :Wait(15)
    :Then()
    :Call("MissionSuccessDadSeen")
    :Then()
    :Call("FadeToBlack", 500)
    :Then()
    :FinalizeCutscene()
    :Start()
end

---@type ZoneScriptEvents
ExecutionTrigger = {
  Enter = function(actor)
    if actor.is_hero then
      if Globals.executionStarted then
        return
      end
      Globals.executionStarted = true

      CyrSeq()
        :BeginCutscene()
        :Then()
        :SetZoomLevel(ZoomLevel.default)
        :Then()
        :ScrollCameraTo(actor.location)
        :Then()
        :Call("TriggerExecutionCutscene")
        :Start()
    end
  end,
}

function RobinRunToViewpoint()
    local robinLoc = GetRobinCustom().location
    if robinLoc == nil then
      return
    end
    local dist = 100000
    local finalLoc = robinLoc
    for _, loc in pairs({
      Locations["Node_94"],
      Locations["Node_108"],
      Locations["Node_109"],
      Locations["Node_110"],
      Locations["Node_111"],
      Locations["Node_112"],
    }) do
      local d = robinLoc:DistanceTo(loc)
      if d < dist then
        dist = d
        finalLoc = loc
      end
    end

    CyrSeq()
      :Move(GetRobinCustom(), finalLoc, MovementStyle.walking)
      :Then()
      :TurnTo(GetRobinCustom(), Locations["Node_57"])
      :Then()
      :Call("Actor.Crouch", GetRobinCustom())
      :Start()
end

function ActivateGodwinBringingKnight()
  CyrSeq()
    :Wait(35)
    :Then()
    :Call("Actor.Activate", Actors["Soldier_3"])
    :Call("Actor.Reveal", Actors["Soldier_3"])
    :Then()
    :Move(Actors["Soldier_3"], Locations["Node_62"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_3"], Locations["Node_56"])
    :Start()
end

function TriggerExecutionCutscene()
  Globals.executionStarted = true
  SetLockDoorForAll(MiscDoor.WeaponRoomInnerHouse.outerNorthEast, false)
  SetOutlineDisplay(false)
  DisplayMap(false)
  Actors["Soldier_8"]:Activate()
  Actors["Soldier_4"]:Activate()
  Actors["Soldier_7"]:Activate()
  Actors["Soldier_6"]:Activate()
  Actors["Soldier_5"]:Activate()

  Actors["Soldier_4"]:Reveal()
  Actors["Soldier_7"]:Reveal()
  Actors["Soldier_6"]:Reveal()
  Actors["Soldier_5"]:Reveal()

  CyrSeq()
    :MoveCameraTo(Locations["Node_57"], 3)
    :Start()

  for _, z in pairs({
    Locations["VisionNode_1"],
    Locations["Node_114"],
    Locations["Node_55"],
    Locations["Node_113"],
    Locations["VisionNode_7"],
    Locations["VisionNode_16"],
    Locations["VisionNodeIn_22"],
    Locations["VisionNodeIn_21"],
  }) do
    for _, a in pairs(GetAllActorsInZone(z)) do
      a:LockAi(false)

      CyrSeq()
        :Move(a, Locations["Node_112"], MovementStyle.running)
        :Then()
        :If(a:GetCustomValue(NPCValueIndices.UnlockableAI) > 0)
          :Call("Actor.UnlockAi", a)
        :Endif()
        :Start()
    end
  end

  CyrSeq()
    :Wait(20)
    :Then()
    :Call("Actor.Stop", GetRobinCustom())
    :Then()
    :TurnTo(GetRobinCustom(), Locations["Node_96"])
    :Then()
    :Wait(10)
    :Then()
    :Call("RobinRunToViewpoint")
    :Start()

  CyrSeq()
    :Wait(65)
    :Then()
    :Move(Actors["Soldier_4"], Locations["Node_90"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_4"], Locations["Node_64"])
    :Start()

  CyrSeq()
    :Wait(45)
    :Then()
    :Move(Actors["Soldier_5"], Locations["Node_87"], MovementStyle.walking)
    :Start()

  Actors["MainVillain_5"]:Reveal()
  Actors["MainVillain_5"]:Activate()
  CyrSeq()
    :Move(Actors["MainVillain_5"], Locations["Node_57"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_61"])
    :Start()

  CyrSeq()
    :Wait(25)
    :Then()
    :Call("Actor.Reveal", Actors["Soldier_11"])
    :Call("Actor.Activate", Actors["Soldier_11"])
    :Call("MoveAndTurn", Actors["Soldier_11"], Locations["Node_60"], MovementStyle.walking, Locations["Node_61"])
    :Then()
    :Wait(10)
    :Then()
    :Call("Actor.Activate", Actors["TaxCollector_2"])
    :Call("Actor.Reveal", Actors["TaxCollector_2"])
    :Then()
    :Call("ActivateGodwinBringingKnight")
    :Then()
    :Move(Actors["TaxCollector_2"], Locations["Node_58"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["TaxCollector_2"], Locations["Node_61"])
    :Then()
    :Wait(5)
    :Then()
    :Call("CallCivilianSeeExecution")
    :Start()
end

function ExecutionLancersRunToGuisborne()
  CyrSeq()
    :Move(Actors["Soldier_4"], Locations["Node_74"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_4"], Actors["Soldier_11"].location)
    :Start()
  
  CyrSeq()
    :Move(Actors["Soldier_5"], Locations["Node_71"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_5"], Actors["Soldier_11"].location)
    :Start()
  
  CyrSeq()
    :Move(Actors["Soldier_6"], Locations["Node_72"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_6"], Actors["Soldier_11"].location)
    :Start()
end

function ExecutionLancersRunForCivilians()
  CyrSeq()
    :Move(Actors["Soldier_4"], Locations["Node_75"], MovementStyle.running)
    :Start()
  
  CyrSeq()
    :Move(Actors["Soldier_5"], Locations["Node_75"], MovementStyle.running)
    :Start()
  
  CyrSeq()
    :Wait(3)
    :Then()
    :Move(Actors["Soldier_7"], Locations["Node_75"], MovementStyle.running)
    :Start()

  Actors["Civilian_17"]:Activate()
  Actors["Civilian_17"]:Reveal()
end

---@param actor Actor
---@param moveLocation Location
---@param movementStyle MovementStyle
---@param turnLocation Location
function MoveAndTurn(actor, moveLocation, movementStyle, turnLocation)
  CyrSeq()
    :Move(actor, moveLocation, movementStyle)
    :Then()
    :TurnTo(actor, turnLocation)
    :Start()
end

---@param civilian Actor
function MoveCivilianToARandomSpot(civilian)
  local r1 = Rand(100) * 0.009999999776482582
  local p1 = Locations["Node_87"]:PointBetween(Locations["Node_89"], r1)
  local p2 = Locations["Node_86"]:PointBetween(Locations["Node_88"], r1)
  local r2 = Rand(100) * 0.009999999776482582
  local p3 = p1:PointBetween(p2, r2)
  civilian:Reveal()
  CyrSeq()
    :Wait(Rand(8)+1)
    :Then()
    :Move(civilian, p3, MovementStyle.walking)
    :Start()
end

function CrossbowmanAimCivilians()
  Actors["Soldier_8"]:Reveal()
  CyrSeq()
    :Move(Actors["Soldier_8"], Locations["Node_65"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_8"], Locations["Node_59"])
    :Then()
    :Action(Actors["Soldier_8"], ScriptCommand.aim, Actors["Civilian_6"].index)
    :Start()

  CyrSeq()
    :Move(Actors["Soldier_4"], Locations["Node_66"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_4"], Locations["Node_59"])
    :Start()
end

function FirstGuardBringCivilians()
  Actors["Civilian_17"]:Deactivate()

  CyrSeq()
    :Move(Actors["Soldier_4"], Locations["Node_95"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_4"], Locations["Node_92"])
    :Then()
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_4"], true)
    :Start()
end

function CallCivilianSeeExecution()
  MiscDoor.NorthBattlement.eastRampart.locked_for_pcs =  false
  MiscDoor.NorthBattlement.westRampart.locked_for_pcs =  false
  MiscDoor.NorthBattlement.top.locked_for_pcs =  false
  MiscDoor.NorthBattlement.courtyard.locked_for_pcs =  false

  local s = CyrSeq()
    :PlayAnim(Actors["Soldier_11"], ActorAction.gathering_soldiers)
    :Speak(Actors["Soldier_11"], NpcRemark.officer_calls_group)
    :Then()
    :Call("ExecutionLancersRunToGuisborne")
    :Move(Actors["Soldier_7"], Locations["Node_73"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_7"], Actors["Soldier_11"].location)
    :Then()
    :TurnTo(Actors["Soldier_11"], Actors["MainVillain_5"].location)
    :Then()
    :Wait(20)
    :Then()
    :TurnTo(Actors["Soldier_11"], Locations["Node_61"])
    :Then()
    :Wait(10)
    :Then()
    :TurnTo(Actors["Soldier_4"], Actors["MainVillain_5"].location)
    :TurnTo(Actors["Soldier_5"], Actors["MainVillain_5"].location)
    :TurnTo(Actors["Soldier_7"], Actors["MainVillain_5"].location)
    :TurnTo(Actors["Soldier_6"], Actors["MainVillain_5"].location)
    :Then()
    :Wait(10)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_75"])
    :Then()
    :PlayAnim(Actors["MainVillain_5"], ActorAction.pointing)
    :Then()
    :Call("ExecutionLancersRunForCivilians")
    :Then()
    :Move(Actors["Soldier_6"], Locations["Node_75"], MovementStyle.running)
    :Then()
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_5"], true)
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_7"], true)
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_6"], true)
    :Then()
    :Wait(15)
    :Then()
    :Speak(Actors["Civilian_17"], NpcRemark.civilian_panic)
    :Then()
    :Wait(5)
    :Then()
    :Call("FirstGuardBringCivilians")
    :Then()

  local civils = {
    {Actors["ManCivilianOld_1"], Locations["Node_76"]},
    {Actors["Civilian_6"], Locations["Node_77"]},
    {Actors["Civilian_7"], Locations["Node_80"]},
    {Actors["Civilian_8"], Locations["Node_78"]},
    {Actors["Civilian_9"], Locations["Node_79"]},
    {Actors["Civilian_10"], Locations["Node_84"]},
    {Actors["Civilian_11"], Locations["Node_83"]},
    {Actors["Civilian_12"], Locations["Node_85"]},
    {Actors["Civilian_13"], Locations["Node_82"]},
    {Actors["Civilian_14"], Locations["Node_81"]},
    {Actors["Priest_15"], Locations["Node_107"]},
  }

  for _, value in ipairs(civils) do
    s = s
      :Call("MoveCivilianToARandomSpot", value[0])
  end
  s = s
    :Then()
    :Wait(120)
    :Then()
    :Call("MoveAndTurn", Actors["Soldier_5"], Locations["Node_93"], MovementStyle.walking, Locations["Node_92"])
    :Then()
    :Wait(8)
    :Then()
    :Call("MoveAndTurn", Actors["Soldier_7"], Locations["Node_90"], MovementStyle.walking, Locations["Node_92"])
    :Then()
    :Wait(8)
    :Then()
    :Call("MoveAndTurn", Actors["Soldier_6"], Locations["Node_91"], MovementStyle.walking, Locations["Node_92"])
    :Wait(140)
    :Then()
    :Speak(Actors["Soldier_4"], NpcRemark.good_strike_combat)
    :Then()
    :Wait(10)
    :Then()

  for _, value in ipairs(civils) do
    s = s
      :Call("MoveAndTurn", value[1], value[2], MovementStyle.walking, Locations["Node_56"])
  end
  s
    :Then()
    :Wait(5)
    :Then()
    :Call("CrossbowmanAimCivilians")
    :Then()
    :Wait(16)
    :Then()
    :Call("MoveAndTurn", Actors["Soldier_5"], Locations["Node_69"], MovementStyle.walking, Locations["Node_59"])
    :Call("MoveAndTurn", Actors["Soldier_7"], Locations["Node_67"], MovementStyle.walking, Locations["Node_59"])
    :Then()
    :Wait(10)
    :Then()
    :Call("MoveAndTurn", Actors["Soldier_6"], Locations["Node_68"], MovementStyle.walking, Locations["Node_59"])
    :Then()
    :Wait(60)
    :Then()
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_6"], false)
    :Call("Actor.SetAlwaysAttentive", Actors["Soldier_7"], false)
    :Then()
    :Call("BringGodwin")
    :Start()
end

local delayBetweenOut = 25
local dealyBeforePopup = 30

function GodwinKnightGuard1Walk()
  Actors["Soldier_10"]:Activate()
  Actors["Soldier_10"]:Reveal()
  CyrSeq()
    :Move(Actors["Soldier_10"], Locations["Node_63"], MovementStyle.walking)
    :Then()
    :Move(Actors["Soldier_10"], Locations["Node_64"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_10"], Locations["Node_56"])
    :Start()
end

function GodwinKnightGuard2Walk()
  Actors["Soldier_26"]:Activate()
  Actors["Soldier_26"]:Reveal()

  CyrSeq()
    :Move(Actors["Soldier_26"], Locations["Node_63"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_26"], Locations["Node_56"])
    :Start()

  CyrSeq()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_56"])
    :Start()
end

function GodwinKnightMoveIntoBuilding()
  CyrSeq()
    :MoveIntoBuilding(Actors["Soldier_3"], Locations["Node_96"], MovementStyle.running)
    :Start()
end

function GodwinWalkOut()
  Actors["Godwin_3"]:Activate()
  Actors["Godwin_3"]:Reveal()
  CyrSeq()
    :Move(Actors["Godwin_3"], Locations["Node_56"], MovementStyle.walking)
    :Start()
end

function GodwinGoToFinalPosition()
  CompleteObjective(0)
  CyrSeq()
    :Move(Actors["Godwin_3"], Locations["Node_56"], MovementStyle.walking)
    :Then()
    :Call("SetProperty", Globals, "isGodwinOnPlace", 1)
    :Then()
    :TurnTo(Actors["Godwin_3"], Locations["Node_59"])
    :Start()
end

function GodwinKnightGoOutOfBuilding()
  Actors["Soldier_3"]:LockAi(false)
  CyrSeq()
    :Move(Actors["Soldier_3"], Locations["Node_62"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_3"], Locations["Node_56"])
    :Then()
    :UnlockAi(Actors["Soldier_3"])
    :Then()
    :Wait(1)
    :Then()
    :Call("SetCurrentActorPost", Actors["Soldier_3"])
    :Start()
end

function BringGodwin()
  CyrSeq()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_81"])
    :Then()
    :Speak(Actors["MainVillain_5"], NpcRemark.vip_war_cry)
    :Then()
    :Wait(50)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_62"])
    :Then()
    :Call("GodwinKnightMoveIntoBuilding")
    :Then()
    :Wait(40)
    :Then()
    :Call("GodwinKnightGuard1Walk")
    :Then()
    :Wait(delayBetweenOut + 22)
    :Then()
    :Call("GodwinWalkOut")
    :Then()
    :Wait(delayBetweenOut - 10)
    :Then()
    :Call("GodwinKnightGuard2Walk")
    :Then()
    :Wait(dealyBeforePopup)
    :Then()
    :DisplayPopupText(10)
    :Then()
    :Wait(delayBetweenOut)
    :Then()
    :Call("GodwinGoToFinalPosition")
    :Then()
    :Call("LockEnemyOnExecutionAI")
    :Then()
    :Call("GodwinKnightGoOutOfBuilding")
    :Then()
    :Wait(75)
    :Then()
    :Call("Actor.AssignPatrol", Actors["MainVillain_5"], Patrols["Patrol_6"])
    :Call("Actor.UnlockAi", Actors["MainVillain_5"])
    :Start()
end

function LockEnemyOnExecutionAI()
  Actors["Soldier_11"]:LockAi(false)
  Actors["Soldier_10"]:LockAi(false)
  Actors["Soldier_3"]:LockAi(false)
  Actors["Soldier_26"]:LockAi(false)
  Actors["Soldier_4"]:LockAi(false)
  Actors["Soldier_7"]:LockAi(false)
  Actors["Soldier_6"]:LockAi(false)
  Actors["Soldier_5"]:LockAi(false)
  Actors["Soldier_8"]:LockAi(false)

  Actors["Soldier_6"]:SetAlwaysAttentive(true)
  Actors["Soldier_7"]:SetAlwaysAttentive(true)

  CyrSeq()
    :Wait(1)
    :Then()
    :TurnTo(Actors["Soldier_4"], Locations["Node_59"])
    :Start()

  CyrSeq()
    :Wait(1)
    :Then()
    :TurnTo(Actors["Soldier_5"], Locations["Node_59"])
    :Start()

  CyrSeq()
    :Wait(1)
    :Then()
    :Move(Actors["Soldier_10"], Locations["Node_64"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_10"], Locations["Node_56"])
    :Start()

  CyrSeq()
    :Wait(1)
    :Then()
    :Move(Actors["Soldier_26"], Locations["Node_63"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_26"], Locations["Node_56"])
    :Start()

  CyrSeq()
    :Wait(1)
    :Then()
    :Move(Actors["Soldier_3"], Locations["Node_62"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_3"], Locations["Node_56"])
    :Start()
end

WaypointPunchGodwin = {
  ReachPoint = function(actor)
    actor:AssignPatrol(God())
    actor:LockAi(false)
    local s = CyrSeq()
    -- SequencePlayDialog(0) --tell Godwin to kneel, refuse, punch him
    --   :Then()
      :Then()

    SequencePunchGodwin(s, actor)
    s
      :Then()
      :Wait(15)
      :Then()
      :Call("ExecutionStart")
      :Start()
  end
}

function SequencePunchGodwin(sequence, actor)
  return sequence
    :Wait(15)
    :Then()
    :Speak(actor, NpcRemark.vip_starts_combat)
    :Then()
    :Wait(15)
    :Then()
    :Call("FindOutVillainsPlan")
    :Then()
    :Wait(35)
    :Then()
    :Call("VillainFistPunch")
    :Wait(14)
    :Then()
    :Call("MakeActorUnconscious", Actors["Godwin_3"], 1000000)
end

function FindOutVillainsPlan()
  
end

function VillainFistPunch()
  CyrSeq()
    :PlayAnim(Actors["MainVillain_5"], ActorAction.hitting)
    :Start()
end

local talkingDistance = 30

function ExecutionStart()
  Actors["Executioner_4"]:Activate()
  Actors["Executioner_4"]:Reveal()

  CyrSeq()
    :Move(Actors["MainVillain_5"], Locations["Node_105"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_79"])
    :Then()
    :Wait(10)
    :Then()
    :DisplayPopupText(11)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_56"])
    :Then()
    :Call("PriestInterception")
    :Then()
    :Wait(10)
    :Then()
    :Move(Actors["Executioner_4"], Locations["Node_106"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Executioner_4"], Locations["Node_63"])
    :Start()
end

function ExecutionerExecute()
  CyrSeq()
    :PlayAnimFreeze(Actors["Executioner_4"], ActorAction.executing_sword)
    :Then()
    :Speak(Actors["Civilian_8"], NpcRemark.civilian_wounded)
    :Speak(Actors["Civilian_14"], NpcRemark.civilian_sees_dead_body)
    :Start()
  
  FadeToBlack(22)
  Actors["Soldier_25"]:Activate()
  Actors["Soldier_25"]:Reveal()
  Actors["Soldier_25"].invisible = true
end

function GodwinBodySwap()
  CyrSeq()
    :Speak(Actors["Soldier_25"], NpcRemark.strangled)
    :Start()
  AdvanceSpeakObjective()

  Actors["Godwin_3"]:Deactivate()
  Actors["GodwinBody_16"].location =  Actors["Godwin_3"].location
  Actors["GodwinBody_16"].direction = Actors["Godwin_3"].direction
  Actors["GodwinBody_16"]:Activate()
  Actors["GodwinBody_16"]:Reveal()
end

function PriestInterception()
  Actors["Priest_15"]:Activate()
  Actors["Priest_15"]:Reveal()

  CyrSeq()
    :MoveNear(Actors["Priest_15"], Actors["MainVillain_5"].location, MovementStyle.running, talkingDistance)
    :Then()
    :TurnTo(Actors["Priest_15"], Actors["MainVillain_5"].location)
    :TurnTo(Actors["MainVillain_5"], Actors["Priest_15"].location)
    :Then()
    :Wait(5)
    :Then()
    :DisplayPopupText(12)
    :Then()
    :DisplayPopupText(13)
    :Then()
    :Call("VillainFistPunch")
    :Wait(14)
    :Then()
    :Call("MakeActorUnconscious", Actors["Priest_15"], 1000000)
    :Speak(Actors["Civilian_10"], NpcRemark.civilian_wasps)
    :Then()
    :Wait(15)
    :Then()
    :TurnTo(Actors["MainVillain_5"], Locations["Node_56"])
    :Then()
    :Wait(30)
    :Then()
    :Call("ExecutionerExecute")
    :Then()
    :Wait(40)
    :Then()
    :Call("GodwinBodySwap")
    :Then()
    :Wait(40)
    :Then()
    :Call("InstructTaxCollector")
    :Wait(1)
    :Then()
    :Call("Actor.Deactivate", Actors["Soldier_25"])
    :Start()
end

function InstructTaxCollector()
  CyrSeq()
    :TurnTo(Actors["MainVillain_5"], Actors["TaxCollector_2"].location)
    :Then()
    :PlayAnim(Actors["MainVillain_5"], ActorAction.pointing)
    :Then()
    :Wait(5)
    :Then()
    :DisplayPopupText(15)
    :Then()
    :Call("AlertTaxCollectorGroup")
    :Then()
    :Wait(10)
    :Then()
    :Call("LeaveExecutionVillain")
    :Then()
    :Wait(10)
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_11"])
    :Call("Actor.AssignPatrol", Actors["Soldier_11"], Patrols["Patrol_9"])
    :Start()
end

function LeaveExecutionVillain()
  Actors["MainVillain_5"]:UnlockAi()
  Actors["MainVillain_5"]:AssignPatrol(Patrols["Patrol_7"])

  Actors["Soldier_10"]:UnlockAi()
  Actors["Soldier_26"]:UnlockAi()
  Actors["MainVillain_5"]:AddSquadMember(Actors["Soldier_10"])
  Actors["MainVillain_5"]:AddSquadMember(Actors["Soldier_26"])
  
  CyrSeq()
    :Wait(60)
    :Then()
    :Call("Actor.UnlockAi", Actors["Executioner_4"])
    :Call("Actor.AssignPatrol", Actors["Executioner_4"], Patrols["Patrol_9"])
    :Start()
end

function LeaveExecutionTaxCollectorGroup()
  Actors["Soldier_11"]:UnlockAi()
  Actors["Soldier_11"]:AssignPatrol(Patrols["Patrol_8"])

  for _, a in pairs({
    Actors["Soldier_4"],
    Actors["Soldier_5"],
    Actors["Soldier_6"],
    Actors["Soldier_7"],
  }) do
    a:UnlockAi()
    a:SetAlwaysAttentive(false)
    Actors["Soldier_11"]:AddSquadMember(a)
  end

  CyrSeq()
    :Wait(50)
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_8"])
    :Call("Actor.AssignPatrol", Actors["Soldier_8"], Patrols["Patrol_9"])
    :Then()
    :Wait(10)
    :Then()
    :Call("Actor.UnlockAi", Actors["TaxCollector_2"])
    :Call("Actor.AssignPatrol", Actors["TaxCollector_2"], Patrols["Patrol_9"])
    :Start()
end

function ActivateTaxCollectorGuards()
  Actors["Soldier_24"]:AssignPatrol(Patrols["Patrol_17"])
  Actors["Soldier_7"]:SetAlwaysAttentive(false)
  Actors["Soldier_6"]:SetAlwaysAttentive(false)
  Actors["Soldier_5"]:SetAlwaysAttentive(false)
  Actors["Soldier_4"]:SetAlwaysAttentive(false)

  CyrSeq()
    :Move(Actors["Soldier_7"], Locations["Node_121"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_7"], Locations["Node_120"])
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_7"])
    :Then()
    :Wait(1)
    :Then()
    :Call("SetCurrentActorPost", Actors["Soldier_7"])
    :Start()

  CyrSeq()
    :Move(Actors["Soldier_6"], Locations["Node_122"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Soldier_6"], Locations["Node_120"])
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_6"])
    :Then()
    :Wait(1)
    :Then()
    :Call("SetCurrentActorPost", Actors["Soldier_6"])
    :Start()
end

function ActivateTaxCollectorSearchers()
  ShowPersonInside(Actors["Soldier_20"])
  ShowPersonInside(Actors["Soldier_21"])
  ShowPersonInside(Actors["Soldier_31"])

  CyrSeq()
    :Move(Actors["Soldier_5"], Locations["Node_128"], MovementStyle.walking)
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_5"])
    :Call("Actor.AddSquadMember", Actors["Soldier_4"], Actors["Soldier_5"])
    :Start()
  
  CyrSeq()
    :Move(Actors["Soldier_4"], Locations["Node_126"], MovementStyle.walking)
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_4"])
    :Call("Actor.AssignPatrol", Actors["Soldier_4"], Patrols["Patrol_11.1"])
    :Start()
end

function AlertTaxCollectorGroup()
  ShowPersonInside(Actors["Soldier_22"])
  ShowPersonInside(Actors["Soldier_23"])

  CyrSeq()
    :Move(Actors["TaxCollector_2"], Locations["Node_124"], MovementStyle.walking)
    :Then()
    :Move(Actors["TaxCollector_2"], Locations["Node_120"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["TaxCollector_2"], Locations["Node_67"])
    :Then()
    :Call("Actor.UnlockAi", Actors["TaxCollector_2"])
    :Then()
    :Wait(1)
    :Then()
    :Call("SetCurrentActorPost", Actors["TaxCollector_2"])
    :Then()
    :ScrollCameraTo(GetRobinCustom().location)
    :Then()
    :FinalizeCutscene()
    :Start()

  CyrSeq()
    :Move(Actors["Soldier_8"], Locations["Node_124"], MovementStyle.walking)
    :Then()
    :Move(Actors["Soldier_8"], Locations["Node_123"], MovementStyle.walking)
    :Then()
    :TurnTo(Actors["Soldier_8"], Locations["Node_120"])
    :Then()
    :Call("Actor.UnlockAi", Actors["Soldier_8"])
    :Then()
    :Wait(1)
    :Then()
    :Call("SetCurrentActorPost", Actors["Soldier_8"])
    :Start()

  ShowPersonInside(Actors["Soldier_24"])
  CyrSeq()
    :Wait(40)
    :Then()
    :Call("ActivateTaxCollectorGuards")
    :Start()

  CyrSeq()
    :Wait(180)
    :Then()
    :Call("ActivateTaxCollectorSearchers")
    :Start()
end

function CiviliansFlee()

  local groups = {
    {
      people = {"Civilian_10", "Civilian_11", "Civilian_12"},
      place = Locations["Node_116"],
      turnTo = nil,
      seq = nil,
    },
    {
      people = {"Civilian_13", "Civilian_14"},
      place = Locations["Node_118"],
      turnTo = nil,
      seq = nil,
    },
    {
      people = {"Civilian_6"},
      place = Locations["Node_44"],
      turnTo = nil,
      seq = nil,
    },
    {
      people = {"Civilian_8"},
      place = Locations["Node_172"],
      turnTo = Locations["Node_119"],
      seq = function (s)
          return s
            :Call("Actor.AttachScroll", Actors["Civilian_8"], Scrolls["Scroll_2"])
            :Call("LockOnPlace", Actors["Civilian_8"])
            :Then()
            :PlayAnimLoop(Actors["Civilian_8"], ActorAction.weeping)
      end,
    },
    {
      people = {"ManCivilianOld_1"},
      place = Locations["Node_115"],
      turnTo = nil,
      seq = function (s)
        return s
          :Call("Actor.AttachScroll", Actors["ManCivilianOld_1"], Scrolls["Scroll_3"])
          :Call("ShowPersonInside", Actors["ManCivilianOld_1"])
          :Then()
          :Wait(1)
          :Then()
          :Call("Actor.AssignPatrol", Actors["ManCivilianOld_1"], Patrols["Patrol_15"])
      end,
    },
    {
      people = {"Civilian_7"},
      place = Locations["Node_47"],
      turnTo = nil,
      seq = nil,
    },{
      people = {"Civilian_9"},
      place = Locations["Node_164"],
      turnTo = Locations["Node_165"],
      seq = function (s)
        return s
          :Call("Actor.AttachScroll", Actors["Civilian_9"], Scrolls["Scroll_7"])
          :Then()
          :Call("LockOnPlace", Actors["Civilian_9"])
          :Then()
          :PlayAnim(Actors["Civilian_9"], ActorAction.sitting_down)
          :Then()
          :PlayAnimLoop(Actors["Civilian_9"], ActorAction.sitting)
      end,
    }
  }

  for _, g in pairs(groups) do
    local time = Rand(20) + 10
    for _, a in pairs(g.people) do
      local actor = Actors[a]
      local first = (Rand(100) < 10)
      local second = (not first) and (Rand(100) < 10)
      actor:LockAi(false)

      local s = CyrSeq()
        :If(first)
          :Speak(actor, NpcRemark.civilian_panic)
          :Then()
        :Endif()
        :Wait(time + Rand(7))
        :Then()
        :If(second)
          :Speak(actor, NpcRemark.civilian_panic)
          :Then()
        :Endif()
        :If(g.turnTo == nil)
          :MoveIntoBuilding(actor, g.place, MovementStyle.running)
          :Then()
          :Call("DeactivateInside", actor)
        :Else()
          :Move(actor, g.place, MovementStyle.running)
          :Then()
          :TurnTo(actor, g.turnTo)
          :Then()
          :UnlockAi(actor)
          :Then()
          :Wait(1)
          :Then()
          :Call("SetCurrentActorPost", actor)
        :Endif()
        :Then()
        :If(g.seq ~= nil)
          s = g.seq(s)
      s
        :Endif()
        :Start()
    end
  end
end

RemoveMainVillain = {
  ReachPoint = function (actor)
    actor:AssignPatrol(God())
    DeactivateInside(Actors["MainVillain_5"])
    DeactivateInside(Actors["Soldier_10"])
    DeactivateInside(Actors["Soldier_26"])
    CiviliansFlee()
  end
}

RemoveTaxSoldiers = {
  ReachPoint = function (actor)
    for _, a in pairs({
      Actors["Soldier_4"],
      Actors["Soldier_5"],
      Actors["Soldier_6"],
      Actors["Soldier_7"],
      Actors["Soldier_11"],
    }) do
      DeactivateInside(a)
    end
    actor:AssignPatrol(God())
  end
}

RemoveMe = {
  ReachPoint = function (actor)
    print(actor.name)
    if actor == Actors["TaxCollector_2"] then
      CyrSeq()
        :ScrollCameraTo(GetRobinCustom().location)
        :Then()
        :FinalizeCutscene()
        :Start()
      Select(PcSelection.all)
    end
    actor:AssignPatrol(God())
    DeactivateInside(actor)
  end
}

PracticeTarget = {
  ActivatedByArrow = function(actorSource)
    actorSource:SetProperty(PersistentProperty.arrows, actorSource:GetProperty(PersistentProperty.arrows) + 1)
    for _, t in ipairs(targets[Globals.currentTargetGroup]) do
      print("deactivate target: " .. t)
      Actors[t]:Deactivate()
    end
    if Globals.currentTargetGroup == 1 then
      AddObjective(7, false)
      DisplayPopupText(16)
    end
    Globals.currentTargetGroup = Globals.currentTargetGroup + 1
    if Globals.currentTargetGroup > #targets then
      DisplayPopupText(17)
      SetLockDoorForAll(Battlement.Door.gardenDoor, false)
      Items["Money_5"]:Activate()
      CompleteObjective(7)
    else
      for _, t in pairs(targets[Globals.currentTargetGroup]) do
        Actors[t]:Activate()
      end
    end
  end,
}

function EdwardSobing()
  CyrSeq()
    :Wait(Rand(800) + 1200)
    :Then()
    :Speak(Actors["ManCivilianOld_1"], NpcRemark.civilian_cries)
    :Then()
    :Call("EdwardSobing")
    :Start()
end

EdwardPatrol = {
  ReachPoint = function(actor)
    BedRoom.Door.innerToTop.locked_for_pcs =  false
    BedRoom.Door.outerToTop.locked_for_pcs =  false
    actor:AssignPatrol(God())
    CyrSeq()
      :TurnTo(actor, Locations["Node_117"])
      :Then()
      :Call("EdwardSobing")
      :Start()
  end
}

ShiftScroll = {
  Taken = function(actorSource)
    DisplayPopupText(22)
    if(not Globals.shiftScrollPickedUp) then
      Globals.shiftScrollPickedUp = true
      Scrolls["Scroll_5"].state = ScrollState.visible
      Scrolls["Scroll_8"].state = ScrollState.visible
    end
  end,
}

PurseScroll = {
  Taken = function(actorSource)
    DisplayPopupText(23)
    if(not Globals.pursesScrollPickedUp) then
      Globals.pursesScrollPickedUp = true
      Items["Purses_7"]:Activate()
    end
  end,
}

YouCanShootScroll = {
  Taken = function(actorSource)
    DisplayPopupText(24)
    if(not Globals.arrowsScrollPickedUp) then
      Globals.arrowsScrollPickedUp = true
      Items["Arrows_3"]:Activate()
    end
  end,
}

CollectMoneyBack = {
  Taken = function(actorSource)
    DisplayPopupText(29)
  end,

  Timer = function()
    local state = 0;
    if(ThisScroll().state == ScrollState.invisible) then
      state = 1
      if(Items["Purses_7"].picked_up) then
        state = 2
        if(GetRobinCustom():GetProperty(PersistentProperty.purses) == 0) then
          state = 3
          local count = 0
          for _, a in ipairs({Actors["Soldier_13"],Actors["Soldier_14"],Actors["Soldier_15"]}) do
            if a.knocked_out then
              count = count + 1
            end
          end
          if(count > 1) then
            state = 4
            ThisScroll().state = ScrollState.visible
          end
        end
      end
    end
    print(state)
  end,
}