-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

MiscPatch = {}

MiscDoor = {}

MiscBuilding = {}

MiscAnimation = {}

---@type RevealingControllerWithFallGate
CastleFallGateRoom = {
  patch = nil,
  fallGate = nil,
  treadWheel = nil,
  torchAnimation = nil,

  Reveal = function(self)
    self.patch:Apply()
    Actors["CastleTreadWheel"]:Activate()
    self.torchAnimation:Activate()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_5"]
    self.fallGate = MiscPatch.fallgate
    self.treadWheel = Patches["Patch_4"]
    self.torchAnimation = Animations["Animation_31"]

    Actors["CastleTreadWheel"]:Deactivate()
  end,

  ActivateFallGate = function (self, soundLocation)
    Sequence()
      :PlayAnimFreeze(Actors["CastleTreadWheel"], ActorAction.getting_up_from_sitting)
      :Start()
    soundLocation:MakeNoise(NoiseType.drawbridge)
    self.treadWheel:Apply()
    self.fallGate:Apply()
  end
}

---@type RevealingControllerWithDoor
CastleMainHall = {
  patch = nil,
  doorPatch = nil,

  Door = {},

  Animation = {},

  Reveal = function (self)
    self.patch:Apply()
    self.doorPatch:Apply()
    self.Door.entranceWest:SetClickable(false)
    self.Door.entranceSouth:SetClickable(false)
    self.Door.tower:SetClickable(true)
    ActivateAnimations(self.Animation)
  end,

  Initialize = function (self)
    self.patch = Patches["Patch_1"]
    self.doorPatch = Patches["Patch_3"]

    self.Door.entranceWest = Doors["Door_15"]
    self.Door.entranceSouth = Doors["Door_17"]
    self.Door.tower = Doors["Door_23"]

    self.Animation.candles = Animations["Animation_1"]
    self.Animation.chandelier1 = Animations["Animation_2"]
    self.Animation.chandelier2 = Animations["Animation_3"]
    self.Animation.towerTorch = Animations["Animation_33"]

    self.Door.tower:SetClickable(false)
    DeactivateAnimations(self.Animation)
  end
}

---@type RevealingControllerWithDoor
CastleHallway = {
  patch = nil,

  Door = { },

  Animation = {},

  Reveal = function (self)
    self.patch:Apply()
    if not CastleMainHall.patch.applied then
      self.Door.exitNorth:SetClickable(true)
    end
    self.Door.entranceSouth:SetClickable(false)
    ActivateAnimations(self.Animation)
  end,

  Initialize = function (self)
    self.patch = Patches["Patch_2"]
    self.Door.entranceSouth = Doors["Door_16"]
    self.Door.exitNorth = Doors["Door_17"]
    self.Animation.candles = Animations["Animation_0"]
    self.Animation.torch = Animations["Animation_32"]

    self.Door.exitNorth:SetClickable(false)
    DeactivateAnimations(self.Animation)
  end
}

---@type RevealingControllerWithDoor
Church = {
  patch = nil,

  Door = {},

  Animation = {
  },

  Reveal = function (self)
    self.patch:Apply()
    self.Door.sideRoom:SetClickable(true)
    ActivateAnimations(self.Animation)
  end,

  Initialize = function (self)
    self.patch = Patches["Patch_6"]
    self.Door.sideRoom = Doors["Door_122"]
    self.Animation.candles1 = Animations["Animation_4"]
    self.Animation.candles2 = Animations["Animation_5"]
    self.Animation.candles3 = Animations["Animation_6"]
    self.Animation.candles4 = Animations["Animation_7"]
    self.Animation.candles5 = Animations["Animation_8"]
    self.Animation.candles6 = Animations["Animation_9"]
    self.Animation.candles7 = Animations["Animation_10"]
    self.Animation.candles8 = Animations["Animation_11"]
    self.Animation.candles9 = Animations["Animation_12"]
    self.Animation.candles10 = Animations["Animation_13"]

    self.Door.sideRoom:SetClickable(false)
    DeactivateAnimations(self.Animation)
  end
}

function InitializeYork()
  MiscPatch.outerEastGate = Patches["Patch_7"]
  MiscPatch.innerEastGate = Patches["Patch_8"]
  MiscPatch.marketStandPixelVert = Patches["Patch_9"]
  MiscPatch.fallgate = Patches["Patch_0"]
  
  MiscDoor.secretPassageInnerEast = Doors["Door_18"]
  MiscDoor.secretPassageInnerWest = Doors["Door_19"]
  MiscDoor.secretPassageOuter = Doors["Door_20"]
  MiscDoor.officerWithAmpuleDoor = Doors["Door_32"]
  MiscDoor.ampuleWomanDoor = Doors["Door_33"]
  MiscDoor.loanSharkDoor = Doors["Door_44"]
  MiscDoor.northWestBridgeHouseCathedralDoor = Doors["Door_119"]
  MiscDoor.northWestBridgeHouseBridgeDoor = Doors["Door_120"]
  MiscDoor.northWestBridgeHouseRampartDoor = Doors["Door_121"]
  
  MiscBuilding.CastleTower = Buildings["Building_4"]
  MiscBuilding.ChurchInnerBuilding = Buildings["Building_73"]
  
  MiscAnimation.pigeonsWestOfCathedral = Animations["Animation_54"]
  MiscAnimation.crowNorthWest01 = Animations["Animation_55"]
  MiscAnimation.crowNorthWest02 = Animations["Animation_56"]
  MiscAnimation.crowNorthWest03 = Animations["Animation_57"]
  MiscAnimation.crowSouthWest01 = Animations["Animation_58"]
  MiscAnimation.crowSouthWest02 = Animations["Animation_59"]

  CastleFallGateRoom:Initialize()
  CastleMainHall:Initialize()
  CastleHallway:Initialize()
  Church:Initialize()

  DeactivateSherwoodSigns()
end