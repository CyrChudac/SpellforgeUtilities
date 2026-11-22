-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

MiscDoor = {}

MiscPatch = {
}

MiscAnimation = {
  Animals = {},
  LakeParts = {}
}

---@type RevealingController
TowerNorth = {
  patch = nil,

  Reveal = function (self)
    self.patch:Apply()
  end,

  Initialize = function (self)
    self.patch = Patches["Patch_7"]
  end
}

---@type RevealingController
CellTower = {
  Door = {},
  patch = nil,

  Reveal = function (self)
    self.patch:Apply()
    self.Door.cell:SetClickable(true)
  end,

  Initialize = function (self)
    self.patch = Doors["Door_13"]
    self.Door.cell = MiscDoor.cell

    self.Door.cell:SetClickable(false)
  end
}

---@type RevealingControllerWithBridge
TowersEast = {
  patch = nil,
  drawBridge = nil,
  lever = nil,

  ---@comment Requires a target called "_Mecanisme01_target_1".
  Reveal = function(self)
    self.patch:Apply()
    Actors["Leicester_-_Mecanisme01_target_1"]:Activate()
  end,

  ---@comment Requires a target called "_Mecanisme01_target_1".
  Initialize = function(self)
    self.patch = Patches["Patch_3"]
    self.drawbridge = Patches["Patch_8"]
    self.lever = Patches["Patch_9"]

    Actors["Leicester_-_Mecanisme01_target_1"]:Deactivate()
  end,

  ---@comment Requires a target called "_Mecanisme01_target_1".
  ActivateDrawBridge = function(self)
    Sequence()
      :PlayAnimFreeze(Actors["Leicester_-_Mecanisme01_target_1"], ActorAction.getting_up_from_sitting)
      :Then()
      :Call(function()
        Actors["Leicester_-_Mecanisme01_target_1"].location:MakeNoise(NoiseType.drawbridge)
      end)
      :Start()
    self.drawBridge:Apply()
    self.lever:Apply()
  end
}

---@type RevealingController
BedRoom = {
  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.BedroomCandles:Activate()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_5"]
    self.Animation.BedroomCandles = Animations["Animation_29"]

    self.Animation.BedroomCandles:Deactivate()
  end
}

---@type RevealingController
ChimneyRoom = {
  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.chimney:Activate()
    self.Animation.candles:Activate()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_6"]
    self.Animation.chimney = Animations["Animation_22"]
    self.Animation.candles = Animations["Animation_30"]

    self.Animation.chimney:Deactivate()
    self.Animation.candles:Deactivate()
  end
}

---@type RevealingController
Hallway = {

  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    MiscDoor.hallwaySideDoor:SetClickable(true)
    self.Animation.chandelier:Activate()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_0"]
    self.Animation.chandelier = Animations["Animation_28"]

    MiscDoor.hallwaySideDoor:SetClickable(false)
    self.Animation.chandelier:Deactivate()
  end
}

---@type RevealingControllerWithBridge
DrawBridgeRoomSouth = {
  Door = {},

  patch = nil,
  drawBridge = nil,
  lever = nil,

  ---@comment Requires a target called "Leicester_-_Mecanisme03_target_3".
  Reveal = function(self)
    self.patch:Apply()
    self.Door.flap:SetClickable(true)
    Actors["Leicester_-_Mecanisme03_target_3"]:Activate()
  end,

  ---@comment Requires a target called "Leicester_-_Mecanisme03_target_3".
  Initialize = function(self)
    self.patch = Patches["Patch_4"]
    self.drawBridge = Patches["Patch_10"]
    self.lever = Patches["Patch_11"]

    self.Door.east = Doors["Door_10"]
    self.Door.flap = MiscDoor.southBridgeRoomFlap
    self.Door.west = Doors["Door_12"]

    Actors["Leicester_-_Mecanisme03_target_3"]:Deactivate()
    self.Door.flap:SetClickable(false)
  end,

  ---@comment Requires a target called "Leicester_-_Mecanisme03_target_3".
  ActivateDrawBridge = function(self)
      Actors["Leicester_-_Mecanisme03_target_3"].location:MakeNoise(NoiseType.drawbridge)
      Sequence()
        :PlayAnimFreeze(Actors["Leicester_-_Mecanisme03_target_3"], ActorAction.getting_up_from_sitting)
        :Start()
      self.lever:Apply()
      self.drawBridge:Apply()
  end

}

---@type RevealingController
Cell = {
  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    MiscDoor.cell:SetClickable(not CellTower.patch.applied)
  end,

  Initialize = function (self)
    self.patch = Patches["Patch_14"]
  end
}

function InitializeLeicester()
  MiscDoor.secretPassageOutside = Doors["Door_25"]
  MiscDoor.secretPassageInside = Doors["Door_26"]
  MiscDoor.cell = Doors["Door_55"]
  MiscDoor.hallwaySideDoor = Doors["Door_39"]
  MiscDoor.southBridgeRoomFlap = Doors["Door_11"]
  
  MiscPatch.drawBridgeInside = Patches["Patch_1"]
  MiscPatch.leverInside = Patches["Patch_2"]
  MiscPatch.towerNorth = Patches["Patch_7"]
  MiscPatch.pixel_vert1 = Patches["Patch_12"]
  MiscPatch.pixel_vert2 = Patches["Patch_15"]

  MiscAnimation.Animals.butterfly1 = Animations["Animation_39"]
  MiscAnimation.Animals.butterfly2 = Animations["Animation_40"]
  MiscAnimation.Animals.butterfly3 = Animations["Animation_41"]
  MiscAnimation.Animals.pigs = Animations["Animation_43"]
  MiscAnimation.Animals.cow1 = Animations["Animation_44"]
  MiscAnimation.Animals.cow2 = Animations["Animation_45"]
  MiscAnimation.Animals.duck = Animations["Animation_46"]

  MiscAnimation.LakeParts.bubbles1 = Animations["Animation_32"]
  MiscAnimation.LakeParts.bubbles2 = Animations["Animation_33"]
  MiscAnimation.LakeParts.bubbles3 = Animations["Animation_34"]
  MiscAnimation.LakeParts.bubbles4 = Animations["Animation_35"]
  MiscAnimation.LakeParts.bubbles5 = Animations["Animation_36"]

  TowerNorth:Initialize()
  CellTower:Initialize()
  Hallway:Initialize()
  DrawBridgeRoomSouth:Initialize()
  BedRoom:Initialize()
  ChimneyRoom:Initialize()
  Cell:Initialize()

  DeactivateSherwoodSigns()
end
