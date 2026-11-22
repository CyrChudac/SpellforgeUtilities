-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

MiscDoor = {}

MiscBuildings = {}

MiscPatch = {}

MiscAnimation = {}

---@type RevealingControllerWithDoor
Church = {
    Door = {},

    Animation = {},

    patch = nil,

    Reveal = function (self)
        self.patch:Apply()

        self.Door.confessionalBox1:SetClickable(true)
        self.Door.confessionalBox2:SetClickable(true)
        self.Door.sideEntrance:SetClickable(false)
        self.Door.mainEntrance:SetClickable(false)

        self.Animation.candles:Activate()
    end,

    Initialize = function (self)
        self.patch = Patches["Patch_0"]

        self.Animation.candles = Animations["Animation_28"]

        self.Door.sideEntrance = Doors["Door_54"]
        self.Door.mainEntrance = Doors["Door_55"]
        self.Door.confessionalBox1 = Doors["Door_56"]
        self.Door.confessionalBox2 = Doors["Door_57"]

        self.Door.confessionalBox1:SetClickable(false)
        self.Door.confessionalBox2:SetClickable(false)

        self.Animation.candles:Deactivate()
    end
}

---@type RevealingControllerWithDoor
PrisonNorth = {
    Door = {},

    patch = nil,

    Reveal = function (self)
        self.patch:Apply()

        self.Door.cell:SetClickable(true)
        self.Door.exit:SetClickable(true)
        self.Door.southEntrance:SetClickable(false)
    end,

    Initialize = function (self)
        self.patch = Patches["Patch_2"]

        self.Door.cell = Doors["Door_58"]
        self.Door.southEntrance = Doors["Door_59"]
        self.Door.exit = Doors["Door_74"]
        self.Door.exitTop = Doors["Door_75"]
        self.Door.exitOuter = Doors["Door_76"]

        self.Door.cell:SetClickable(false)
        self.Door.exit:SetClickable(false)
    end
}

---@type RevealingControllerWithFallGate
FallGateRoom = {
    ---@ Animation[]
    Animation = {},

    patch = nil,
    fallGate = nil,
    lever = nil,

    Reveal = function (self)
        self.patch:Apply()
        Actors["Treadwheel"]:Activate()
        self.Animation.torch:Activate()
    end,

    Initialize = function (self)
        self.Animation.torch = Animations["Animation_35"]
        self.patch = Patches["Patch_5"]
        self.lever = Patches["Patch_4"]
        self.fallGate = MiscPatch.fallGate

        Actors["Treadwheel"]:Deactivate()
        self.Animation.torch:Deactivate()
    end,

    ActivateFallGate = function(self, location)
        Sequence()
            :PlayAnimFreeze(Actors["Treadwheel"], ActorAction.getting_up_from_sitting)
            :Then()
            :Call("Location.MakeNoise", location, NoiseType.drawbridge)
            :Start()
        self.fallGate:Apply()
        self.lever:Apply()
      end
}

---@type RevealingControllerWithDoor
PrisonSouth = {
    Door = {},

    Animation = {},

    patch = nil,

    Reveal = function (self)
        self.patch:Apply()

        self.Animation.torch1:Activate()
        self.Animation.torch2:Activate()

        self.Door.cell:SetClickable(true)
        self.Door.stairs:SetClickable(true)
        self.Door.sideEntrance:SetClickable(false)
        self.Door.mainEntrance:SetClickable(false)
    end,

    Initialize = function (self)
        self.patch = Patches["Patch_7"]

        self.Door.sideEntrance = Doors["Door_81"]
        self.Door.mainEntrance = Doors["Door_82"]
        self.Door.cell = Doors["Door_83"]
        self.Door.stairs = Doors["Door_84"]
        
        self.Animation.torch1 = Animations["Animation_33"]
        self.Animation.torch2 = Animations["Animation_34"]

        self.Animation.torch1:Deactivate()
        self.Animation.torch2:Deactivate()

        self.Door.cell:SetClickable(false)
        self.Door.stairs:SetClickable(false)
    end
}

---@type RevealingControllerWithDoor
Chateau = {
    Door = {},
    Animation = {},
    patch = nil,

    Reveal = function (self)
        self.patch:Apply()

        self.Animation.chimney:Activate()
        self.Animation.chandelier:Activate()
        self.Animation.candles1:Activate()
        self.Animation.candles2:Activate()
        self.Animation.candles3:Activate()

        self.Door.main:SetClickable(true)
        self.Door.cupboard:SetClickable(true)
        self.Door.side:SetClickable(false)
    end,

    Initialize = function (self)
        self.patch = Patches["Patch_8"]

        self.Animation.chimney = Animations["Animation_27"]
        self.Animation.chandelier = Animations["Animation_29"]
        self.Animation.candles1 = Animations["Animation_30"]
        self.Animation.candles2 = Animations["Animation_31"]
        self.Animation.candles3 = Animations["Animation_32"]

        self.Door.side = Doors["Door_86"]
        self.Door.main = Doors["Door_87"]
        self.Door.cupboard = Doors["Door_92"]
        self.Door.mainOuter = Doors["Door_88"]
        self.Door.northTower = Doors["Door_89"]

        self.Animation.chimney:Deactivate()
        self.Animation.chandelier:Deactivate()
        self.Animation.candles1:Deactivate()
        self.Animation.candles2:Deactivate()
        self.Animation.candles3:Deactivate()

        self.Door.main:SetClickable(false)
        self.Door.cupboard:SetClickable(false)
    end
}

function InitializeNottingham()
    MiscAnimation.castleBanner = Animations["Animation_26"]
    MiscAnimation.gateBanner = Animations["Animation_40"]
    MiscAnimation.eastPigeon01 = Animations["Animation_41"]
    MiscAnimation.eastPigeon02 = Animations["Animation_42"]
    MiscAnimation.southEastCow = Animations["Animation_43"]
    MiscAnimation.southEastFlies = Animations["Animation_44"]
    MiscAnimation.southEastChicken = Animations["Animation_45"]
    MiscAnimation.southWestPig = Animations["Animation_46"]
    MiscAnimation.northWestPigeons = Animations["Animation_47"]

    MiscPatch.prisonNorthDoor = Patches["Patch_1"]
    MiscPatch.prisonSouthDoor = Patches["Patch_6"]
    MiscPatch.fallGate = Patches["Patch_3"]
    MiscPatch.pixel_vert1 = Patches["Patch_9"]
    MiscPatch.pixel_vert2 = Patches["Patch_10"]

    MiscBuildings.sheriffCousinHouse = Buildings["Building_4"]
    MiscBuildings.baitBeggarHouse1 = Buildings["Building_12"]
    MiscBuildings.baitBeggarHouse2 = Buildings["Building_13"]
    MiscBuildings.northWallEastTower = Buildings["Building_18"]
    MiscBuildings.southGateTower = Buildings["Building_21"]
    MiscBuildings.mill = Buildings["Building_24"]
    MiscBuildings.confessionalCivilian = Buildings["Building_30"]
    MiscBuildings.middleTower = Buildings["Building_35"]
    MiscBuildings.citadelWestTower = Buildings["Building_41"]

    MiscDoor.sheriffCousinHouse = Doors["Door_4"]
    MiscDoor.eastOfSheriffsCousinsHouse = Doors["Door_5"]
    MiscDoor.easternMostFromCCousinsHouse = Doors["Door_6"]
    MiscDoor.mariannesHouse = Doors["Door_8"]
    MiscDoor.lockTutorialHouse1 = Doors["Door_9"]
    MiscDoor.lockTutorialHouse2 = Doors["Door_10"]
    MiscDoor.lockTutorialHouseNorth = Doors["Door_13"]
    MiscDoor.houseNorth2 = Doors["Door_15"]
    MiscDoor.towerNorthEast = Doors["Door_24"]
    MiscDoor.towerNorthEastExit = Doors["Door_25"]
    MiscDoor.northGateWestTowerBot = Doors["Door_30"]
    MiscDoor.prisonEntranceNorth = Doors["Door_76"]
    MiscDoor.castleStairsPassageBottom = Doors["Door_79"]
    MiscDoor.castleStairsPassageTop = Doors["Door_80"]
    MiscDoor.castleRampartEntrance = Doors["Door_93"]
    MiscDoor.castleRampartEntranceTop = Doors["Door_94"]

    Church:Initialize()
    PrisonNorth:Initialize()
    FallGateRoom:Initialize()
    PrisonSouth:Initialize()
    Chateau:Initialize()

    DeactivateSherwoodSigns()
end