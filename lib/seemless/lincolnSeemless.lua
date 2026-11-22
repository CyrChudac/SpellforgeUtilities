require("lib.lincoln")
require("lib.seemless.seemlessCommon")

---@return {[string]: HiddenSpace}
---@param data {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
local CreateInterriors = function (data)
  return {
    weapon_room = GetBaseObject(
      data.weapon_room.Interrior,
      data.weapon_room.Exterrior,
      WeaponRoom
    ),
    staircase = GetBaseObject(
      data.staircase.Interrior,
      data.staircase.Exterrior,
      StairCase
    ),
    dungeon_tower = GetBaseObject(
      data.dungeon_tower.Interrior,
      data.dungeon_tower.Exterrior,
      DungeonTower
    ),
    prison = GetBaseObject(
      data.prison.Interrior,
      data.prison.Exterrior,
      Dungeon
    ),
    bedroom = GetBaseObject(
      data.bedroom.Interrior,
      data.bedroom.Exterrior,
      BedRoom
    ),
    throne_room = GetBaseObject(
      data.throne_room.Interrior,
      data.throne_room.Exterrior,
      ThroneRoom
    ),
    bridge_room = GetBaseObject(
      data.bridge_room.Interrior,
      data.bridge_room.Exterrior,
      DrawBridgeRoom
    ),
    battlement = GetBaseObject(
      data.battlement.Interrior,
      data.battlement.Exterrior,
      Battlement
    )
  }
end

DoorSets = {
  WeaponRoom = {
    SouthWest = {"Door_5"},
    SouthEast = {"Door_4"},
    NorthEast = {"Door_25", "Door_27"},
    Tower = {"Door_25", "Door_26"}
  },
  Staircase = {
    Top = {},
    Bottom = {}
  },
  DungeonTower = {
    Rampart = {},
    Prison = {"Door_21", "Door_20"}
  },
  Prison = {
    TheOnlyOne = {"Door_20", "Door_21"}
  },
  Bedroom = {
    Ivy = {"Door_22"},
    Rampart = {"Door_23", "Door_24"}
  },
  ThroneRoom = {
    SouthEast = {"Door_0"},
    NorthWest = {}
  },
  BridgeRoom = {
    Rampart = {},
    Tower = {"Door_52", "Door_53"}
  },
  Battlement = {
    Top = {"Door_37", "Door_36"},
    SouthWest = {"Door_6"},
    Garden = {"Door_36", "Door_38"}
  }
}
---@type {[string]: InterriorExterriorData}
local spaces_data = {
  weapon_room = {
    Interrior = {"ThroneRoomInnerZone_28", "WeaponRoomInnerZone_29"},
    Exterrior = {
      {
        Zone = "WeaponRoomSouthZone_24",
        Doors = DoorSets.WeaponRoom.SouthEast
      },
      {
        Zone = "WeaponRoomEastZone_26",
        Doors = DoorSets.WeaponRoom.NorthEast
      },
      {
        Zone = "WeaponRoomWestZone_25",
        Doors = DoorSets.WeaponRoom.SouthWest
      },
      {
        Zone = "WeaponRoomTowerZone_27",
        Doors = DoorSets.WeaponRoom.Tower
      }
    }
  },
  staircase = {
    Interrior = {"StaircaseInnerZone_22", "StaircaseInnerZone_23"},
    Exterrior = {
      {
        Zone = "StaircaseBottomZone_21",
        Doors = DoorSets.Staircase.Bottom
      },
      {
        Zone = "StaircaseTopZone_20",
        Doors = DoorSets.Staircase.Top
      },
    }
  },
  dungeon_tower = {
    Interrior = {
      "DungeonInnerZone_12", "DungeonInnerZone_32", "DungeonInnerZone_33", 
      "DungeonInnerZone_34", "DungeonInnerZone_35", "DungeonInnerZone_36"
    },
    Exterrior = {
      {
        Zone = "DungeonRampartZone_16",
        Doors = DoorSets.DungeonTower.Rampart
      },
      {
        Zone = "PrisonInnerZone_13",
        Doors = DoorSets.DungeonTower.Prison
      }
    }
  },
  prison = {
    Interrior = {"PrisonInnerZone_13", "PrisonInnerZone_14", "PrisonInnerZone_15"},
    Exterrior = {
      {
        Zone = "DungeonInnerZone_12",
        Doors = DoorSets.Prison.TheOnlyOne
      }
    }
  },
  bedroom = {
    Interrior = {"BedroomInnerZone_4"},
    Exterrior = {
      {
        Zone = "BedroomBalconyZone_2",
        Doors = DoorSets.Bedroom.Ivy
      },
      {
        Zone = "BedroomRampartZone_3",
        Doors = DoorSets.Bedroom.Rampart
      }
    }
  },
  throne_room = {
    Interrior = {
      "ThroneRoomInnerZone_19", "ThroneRoomInnerZone_30", "ThroneRoomInnerZone_31"
    },
    Exterrior = {
      {
        Zone = "ThroneRoomNorthZone_18",
        Doors = DoorSets.ThroneRoom.NorthWest
      },
      {
        Zone = "ThroneRoomSouthZone_17",
        Doors = DoorSets.ThroneRoom.SouthEast
      }
    }
  },
  bridge_room = {
    Interrior = {"DrawbridgeInnerZone_11"},
    Exterrior = {
      {
        Zone = "DrawBridgeRampartZone_10",
        Doors = DoorSets.BridgeRoom.Rampart
      },
      {
        Zone = "DrawBridgeTowerZone_9",
        Doors = DoorSets.BridgeRoom.Tower
      }
    }
  },
  battlement = {
    Interrior = {"BattlementInnerZone_8"},
    Exterrior = {
      {
        Zone = "BattlementTopZone_5",
        Doors = DoorSets.Battlement.Top
      },
      {
        Zone = "BattlementRampartZone_6",
        Doors = DoorSets.Battlement.SouthWest
      },
      {
        Zone = "BattlementGardenZone_7",
        Doors = DoorSets.Battlement.Garden
      }
    }
  }
}

---@param interriorExterriorDefinitions {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
InitLincolnSeemless = function (interriorExterriorDefinitions)
  InitializeLincoln()
  HiddenSpaces = CreateInterriors(interriorExterriorDefinitions)
  InitSeemless(HiddenSpaces)
  table.insert(HiddenSpaces.throne_room.OnRevealFuncs, RevealStaircase)
end

RevealWeaponRoom = function()
  HiddenSpaces.weapon_room:Reveal({})
end

RevealDungeonTower = function()
  HiddenSpaces.dungeon_tower:Reveal({})
end

RevealBedRoom = function()
  HiddenSpaces.bedroom:Reveal({})
end

RevealStaircase = function()
  HiddenSpaces.staircase:Reveal({})
end

RevealThroneRoom = function()
  HiddenSpaces.throne_room:Reveal({})
end

RevealBridgeRoom = function()
  HiddenSpaces.bridge_room:Reveal({})
end

RevealBattlement = function()
  HiddenSpaces.battlement:Reveal({})
end

RevealPrison = function()
  HiddenSpaces.prison:Reveal({})
end

local DooredRevealWeaponRoom = function(doors)
  HiddenSpaces.weapon_room:Reveal(doors)
end

local DooredRevealDungeonTower = function(doors)
  HiddenSpaces.dungeon_tower:Reveal(doors)
end

local DooredRevealBedRoom = function(doors)
  HiddenSpaces.bedroom:Reveal(doors)
end

local DooredRevealStaircase = function(doors)
  HiddenSpaces.staircase:Reveal(doors)
end

local DooredRevealThroneRoom = function(doors)
  HiddenSpaces.throne_room:Reveal(doors)
end

local DooredRevealBridgeRoom = function(doors)
  HiddenSpaces.bridge_room:Reveal(doors)
end

local DooredRevealBattlement = function(doors)
  HiddenSpaces.battlement:Reveal(doors)
end

local DooredRevealPrison = function(doors)
  HiddenSpaces.prison:Reveal(doors)
end

--Zones
BridgeRoomRevealRampart = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBridgeRoom(DoorSets.BridgeRoom.Rampart)
    end
  end
}
BridgeRoomRevealTower = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBridgeRoom(DoorSets.BridgeRoom.Tower)
    end
  end
}


PrisonReveal = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealPrison(DoorSets.Prison.TheOnlyOne)
    end
  end
}


DungeonTowerRevealRampart = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealDungeonTower(DoorSets.DungeonTower.Rampart)
    end
  end
}
DungeonTowerRevealPrison = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealDungeonTower(DoorSets.DungeonTower.Prison)
    end
  end
}


BattlementRevealTop = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBattlement(DoorSets.Battlement.Top)
    end
  end
}
BattlementRevealSouthWest = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBattlement(DoorSets.Battlement.SouthWest)
    end
  end
}
BattlementRevealGarden = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBattlement(DoorSets.Battlement.Garden)
    end
  end
}


ThroneRoomRevealNorthWest = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealThroneRoom(DoorSets.ThroneRoom.NorthWest)
    end
  end
}
ThroneRoomRevealSouthEast = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealThroneRoom(DoorSets.ThroneRoom.SouthEast)
    end
  end
}


WeaponRoomRevealSouthEast = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealWeaponRoom(DoorSets.WeaponRoom.SouthEast)
    end
  end
}
WeaponRoomRevealSouthWest = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealWeaponRoom(DoorSets.WeaponRoom.SouthWest)
    end
  end
}
WeaponRoomRevealNorthEast = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealWeaponRoom(DoorSets.WeaponRoom.NorthEast)
    end
  end
}
WeaponRoomRevealTower = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealWeaponRoom(DoorSets.WeaponRoom.Tower)
    end
  end
}


BedroomRevealIvy = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBedRoom(DoorSets.Bedroom.Ivy)
    end
  end
}
BedroomRevealRampart = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealBedRoom(DoorSets.Bedroom.Rampart)
    end
  end
}


StaircaseRevealTop = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealStaircase(DoorSets.Staircase.Top)
    end
  end
}
StaircaseRevealBottom = {
  Enter = function(actor)
    if actor.is_hero then
      DooredRevealStaircase(DoorSets.Staircase.Bottom)
    end
  end
}

InitH01 = function ()
  InitLincolnSeemless(spaces_data)
end

BridgeTreadwheel = {
  ActivatedBySword = function(actorSource)
    DrawBridgeRoom:ActivateDrawBridge(Locations["BridgeNoiseLoc_37"])
  end
}

