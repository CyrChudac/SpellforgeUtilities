-- Decompiled by SpellForge from H01_Lin_VL.scb: 47 classes, 198 functions.
-- A class's variables keep their names (m.name, kept in Globals so savegames keep
-- them); the names of locals are not in the compiled file (var1, ..., t1, ...). The
-- game's functions are written the way RhMod offers them (methods and properties of
-- the objects: actor:Stop(), actor.ai_state); events are named like RhMod calls them.
-- The script classes are named without the number the original editor added to them
-- (Acher01_80000040 is Acher01 here and in the mission).
-- Character, item, scroll, script node, patrol, door, patch, sound, building and
-- mobile element numbers are shown as the names they have in Homecomming.rhm and its
-- location (Actors.Name, Locations.Name, ...).
-- 138 event function(s) that do nothing are left out:
-- without them RhMod gives the game the same result.

Globals = {
  global = {},  -- the game's InitGlobal / SetGlobal / GetGlobal numbers
  StartUp = {},
  Cible1 = {},
  Cible2 = {},
  Cible3 = {},
  Cible4 = {},
  mecanisme_pont_levis = {},
  TutGetObject = {},
  EdwardZone = {},
}

-- The mission's elements by the numbers the game gives them (the script counts with them),
-- read from the mission the first time the script asks: elements added to or removed
-- from the mission since the script was compiled change the others' numbers.
local ElementByNumberList
local function ElementByNumber(number)
  if ElementByNumberList == nil then
    ElementByNumberList = {}
    for _, objects in ipairs({Animations, Actors, Items, Scrolls, MobileElements}) do
      for _, object in pairs(objects) do
        if object.index >= 0 then
          ElementByNumberList[object.index] = object
        end
      end
    end
  end
  local object = ElementByNumberList[number]
  if object == nil and number ~= nil then
    -- the heroes the player brought stand on the placeholders without a name
    for i = 0, GetNumberOfPcs() - 1 do
      local found = GetPc(i)
      if found ~= nil and found.index == number then
        return found
      end
    end
  end
  return object
end

-- The mission's events (the game's StartUp class) ---------------------------------

function Initialize(seed)
  local m = Globals.StartUp
  SetCustomCampaignValue(6, 0)
  SetCustomCampaignValue(7, 0)
  SetCustomCampaignValue(8, 0)
  SetCustomCampaignValue(9, 0)
  SetCustomCampaignValue(3, 0)
  Animations.Animation_26:Deactivate()
  Animations.Animation_27:Deactivate()
  Animations.Animation_28:Deactivate()
  Animations.Animation_29:Deactivate()
  Animations.Animation_30:Deactivate()
  Animations.Animation_31:Deactivate()
  Animations.Animation_32:Deactivate()
  Animations.Animation_19:Deactivate()
  Animations.Animation_20:Deactivate()
  Animations.Animation_21:Deactivate()
  Animations.Animation_22:Deactivate()
  Animations.Animation_23:Deactivate()
  Animations.Animation_24:Deactivate()
  Animations.Animation_25:Deactivate()
  Doors.Door_8:SetClickable(false)
  m.iLastTimeShoot = 0
  m.bDontRunTwice = 0
  m.bWormanDone = 0
  m.bHaldricDone = 0
  m.bImGoingAway = 0
  m.iSoldat = 0
  m.iMax = 0
  m.MonActeur = God()
  Actors.Lincoln_Mecanisme_target_50:Deactivate()
  Globals.global[1] = 0
  Globals.global[2] = 0
  Globals.global[3] = 0
  Doors.Door_20.locked_for_pcs = true
  Doors.Door_28.locked_for_pcs = true
  Doors.Door_20:SetClickable(false)
  Doors.Door_21:SetClickable(false)
  Doors.Door_37:SetClickable(false)
  Doors.Door_25:SetClickable(false)
  Doors.Door_23:SetClickable(false)
  Actors.Homme_A_1:Deactivate()
  Actors.Homme_A_1:LockAi(false)
  Actors.Homme_A_1:SetCustomValue(1, 1)
  Actors.Arbaletrier_30:Deactivate()
  Actors.Arbaletrier_30:LockAi(false)
  Actors.Arbaletrier_30:SetCustomValue(1, 1)
  Actors.Homme_D_4:Deactivate()
  Actors.Homme_D_4:LockAi(false)
  Actors.Homme_D_4:SetCustomValue(1, 1)
  Actors.Soldat_A_43:Deactivate()
  Actors.Soldat_A_43:LockAi(false)
  Actors.Soldat_A_43:SetCustomValue(1, 1)
  Actors.Homme_C_3:LockAi(false)
  Actors.Homme_C_3:SetCustomValue(1, 1)
  Items.Purse_7:Deactivate()
  Items.Ransom_9:Deactivate()
  Items.Amulet_11:Deactivate()
  Items.Arrow_3:Deactivate()
  Items.Ransom_6:Deactivate()
  Items.Purse_5:Deactivate()
  Items.Purse_10:Deactivate()
  Items.Arrow_3:Deactivate()
  if GetActorForPlaceholder(0) ~= nil then GetActorForPlaceholder(0):SetProperty(PersistentProperty.arrows, 0) end  -- the hero on placeholder 1
  if GetActorForPlaceholder(0) ~= nil then GetActorForPlaceholder(0):SetProperty(PersistentProperty.purses, 0) end  -- the hero on placeholder 1
end

function PostInitialize()
  AddObjective(0, true)
  Sequence()
    :DisplayPopupText(0)
    :Then()
    :DisplayPopupText(1)
    :Then()
    :DisplayPopupText(2)
    :Then()
    :JumpCameraTo(Heroes.Robin.location)
    :Start()
end

-- the game's Hourglass
function Timer(seconds)
  local m = Globals.StartUp

  if seconds - m.iLastTimeShoot > 15 and Globals.global[1] == 0 then
    SendMessage(Actors.Archer_21, 1)
    m.iLastTimeShoot = seconds
  end

  if Actors.Soldat_A_38.out_of_action and m.bDontRunTwice == 0 then
    m.bDontRunTwice = 1
    Actors.Soldat_A_38:AssignPatrol(Patrols.Patrol_66)
    Actors.Femme_C_2:AssignPatrol(Patrols.Patrol_59)
    Actors.Femme_C_2:SetPatrolStyle(MovementStyle.running)
  end

  if Globals.global[3] == 0 and Actors.Soldat_A_32.out_of_action and Actors.Soldat_A_33.out_of_action and Actors.Garde_B_34.out_of_action and Actors.Garde_B_35.out_of_action then
    SendMessage(Actors.Homme_C_3, 1)
  end

  if m.bWormanDone == 0 and Items.Ransom_6.picked_up then
    m.bWormanDone = 1
    CompleteObjective(3)

    if Scrolls.Scroll_10.state < ScrollState.taken then
      Scrolls.Scroll_10.state = Scrolls.Scroll_10.state + 2
    end
  end

  if m.bHaldricDone == 0 and Actors.Soldat_B_29:GetProperty(PersistentProperty.money) == 0 then
    m.bHaldricDone = 1
    CompleteObjective(4)

    if Scrolls.Scroll_11.state < ScrollState.taken then
      Scrolls.Scroll_11.state = Scrolls.Scroll_11.state + 2
    end
  end

  if m.bImGoingAway == 0 and (Actors.Garde_B_26.out_of_action or Actors.Garde_B_27.out_of_action or Actors.Garde_B_28.out_of_action) then
    m.bImGoingAway = 1
    Actors.Femme_C_7:AssignPatrol(Patrols.Patrol_58)
  end
end

function CheckVictoryCondition(seconds)
  if Globals.global[2] == 1 then
    ChooseVictoryDefeatText(0)
  end
  return Globals.global[2]
end

function ProcessMessage(message, argument, extended)
  local m = Globals.StartUp

  if message == 1 and Globals.global[1] == 0 then
    CompleteObjective(5)
    Globals.global[1] = 1

    if Scrolls.Scroll_1.state ~= ScrollState.taken then
      Scrolls.Scroll_1.state = ScrollState.opened
    end
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_19)
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_20)
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_21)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_23)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_24)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_25)
    Actors.Garde_B_27:AssignPatrol(Patrols.Patrol_52)
    Actors.Garde_B_26:AssignPatrol(Patrols.Patrol_51)
    Actors.Garde_B_28:AssignPatrol(Patrols.Patrol_53)
    Actors.Garde_A_13:AssignPatrol(Patrols.Patrol_3)

    if not Actors.OfficierB_22.out_of_action then
      DisplayPopupText(6)
      Actors.OfficierB_22:AssignPatrol(Patrols.Patrol_39)
    else
      Actors.Archer_19:AssignPatrol(Patrols.Patrol_72)
      Actors.Archer_20:AssignPatrol(Patrols.Patrol_71)
      Actors.Archer_21:AssignPatrol(Patrols.Patrol_70)
      Actors.Soldat_A_23:AssignPatrol(Patrols.Patrol_69)
      Actors.Soldat_A_24:AssignPatrol(Patrols.Patrol_67)
      Actors.Soldat_A_25:AssignPatrol(Patrols.Patrol_68)
      Actors.Garde_A_13:AssignPatrol(Patrols.Patrol_3)
    end
  end

  if message == 2 then
    Globals.global[1] = 1
    Scrolls.Scroll_1.state = ScrollState.opened
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_19)
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_20)
    Actors.OfficierB_22:AddSquadMember(Actors.Archer_21)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_23)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_24)
    Actors.OfficierB_22:AddSquadMember(Actors.Soldat_A_25)
    Actors.Garde_B_27:AssignPatrol(Patrols.Patrol_52)
    Actors.Garde_B_26:AssignPatrol(Patrols.Patrol_51)
    Actors.Garde_B_28:AssignPatrol(Patrols.Patrol_53)
    Actors.Garde_A_13:AssignPatrol(Patrols.Patrol_3)
  end

  if message == 3 and not Patches.Patch_1.applied then
    Patches.Patch_1:Apply()
    Animations.Animation_32:Activate()
    Items.Ransom_6:Activate()
    Items.Purse_5:Activate()
    Doors.Door_20:SetClickable(true)
    Actors.Arbaletrier_30:Activate()
    Actors.Arbaletrier_30:UnlockAi()
    Actors.Arbaletrier_30:SetCustomValue(1, 0)
    Actors.Homme_A_1:Activate()
    Actors.Homme_A_1:UnlockAi()
    Actors.Homme_A_1:SetCustomValue(1, 0)
    Actors.Homme_A_1:AssignPatrol(Patrols.Patrol_25)
  end

  if message == 5 then
    Doors.Door_0:SetClickable(false)

    if not Patches.Patch_10.applied then
      Patches.Patch_10:Apply()
      Animations.Animation_24:Activate()
      Animations.Animation_25:Activate()
    end

    if not Patches.Patch_11.applied then
      Patches.Patch_11:Apply()
      Animations.Animation_26:Activate()
      Animations.Animation_27:Activate()
      Animations.Animation_28:Activate()
      Animations.Animation_29:Activate()
      Animations.Animation_30:Activate()
      Animations.Animation_31:Activate()
      Animations.Animation_19:Activate()
      Animations.Animation_20:Activate()
      Actors.Homme_D_4:Activate()
      Actors.Homme_D_4:AttachScroll(Scrolls.Scroll_3)
    end
    Actors.Homme_D_4:Reveal()
    Actors.Homme_D_4:SetCustomValue(1, 0)
    Actors.Homme_D_4:UnlockAi()
  end

  if message == 6 and not Patches.Patch_8.applied then
    Patches.Patch_8:Apply()
    Doors.Door_25:SetClickable(true)
    Doors.Door_4:SetClickable(false)
    Doors.Door_5:SetClickable(false)
    Actors.Soldat_A_43:Activate()
    Actors.Soldat_A_43:UnlockAi()
    Actors.Soldat_A_43:SetCustomValue(1, 0)
    Actors.Soldat_A_43:AssignPatrol(Patrols.Patrol_54)
  end

  if message == 7 and not Patches.Patch_7.applied then
    Patches.Patch_7:Apply()
    Doors.Door_23:SetClickable(true)
    Doors.Door_22:SetClickable(false)
    Items.Purse_10:Activate()

    if Scrolls.Scroll_13.state == ScrollState.visible then
      Scrolls.Scroll_13.state = ScrollState.opened
    elseif Scrolls.Scroll_13.state == ScrollState.invisible then
      Scrolls.Scroll_13.state = ScrollState.taken
    end
  end

  if message == 8 then
    if ElementByNumber(argument) ~= nil then ElementByNumber(argument):AssignPatrol(Patrols.Patrol_49) end
  end

  if message == 9 then
    if ElementByNumber(argument) ~= nil then ElementByNumber(argument):AssignPatrol(Patrols.Patrol_49) end
    if ElementByNumber(argument) ~= nil then ElementByNumber(argument):SetCustomValue(1, 1) end
    Sequence()
      :LockAi(ElementByNumber(argument))
      :Then()
      :MoveIntoBuilding(ElementByNumber(argument), Locations.Point_1, MovementStyle.walking)
      :Start()
  end

  if message == 10 then
    Actors.Homme_C_3:AttachScroll(Scrolls.Scroll_15)
  end

  if message == 11 then
    m.iLastTimeShoot = m.iLastTimeShoot - 15
  end

  if message == 12 then
    Actors.Homme_B_5:AssignPost(Locations.Point_10, ActorDirection.south)
    Actors.Homme_B_5:AttachScroll(Scrolls.Scroll_4)
  end

  if message == 13 then
    m.iMax = GetNumberOfActorsInEngine()
    m.iSoldat = 0

    while m.iSoldat < m.iMax do
      m.MonActeur = ElementByNumber(m.iSoldat)

      if m.MonActeur ~= nil and m.MonActeur.is_npc then
        if argument == 1 then
          m.MonActeur:LockAi(true)
        elseif m.MonActeur:GetCustomValue(1) ~= 1 then
          m.MonActeur:UnlockAi()
        end
      end
      m.iSoldat = m.iSoldat + 1
    end
  end

  if message == 14 then
    Sequence()
      :SetZoomLevel(1.0)
      :Then()
      :LockUser()
      :SendMessageWithArguments(God(), 13, 1, 0)
      :Then()
      :DisplayPopupText(8)
      :DisplayPopupText(9)
      :DisplayPopupText(10)
      :Then()
      :ScrollCameraTo(Locations.Point_10)
      :Then()
      :Move(Actors.Homme_B_5, Locations.Point_10, MovementStyle.walking)
      :Then()
      :SendMessage(God(), 12)
      :Then()
      :Wait(1.6)
      :Then()
      :JumpCameraTo(Heroes.Robin.location)
      :SendMessageWithArguments(God(), 13, 0, 0)
      :UnlockUser()
      :Start()
  end

  if message == 15 then
    Locations.Point_15:MakeNoise(NoiseType.drawbridge)
  end
end

-- character class PoorWeepingOne: civilian "Homme_C_3"
PoorWeepingOne = {}

function PoorWeepingOne.ProcessMessage(message, argument, extended)
  if message == 1 then
    Actors.Soldat_A_32:AssignPatrol(Patrols.Patrol_26)
    Actors.Soldat_A_33:AssignPatrol(Patrols.Patrol_27)
    Actors.Garde_B_34:AssignPatrol(Patrols.Patrol_28)
    Actors.Garde_B_35:AssignPatrol(Patrols.Patrol_29)
    Globals.global[3] = 1
    Actors.Homme_A_1:SetCustomValue(1, 0)
    Sequence()
      :Move(Actors.Homme_C_3, Locations.Point_8, MovementStyle.running)
      :Then()
      :TurnTo(Actors.Homme_C_3, Locations.Point_9)
      :Then()
      :SendMessage(God(), 10)
      :Start()
  end
end

-- character class Acher03: soldier "Archer_19"
Acher03 = {}

function Acher03.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class Acher02: soldier "Archer_20"
Acher02 = {}

function Acher02.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class Acher01: soldier "Archer_21"
Acher01 = {}

function Acher01.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

function Acher01.ProcessMessage(message, argument, extended)
  local sequence

  if message == 1 and Globals.global[1] == 0 then
    sequence = Sequence()
    sequence:SendMessage(Actors.OfficierB_22, 1)
    sequence:Then()
    sequence:Wait(0.48)
    sequence:Then()

    if Globals.global[1] == 0 then
      sequence:Action(Actors.Archer_21, ScriptCommand.shoot, Actors.Cible01_47.index)
    end
    sequence:PlayAnimFreeze(Actors.Cible01_47, ActorAction.waiting_bored)
    sequence:Wait(0.48)
    sequence:Then()
    sequence:SendMessage(Actors.OfficierB_22, 2)
    sequence:Start()
  end
end

-- character class SergentArchers: soldier "OfficierB_22"
SergentArchers = {}

function SergentArchers.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

function SergentArchers.ProcessMessage(message, argument, extended)
  if message == 1 and Globals.global[1] == 0 then
    Sequence()
      :TurnTo(Actors.OfficierB_22, Locations.Point_2)
      :Start()
  end

  if message == 2 and Globals.global[1] == 0 then
    Actors.Archer_21:SetProperty(PersistentProperty.arrows, Actors.Archer_21:GetProperty(PersistentProperty.arrows) + 1)
    Sequence()
      :TurnTo(Actors.OfficierB_22, Actors.Archer_21.location)
      :Then()
      :PlayAnim(Actors.OfficierB_22, ActorAction.gathering_soldiers)
      :Start()
  end
end

-- character class SoldatCibles01: soldier "Soldat_A_23"
SoldatCibles01 = {}

function SoldatCibles01.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class SoldatCibles02: soldier "Soldat_A_24"
SoldatCibles02 = {}

function SoldatCibles02.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class SoldatCibles03: soldier "Soldat_A_25"
SoldatCibles03 = {}

function SoldatCibles03.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class LancierEscalierHcour01: soldier "Garde_B_26"
LancierEscalierHcour01 = {}

function LancierEscalierHcour01.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class LancierHCour02: soldier "Garde_B_27"
LancierHCour02 = {}

function LancierHCour02.ActionChange(action, oldAction)
  if oldAction == 141 then
    SendMessage(God(), 2)
  end
end

-- character class BouclierXT01: soldier "Soldat_A_38"
BouclierXT01 = {}

function BouclierXT01.ActionChange(action, oldAction)
  if oldAction == 141 then
    Actors.Soldat_A_38:AssignPatrol(Patrols.Patrol_66)
    Actors.Femme_C_2:AssignPatrol(Patrols.Patrol_59)
  end
end

-- target class Cible1: target "Cible00_46"
Cible1 = {}

function Cible1.Initialize()
  local m = Globals.Cible1
  m.bWasHit = 0
end

function Cible1.ActivatedByArrow(actorSource)
  local m = Globals.Cible1

  if m.bWasHit == 0 and actorSource.is_hero then
    m.bWasHit = 1
    Sequence()
      :PlayAnimFreeze(Actors.Cible00_46, ActorAction.target_1)
      :Then()
      :Wait(0.4)
      :Then()
      :SendMessage(God(), 1)
      :Start()
  end
end

-- target class Cible2: target "Cible01_47"
Cible2 = {}

function Cible2.Initialize()
  local m = Globals.Cible2
  m.bWasHit = 0
end

function Cible2.ActivatedByArrow(actorSource)
  local m = Globals.Cible2

  if m.bWasHit == 0 and actorSource.is_hero then
    m.bWasHit = 1
    Sequence()
      :PlayAnimFreeze(Actors.Cible01_47, ActorAction.target_1)
      :Then()
      :Wait(0.4)
      :Then()
      :SendMessage(God(), 1)
      :Start()
  end
end

-- target class Cible3: target "Cible02_48"
Cible3 = {}

function Cible3.Initialize()
  local m = Globals.Cible3
  m.bWasHit = 0
end

function Cible3.ActivatedByArrow(actorSource)
  local m = Globals.Cible3

  if m.bWasHit == 0 and actorSource.is_hero then
    m.bWasHit = 1
    Sequence()
      :PlayAnimFreeze(Actors.Cible02_48, ActorAction.target_1)
      :Then()
      :Wait(0.4)
      :Then()
      :SendMessage(God(), 1)
      :Start()
  end
end

-- target class Cible4: target "Cible03_49"
Cible4 = {}

function Cible4.Initialize()
  local m = Globals.Cible4
  m.bWasHit = 0
end

function Cible4.ActivatedByArrow(actorSource)
  local m = Globals.Cible4

  if m.bWasHit == 0 and actorSource.is_hero then
    m.bWasHit = 1
    Sequence()
      :PlayAnimFreeze(Actors.Cible03_49, ActorAction.target_1)
      :Then()
      :Wait(0.4)
      :Then()
      :SendMessage(God(), 1)
      :Start()
  end
end

-- target class mecanisme_pont_levis: target "Lincoln_Mecanisme_target_50"
mecanisme_pont_levis = {}

function mecanisme_pont_levis.Initialize()
  local m = Globals.mecanisme_pont_levis
  m.deja_fait = 0
end

function mecanisme_pont_levis.ActivatedBySword(actorSource)
  local m = Globals.mecanisme_pont_levis

  if m.deja_fait == 0 then
    m.deja_fait = 1
    Sequence()
      :PlayAnimFreeze(Actors.Lincoln_Mecanisme_target_50, ActorAction.getting_up_from_sitting)
      :Then()
      :SendMessage(God(), 15)
      :Start()
    Patches.Patch_4:Apply()
    Patches.Patch_3:Apply()
  end
end

-- waypoint class OfficierdesArchers__6: waypoint 7 of patrol "Patrol_39"
OfficierdesArchers__6 = {}

function OfficierdesArchers__6.ReachPoint(actor)
  Sequence()
    :SendMessageWithArguments(God(), 9, Actors.OfficierB_22.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Archer_19.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Archer_20.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Soldat_A_23.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Soldat_A_24.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Archer_21.index, 0)
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 9, Actors.Soldat_A_25.index, 0)
    :Start()
end

-- waypoint class GirlWay01__1: waypoint 2 of patrol "Patrol_62"
GirlWay01__1 = {}

function GirlWay01__1.ReachPoint(actor)
  Actors.Soldat_A_38:SetPatrolStyle(MovementStyle.running)
  Actors.Soldat_A_38:AssignPatrol(Patrols.Patrol_61)
  actor:AssignPatrol(Patrols.Patrol_65)
end

-- waypoint class GirlWay02__1: waypoint 2 of patrol "Patrol_63"
GirlWay02__1 = {}

function GirlWay02__1.ReachPoint(actor)
  Actors.Soldat_A_38:SetPatrolStyle(MovementStyle.walking)
  Actors.Soldat_A_38:AssignPatrol(Patrols.Patrol_60)
  actor:AssignPatrol(Patrols.Patrol_64)
  -- StareActor(Actors.Soldat_A_38, Actors.Femme_C_2, true)  (the game's function; RhMod has none)
end

-- scroll class ParchArcherDebut: scroll "Scroll_1"
ParchArcherDebut = {}

-- the game's IsTaken
function ParchArcherDebut.Taken(actorSource)
  if Globals.global[1] == 0 then
    AddObjective(5, false)
    Sequence()
      :SetZoomLevel(1.0)
      :Then()
      :LockUser()
      :SendMessageWithArguments(God(), 13, 1, 0)
      :Then()
      :ScrollCameraTo(Actors.OfficierB_22.location)
      :Then()
      :Wait(0.6)
      :Then()
      :Speak(Actors.OfficierB_22, NpcRemark.officer_complains)
      :Then()
      :DisplayPopupText(5)
      :Then()
      :DisplayPopupText(22)
      :Then()
      :SendMessage(God(), 11)
      :Then()
      :SendMessageWithArguments(God(), 13, 0, 0)
      :UnlockUser()
      :Start()
  end
  return true
end

-- scroll class ParchArgent: scroll "Scroll_2"
ParchArgent = {}

-- the game's IsTaken
function ParchArgent.Taken(actorSource)
  if Globals.global[1] == 1 then
    DisplayPopupText(19)
  end
  Items.Ransom_9:Activate()
  return true
end

-- scroll class ParchEdwardSpeak: scroll "Scroll_3"
ParchEdwardSpeak = {}

-- the game's IsTaken
function ParchEdwardSpeak.Taken(actorSource)
  AddObjective(1, true)
  CompleteObjective(0)
  Actors.Homme_B_5:Reveal()
  SendMessage(God(), 14)
  Actors.Homme_D_4:AttachScroll(God())
  return true
end

-- scroll class ParchFilsEdward: scroll "Scroll_4"
ParchFilsEdward = {}

-- the game's IsTaken
function ParchFilsEdward.Taken(actorSource)
  AddObjective(2, true)
  CompleteObjective(1)
  DisplayPopupText(11)
  Globals.global[2] = 1
  Actors.Homme_B_5:AttachScroll(God())
  return true
end

-- scroll class TutGrimper: scroll "Scroll_5"
TutGrimper = {}

-- the game's IsTaken
function TutGrimper.Taken(actorSource)
  Sequence()
    :SetZoomLevel(1.0)
    :Then()
    :LockUser()
    :SendMessageWithArguments(God(), 13, 1, 0)
    :Then()
    :ScrollCameraTo(Locations.Point_12)
    :Then()
    :Wait(0.48)
    :Then()
    :DisplayPopupText(12)
    :Then()
    :Wait(0.48)
    :Then()
    :SendMessageWithArguments(God(), 13, 0, 0)
    :UnlockUser()
    :Start()
  return false
end

-- scroll class TutJump: scroll "Scroll_6"
TutJump = {}

-- the game's IsTaken
function TutJump.Taken(actorSource)
  DisplayPopupText(13)
  return false
end

-- scroll class TutKO: scroll "Scroll_7"
TutKO = {}

-- the game's IsTaken
function TutKO.Taken(actorSource)
  DisplayPopupText(14)
  DisplayPopupText(21)
  return false
end

-- scroll class TutBeggar: scroll "Scroll_8"
TutBeggar = {}

-- the game's IsTaken
function TutBeggar.Taken(actorSource)
  Sequence()
    :SetZoomLevel(1.0)
    :Then()
    :LockUser()
    :Then()
    :ScrollCameraTo(Locations.Point_1)
    :Then()
    :Wait(0.6)
    :Then()
    :Reveal(Actors.Mendiant_6)
    :Then()
    :DisplayPopupText(16)
    :Then()
    :Wait(1.6)
    :Then()
    :JumpCameraTo(actorSource.location)
    :Then()
    :UnlockUser()
    :Start()
  return false
end

-- scroll class TutGetObject: scroll "Scroll_9"
TutGetObject = {}

function TutGetObject.Initialize()
  local m = Globals.TutGetObject
  m.bFirstTime = 1
end

-- the game's IsTaken
function TutGetObject.Taken(actorSource)
  local m = Globals.TutGetObject
  DisplayPopupText(15)

  if m.bFirstTime == 1 then
    DisplayPopupText(17)
    m.bFirstTime = 0
    Items.Purse_7:Activate()
  end
  return false
end

-- scroll class BeggarWorman: scroll "Scroll_10"
BeggarWorman = {}

-- the game's IsTaken
function BeggarWorman.Taken(actorSource)
  if not Items.Ransom_6.picked_up then
    AddObjective(3, false)
    Sequence()
      :SetZoomLevel(1.0)
      :Then()
      :LockUser()
      :SendMessageWithArguments(God(), 13, 1, 0)
      :Then()
      :ScrollCameraTo(Locations.Point_4)
      :Then()
      :SendMessage(God(), 3)
      :Then()
      :Reveal(Actors.Arbaletrier_30)
      :Reveal(Actors.Homme_A_1)
      :Then()
      :Wait(0.6)
      :Then()
      :DisplayPopupText(4)
      :Then()
      :Wait(1.6)
      :Then()
      :JumpCameraTo(actorSource.location)
      :Then()
      :UnlockUser()
      :SendMessageWithArguments(God(), 13, 0, 0)
      :Start()
  end
  return true
end

-- scroll class BeggarHaldric: scroll "Scroll_11"
BeggarHaldric = {}

-- the game's IsTaken
function BeggarHaldric.Taken(actorSource)
  if Actors.Soldat_B_29:GetProperty(PersistentProperty.money) ~= 0 then
    AddObjective(4, false)
    Sequence()
      :SetZoomLevel(1.0)
      :Then()
      :LockUser()
      :SendMessageWithArguments(God(), 13, 1, 0)
      :Then()
      :DisplayPopupText(7)
      :Then()
      :ScrollCameraTo(Actors.Soldat_B_29.location)
      :Then()
      :Wait(0.6)
      :Then()
      :Reveal(Actors.Soldat_B_29)
      :Then()
      :Wait(1.6)
      :Then()
      :JumpCameraTo(actorSource.location)
      :Then()
      :SendMessageWithArguments(God(), 13, 0, 0)
      :UnlockUser()
      :Start()
  end
  return true
end

-- scroll class Beggarpatch01: scroll "Scroll_12"
Beggarpatch01 = {}

-- the game's IsTaken
function Beggarpatch01.Taken(actorSource)
  if not Patches.Patch_5.applied then
    Patches.Patch_5:Apply()
    Actors.Lincoln_Mecanisme_target_50:Activate()
  end
  Sequence()
    :SetZoomLevel(1.0)
    :Then()
    :LockUser()
    :SendMessageWithArguments(God(), 13, 1, 0)
    :Then()
    :ScrollCameraTo(Locations.Point_14)
    :Then()
    :Wait(0.6)
    :Then()
    :DisplayPopupText(20)
    :Then()
    :Wait(1.6)
    :Then()
    :JumpCameraTo(actorSource.location)
    :Then()
    :SendMessageWithArguments(God(), 13, 0, 0)
    :UnlockUser()
    :Start()
  return false
end

-- scroll class TutOpenSalle: scroll "Scroll_13"
TutOpenSalle = {}

-- the game's IsTaken
function TutOpenSalle.Taken(actorSource)
  if Patches.Patch_7.applied then
    return true
  end
  Sequence()
    :SetZoomLevel(1.0)
    :Then()
    :LockUser()
    :SendMessageWithArguments(God(), 13, 1, 0)
    :Then()
    :ScrollCameraTo(Locations.Point_13)
    :Then()
    :Wait(0.6)
    :Then()
    :SendMessage(God(), 7)
    :Then()
    :Wait(1.6)
    :Then()
    :JumpCameraTo(actorSource.location)
    :Then()
    :SendMessageWithArguments(God(), 13, 0, 0)
    :UnlockUser()
    :Start()
  return true
end

-- scroll class ArrowsAtEnd: scroll "Scroll_14"
ArrowsAtEnd = {}

-- the game's IsTaken
function ArrowsAtEnd.Taken(actorSource)
  Items.Arrow_3:Activate()
  return true
end

-- scroll class PoorManScroll: scroll "Scroll_15"
PoorManScroll = {}

-- the game's IsTaken
function PoorManScroll.Taken(actorSource)
  Items.Amulet_11:Activate()
  Actors.Homme_C_3:AttachScroll(God())
  Sequence()
    :Speak(Actors.Homme_C_3, NpcRemark.civilian_thanks)
    :Then()
    :DisplayPopupText(3)
    :Start()
  return true
end

-- script zone class ZP06Sud: script zone "Zone_16"
ZP06Sud = {}

-- the game's EnterZone
function ZP06Sud.Enter(actor)
  if actor.is_hero and not Patches.Patch_8.applied then
    SendMessage(God(), 6)
  end
end

-- script zone class ZP06Est: script zone "Zone_17"
ZP06Est = {}

-- the game's EnterZone
function ZP06Est.Enter(actor)
  if actor.is_hero and not Patches.Patch_8.applied then
    SendMessage(God(), 6)
  end
end

-- script zone class ZP03TourOuest: script zone "Zone_18"
ZP03TourOuest = {}

-- the game's EnterZone
function ZP03TourOuest.Enter(actor)
  if actor.is_hero and not Patches.Patch_1.applied then
    SendMessage(God(), 3)
  end
end

-- script zone class ZP01TourPtLevis: script zone "Zone_19"
ZP01TourPtLevis = {}

-- the game's EnterZone
function ZP01TourPtLevis.Enter(actor)
  if actor.is_hero and not Patches.Patch_5.applied then
    Patches.Patch_5:Apply()
    Actors.Lincoln_Mecanisme_target_50:Activate()
    Scrolls.Scroll_12.state = ScrollState.opened
  end
end

-- script zone class ZP04CentralBas: script zone "Zone_20"
ZP04CentralBas = {}

-- the game's EnterZone
function ZP04CentralBas.Enter(actor)
  if actor.is_hero and not Patches.Patch_6.applied then
    Patches.Patch_6:Apply()
    Animations.Animation_23:Activate()
    Doors.Door_37:SetClickable(true)
    Doors.Door_6:SetClickable(false)
  end
end

-- script zone class ZP07Bas: script zone "Zone_21"
ZP07Bas = {}

-- the game's EnterZone
function ZP07Bas.Enter(actor)
  if actor.is_hero and not Patches.Patch_7.applied then
    SendMessage(God(), 7)
  end
end

-- script zone class ZP07Haut: script zone "Zone_22"
ZP07Haut = {}

-- the game's EnterZone
function ZP07Haut.Enter(actor)
  if actor.is_hero and not Patches.Patch_7.applied then
    SendMessage(God(), 7)
  end
end

-- script zone class ZP05GdSalle: script zone "Zone_23"
ZP05GdSalle = {}

-- the game's EnterZone
function ZP05GdSalle.Enter(actor)
  if actor.is_hero and not Patches.Patch_11.applied then
    SendMessage(God(), 5)
  end
end

-- script zone class ZP09EscalierBas: script zone "Zone_24"
ZP09EscalierBas = {}

-- the game's EnterZone
function ZP09EscalierBas.Enter(actor)
  if actor.is_hero and not Patches.Patch_10.applied then
    Patches.Patch_10:Apply()
    Animations.Animation_24:Activate()
    Animations.Animation_25:Activate()
  end
end

-- script zone class ZP09EscalierHaut: script zone "Zone_25"
ZP09EscalierHaut = {}

-- the game's EnterZone
function ZP09EscalierHaut.Enter(actor)
  if actor.is_hero and not Patches.Patch_10.applied then
    Patches.Patch_10:Apply()
    Animations.Animation_24:Activate()
    Animations.Animation_25:Activate()
  end
end

-- script zone class EdwardZone: script zone "Zone_26"
EdwardZone = {}

function EdwardZone.Initialize()
  local m = Globals.EdwardZone
  m.bFirstTime = 1
end

-- the game's EnterZone
function EdwardZone.Enter(actor)
  local m = Globals.EdwardZone

  if actor.is_hero and m.bFirstTime == 1 then
    actor:Stop()
    m.bFirstTime = 0
    Sequence()
      :SetZoomLevel(1.0)
      :Then()
      :LockUser()
      :SendMessageWithArguments(God(), 13, 1, 0)
      :Then()
      :ScrollCameraTo(Locations.Point_5)
      :Then()
      :Wait(0.6)
      :Then()
      :DisplayPopupText(18)
      :Then()
      :Wait(1.6)
      :Then()
      :UnlockUser()
      :SendMessageWithArguments(God(), 13, 0, 0)
      :Start()
  end
end

-- script zone class persecutionZone: script zone "Zone_27"
persecutionZone = {}

-- the game's ExitZone
function persecutionZone.Exit(actor)
  if #Locations.Zone_27.actors_inside == 1 and Globals.global[3] == 0 then
    Globals.global[3] = 1
    SendMessage(Actors.Homme_C_3, 1)
  end
end

