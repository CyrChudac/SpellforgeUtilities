require("lib.common")
-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

MiscDoor = {
  NorthBattlement = {},
  NorthTower = {},
  WeaponRoomInnerHouse = {}
}

MiscPatch = {
}

MiscAnimation = {}


---@type RevealingControllerWithDoor
Dungeon = {
  Door = {},

  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.torch1:Activate()
    self.Animation.torch2:Activate()
    self.Door.exit:SetClickable(true)
    self.Door.cell:SetClickable(true)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_0"]
    self.Animation.torch1 = Animations["Animation_21"]
    self.Animation.torch2 = Animations["Animation_22"]
    self.Door.cell = Doors["Door_8"]
    self.Door.exit = Doors["Door_21"]

    self.Animation.torch1:Deactivate()
    self.Animation.torch2:Deactivate()

    self.Door.exit:SetClickable(false)
    self.Door.cell:SetClickable(false)
  end
}

---@type RevealingControllerWithDoor
DungeonTower = {
  Door = {},

  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.candles:Activate()
    self.Door.dungeonEntrance:SetClickable(true)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_1"]
    self.Animation.candles = Animations["Animation_32"]
    self.Door.dungeonEntrance = MiscDoor.dungeonEntranceOuter

    self.Animation.candles:Deactivate()
    self.Door.dungeonEntrance:SetClickable(false)
  end
}

---@type RevealingControllerWithDoor
BedRoom = {
  Door = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Door.innerToTop:SetClickable(true)
    self.Door.balcony:SetClickable(false)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_7"]
    self.Door.balcony = Doors["Door_22"]
    self.Door.innerToTop = Doors["Door_23"]
    self.Door.outerToTop = Doors["Door_24"]

    self.Door.innerToTop:SetClickable(false)
  end
}

---@type RevealingControllerWithBridge
DrawBridgeRoom = {
  patch = nil,
  lever = nil,
  drawBridge = nil,

  ---@comment Requires a target called "Treadwheel".
  Reveal = function(self)
    self.patch:Apply()
    Actors["Treadwheel"]:Activate()
  end,

  ---@comment Requires a target called "Treadwheel".
  Initialize = function(self)
    self.patch = Patches["Patch_5"]
    self.lever = Patches["Patch_4"]
    self.drawBridge = Patches["Patch_3"]

    Actors["Treadwheel"]:Deactivate()
  end,

  ---@comment Requires a target called "Treadwheel".
  ActivateDrawBridge = function(self, soundLocation)
    Sequence()
      :PlayAnimFreeze(Actors["Treadwheel"], ActorAction.getting_up_from_sitting)
      :Then()
      :Call("Location.MakeNoise", soundLocation, NoiseType.drawbridge)
      :Start()
    self.drawBridge:Apply()
    self.lever:Apply()
  end
}

---@type RevealingControllerWithDoor
Battlement = {
  Door = {},

  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.torch:Activate()
    self.Door.innerDoor:SetClickable(true)
    self.Door.exit:SetClickable(false)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_6"]
    self.Animation.torch = Animations["Animation_23"]
    
    self.Door.exit = Doors["Door_6"]
    self.Door.innerDoor = Doors["Door_37"]
    self.Door.gardenDoor = Doors["Door_38"]

    self.Animation.torch:Deactivate()
    self.Door.innerDoor:SetClickable(false)
  end
}

---@type RevealingControllerWithDoor
WeaponRoom = {
  Door = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Door.innerDoor:SetClickable(true)
    self.Door.southEntrance:SetClickable(false)
    self.Door.westEntrance:SetClickable(false)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_8"]

    self.Door.southEntrance = Doors["Door_4"]
    self.Door.westEntrance = Doors["Door_5"]
    self.Door.innerDoor = MiscDoor.WeaponRoomInnerHouse.fromWeaponRoom
    
    self.Door.innerDoor:SetClickable(false)
  end
}

---@type RevealingController
StairCase = {
  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()
    self.Animation.torch1:Activate()
    self.Animation.torch2:Activate()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_10"]
    self.Animation.torch1 = Animations["Animation_24"]
    self.Animation.torch2 = Animations["Animation_25"]

    self.Animation.torch1:Deactivate()
    self.Animation.torch2:Deactivate()
  end
}

---@type RevealingControllerWithDoor
ThroneRoom = {
  Door = {},

  Animation = {},

  patch = nil,

  Reveal = function(self)
    self.patch:Apply()

    self.Animation.chimneyFire1:Activate()
    self.Animation.chimneyFire2:Activate()
    self.Animation.candles1:Activate()
    self.Animation.candles2:Activate()
    self.Animation.bedroomCandles:Activate()
    self.Animation.tableCandles1:Activate()
    self.Animation.tableCandles2:Activate()
    self.Animation.tableCandles3:Activate()

    self.Door.exit:SetClickable(false)
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_11"]
    
    self.Animation.chimneyFire1 = Animations["Animation_19"]
    self.Animation.chimneyFire2 = Animations["Animation_20"]
    self.Animation.candles1 = Animations["Animation_26"]
    self.Animation.candles2 = Animations["Animation_27"]
    self.Animation.bedroomCandles = Animations["Animation_28"]
    self.Animation.tableCandles1 = Animations["Animation_29"]
    self.Animation.tableCandles2 = Animations["Animation_30"]
    self.Animation.tableCandles3 = Animations["Animation_31"]
    
    self.Door.exit = Doors["Door_0"]

    self.Animation.chimneyFire1:Deactivate()
    self.Animation.chimneyFire2:Deactivate()
    self.Animation.candles1:Deactivate()
    self.Animation.candles2:Deactivate()
    self.Animation.bedroomCandles:Deactivate()
    self.Animation.tableCandles1:Deactivate()
    self.Animation.tableCandles2:Deactivate()
    self.Animation.tableCandles3:Deactivate()
  end
}

function InitializeLincoln()
  MiscAnimation.riverPier = Animations["Animation_1"]
  MiscAnimation.smokeInnerVillage1 = Animations["Animation_15"]
  MiscAnimation.smokeInnerVillage2 = Animations["Animation_16"]
  MiscAnimation.smokeOuterVillage1 = Animations["Animation_17"]
  MiscAnimation.smokeOuterVillage2 = Animations["Animation_18"]
  MiscAnimation.pigs = Animations["Animation_37"]

  MiscPatch.dungeonDoor = Patches["Patch_2"]
  MiscPatch.pixel_vert = Patches["Patch_9"]
  

  MiscDoor.garissonEntrance = Doors["Door_28"]
  MiscDoor.bridgeBattlementBottom = Doors["Door_52"]
  MiscDoor.dungeonEntranceOuter = Doors["Door_20"]

  MiscDoor.NorthBattlement.courtyard = Doors["Door_29"]
  MiscDoor.NorthBattlement.eastRampart = Doors["Door_30"]
  MiscDoor.NorthBattlement.top = Doors["Door_31"]
  MiscDoor.NorthBattlement.westRampart = Doors["Door_32"]

  MiscDoor.NorthTower.top = Doors["Door_54"]
  MiscDoor.NorthTower.middle = Doors["Door_55"]
  MiscDoor.NorthTower.bottom = Doors["Door_56"]

  MiscDoor.WeaponRoomInnerHouse.fromWeaponRoom = Doors["Door_25"]
  MiscDoor.WeaponRoomInnerHouse.towerDoor = Doors["Door_26"]
  MiscDoor.WeaponRoomInnerHouse.outerNorthEast = Doors["Door_27"]

  Dungeon:Initialize()
  DungeonTower:Initialize()
  BedRoom:Initialize()
  DrawBridgeRoom:Initialize()
  Battlement:Initialize()
  WeaponRoom:Initialize()
  StairCase:Initialize()
  ThroneRoom:Initialize()
end
