require("lib/ambush")

FightState = {
  Initial = 0,
  Started = 1,
  Running = 2,
  Ended = 3,
}

GameState = {
  BeforeEnemies = 0,
  WithEnemies = 1,
  EnemiesKO = 2,
  Won = 3
}

Globals = {
  FightState = FightState.Initial,
  FightStartTime = nil,
  FightDuration = 12,
  FightEndMaxRange = 50,
  FightEndMinRange = 20,
  IsReturningRobinIntoFight = false,
  CameraAlreadyLockedOnOfficer = false,
  GameState = GameState.BeforeEnemies,
  LancierUnderTrapTriggered = false,
  RockPatrolsChanged = false,
}

local lowestLittleJohnEnemyHp = 150
local maxEnemyLittleJohnHp = 250
local damageToWinFight = 35
local archerDamage = 8

function Initialize()
  CyrSeq()
    :DeactivateMobileElement(0)
    :Start()

  for _, a in pairs({
    Actors["Lancier_Bleu_10"],
    Actors["Lancier_Bleu_11"],
    Actors["Lancier_Bleu_12"],
    Actors["Lancier_Bleu_13"],
    Actors["Epee_Bleu_14"],
    Actors["Epee_Bleu_15"],
    Actors["Lancier_Bleu_16"],
    Actors["Epee_Bleu_17"],
    Actors["Archer_Bleu_18"],
    Actors["Archer_Bleu_19"],
    Actors["Archer_Bleu_20"],
    Actors["Officier_Bleu_21"],
    Actors["Lancier_Bleu_22"],
  }) do
    DeactivateInside(a)
  end

  Actors["Soldier_21"]:Deactivate()
  Deactivate(GetActorScript(18))

  Patches["Patch_12"]:SetAnimationActive(false)
  Patches["Patch_13"]:SetAnimationActive(false)
  Patches["Patch_14"]:SetAnimationActive(false)
  Patches["Patch_21"]:SetAnimationActive(false)
  
  Patches["Patch_20"]:SetAnimationActive(false)
  Patches["Patch_2"]:Apply()

  Deactivate(Items["Arrows_1"])

  Actors["LittleJohnEnemy_20"].location = NoWhere()
  DeactivateInside(Actors["LittleJohnEnemy_20"])

  Actors["Bow_Target_2"]:Deactivate()
  Actors["Bow_Target_6"]:Deactivate()
  Actors["Bow_Target_8"]:Deactivate()
  Actors["Target_16"]:Deactivate()
  Actors["Croisement03_-_rocher01_b1_9"]:Deactivate()
  Actors["Croisement03_-_rocher01_b1_14"]:Deactivate()
  Actors["Croisement03_-_piege02h_1"]:Deactivate()
  Actors["TARGET_PaysanDbaton_08_3"]:Deactivate()
  Actors["TARGET_PaysanDbaton_08_4"]:Deactivate()
  Actors["TARGET_PaysanDbaton_08_5"]:Deactivate()

  Actors["Hero_2"].location = Locations["Node_61"]
  Actors["Hero_3"].location = Locations["Node_61"]
  Actors["Hero_4"].location = Locations["Node_61"]
  Actors["Hero_4"]:SetProperty(PersistentProperty.hp, archerDamage)
  SetCustomCampaignValue(CampaignValueIndices.LittleJohnInjured, 1)
  Actors["Hero_1"]:AddToGang()
  Actors["Hero_2"]:AddToGang()
  Actors["Hero_3"]:AddToGang()

  GetMuch():SetProperty(PersistentProperty.arrows, GetMuch():GetProperty(PersistentProperty.arrows) + 2)

  SetOutlineDisplay(false)
  DisplayMap(false)

  JumpCameraTo(Locations["Node_30"])
end

function PostInitialize()
  WalkToLog()

  AddObjective(0, true)
end

function WalkToLog()
  SimultaneousSequencesInSequence({
    {
      function ()
          :LockUser()
      end,
      function ()
          :Move(Heroes.Robin, Locations["Node_35"], MovementStyle.walking)
          :Then()
          :TurnTo(Heroes.Robin, Locations["Node_29"])
      end,
      function ()
          :Move(GetMuch(), Locations["Node_49"], MovementStyle.walking)
          :Then()
          :TurnTo(GetMuch(), Locations["Node_29"])
      end,
      function ()
          :MoveCameraTo(Locations["Node_45"], 8)
      end,
    },{
      function ()
          :Wait(22)
          :Then()
          :DisplayPopupText(0)
      end,
    },{
      function ()
          :Move(GetMuch(), Locations["Node_45"], MovementStyle.walking)
          :Then()
          :Move(GetMuch(), Locations["Node_50"], MovementStyle.walking)
          :Then()
          :Move(GetMuch(), Locations["Node_47"], MovementStyle.walking)
      end,
      function ()
          :Move(Heroes.Robin, Locations["Node_46"], MovementStyle.walking)
          :Then()
          :Move(Heroes.Robin, Locations["Node_39"], MovementStyle.walking)
          :Then()
          :Move(Heroes.Robin, Locations["Node_48"], MovementStyle.walking)
      end,
      function ()
        CyrSeq()
          :Wait(100)
          :Then()
          :Call(RobinJohnFightInitiate)
          :Start()
      end,
    }
  })
end

function RobinJohnFightInitiate()
  SimultaneousSequencesInSequence(
    {
      {
        function ()
            :Call(function ()
            CyrSeq()
              :MoveCameraTo(Locations["Node_56"], 3)
              :Start()
          end)
            :Wait(15)
            :Then()
            :Call(function ()
            Actors["Hero_1"].location = Locations["Node_57"]
            Actors["Hero_2"].location = Locations["Node_58"]
            Actors["Hero_3"].location = Locations["Node_59"]
            Actors["Hero_4"].location = Locations["Node_60"]
          end)
            :Wait(10)
        end
      },{
        function ()
            :Move(Actors["Hero_1"], Locations["Node_54"], MovementStyle.running)
            :Then()
            :TurnTo(Actors["Hero_1"], Locations["Node_55"])
        end,
        function ()
            :Call(function ()
            CyrSeq()
              :Move(Actors["Hero_2"], Locations["Node_52"], MovementStyle.walking)
              :Then()
              :TurnTo(Actors["Hero_2"], Locations["Node_55"])
              :Start()
          end)
        end,
        function ()
            :Move(Actors["Hero_3"], Locations["Node_53"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_3"], Locations["Node_55"])
        end,
        function ()
            :Move(Actors["Hero_4"], Locations["Node_51"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_4"], Actors["Target_15"].location)
            :Then()
            :Action(Actors["Hero_4"], ActorAction.targetHold, Actors["Target_15"].index)
            :Then()
            :Wait(25)
        end,
        function ()
            :Wait(40)
            :Then()
            :TurnTo(GetMuch(), Locations["Node_54"])
        end,
        function ()
            :Wait(30)
            :Then()
            :TurnTo(Heroes.Robin, Locations["Node_54"])
        end,
      },{
        function ()
            :Move(Heroes.Robin, Locations["Node_55"], MovementStyle.walking)
            :Then()
            :TurnTo(Heroes.Robin, Locations["Node_54"])
        end,
      },{
        function ()
            :Wait(10)
            :Then()
            :DisplayPopupText(2)
            :Then()
            :CharacterAvailable(GetMuch(), false)
            :Then()
            :DisplayPopupText(3)
            :Then()
            :Action(Actors["Hero_4"], ActorAction.targetStop, 0)
            :Then()
            :Wait(10)
        end
      },{
        function ()
            :Move(Heroes.Robin, Locations["Node_63"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_4"], Locations["Node_62"])
            :Then()
            :TurnTo(Heroes.Robin, Locations["Node_62"])
        end,
        function ()
            :Move(Actors["Hero_1"], Locations["Node_62"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_1"], Locations["Node_63"])
            :Then()
            :Call(function ()
            Actors["LittleJohnEnemy_20"]:Activate()
            Actors["LittleJohnEnemy_20"].location = Actors["Hero_1"].location
            Actors["LittleJohnEnemy_20"].direction = Actors["Hero_1"].direction
            Actors["Hero_1"].location = Locations["Node_61"]
          end)
        end,
      },{
        RobinJohnFight
      }
    }
  )
end

function GetMuch()
  local much = GetActorScript(GetNumberOfActorsInEngine() - 1)
  if(Heroes.Robin == much) then
    much = GetActorScript(GetNumberOfActorsInEngine() - 2)
  end
  return much
end

function RobinJohnFight()
  GetMuch().invisible = true
  Actors["Hero_1"].invisible = true
  Actors["Hero_2"].invisible = true
  Actors["Hero_3"].invisible = true
  Actors["Hero_4"].invisible = true
  UnlockFromPlace(Actors["LittleJohnEnemy_20"])
  Globals.FightState = FightState.Started

  CyrSeq()
    :UnlockUser()
    :Then()
    :Action(Actors["LittleJohnEnemy_20"], ActorAction.stab1, Heroes.Robin.index)
    :Start()
end

function Timer(secondsPassed)
  if (Globals.FightState == FightState.Started) then
    Globals.FightStartTime = secondsPassed
    Globals.FightState = FightState.Running
  elseif (Globals.FightState == FightState.Running) then
    if (Actors["LittleJohnEnemy_20"]:GetProperty(PersistentProperty.concussion) > 0) then
      if(IsActorKO(Actors["LittleJohnEnemy_20"])) then
        Globals.FightStartTime = Globals.FightStartTime + 2
      end
      Actors["LittleJohnEnemy_20"]:SetProperty(PersistentProperty.concussion, 0)
    end
    local hp = Actors["LittleJohnEnemy_20"]:GetProperty(PersistentProperty.hp)
    if (hp < lowestLittleJohnEnemyHp) then
      Actors["LittleJohnEnemy_20"]:SetProperty(PersistentProperty.hp, lowestLittleJohnEnemyHp)
    end
    if (Globals.FightStartTime + Globals.FightDuration <= secondsPassed) then
      if(maxEnemyLittleJohnHp - hp >= damageToWinFight) then
        if(not Globals.IsReturningRobinIntoFight) then
          local d = Heroes.Robin.location:DistanceTo(Actors["LittleJohnEnemy_20"].location)
          if (d < Globals.FightEndMaxRange and d > Globals.FightEndMinRange) then
            RobinJohnFightEnd()
          end
        end
      end
    end
  end
  if(Globals.GameState == GameState.WithEnemies) then
    if( not Globals.LancierUnderTrapTriggered) then
      if not (Actors["Lancier_Bleu_13"].active or Actors["Lancier_Bleu_16"].active) then
        Globals.LancierUnderTrapTriggered = true
        Actors["Lancier_Bleu_10"]:AssignPatrol(Patrols["Patrol_20"])
      end
    end
    if(AreAllEnemiesKO()) then
      Globals.GameState = GameState.EnemiesKO
      CompleteObjective(1)
      GetKennyAndLeave()
    end
  end
  if(not Globals.RockPatrolsChanged) then
    if(IsPatchApplied(Patches["Patch_6"])) then
      Actors["Archer_Bleu_19"]:AssignPatrol(Patrols["Patrol_41"])
      Actors["Epee_Bleu_14"]:AssignPatrol(Patrols["Patrol_40"])
      Globals.RockPatrolsChanged = true
    end
  end
end

function GetKennyAndLeave()
  CyrSeq()
    :Start()
  Globals.GameState = GameState.Won
end

function Finalize(unk)
end

function CheckVictoryCondition(secondsPassed)
  if(Globals.GameState == GameState.Won) then
    return 1
  end
  if(IsActorDead(Actors["Hero_2"]) and IsActorDead(Actors["Hero_3"])) then
    return 2
  end
end

function AreAllEnemiesKO()
  for i = 0,(GetNumberOfActorsInEngine() - 1) do
    if not IsOutOfActionIfEnemy(GetActorScript(i)) then
      return false
    end
  end
  return true
end

function IsOutOfActionIfEnemy(a)
  return IsNull(a) or (not a.is_soldier) or (not (a.attitude == 1)) or a.out_of_action or (not a.active)
end

function MatchFriendlyJohnsHpToEnemyJohnsHp()
  local healthRemaining = Actors["LittleJohnEnemy_20"]:GetProperty(PersistentProperty.hp)
  healthRemaining = math.max(healthRemaining, lowestLittleJohnEnemyHp)
  local maxAllyVersionHp = 100
  local health = archerDamage + 1 + (maxAllyVersionHp - archerDamage - 1) * (healthRemaining - lowestLittleJohnEnemyHp) / (maxEnemyLittleJohnHp - lowestLittleJohnEnemyHp)
  Actors["Hero_1"]:SetProperty(PersistentProperty.hp,  health)
end

function RobinJohnFightEnd()
  Globals.FightState = FightState.Ended
  Actors["LittleJohnEnemy_20"].ai_state = AiState.script

  CyrSeq()
    :LockUser()
    :Start()

  CyrSeq()
    :TurnTo(Actors["LittleJohnEnemy_20"], Heroes.Robin.location)
    :Then()
    :Call(function ()
    CyrSeq()
      :TurnTo(Heroes.Robin, Actors["LittleJohnEnemy_20"].location)
      :Then()
      :Wait(14)
      :Then()
      :PlayAnimFreeze(Heroes.Robin, ActorAction.layDown)
      :Start()
  end)
    :Then()
    :PlayAnim(Actors["LittleJohnEnemy_20"], ActorAction.fistPunch)
    :Then()
    :Call(function ()
    LockOnPlace(Actors["LittleJohnEnemy_20"])
  end)
    :Then()
    :Wait(10)
    :Then()
    :Call(function ()
    CyrSeq()
      :Move(Actors["LittleJohnEnemy_20"], GetJohnFightFinalPos(Actors["LittleJohnEnemy_20"]), MovementStyle.walking)
      :Then()
      :TurnTo(Actors["LittleJohnEnemy_20"], Actors["Hero_3"].location)
      :Then()
      :Call(function ()
        Actors["Hero_1"].location = Actors["LittleJohnEnemy_20"].location
        Actors["Hero_1"].direction = Actors["LittleJohnEnemy_20"].direction
        DeactivateInside(Actors["LittleJohnEnemy_20"])
        Actors["LittleJohnEnemy_20"].location = Locations["Node_61"]
    end)
      :Then()
      :Wait(15)
      :Then()
      :Call(function ()
      CyrSeq()
        :SpeakPC(Actors["Hero_3"], 5, 0)
        :Start()
    end)
      :Then()
      :PlayAnim(Actors["Hero_1"], ActorAction.provoking)
      :Then()
      :SpeakPC(Actors["Hero_1"], 2, 0)
      :Then()
      :Wait(5)
      :Then()
      :PlayAnim(Heroes.Robin, ActorAction.standUp)
      :Then()
      :Call(function ()
      CyrSeq()
        :TurnTo(Heroes.Robin, Actors["Hero_1"].location)
        :Then()
        :Call(function ()
        CyrSeq()
          :PlayAnim(Heroes.Robin, ActorAction.fistPunch)
          :Start()
      end)
        :Then()
        :Wait(14)
        :Then()
        :Call(function ()
        MatchFriendlyJohnsHpToEnemyJohnsHp()
        Actors["Hero_1"]:Damage(0, true)
        Actors["Hero_1"]:SetProperty(PersistentProperty.concussion, 75)
      end)
        :Then()
        :Call(function ()
        GetMuch().invisible = false
        Actors["Hero_1"].invisible = false
        Actors["Hero_2"].invisible = false
        Actors["Hero_3"].invisible = false
        Actors["Hero_4"].invisible = false
      end)
        :Then()
      SequenceWakeUpJohn()
        :Start()
    end)
      :Start()
  end)
    :Start()
end

function SequenceWakeUpJohn()
    :Wait(15)
    :Then()
    :WakeUp(Actors["Hero_2"], Actors["Hero_1"], MovementStyle.running, false)
    :Then()
  SequenceJohnTakesRobinIntoHisGang()
end

function SequenceJohnTakesRobinIntoHisGang()
    :Wait(15)
    :Call(function ()
    SimultaneousSequencesInSequence({
      {
        function ()
            :Move(Actors["Hero_2"], Locations["Node_52"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_2"], Locations["Node_56"])
        end,
        function ()
            :Wait(20)
            :Then()
            :TurnTo(Actors["Hero_1"], Heroes.Robin.location)
            :Then()
            :Wait(10)
            :Then()
            :Move(Actors["Hero_1"], Locations["Node_76"], MovementStyle.walking)
            :Then()
            :Move(Actors["Hero_1"], Locations["Node_70"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_1"], Locations["Node_74"])
        end,
        function ()
            :Wait(35)
            :Then()
            :Move(Heroes.Robin, Locations["Node_76"], MovementStyle.walking)
            :Then()
            :Move(Heroes.Robin, Locations["Node_74"], MovementStyle.walking)
            :Then()
            :TurnTo(Heroes.Robin, Locations["Node_70"])
        end,
        function ()
            :Wait(45)
            :Then()
            :Move(GetMuch(), Locations["Node_76"], MovementStyle.walking)
            :Then()
            :Move(GetMuch(), Locations["Node_75"], MovementStyle.walking)
            :Then()
            :CharacterAvailable(GetMuch(), true)
            :Then()
            :Call(function ()
            CompleteObjective(0)
          end)
            :Then()
            :TurnTo(GetMuch(), Locations["Node_70"])
        end,
        function ()
            :Wait(180)
            :Then()
            :Move(Actors["Hero_2"], Locations["Node_71"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_2"], Locations["Node_74"])
        end,
        function ()
            :Wait(197)
            :Then()
            :Move(Actors["Hero_3"], Locations["Node_72"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_3"], Locations["Node_74"])
        end,
        function ()
            :Wait(215)
            :Then()
            :TurnTo(Actors["Hero_1"], Actors["Hero_4"].location)
            :Then()
            :Call(function ()
            CyrSeq()
              :Wait(15)
              :Then()
              :TurnTo(Actors["Hero_1"], Locations["Node_74"])
              :Start()
          end)
            :Then()
            :Move(Actors["Hero_4"], Locations["Node_73"], MovementStyle.running)
            :Then()
            :TurnTo(Actors["Hero_4"], Locations["Node_74"])
        end,
      },{
        function ()
          Actors["Target_16"]:Activate()

            :DisplayPopupText(4)
            :Then()
            :CharacterAvailable(Actors["Hero_1"], true)
            :Then()
            :TurnTo(Actors["Hero_1"], GetMuch(.location))
            :Then()
            :Wait(7)
            :Then()
            :TurnTo(Actors["Hero_1"], Actors["Target_16"].location)
            :Then()
            :Wait(10)
            :Then()
            :Move(Heroes.Robin, Locations["Node_82"], MovementStyle.walking)
            :Then()
            :TurnTo(Heroes.Robin, Actors["Target_16"].location)
            :Then()
            :TurnTo(GetMuch(), Actors["Target_16"].location)
            :Then()
            :Action(GetMuch(), ActorAction.targetHold, Actors["Target_16"].index)
        end
      },{
        function()
            :Wait(5)
            :Call(function ()
            CyrSeq()
              :Action(GetMuch(), ActorAction.shoot, Actors["Target_16"].index)
              :Then()
              :Wait(10)
              :Then()
              :TurnTo(GetMuch(), Actors["Hero_1"].location)
              :Then()
              :TurnTo(Actors["Hero_1"], GetMuch(.location))
              :Then()
              :Wait(5)
              :Then()
              :PlayAnim(Actors["Hero_1"], ActorAction.provoking)
              :Then()
              :TurnTo(GetMuch(), Actors["Target_16"].location)
              :Then()
              :Action(GetMuch(), ActorAction.targetHold, Actors["Target_16"].index)
              :Start()
          end)
        end,
        function ()
            :Call(function ()

            CyrSeq()
              :EnterLevel(Actors["Archer_Bleu_18"], Locations["Node_77"], ActorDirection.northWest, MovementStyle.running)
              :Then()
              :Move(Actors["Archer_Bleu_18"], Locations["Node_55"], MovementStyle.running)
              :Then()
              :Action(Actors["Archer_Bleu_18"], ActorAction.shoot, Actors["Hero_4"].index)
              :Then()
              :Wait(17)
              :Then()
              :Action(Actors["Archer_Bleu_18"], ActorAction.shoot, Actors["Hero_1"].index)
              :Then()
              :Action(Actors["Archer_Bleu_18"], ActorAction.targetHold, GetMuch(.index))
              :Start()
          end)
        end,
        function ()
            :Wait(128)
            :Then()
            :Call(function ()
            CyrSeq()
              :Move(Actors["Hero_1"], Locations["Node_67"], MovementStyle.running)
              :Start()
          end)
        end,
        function ()
            :Wait(115)
            :Then()
            :Move(GetMuch(), Locations["Node_83"], MovementStyle.running)
            :Then()
            :TurnTo(GetMuch(), Locations["Node_55"])
            :Then()
          --   :Action(GetMuch(), ActorAction.targetHold, Actors["Archer_Bleu_18"].index)
          --   :Then()
          --   :Wait(10)
          --   :Then()
            :Action(GetMuch(), ActorAction.shoot, Actors["Archer_Bleu_18"].index)
        end,
        function ()
            :Wait(130)
            :Then()
            :MoveNear(Heroes.Robin, Actors["Hero_4"].location, MovementStyle.running, 20)
            :Then()
            :TurnTo(Heroes.Robin, Actors["Hero_4"].location)
            :Then()
            :Call(function ()
            Heroes.Robin:Crouch()
          end)
        end,
        function ()
            :Wait(145)
            :Then()
            :Move(Actors["Hero_2"], Locations["Node_93"], MovementStyle.running)
            :Then()
            :TurnTo(Actors["Hero_2"], Actors["Hero_4"].location)
            :Then()
            :Wait(10)
            :Then()
            :Call(function ()
            Actors["Hero_2"]:Crouch()
          end)
        end,
        function ()
            :Wait(155)
            :Then()
            :Move(Actors["Hero_3"], Locations["Node_92"], MovementStyle.walking)
            :Then()
            :TurnTo(Actors["Hero_3"], Actors["Hero_4"].location)
        end
      },{
        function ()
            :MoveNear(GetMuch(), Actors["Hero_1"].location, MovementStyle.running, 40)
            :Then()
            :Wait(5)
            :Then()
            :DisplayPopupText(5)
            :Then()
            :DisplayPopupText(6)
        end
      },{
        function ()
            :Move(GetMuch(), Locations["Node_80"], MovementStyle.walking)
            :Then()
            :TurnTo(GetMuch(), Locations["Node_67"])
        end,
        function ()
            :Move(Actors["Hero_1"], Locations["Node_79"], MovementStyle.walking)
            :Then()
            :Call(function ()
            CyrSeq()
              :Move(GetMuch(), Locations["Node_76"], MovementStyle.walking)
              :Start()
          end)
            :Move(Actors["Hero_1"], Locations["Node_52"], MovementStyle.walking)
        end,
      },{
        function ()
            :DisplayPopupText(7)
            :Then()
            :CharacterAvailable(GetMuch(), false)
            :Then()
            :CharacterAvailable(Actors["Hero_1"], false)
            :Then()
            :CharacterAvailable(Actors["Hero_2"], true)
            :Then()
            :CharacterAvailable(Actors["Hero_3"], true)
          --   :Then()
          --   :CharacterAvailable(Actors["Hero_4"], true)
            :Then()
            :DisplayPopupText(8)
            :Then()
            :Call(function ()
            AddObjective(1, true)
            CyrSeq()
              :Move(Actors["Hero_1"], Locations["Node_94"], MovementStyle.walking)
              :Then()
              :Move(Actors["Hero_1"], Locations["Node_95"], MovementStyle.walking)
              :Then()
              :Move(Actors["Hero_1"], Locations["Node_96"], MovementStyle.walking)
              :Then()
              :LeaveLevel(Actors["Hero_1"], Locations["Node_81"], ActorDirection.southWest, MovementStyle.walking)
              :Start()

            CyrSeq()
              :Wait(10)
              :Then()
              :Move(GetMuch(), Locations["Node_94"], MovementStyle.walking)
              :Then()
              :Move(GetMuch(), Locations["Node_95"], MovementStyle.walking)
              :Then()
              :Move(GetMuch(), Locations["Node_96"], MovementStyle.walking)
              :Then()
              :LeaveLevel(GetMuch(), Locations["Node_81"], ActorDirection.southWest, MovementStyle.walking)
              :Start()
          end)
            :Then()
            :Call(PCsToStartPositions)
            :Then()
            :Wait(35)
            :Then()
            :SetZoomLevel(ZoomLevel.close)
            :Then()
            :Call(function ()
            CyrSeq()
              :MoveCameraTo(Locations["Node_88"], 12)
              :Start()
          end)
            :Then()
            :Call(function ()
            Actors["Soldier_21"]:Activate()
            Actors["Soldier_21"].location = Actors["Archer_Bleu_18"].location
            Actors["Soldier_21"].direction = Actors["Archer_Bleu_18"].direction
            Actors["Archer_Bleu_18"]:Deactivate()
          end)
            :Then()
          SequenceSoldiersEnter()
        end
      }
    })
  end)
end

function SequenceSoldiersEnter()
  local chief = Actors["Officier_Bleu_21"]
  local betweenTime = 20
    :Call(function ()
    CyrSeq()
      :EnterLevel(chief, Locations["Node_89"], ActorDirection.west, MovementStyle.walking)
      :Then()
      :Call(function ()
      ShowPersonInside(chief)
    end)
      :Start()
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldiersComeFromEast(Actors["Lancier_Bleu_16"], Actors["Lancier_Bleu_11"], chief)
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldiersComeFromEast(Actors["Lancier_Bleu_13"], Actors["Lancier_Bleu_12"], chief)
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldiersComeFromEast(Actors["Lancier_Bleu_10"], Actors["Lancier_Bleu_22"], chief)
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldiersComeFromEast(Actors["Epee_Bleu_17"], Actors["Epee_Bleu_15"], chief)
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldiersComeFromEast(Actors["Archer_Bleu_20"], Actors["Archer_Bleu_19"], chief)
  end)
    :Then()
    :Wait(betweenTime)
    :Then()
    :Call(function ()
    SoldierComeFromEast(Actors["Epee_Bleu_14"], chief)
  end)
    :Then()
    :Wait(40)
end

function SoldiersComeFromEast(upper, lower, chief)
  SimultaneousSequencesInSequence({
    {
      function ()
          :EnterLevel(upper, Locations["Node_90"], ActorDirection.west, MovementStyle.walking)
      end,
      function ()
          :EnterLevel(lower, Locations["Node_89"], ActorDirection.west, MovementStyle.walking)
      end,
    },{
      function ()
        ShowPersonInside(upper)
        ShowPersonInside(lower)
        chief:AddSquadMember(upper)
        chief:AddSquadMember(lower)
      end
    }
  })
end

function SoldierComeFromEast(soldier, chief)
  CyrSeq()
    :EnterLevel(soldier, Locations["Node_89"], ActorDirection.west, MovementStyle.walking)
    :Then()
    :Call(function ()
    ShowPersonInside(soldier)
    chief:AddSquadMember(soldier)
  end)
    :Start()
end

function PCsToStartPositions()
  CyrSeq()
    :Move(Actors["Hero_2"], Locations["Node_84"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Hero_2"], Locations["Node_14"])
    :Start()
  
  CyrSeq()
    :Wait(3)
    :Then()
    :Move(Heroes.Robin, Locations["Node_85"], MovementStyle.running)
    :Then()
    :TurnTo(Heroes.Robin, Locations["Node_14"])
    :Then()
    :Call(function ()
    Heroes.Robin:Crouch()
  end)
    :Start()
  
  CyrSeq()
    :Wait(10)
    :Then()
    :Move(Actors["Hero_3"], Locations["Node_86"], MovementStyle.running)
    :Then()
    :TurnTo(Actors["Hero_3"], Locations["Node_17"])
    :Then()
    :Call(function ()
    Actors["Hero_3"]:Crouch()
  end)
    :Start()
end

function GetJohnFightFinalPos(johnActor)
  local pos1 = NoWhere()
  local bestDist = 100000
  local pos2 = pos1
  local rob = Heroes.Robin.location
  local logEnd = Locations["Node_54"]
  local robToEnd = rob:DistanceTo(logEnd)
  for _, p in pairs({
    Locations["Node_55"],
    Locations["Node_67"],
    Locations["Node_63"],
    Locations["Node_64"],
    Locations["Node_56"],
    Locations["Node_65"],
    Locations["Node_62"],
    Locations["Node_68"],
    Locations["Node_54"],
  }) do
    local dist = p:DistanceTo(logEnd)
    if (dist < robToEnd) then
      dist = p:DistanceTo(rob)
      if(dist < bestDist) then
        pos2 = pos1
        pos1 = p
        bestDist = dist
      end
    end
  end

  if (bestDist < 7) then
    pos1 = pos2
  end

  local d1 = pos1:DistanceTo(logEnd)
  local johnLoc = johnActor.location
  local d2 = johnLoc:DistanceTo(logEnd)
  if(d1 < d2) then
    return pos1
  else
    return johnLoc
  end
end

function GetFightEscapeZone(returnTo)
 return {
    Enter = function(actor)
      if (Globals.FightState == FightState.Running) then
        if actor == Heroes.Robin then
          Globals.IsReturningRobinIntoFight = true
          CyrSeq()
            :LockUser()
            :Then()
            :Move(actor, Locations[returnTo], MovementStyle.walking)
            :Then()
            :UnlockUser()
            :Then()
            :Call(function ()
              Globals.IsReturningRobinIntoFight = false
            end)
            :Start()
        end
      end
    end,
  }
end

FightEscapeZoneWest = GetFightEscapeZone("Node_68")
FightEscapeZoneEast = GetFightEscapeZone("Node_67")



Tree_men_target_1 = TreeMerrymenTarget("Bow_Target_6",
  {
    {
      man = "Mmen_Baton_3",
      rope = "TARGET_PaysanDbaton_08_5",
      location = "Node_3",
    },
    {
      man = "Mmen_Baton_2",
      rope = "TARGET_PaysanDbaton_08_4",
      location = "Node_2",
    },
    {
      man = "Mmen_Baton_1",
      rope = "TARGET_PaysanDbaton_08_3",
      location = "Node_1",
    },
  }
)

Hidden_archers_target_1 = HiddenArchersTarget(
  "Bow_Target_8",
  20,
  2,
  {
    {
      man = "Mmen_Arc_7",
      location = "Node_7",
    },
    {
      man = "Mmen_Arc_8",
      location = "Node_8",
    },
    {
      man = "Mmen_Arc_9",
      location = "Node_9",
    },
  }

)

GroundTrap1Predicate = GroundTrapZone("Node_44", "Node_41", 14)
Ground_trap_zone_1 = {
  Initialize = function()
    Globals.GroundTrapActive = false
  end,

  Activate = function ()
    Globals.GroundTrapActive = true
    GroundTrap1Predicate.Initialize()
  end,

  Enter = function(actor)
    if(Globals.GroundTrapActive) then
      GroundTrap1Predicate.Enter(actor)
    end
  end
}

local eject_trap_pair_1 = EjectSwingTrapTargetAndZone(
  "Node_43",
  "Bow_Target_2",
  "Croisement03_-_piege02h_1",
  9,
  10,
  11
)

Eject_trap_zone_1 = eject_trap_pair_1.Zone
Eject_trap_target_1 = eject_trap_pair_1.Target

Falling_rock_target_1 = FallingRockTarget(
  "Croisement03_-_rocher01_b1_9",
  "Croisement03_-_rocher01_b1_14",
  "Node_40",
  "Node_42",
  5,
  6,
  21,
  {"Node_100", "Node_101"}
)

Merry_under_leaves_A = PcUnderLeavesActor(15)
Merry_under_leaves_B = PcUnderLeavesActor(16)
Merry_under_leaves_C = PcUnderLeavesActor(17)

LittleJohnEnemy_Test = {
  ActionChange = function(action, oldAction)
    --print(oldAction .. " -> " .. action .. " (with AIState " .. GetAIState(ThisActor()) .. ")")
  end,
}

LittleJohnHero_Actor = {
  ActionChange = function(action, oldAction)
    if(oldAction == ActorAction.hitArrow) then
      ThisActor():Stop()
      ThisActor():Crouch()
    end
  end,
}

TargetMuchShowSkill = {
  ActivatedByArrow = function(actorSource)
    CyrSeq()
      :PlayAnimFreeze(Actors["Target_16"], ActorAction.target_1)
      :Start()
  end,
}

OfficerReachLogs = {
  ReachPoint = function(actor)
    actor:AssignPatrol(God())

    CyrSeq()
      :Wait(10)
      :Then()
      :TurnTo(actor, Locations["Node_35"])
      :Then()
      :Wait(10)
      :Then()
      :PlayAnim(actor, ActorAction.pointing)
      :Then()
      :TurnTo(actor, Locations["Node_29"])
      :Then()
      :Call(function ()
        CyrSeq()
          :Speak(actor, 42)
          :Start()
      end)
      :Then()
      :PlayAnim(actor, ActorAction.pointing)
      :Then()
      :Call(StartRemovingLogs)
      :Then()
      :Call(CreateSearchPatrol)
      :Then()
      :Wait(10)
      :Then()
      :TurnTo(actor, Locations["Node_35"])
      :Then()
      :Wait(35)
      :Then()
      :TurnTo(actor, Locations["Node_98"])
      :Then()
      :Call(function ()
        CyrSeq()
          :Wait(3)
          :Then()
          :Speak(actor, 68)
          :Start()
      end)
      :Then()
      :PlayAnim(actor, ActorAction.pointing)
      :Then()
      :Wait(5)
      :Then()
      :ClearCameraLock()
      :Then()
      :MoveCameraTo(Actors["Epee_Bleu_14"].location, 10)
      :Then()
      :LockCameraOn(Actors["Epee_Bleu_14"])
      :Then()
      :Wait(5)
      :Then()
      :Call(function ()
      Actors["Epee_Bleu_14"]:AssignPatrol(Patrols["Patrol_4"])
    end)
      :Start()
  end
}

function StartRemovingLogs()
  for _, p in pairs({
    {actor = Actors["Lancier_Bleu_16"], patrol = Patrols["Patrol_5"]},
    {actor = Actors["Lancier_Bleu_11"], patrol = Patrols["Patrol_6"]},
    {actor = Actors["Lancier_Bleu_13"], patrol = Patrols["Patrol_9"]},
    {actor = Actors["Lancier_Bleu_12"], patrol = Patrols["Patrol_7"]},
    {actor = Actors["Lancier_Bleu_10"], patrol = Patrols["Patrol_10"]},
    {actor = Actors["Lancier_Bleu_22"], patrol = Patrols["Patrol_8"]},
    {actor = Actors["Epee_Bleu_17"], patrol = Patrols["Patrol_12"]},
    {actor = Actors["Epee_Bleu_15"], patrol = Patrols["Patrol_13"]},
    {actor = Actors["Archer_Bleu_20"], patrol = Patrols["Patrol_15"]},
  }) do
    p.actor:SetPatrolStyle(MovementStyle.running)
    p.actor:AssignPatrol(p.patrol)
  end
  Actors["Officier_Bleu_21"]:RemoveAllSquadMembers()
end

function CreateSearchPatrol()
  local chief = Actors["Epee_Bleu_14"]
  chief:SetPatrolStyle(MovementStyle.running)
  chief:AssignPatrol(Patrols["Patrol_14"])
  chief:AddSquadMember(Actors["Archer_Bleu_19"])
end

LockCameraOnOfficerArea = {
  Enter = function (actor)
    if(actor == Actors["Officier_Bleu_21"]) then
      if (not Globals.CameraAlreadyLockedOnOfficer) then
        Globals.CameraAlreadyLockedOnOfficer = true
        CyrSeq()
          :LockCameraOn(actor)
          :Start()
      end
    end
  end
}

RemoveLogsWaypoint = {
  ReachPoint = function(actor)
    Actors["Target_7"]:Deactivate()
    local chief = Actors["Officier_Bleu_21"]
    local actors = {
      {
        Actors["Lancier_Bleu_10"],
        Actors["Lancier_Bleu_11"],
        Actors["Lancier_Bleu_12"],
        Actors["Lancier_Bleu_13"],
        Actors["Lancier_Bleu_16"],
        Actors["Lancier_Bleu_22"],
      },
      {
        Actors["Epee_Bleu_15"],
        Actors["Epee_Bleu_17"],
      },{
        Actors["Archer_Bleu_20"],
      }
    }
    local turnTo = Locations["Node_99"]

    CyrSeq()
    for _, group in ipairs(actors) do
        :Call(function ()
          for _, a in ipairs(group) do
            a:SetPatrolStyle(MovementStyle.walking)
            a:AssignPatrol(God())
          end
        end)
        :Then()
        :Wait(12)
        :Then()
        :Call(function ()
          for _, a in ipairs(group) do
            chief:AddSquadMember(a)
            CyrSeq()
              :TurnTo(a, turnTo)
              :Start()
          end
        end)
        :Then()
        :Wait(12)
        :Then()
    end
      :Call(function ()
        chief:AssignPatrol(Patrols["Patrol_16"])
      end)
      :Start()
  end
}

EndSearchWaypoint = {
  ReachPoint = function(actor)
    actor:AssignPatrol(God())
    CyrSeq()
      :TurnTo(actor, Actors["Officier_Bleu_21"].location)
      :Start()

    CyrSeq()
      :ClearCameraLock()
      :Then()
      :Speak(actor, 15)
      :Then()
      :Wait(15)
      :Then()
      :TurnTo(Actors["Officier_Bleu_21"], Locations["Node_35"])
      :Then()
      :Wait(10)
      :Then()
      :TurnTo(Actors["Officier_Bleu_21"], Heroes.Robin.location)
      :Then()
      :Call(function ()
      CyrSeq()
        :Wait(3)
        :Then()
        :Speak(Actors["Officier_Bleu_21"], 68)
        :Start()
    end)
      :Then()
      :PlayAnim(Actors["Officier_Bleu_21"], ActorAction.pointing)
      :Then()
      :SetZoomLevel(ZoomLevel.default)
      :Then()
      :Wait(10)
      :Then()
      :Call(function ()
      actor:RemoveAllSquadMembers()
    end)
      :Then()
      :Call(EnemiesToFinalPatrols)
      :Then()
      :Wait(30)
      :Then()
      :MoveCameraTo(Heroes.Robin.location, 4)
      :Then()
      :UnlockUser()
      :Then()
      :Call(function ()
      SelectActorPC(Heroes.Robin, true)
      Globals.GameState = GameState.WithEnemies
    end)
      :Start()
  end
}

function EnemiesToFinalPatrols()
  local toSet = {
    { actor = Actors["Lancier_Bleu_10"], patrol = Patrols["Patrol_19"], attentive = true },
    { actor = Actors["Lancier_Bleu_11"], patrol = Patrols["Patrol_25"], attentive = true },
    { actor = Actors["Lancier_Bleu_12"], patrol = Patrols["Patrol_23"], attentive = true },
    { actor = Actors["Lancier_Bleu_13"], patrol = Patrols["Patrol_21"], attentive = true },
    { actor = Actors["Lancier_Bleu_16"], patrol = Patrols["Patrol_22"], attentive = true },
    { actor = Actors["Lancier_Bleu_22"], patrol = Patrols["Patrol_29"], attentive = true },
    { actor = Actors["Epee_Bleu_14"], patrol = Patrols["Patrol_17"], attentive = false },
    { actor = Actors["Epee_Bleu_15"], patrol = Patrols["Patrol_27"], attentive = true },
    { actor = Actors["Epee_Bleu_17"], patrol = Patrols["Patrol_26"], attentive = true },
    { actor = Actors["Archer_Bleu_19"], patrol = Patrols["Patrol_18"], attentive = true },
    { actor = Actors["Archer_Bleu_20"], patrol = Patrols["Patrol_24"], attentive = true },
    { actor = Actors["Officier_Bleu_21"], patrol = Patrols["Patrol_28"], attentive = false },
  }
  for _, p in ipairs(toSet) do
    local all = Rand(13) + 3
    local untilAttentive = Rand(all - 2) + 1
    CyrSeq()
    if(p.attentive) then
        :Wait(untilAttentive)
        :Then()
        :Call(function ()
        p.actor:SetAlwaysAttentive(true)
        p.actor:SetPatrolStyle(MovementStyle.running)
      end)
        :Then()
        :Wait(all - untilAttentive)
    else
        :Wait(all)
    end
      :Then()
      :Call(function ()
      p.actor:AssignPatrol(p.patrol)
    end)
      :Start()
  end

  CyrSeq()
    :Wait(210)
    :Then()
    :Call(function ()
    Actors["Archer_Bleu_19"]:SetAlwaysAttentive(false)
    Actors["Archer_Bleu_19"]:SetPatrolStyle(MovementStyle.walking)
  end)
    :Start()

  Actors["Officier_Bleu_21"]:RemoveAllSquadMembers()
end

SawDeadArcherWaypoint = {
  ReachPoint = function(actor)
    actor:SetEmoticon(ActorEmoticon.alert, 150)
    CyrSeq()
      :Speak(actor, 2)
      :Start()
  end
}

NoLongerEmotingArcherWaypoint = {
  ReachPoint = function(actor)
    actor:SetEmoticon(ActorEmoticon.none, 10)
  end
}

SeeDeadKennyWaypoint = {
  ReachPoint = function(actor)
    actor:SetEmoticon(ActorEmoticon.wondering, 150)
    CyrSeq()
      :Speak(actor, 0)
      :Start()
  end
}

NoLongerEmotingKennyWaypoint = {
  ReachPoint = function(actor)
    actor:SetEmoticon(ActorEmoticon.none, 10)
    CyrSeq()
      :Speak(actor, 44)
      :Start()
  end
}

function ActorActivator(actor)
  return function()
    actor:Activate()
  end
end

function PatchReseter(patch)
  return function()
    ResetPatch(patch)
  end
end

function PatchAnimActivator(patch)
  return function()
    patch:SetAnimationActive(true)
  end
end

ThereAreTrapsScroll = {
  Taken = function (actorSource)
    local traps = {
      {
        funcs = {
          PatchAnimActivator(Patches["Patch_21"]),
          ActorActivator(Actors["Croisement03_-_rocher01_b1_9"]),
          ActorActivator(Actors["Croisement03_-_rocher01_b1_14"]),
        },
        position = Locations["Node_18"]
      },
      {
        funcs = {
          ActorActivator(Actors["Bow_Target_6"]),
          ActorActivator(Actors["TARGET_PaysanDbaton_08_3"]),
          ActorActivator(Actors["TARGET_PaysanDbaton_08_4"]),
          ActorActivator(Actors["TARGET_PaysanDbaton_08_5"]),
        },
        position = Locations["Node_38"]
      },
      {
        funcs = {
          ActorActivator(Actors["Bow_Target_8"]),
          PatchReseter(Patches["Patch_2"]),
          PatchAnimActivator(Patches["Patch_20"]),
        },
        position = Locations["Node_7"]
      },
      {
        funcs = {
          ActorActivator(Actors["Bow_Target_2"]),
          ActorActivator(Actors["Croisement03_-_piege02h_1"]),
        },
        position = Locations["Node_37"]
      },
      {
        funcs = {
          PatchAnimActivator(Patches["Patch_14"]),
          Ground_trap_zone_1.Activate
        },
        position = Locations["Node_41"]
      },
    }
    CyrSeq()
      :BeginCutscene()
      :Then()
      :DisplayPopupText(1)
      :Then()
    for _, o in ipairs(traps) do
        :ScrollCameraTo(o.position)
        :Then()
        :Wait(10)
        :Then()
        :Call(function ()
        for _, f in ipairs(o.funcs) do
          f()
        end
      end)
        :Then()
        :Wait(20)
    end
      :Then()
      :ScrollCameraTo(actorSource.location)
      :Then()
      :Call(function ()
      Activate(Items["Arrows_1"])
    end)
        :Then()
        :Wait(10)
      :Then()
      :FinalizeCutscene()
      :Then()
      :Call(function ()
      SelectActorPC(actorSource, true)
    end)
      :Start()
    return 1
  end
}
