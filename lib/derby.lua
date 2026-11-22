-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

MiscAnimation = {}

MiscBuilding = {}

---@type RevealingControllerWithDoor
MainHall = {
  patch = nil,

  Door = {},

  Animation = {},

  Reveal = function(self)
    self.patch:Apply()
    ActivateDoors({self.Door.entranceEast, self.Door.mainEntrance, self.Door.entranceWest})
    ActivateAnimations(self.Animation)
  end,

  Initialize = function(self)
    self.Door["entranceEast"] = Doors["Door_22"]
    self.Door["mainEntrance"] = Doors["Door_25"]
    self.Door["entranceWest"] = Doors["Door_29"]
    self.Door["OuterCourtyard"] = Doors["Door_23"]
    self.Door["OuterEastRampart"] = Doors["Door_21"]
    self.Door["OuterNorthRampart"] = Doors["Door_30"]

    self.Animation["candles1"] = Animations["Animation_0"]
    self.Animation["candles2"] = Animations["Animation_1"]
    self.Animation["chimney"] = Animations["Animation_6"]
    self.Animation["torch1"] = Animations["Animation_8"]
    self.Animation["torch2"] = Animations["Animation_9"]
    self.Animation["torch3"] = Animations["Animation_10"]
  
    self.patch = Patches["Patch_0"]

    DeactivateDoors({self.Door.entranceEast, self.Door.mainEntrance, self.Door.entranceWest})
    DeactivateAnimations(self.Animation)
  end
}

---@type RevealingControllerWithDoor
PrisonRoom = {
  patch = nil,
  pixel_vert_patch = nil,
  Door = {},

  Reveal = function(self)
    self.patch:Apply()
    self.pixel_vert_patch:Reset()
    self.door:SetClickable(true)
    self.Door.entrance.locked_for_villains = true
  end,

  Initialize = function(self)
    self.Door["entrance"] = Doors["Door_15"]

    self.patch = Patches["Patch_1"]
    self.pixel_vert_patch = Patches["Patch_6"]
  
    self.pixel_vert_patch:Apply()
    self.door:SetClickable(false)
    self.Door.entrance.locked_for_villains = false
  end,
}

---@type RevealingControllerWithDoor
DiningHall = {
  patch = nil,

  Door = {},

  Animation = {},

  Reveal = function(self)
    self.patch:Apply()
    self.Door.staircase:SetClickable(true)
    self.Door.entrance:SetClickable(false)
    ActivateAnimations(self.Animation)
  end,

  Initialize = function(self)
    self.Door["entrance"] = Doors["Door_24"]
    self.Door["staircase"] = Doors["Door_26"]

    self.Animation["candles1"] = Actors["Animation_2"]
    self.Animation["candles2"] = Actors["Animation_3"]
    self.Animation["candles3"] = Actors["Animation_4"]
    self.Animation["candles4"] = Actors["Animation_5"]
    self.Animation["chimney"] = Actors["Animation_7"]

    self.patch = Patches["Patch_2"]

    self.Door.staircase:SetClickable(false)
    DeactivateAnimations(self.Animation)
  end,
}

---@type RevealingControllerWithBridge
DrawBridgeRoom = {
  patch = nil,
  drawBridge = nil,
  lever = nil,

  Door = {
    West = Doors["Door_9"],
    East = Doors["Door_8"]
  },

  ---@comment Requires a target called "Treadwheel".
  Reveal = function(self)
    self.patch:Apply()
    ActivateDoors(self.Door)
    Actors["Treadwheel"]:Activate()
    self.Door.West:SetClickable(false)
    self.Door.East:SetClickable(false)
  end,

  ---@comment Requires a target called "Treadwheel".
  Initialize = function(self)
    self.patch = Patches["Patch_3"]
    self.drawBridge = Patches["Patch_7"]
    self.lever = Patches["Patch_9"]

    Actors["Treadwheel"]:Deactivate()
  end,

  ---@comment Requires a target called "Treadwheel".
  ---@param soundLocation? Location The location to play the sound at. 
  ActivateDrawBridge = function(self, soundLocation)
    if soundLocation == nil then
      soundLocation = Actors["Treadwheel"].location
    end
    if soundLocation ~= nil then
      soundLocation:MakeNoise(NoiseType.drawbridge)
    end
    Sequence()
      :PlayAnimFreeze(Actors["Treadwheel"], ActorAction.getting_up_from_sitting)
      :Start()
    self.lever:Apply()
    self.drawBridge:Apply()
  end
}

FootBridge = {
  patch = nil,

  ---@comment Requires a target called "FootBridgeBowTarget" and "Footbridge".
  Activate = function(self)
    Actors["FootBridgeBowTarget"]:Deactivate()
    Sequence()
      :PlayAnimFreeze(Actors["Footbridge"], ActorAction.getting_up_from_sitting)
      :Start()
    self.patch:Apply()
  end,

  Initialize = function(self)
    self.patch = Patches["Patch_8"]
  end,
}


function InitializeDerby()
  MiscBuilding["NorthOnSouthWestYard"] = Buildings["Building_1"]
  MiscBuilding["UnderStairsEastYard"] = Buildings["Building_7"]

  MiscAnimation["hen1"] = Animations["Animation_11"]
  MiscAnimation["hen2"] = Animations["Animation_12"]

  MainHall:Initialize()
  PrisonRoom:Initialize()
  DiningHall:Initialize()
  DrawBridgeRoom:Initialize()
  FootBridge:Initialize()

  DeactivateSherwoodSigns()
end
