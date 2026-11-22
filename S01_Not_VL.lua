require("lib/seemless/S01")

local missionState = {
  initial = 0,
  spokeWithWife = 1,
  RobinSpokeWithTuck = 2,
  decidedToGo = 3,
  initiatedSheriffTalk = 4,
  inPrison = 5,
  MuchSpokeWithTuck = 6,
  bothFree = 7,
}

Globals = {
  wifeOut = false,
  middleOfficerAlarmed = false,
  maxEnemyAlert = AlertLevel.notAlerted,
  maxAlertFrozen = false,
  missionState = missionState.initial,
  MuchVisible = false,
  pickedUpHerbsProgress = 0,
  arrowsMuchVisible = false,
  TuckAiLocked = false,
  prisonCutsceneTriggered = false,
}

---Events
function Initialize(seed)
  DebugFunc("Initialize", function ()
    InitS01()
  
    --we have to define for each internal space, when it can be revealed and what the reveal triggers
    ---@diagnostic disable: duplicate-set-field
    HiddenSpaces.castle_room.Condition = function ()
      return false
    end
    table.insert(HiddenSpaces.church.OnRevealFuncs, function ()

      return DebugFunc("church.OnRevealFunc", function ()
        Deactivate(GetItem("Clover_5"))
      end)

    end)
    table.insert(HiddenSpaces.prison_north.OnRevealFuncs, function ()
      return DebugFunc("prison_north.OnRevealFunc", function ()
        if Globals.missionState >= missionState.inPrison then
          CleanFromHisBuildingBeforeTeleport(GetRobin())
          SetActorLocation(GetRobin(), GetLocation("Node_55"))
          SetActorDirection(GetRobin(), ActorDirection.southSouthEast)
          ShowPersonInside(GetActor("Sherif_2"))
          ShowPersonInside(GetActor("Chevalier_21"))
          LockAI(GetActor("Chevalier_21"), false)
          LockAI(GetActor("Sherif_2"), false)
        end
      end)
    end)
    ---@diagnostic enable: duplicate-set-field
  
    Deactivate(GetActor("Much_1"))
    SetPersistentProperty(GetActor("Much_1"), PersistentProperty.nameID, 0)
    SetPersistentProperty(GetActor("Much_1"), PersistentProperty.arrows, 1)
  
    --if a playable character starts at a place, from which it can see into some building, this reveals it.
    RevealAnySeenByPCHideOthers()
  
    CustomizeMinimapDisplay(GetActor("Sherif_40"), 444)
    Deactivate(GetActorScript(MiscAnimation.gateBanner))
    FallGateRoom:ActivateFallGate(NoWhere())
    LockDoorForAll(88)
    LockDoorForAll(93)
    SetDoorLockedPC(GetDoorScript(76), true)
    SetDoorLockedNPCCivilian(GetDoorScript(4), true)
    Deactivate(GetItem("Arrows_3"))
    Deactivate(GetItem("Arrows_2"))
    
    DeactivateInside(GetActor("Chevalier_21"))
    DeactivateInside(GetActor("Soldier_63"))
  
    AddObjective(0, true)
  
    AttachScrollToNPC(GetActor("MuchWife_3"), GetScroll("Scroll_1"))
  
    JumpCameraTo(GetActorLocation(GetScroll("Scroll_1")))
  end)
end

function PostInitialize()
  DebugFunc("PostInitialize", function ()
    StartSequence()
    SequenceLockUser()
    Then()
    SequenceSetZoomLevel(ZoomLevel.default)
    Then()
    SequenceTimer(15)
    Then()
    SequenceDisplayPopupText(0)
    --I have to inform the sheriff about the atrocities commited in Lincoln! My father needs justice... And I need piece.
    --Edward told me this new sheriff is not as willing to help as the last one. But he will listen, he must. I should go see Much first though, Edward is right.
    --I can hardly stand being so close to justice and waste my time searching for him. Anyway, this is his house, let's get there. And then to sheriff.
    Then()
    SequenceTimer(40)
    Then()
    SequenceScrollCameraTo(GetActorLocation(GetRobin()))
    Then()
    SequenceCall(function ()
      Activate(GetItem("Arrows_2"))
    end)
    SequenceUnLockUser()
    EndSequence()
  end)
end

local maxAlert = AlertLevel.notAlerted

function Timer(seconds)
  DebugFunc("Timer", function ()
    if Globals.missionState < missionState.RobinSpokeWithTuck then
      if GetPersistentProperty(GetActor("Civilian_4"), PersistentProperty.knockOutTimer) > 30 then
        SetPersistentProperty(GetActor("Civilian_4"), PersistentProperty.knockOutTimer, 30)
      end
    end
  
    if not Globals.maxAlertFrozen then
      Globals.maxEnemyAlert = math.max(Globals.maxEnemyAlert, GetOverallEnemyAlert())
      if not (maxAlert == Globals.maxEnemyAlert) then
        maxAlert = Globals.maxEnemyAlert
        print(maxAlert)
      end
    end

    if Sees(GetActor("Civilian_4"), GetActor("Much_1")) then
      if not Globals.TuckAiLocked then
        LockAI(GetActor("Civilian_4"), true)
        Globals.TuckAiLocked = true
        
        StartSequence()
        SequenceTurnTo(GetActor("Civilian_4"), GetActorLocation(GetActor("Much_1")))
        EndSequence()
      end
    else
      if Globals.TuckAiLocked then
        UnlockAI(GetActor("Civilian_4"))
        Globals.TuckAiLocked = false
      end
      if Sees(GetActor("Civilian_4"), GetRobin()) then
        SetAIState(GetActor("Civilian_4"), AiState.wondering)
        StartSequence()
        SequenceTurnTo(GetActor("Civilian_4"), GetActorLocation(GetRobin()))
        EndSequence()
      end
    end
  end)
end

function CheckVictoryCondition(seconds)
  return DebugFunc("CheckVictoryCondition", function ()
    if IsActorDead(GetActor("Much_1")) then
      ChooseVictoryDefeatText(1)
      return 2
    end
    if Globals.missionState == missionState.bothFree then
      for i = 0, (GetNumberOfPCs() - 1) do
        local pc = GetPC(i)
        if not (IsActorOutOfAction(pc) or IsInside(pc, GetLocation("Node_9")) or IsInside(pc, GetLocation("Node_73"))) then
          return 0
        end
      end
      return 1
    end
    return 0
  end)
end

function AddMuch()
  DebugFunc("AddMuch", function ()
    AddPCToGang(GetActor("Much_1"))
    print("")
    print(Globals.maxEnemyAlert)
    print("")
    Globals.MuchVisible = not (Globals.maxEnemyAlert == AlertLevel.notAlerted)
    if not Globals.MuchVisible then
      SetInvisible(GetActor("Much_1"), true)
    end
    StartSequence()
    SequenceCharacterAvailable(GetActor("Much_1"), true)
    EndSequence()
  end)
end

--Actors
MuchActor = {
  ActionChange = function(action, oldAction)
    DebugFunc("MuchActor.ActionChange", function ()
      if not Globals.MuchVisible then
        local susActions = {
          {19, 33},
          {52, 79},
          {85, 94},
          {97, 97},
          {170, 177},
          {240, 240},
        }
        for _, pair in pairs(susActions) do
          if (action >= pair[1]) and (action <= pair[2]) then
            SetInvisible(GetActor("Much_1"), false)
            DisplayPopupText(14) --Well I bet they noticed regular citizens don't do such things. Guards will probably swarm me whenever they see me from now on.
            Globals.MuchVisible = true
          end
        end
      end
    end)
  end,
}

RemovePatrolOnAlarmed = {
  FilterAiEvent = function(actorSource, event)
    DebugFunc("RemovePatrolOnAlarmed.FilterAiEvent", function ()
      if event == 103 then
        Globals.middleOfficerAlarmed = true
      elseif (event == 101) and (Globals.middleOfficerAlarmed) then
        Globals.middleOfficerAlarmed = false
        RemoveAllSquadMembers(ThisActor())
      end
    end)
  end,
}

--Targets
mecanisme_herse_800003be = {
  ActivatedBySword = function(actorSource)
    FallGateRoom:ActivateFallGate(GetActorLocation(GetActor("Treadwheel")))
  end
}

--Waypoints
local swordsmen = {
  "Soldier_35",
  "Soldier_36"
}

function SwitchChiefSwordsmen(name, startIndex, patrol, waitTime)
  return DebugFunc(name .. " creation", function ()
    return {
      ReachPoint = function(actor)
        DebugFunc(name .. ".ReachPoint", function ()
          SetAIState(actor, AiState.script)
          StartSequence()
          SequenceTimer(waitTime)
          Then()
          SequenceCall(function ()
            RemoveAllSquadMembers(actor)
          end)
          Then()
          SequenceTimer(1)
          Then()
          SequenceCall(function ()
            local i = startIndex
            local first = true
            while first or not (i == startIndex) do
              first = false
              if not IsActorOutOfAction(GetActor(swordsmen[i])) then
                for index, value in ipairs(swordsmen) do
                  AssignPatrol(GetActor(value), GetPatrol(patrol))
                  if not (index == i) then
                    AddAsSquadMember(GetActor(swordsmen[i]), GetActor(swordsmen[index]))
                  end
                end
                break
              end
              i = i + 1
              if i > #swordsmen then
                i = 1
              end
            end
            SetAIState(actor, AiState.default)
          end)
          EndSequence()
        end)
      end
    }
  end)
end

SwitchChiefSwordsmen1 = SwitchChiefSwordsmen("SwitchChiefSwordsmen1", 2, "Patrol_11", 50)
SwitchChiefSwordsmen2 = SwitchChiefSwordsmen("SwitchChiefSwordsmen2", 1, "Patrol_10", 50)

function CrouchOnFieldFunc(name)
  return {
    ReachPoint = function(actor)
      DebugFunc("CrouchOnField" .. name .. ".ReachPoint(" .. GetActorName(actor) .. ")", function ()
        local state = GetAIState(actor)
        LockAI(actor, true)
        StartSequence()
        SequencePlayAnim(actor, AnimationAction.standingToSitting)
        for i = 1,3 do
          if Rand(1000) > 500 then
            Then()
            SequencePlayAnim(actor, AnimationAction.sitting)
          end
        end
        Then()
        SequencePlayAnim(actor, AnimationAction.sittingToStanding)
        Then()
        SequenceUnlockAI(actor)
        EndSequence()
      end)
    end
  }
end

CrouchOnField = CrouchOnFieldFunc("")
CrouchOnField1 = CrouchOnFieldFunc("1")
CrouchOnField2 = CrouchOnFieldFunc("2")
CrouchOnField3 = CrouchOnFieldFunc("3")
CrouchOnField4 = CrouchOnFieldFunc("4")

--Scrolls
MuchWifeScroll = {
  Taken = function(actorSource)
    return DebugFunc("MuchWifeScroll.Taken", function ()
      AttachScrollToNPC(GetActor("MuchWife_3"), God())
      AttachScrollToNPC(GetActor("Civilian_4"), GetScroll("Scroll_2"))
      Globals.missionState = missionState.spokeWithWife
      CompleteObjective(0)
      AddObjective(1, true)
  
      StartSequence()
      SequenceLockUser()
      SequenceCall(LockAllAI)
      Then()
      SequenceSetZoomLevel(ZoomLevel.default)
      Then()
      SequenceMoveCameraTo(GetActorLocation(GetActor("MuchWife_3")), 20)
      Then()
      SequenceTimer(5)
      Then()
      SequenceDisplayPopupText(1)
      --Robin? They told us me you were dead! So glad to you! Much has some work to do for our pastor, you will probably find him in the church.
      Then()
      SequenceTimer(10)
      Then()
      SequenceScrollCameraTo(GetLocation("Node_34"))
      Then()
      SequenceTimer(25)
      Then()
      SequenceJumpCameraTo(GetActorLocation(GetActor("MuchWife_3")))
      Then()
      SequenceUnLockUser()
      SequenceCall(UnlockUnlockableAI)
      Then()
      SequenceTimer(15)
      Then()
      SequenceMoveIntoBuilding(GetActor("MuchWife_3"), GetLocation("Node_37"), MovementStyle.walking)
      Then()
      SequenceCall(function ()
        DeactivateInside(GetActor("MuchWife_3"))
      end)
      EndSequence()
      return 1
    end)
  end,
}

FriarScroll = {
  Taken = function(actorSource)
    return DebugFunc("FriarScroll.Taken", function ()
      AttachScrollToNPC(GetActor("Civilian_4"), God())
      DisplayPopupText(2) --Who... who are you? I don't know anyone called Much. I am calling the guards, just wait here for them to arrive.
      SetAIState(GetActor("Civilian_4"), AiState.wondering)
      CompleteObjective(1)
      Globals.missionState = missionState.RobinSpokeWithTuck
      return 1
    end)
  end,
}

GuardDistractionScroll = {
  Taken = function(actorSource)
    return DebugFunc("GuardDistractionScroll.Taken", function ()
      if IsInside(GetActor("Soldier_44"), GetLocation("Node_30")) then
        if IsInside(GetActor("Civilian_6"), GetLocation("Node_28")) then
          local pc = actorSource
          if GetNumberOfSelectedPCs() > 0 then
            pc = GetSelectedPC(0)
          end
          SwitchToAlertPatrol(GetActor("Soldier_41"))
          DisplayMap(false)

          StartSequence()
          SequenceLockUser()
          SequenceCall(LockAllAI)
          Then()
          SequenceSetZoomLevel(ZoomLevel.default)
          Then()
          SequenceDisplayPopupText(10) --This guard is always helpful to anyone and eager to chat. Let's make him move a bit.
          Then()
          SequenceScrollCameraTo(GetLocation("Node_29"))
          Then()
          SequenceTimer(10)
          Then()
          SequenceReveal(GetActor("Civilian_6"))
          SequenceReveal(GetActor("Soldier_39"))
          SequenceReveal(GetActor("Soldier_44"))
          Then()
          SequenceTimer(10)
          Then()
          SequenceTurnTo(GetActor("Civilian_6"), GetLocation("Node_29"))
          Then()
          SequenceSpeak(GetActor("Civilian_6"), SpeakOffset.civilian + 2)
          Then()
          SequenceCall(function ()
            if IsInside(GetActor("Soldier_39"), GetLocation("Node_32")) then
              StartSequence()
              SequenceTimer(5)
              SequenceTurnTo(GetActor("Soldier_39"), GetActorLocation(GetActor("Civilian_6")))
              Then()
              SequenceTimer(25)
              Then()
              SequenceTurnTo(GetActor("Soldier_39"), GetLocation("Node_31"))
              EndSequence()
            end
          end)
          SequenceUnlockAI(GetActor("Soldier_44"))
          Then()
          SequenceTimer(1)
          Then()
          SequenceCall(function ()
            AssignPatrol(GetActor("Soldier_44"), GetPatrol("Patrol_20"))
            SetPatrolShouldRun(GetActor("Soldier_44"), true)
          end)
          Then()
          SequenceTimer(180)
          Then()
          SequenceUnlockAI(GetActor("Civilian_6"))
          Then()
          SequenceTimer(1)
          Then()
          SequenceCall(function ()
            AssignPatrol(GetActor("Civilian_6"), GetPatrol("Patrol_37"))
          end)
          Then()
          SequenceTimer(50)
          Then()
          SequenceScrollCameraTo(GetActorLocation(pc))
          Then()
          SequenceUnLockUser()
          SequenceCall(UnlockUnlockableAI)
          EndSequence()
          return 1
        else
          DisplayPopupText(12) --We have a plan to distract the guard under the gate, but our man is not ready, just wait for him to return.
        end
      else
        DisplayPopupText(11) --We have a plan to distract the guard that is usually here at the gate, but he is nowhere to be seen, let's wait for him to return. 
      end
    end)
  end,

  Timer = function()
    DebugFunc("GuardDistractionScroll.Timer", function ()
      if not (GetScrollState(ThisScroll()) == ScrollState.collected) then
        if IsActorOutOfAction(GetActor("Soldier_44")) then
          SetScrollState(ThisScroll(), ScrollState.collected)
        end
      end
    end)
  end
}

TuckHostileScroll = {
  Taken = function(actorSource)
    return DebugFunc("TuckHostileScroll.Taken", function ()
      local pc = actorSource
      if GetNumberOfSelectedPCs() > 0 then
        pc = GetSelectedPC(0)
      end
      StartSequence()
      SequenceLockUser()
      SequenceCall(LockAllAI)
      Then()
      SequenceSetZoomLevel(ZoomLevel.default)
      Then()
      SequenceScrollCameraTo(GetLocation("Node_34"))
      Then()
      SequenceTimer(10)
      Then()
      SequenceCall(RevealChurch)
      Then()
      SequenceTimer(15)
      Then()
      SequenceReveal(GetActor("Civilian_4"))
      Then()
      SequenceTimer(10)
      Then()
      SequenceDisplayPopupText(9) --Oh you are looking for our friar? Yeah, he is in the church, I am not sure he will be glad to see you though.
      Then()
      SequenceTimer(10)
      Then()
      SequenceJumpCameraTo(GetActorLocation(pc))
      Then()
      SequenceUnLockUser()
      SequenceCall(UnlockUnlockableAI)
      EndSequence()
      return 1
    end)
  end
}

ShowSyncArcherOfficer = {
  Taken = function(actorSource)
    return DebugFunc("ShowSyncArcherOfficer.Taken", function ()
      local pc = actorSource
      if GetNumberOfSelectedPCs() > 0 then
        pc = GetSelectedPC(0)
      end
      StartSequence()
      SequenceLockUser()
      SequenceCall(LockAllAI)
      Then()
      SequenceSetZoomLevel(ZoomLevel.default)
      Then()
      SequenceScrollCameraTo(GetLocation("Node_33"))
      Then()
      SequenceTimer(10)
      Then()
      SequenceReveal(GetActor("Soldier_46"))
      SequenceReveal(GetActor("Soldier_47"))
      SequenceReveal(GetActor("Soldier_48"))
      SequenceReveal(GetActor("Soldier_49"))
      SequenceReveal(GetActor("Soldier_50"))
      Then()
      SequenceTimer(10)
      Then()
      SequenceDisplayPopupText(13) --This archer and officer are brothers, you wouldn't catch that, would ya? Anyways, they will always check on each other.
      Then()
      SequenceTimer(10)
      Then()
      SequenceJumpCameraTo(GetActorLocation(pc))
      Then()
      SequenceUnLockUser()
      SequenceCall(UnlockUnlockableAI)
      EndSequence()
      return 1
    end)
  end,
}

SomeoneWasLookingForYou = {
  Taken = function(actorSource)
    return DebugFunc("SomeoneWasLookingForYou.Taken", function ()
      AttachScrollToNPC(GetActor("Civilian_4"), God())
      if Globals.pickedUpHerbsProgress == 2 then
        DisplayPopupText(15)
        --Good day my son, you have the herbs? Lovely. Oh look, something is stuck in it, hope it brings you luck.
        --By the way, a scary guy was looking for you, I told him I don't know you. He then headed to the castle hastly.
        local spots = {
          GetLocation("Node_61"),
          GetLocation("Node_62"),
          GetLocation("Node_63"),
          GetLocation("Node_64"),
        }
        local tuckLoc = GetActorLocation(GetActor("Civilian_4"))
        local pos
        local dist = 100000
        for _, s in pairs(spots) do
          local d = GetDistance(tuckLoc, s)
          if d < dist then
            dist = d
            pos = s
          end
        end
        Activate(GetItem("Clover_5"))
        SetActorLocation(GetItem("Clover_5"), pos)
      else
        DisplayPopupText(16)
        --I am dissapointed my son, I really needed the herbs. You will get it tomorrow for me then.
        --By the way, a scary guy was looking for you, I told him I don't know you. He then headed to the castle hastly.
      end
      Globals.missionState = missionState.MuchSpokeWithTuck
      CompleteObjective(4)
      AddObjective(5, true)
      return 1
    end)
  end,
}

YouCanTieUp = {
  Taken = function(actorSource)
    return DebugFunc("YouCanTieUp.Taken", function ()
      DisplayPopupText(20)
      --Each character can do something with dead/unconcious bodies. Remember to check with each new character.
      return 1
    end)
  end
}

ThereAreBeggarsScroll = {
  Taken = function (actor)
    DisplayPopupText(21)
    --Sometimes you will encounter a beggar. They are frownd upon, but they mostly sit and watch all day 
    --so they gather a lot of info about what's going on. I bet they would be eager to share it for some money.
  end
}

--Zones
MuchFamilyHouse = {
  Enter = function(actor)
    return DebugFunc("MuchFamilyHouse.Enter", function ()
      if not Globals.wifeOut then
        if IsActorPC(actor) then
          Globals.wifeOut = true
          ShowPersonInside(GetActor("MuchWife_3"))
          Reveal(GetActor("MuchWife_3"))
          StartSequence()
          SequenceTimer(1)
          Then()
          SequenceCall(function ()
            AssignPatrol(GetActor("MuchWife_3"), GetPatrol("Patrol_21"))
          end)
          EndSequence()
        end
      elseif not Globals.arrowsMuchVisible then
        if IsActorEqual(actor, GetActor("Much_1")) then
          Globals.arrowsMuchVisible = true
          Activate(GetItem("Arrows_3"))
        end
      end
    end)
  end,
}

TellTuckFirst1 = {
  Enter = function(actor)
    return DebugFunc("TellTuckFirst1.Enter", function ()
      if Globals.missionState < missionState.decidedToGo then
        if IsActorPC(actor) then
          StartSequence()
          SequenceLockUser()
          Then()
          SequenceMove(actor, GetLocation("Node_35"), GetMovementStyle(actor))
          Then()
          SequenceDisplayPopupText(8) --I probably shouldn't go there without trying to find Much first.
          Then()
          SequenceUnLockUser()
          EndSequence()
        end
      end
    end)
  end,
}

MuchVisibleZone = {
  Enter = function(actor)
    return DebugFunc("MuchVisibleZone.Enter", function ()
      if not Globals.MuchVisible then
        if IsActorEqual(actor, GetActor("Much_1")) then
          SetInvisible(GetActor("Much_1"), false)
          Globals.MuchVisible = true
  
          if (IsInside(GetActor("Soldier_38"), GetLocation("Node_39")) and not IsActorOutOfAction(GetActor("Soldier_38")))
            or (IsInside(GetActor("Soldier_39"), GetLocation("Node_32")) and not IsActorOutOfAction(GetActor("Soldier_39"))) then
              
            DisplayPopupText(7) --Not a step further, citizen!
          else
            DisplayPopupText(6) --I shouldn't be here, they are probably gonna be hostile from now on.
          end
        end
      end
    end)
  end,
}

OutOfChurchZone = {
  Enter = function(actor)
    return DebugFunc("OutOfChurchZone.Enter", function ()
      if IsActorPC(actor) and (Globals.missionState == missionState.RobinSpokeWithTuck) then
        Globals.missionState = missionState.decidedToGo
        DisplayPopupText(3) --I cannot be bothered to search the whole town to find Much, let's go meet sheriff. That is what I should be doing now.
        AddObjective(3, true)
      end
    end)
  end
}

function LockAICastleYardSoldiers()
  return DebugFunc("LockAICastleYardSoldiers", function ()
    RemoveAllSquadMembers(GetActor("Officier_Bleu_10"))
    local soldiers = {
      GetActor("Officier_Bleu_10"),
      GetActor("Lancier_Bleu_11"),
      GetActor("Lancier_Bleu_12"),
      GetActor("Lancier_Bleu_13"),
      GetActor("Lancier_Bleu_14"),
    }
    for _, s in pairs(soldiers) do
      LockAI(s, false)
    end
  end)
end


function CastleYardSoldierSideways()
  return DebugFunc("CastleYardSoldierSideways", function ()
    local soldiers = {
      GetActor("Officier_Bleu_10"),
      GetActor("Lancier_Bleu_11"),
      GetActor("Lancier_Bleu_12"),
      GetActor("Lancier_Bleu_13"),
      GetActor("Lancier_Bleu_14"),
    }

    for _, s in pairs(soldiers) do
      local pos
      if GetDistance(GetActorLocation(s), GetLocation("Node_41")) < GetDistance(GetActorLocation(s), GetLocation("Node_42")) then
        if Rand(1000) < 500 then
          pos = ComputeLocationBetween(GetLocation("Node_47"), GetLocation("Node_48"), Rand(100) * 0.01)
        else
          pos = ComputeLocationBetween(GetLocation("Node_48"), GetLocation("Node_49"), Rand(100) * 0.01)
        end
      else
        if Rand(1000) < 500 then
          pos = ComputeLocationBetween(GetLocation("Node_50"), GetLocation("Node_51"), Rand(100) * 0.01)
        else
          pos = ComputeLocationBetween(GetLocation("Node_51"), GetLocation("Node_52"), Rand(100) * 0.01)
        end
      end
      StartSequence()
      SequenceTurnTo(s, GetLocation("Node_44"))
      Then()
      SequenceTimer(4 + Rand(12))
      Then()
      SequenceMove(s, pos, MovementStyle.walking)
      Then()
      SequenceTurnTo(s, GetActorLocation(GetActor("Sherif_2")))
      EndSequence()
    end
  end)
end

SherifCutsceneZone = {
  Enter = function(actor)
    return DebugFunc("SherifCutsceneZone.Enter", function ()
      if (not IsActorPC(actor)) or not (Globals.missionState == missionState.decidedToGo) then
        return
      end
      Globals.missionState = missionState.initiatedSheriffTalk
      Globals.maxAlertFrozen = true
      CompleteObjective(2)
      StopActor(actor)
      SetInvisible(actor, true)
      local previousOutlineDisplay = GetOutlineDisplay()
      SetOutlineDisplay(false)
      DisplayMap(false)
      LockAICastleYardSoldiers()
      AttachScrollToNPC(GetActor("Civilian_4"), GetScroll("Scroll_6"))
      LockAllAI()

      StartSequence()
      SequenceTimer(15)
      Then()
      SequenceCall(CastleYardSoldierSideways)
      EndSequence()

      StartSequence()
      SequenceMove(actor, GetLocation("Node_44"), MovementStyle.walking)
      Then()
      SequenceTurnTo(actor, GetActorLocation(GetActor("Sherif_2")))
      EndSequence()

      StartSequence()
      SequenceLockUser()
      Then()
      SequenceMoveCameraTo(GetActorLocation(GetActor("Sherif_2")), 8)
      Then()
      SequenceTimer(5)
      Then()
      SequenceTurnTo(GetActor("Sherif_2"), GetActorLocation(actor))
      Then()
      SequenceTimer(10)
      Then()
      SequenceTurnTo(GetActor("Civilian_7"), GetActorLocation(actor))
      Then()
      SequenceTimer(5)
      Then()
      SequenceCall(function ()
        Activate(GetActor("Chevalier_21"))
        StartSequence()
        SequenceMove(GetActor("Civilian_7"), GetLocation("Node_58"), MovementStyle.running)
        Then()
        SequenceMoveIntoBuilding(GetActor("Civilian_7"), GetLocation("Node_45"), MovementStyle.running)
        Then()
        SequenceCall(function ()
          DeactivateInside(GetActor("Civilian_7"))
        end)
        EndSequence()
      end)
      Then()
      SequenceCall(function ()
        StartSequence()
        SequenceMove(GetActor("Chevalier_21"), GetLocation("Node_44"), MovementStyle.walking)
        Then()
        SequenceTurnTo(GetActor("Chevalier_21"), GetActorLocation(GetActor("Sherif_2")))
        EndSequence()
      end)
      Then()
      SequenceTimer(25)
      Then()
      SequenceMove(actor, GetLocation("Node_46"), MovementStyle.walking)
      Then()
      SequenceTurnTo(actor, GetActorLocation(GetActor("Sherif_2")))
      SequenceTurnTo(GetActor("Sherif_2"), GetActorLocation(actor))
      Then()
      SequenceTimer(20)
      Then()
      SequencePlayDialog(0)
      --My lord, I am Robin of Lincoln, I just returned from the crusades and I have urgent news. My father was just brutally killed on his land.

      --Slow down young man. Robin of Lincoln you say? Do you have any proove of your identity? Some family seal or emblem?

      --Yes my lord, here it is.
      Then()
      SequenceTimer(15)
      Then()
      SequenceCall(function ()
        StartSequence()
        SequenceMove(actor, GetLocation("Node_53"), MovementStyle.walking)
        Then()
        SequencePlayAnim(actor, 124)
        EndSequence()
      end)
      Then()
      SequenceCall(function ()
        StartSequence()
        SequencePlayAnim(GetActor("Sherif_2"), 101)
        EndSequence()
      end)
      Then()
      SequenceMove(GetActor("Chevalier_21"), GetLocation("Node_46"), MovementStyle.running)
      Then()
      SequenceCall(function ()
        StartSequence()
        SequenceTimer(14)
        Then()
        SequenceCall(function ()
          DealDamage(actor, 0, true)
          SetPersistentProperty(actor, PersistentProperty.knockOutTimer, 10000)
        end)
        EndSequence()
      end)
      Then()
      SequencePlayAnim(GetActor("Chevalier_21"), AnimationAction.fistPunch)
      Then()
      SequenceTimer(5)
      Then()
      SequenceTimer(30)
      Then()
      SequenceCall(AddMuch)
      SequenceCharacterAvailable(GetRobin(), false)
      Then()
      SequenceScrollCameraTo(GetActorLocation(GetActor("Much_1")))
      Then()
      SequenceCall(function ()
        AddObjective(3, true)
        TeleportRobinToPrison()
        Globals.missionState = missionState.inPrison
        ShowPersonInside(GetActor("Soldier_63"))
        Reveal(GetActor("Soldier_63"))
        SetActorLocation(GetActor("Lancier_Bleu_11"), GetLocation("Node_65"))
        SetActorLocation(GetActor("Lancier_Bleu_12"), GetLocation("Node_65"))
        SetActorLocation(GetActor("Lancier_Bleu_13"), GetLocation("Node_65"))
        SetActorLocation(GetActor("Lancier_Bleu_14"), GetLocation("Node_65"))
      end)
      SequenceMove(GetActor("Much_1"), GetLocation("Node_54"), MovementStyle.walking)
      Then()
      SequenceUnLockUser()
      SequenceCall(UnlockUnlockableAI)
      Then()
      SequenceCall(function ()
        Select(31)
        SwitchToAlertPatrol(GetActor("Officier_Bleu_10"))
      end)
      Then()
      SequenceCall(function ()
        if Globals.MuchVisible then
          DisplayPopupText(4)
          --How did I deserve this mess? Did I get this as a punishment for my sins? Hell no, it's our pastor's fault. And he wanted me to pick up some herbs in the north woods,
          --but with all he put me through? I think I did enough, let's head back to him and then home.
          --How am I gonna get there though? All of the guards are now mad at me cause of him. And they were alerted for some reason! They will probably pierce me on sight.
        else
          DisplayPopupText(5)
          --How did I deserve this mess? For my sins? Did I get this as a punishment for my sins? Hell no, it's our pastor's fault. And he wanted me to pick up some herbs in the north woods,
          --but with all he put me through? I think I did enough, let's head back to him and then home. At least guards seem to be chill for once today.
          --I should behave though.
        end
        SetOutlineDisplay(previousOutlineDisplay)
        AddObjective(4, false)
      end)
      EndSequence()
    end)
  end
}

function TeleportRobinToPrison()
  return DebugFunc("TeleportRobinToPrison", function ()
    SetActorLocation(GetRobin(), GetLocation("Node_55"))
    SetActorDirection(GetRobin(), ActorDirection.northNorthEast)
    PutActorInBulding(GetRobin(), GetBuildingScript(41))
  
    SetActorLocation(GetActor("Sherif_2"), GetLocation("Node_56"))
    SetActorDirection(GetActor("Sherif_2"), ActorDirection.north)
  
    SetActorLocation(GetActor("Chevalier_21"), GetLocation("Node_57"))
    SetActorDirection(GetActor("Chevalier_21"), ActorDirection.eastNorthEast)
  
    StartSequence()
    SequenceTimer(1)
    Then()
    SequenceCall(function ()
      SetCurrentActorPost(GetActor("Sherif_2"))
      SetCurrentActorPost(GetActor("Chevalier_21"))
    end)
    Then()
    SequenceTimer(1)
    Then()
    SequenceCall(function ()
      Deactivate(GetActor("Sherif_2"))
      Deactivate(GetActor("Chevalier_21"))
      Deactivate(GetRobin())
    end)
    EndSequence()
  end)
end

HowToPickUpHerbsZone = {
  Enter = function(actor)
    return DebugFunc("HowToPickUpHerbsZone.Enter", function ()
      if Globals.pickedUpHerbsProgress < 1 then
        DisplayPopupText(17)
        Globals.pickedUpHerbsProgress = 1
      end
    end)
  end
}

PickUpHerbsZone = {
  Enter = function(actor)
    return DebugFunc("PickUpHerbsZone.Enter", function ()
      if Globals.pickedUpHerbsProgress < 2 then
        Deactivate(GetItem("MedicinalHerbs_4"))
        DisplayPopupText(18)
        CompleteObjective(4)
        Globals.pickedUpHerbsProgress = 2
      end
    end)
  end
}

RobinInPrisonCutscene = {
  Enter = function(actor)
    return DebugFunc("RobinInPrisonCutscene.Enter", function ()
      if (Globals.prisonCutsceneTriggered) then
        return
      end
      if IsActorEqual(actor, GetActor("Much_1")) and (Globals.missionState == missionState.MuchSpokeWithTuck) then
        Globals.prisonCutsceneTriggered = true
        StopActor(actor)
        SetPersistentProperty(GetRobin(), PersistentProperty.knockOutTimer, 0)
        DisplayMap(false)

        StartSequence()
        SequenceLockUser()
        SequenceCall(LockAllAI)
        Then()
        SequenceSetZoomLevel(ZoomLevel.default)
        Then()
        SequenceScrollCameraTo(GetLocation("Node_57"))
        Then()
        SequenceTimer(5)
        SequenceCall(function ()
          StartSequence()
          SequenceMove(actor, GetLocation("Node_67"), MovementStyle.running)
          Then()
          SequenceTurnTo(actor, GetLocation("Node_68"))
          EndSequence()
        end)
        Then()
        SequenceTimer(10)
        Then()
        SequenceMove(GetActor("Sherif_2"), GetLocation("Node_69"), MovementStyle.walking)
        Then()
        SequenceTimer(10)
        Then()
        SequenceDisplayPopupText(19)
        --You are finally awake. Sorry for the inconvinience, at first I thought you don't really fit into the story I am making here.
        --And then it hit me. A son faked his death to kill his father, people are gonna love it! And you will hang. Not exactly today, but shortly.
        --I found you some company so you don't feel lonely in the meantime. Meet Jeff.
        Then()
        SequenceCall(function ()
          SetDoorLockedNPCCivilian(GetDoorScript(88), false)
          StartSequence()
          SequenceTimer(10)
          Then()
          SequenceMoveIntoBuilding(GetActor("Sherif_2"), GetLocation("Node_70"), MovementStyle.walking)
          Then()
          SequenceCall(function ()
            DeactivateInside(GetActor("Sherif_2"))
            SetDoorLockedNPCCivilian(GetDoorScript(88), true)
          end)
          EndSequence()
        end)
        Then()
        SequenceTimer(60)
        Then()
        SequenceCall(function ()
          StartSequence()
          SequenceTimer(5)
          Then()
          SequenceCall(function ()
            StartSequence()
            SequenceTurnTo(GetRobin(), GetActorLocation(GetActor("Chevalier_21")))
            EndSequence()
          end)
          Then()
          SequenceTurnTo(GetActor("Chevalier_21"), GetActorLocation(GetRobin()))
          Then()
          SequenceMove(GetActor("Chevalier_21"), GetLocation("Node_71"), MovementStyle.walking)
          Then()
          SequenceCall(function ()
            StartSequence()
            SequenceTimer(14)
            Then()
            SequencePlayAnimFreeze(GetRobin(), AnimationAction.stunned)
            EndSequence()
          end)
          Then()
          SequencePlayAnim(GetActor("Chevalier_21"), AnimationAction.fistPunch)
          Then()
          EndSequence()
        end)
        Then()
        SequenceTimer(25)
        Then()
        SequenceMove(actor, GetLocation("Node_72"), MovementStyle.walking)
        Then()
        SequenceSpeakPC(actor, 3, 2)
        Then()
        SequenceTurnTo(GetActor("Chevalier_21"), GetActorLocation(actor))
        Then()
        SequenceCall(function ()
          StartSequence()
          SequenceSpeak(GetActor("Chevalier_21"), SpeakOffset.soldier + 3)
          EndSequence()

          StartSequence()
          SequencePlayAnim(GetActor("Chevalier_21"), AnimationAction.provoking)
          EndSequence()
        end)
        Then()
        SequencePlayAnim(GetRobin(), AnimationAction.standUp)
        Then()
        SequenceCall(function ()
          StartSequence()
          SequenceTimer(14)
          Then()
          SequenceCall(function ()
            DealDamage(GetActor("Chevalier_21"), 0, true)
            SetPersistentProperty(GetActor("Chevalier_21"), PersistentProperty.knockOutTimer, 44) --approx 35 seconds until he wakes up
          end)
          EndSequence()
        end)
        Then()
        SequencePlayAnim(GetRobin(), AnimationAction.fistPunch)
        Then()
        SequenceTurnTo(GetRobin(), GetActorLocation(actor))
        Then()
        SequenceCall(function ()
          StartSequence()
          SequenceTurnTo(actor, GetActorLocation(GetRobin()))
          EndSequence()
          CompleteObjective(5)
          AddObjective(6, true)
          Globals.missionState = missionState.bothFree
          ActivateSherwoodSigns()
        end)
        Then()
        SequenceTimer(5)
        Then()
        --SequencePlayDialog(1)
        --Oh hi Much, what's the delay? 

        --Hello Robin, I can see that you are enjoying the hospitability of our sherif.

        --Yeah, I like the room, just Jeff here is no fun.
        --Anyways... I reckon you already know about my father? 
        
        --Yes, I do. My condelences.

        --I need to find someone who can help me enforce justice.

        --You wanna go alone? Don't you start with this, I am going with you! Anyone specific on your mind?

        --I was thinking... Is lady Marian still in Leicester?

        --In? She rules the whole town.
        Then()
        SequenceCharacterAvailable(GetRobin(), true)
        Then()
        SequenceCall(function ()
          SetInvisible(GetRobin(), false)
          SetScrollState(GetScroll("Scroll_7"), ScrollState.default)
        end)
        Then()
        SequenceCall(UnlockUnlockableAI)
        SequenceUnLockUser()
        EndSequence()
      end
    end)
  end
}

FinishZone = {
  Enter = function (actor)
    if (Globals.missionState >= missionState.bothFree) and IsActorPC(actor) then
      ForceCheckVictory()
    end
  end
}