require("seemless.lincolnSeemless")

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  weapon_room = {
    Interrior = {"VisionNodeIn_19", "VisionNodeIn_20"},
    Exterrior = {
      {
        Zone = "VisionNode_1",
        Doors = DoorSets.WeaponRoom.SouthEast
      },
      {
        Zone = "VisionNode_2",
        Doors = DoorSets.WeaponRoom.NorthEast
      },
      {
        Zone = "VisionNode_4",
        Doors = DoorSets.WeaponRoom.SouthWest
      },
      {
        Zone = "VisionNode_3",
        Doors = DoorSets.WeaponRoom.Tower
      }
    }
   },
  staircase = {
    Interrior = {"VisionNodeIn_21", "VisionNodeIn_22"},
    Exterrior = {
      {
        Zone = "VisionNode_8",
        Doors = DoorSets.Staircase.Bottom
      },
      {
        Zone = "VisionNode_7",
        Doors = DoorSets.Staircase.Top
      },
    }
  },
  dungeon_tower = {
    Interrior = {"VisionNode_14", "VisionNodeIn_32", "VisionNodeIn_33", "VisionNodeIn_34", "VisionNodeIn_35", "VisionNodeIn_36"},
    Exterrior = {
      {
        Zone = "VisionNode_12",
        Doors = DoorSets.DungeonTower.Rampart
      },
      {
        Zone = "VisionNode_13",
        Doors = DoorSets.DungeonTower.Prison
      }
    }
  },
  prison = {
    Interrior = {"VisionNode_13", "VisionNodeIn_28", "VisionNodeIn_29"},
    Exterrior = {
      {
        Zone = "VisionNode_14",
        Doors = DoorSets.Prison.TheOnlyOne
      }
    }
  },
  bedroom = {
    Interrior = {"VisionNodeIn_30"},
    Exterrior = {
      {
        Zone = "VisionNode_15",
        Doors = DoorSets.Bedroom.Ivy
      },
      {
        Zone = "VisionNode_16",
        Doors = DoorSets.Bedroom.Rampart
      }
    }
  },
  throne_room = {
    Interrior = {"VisionNodeIn_23", "VisionNodeIn_24", "VisionNodeIn_25", "VisionNodeIn_26"},
    Exterrior = {
      {
        Zone = "VisionNode_5",
        Doors = DoorSets.ThroneRoom.NorthWest
      },
      {
        Zone = "VisionNode_6",
        Doors = DoorSets.ThroneRoom.SouthEast
      }
    }
  },
  bridge_room = {
    Interrior = {"VisionNodeIn_31"},
    Exterrior = {
      {
        Zone = "VisionNode_17",
        Doors = DoorSets.BridgeRoom.Rampart
      },
      {
        Zone = "VisionNode_18",
        Doors = DoorSets.BridgeRoom.Tower
      }
    }
  },
  battlement = {
    Interrior = {"VisionNodeIn_27"},
    Exterrior = {
      {
        Zone = "VisionNode_9",
        Doors = DoorSets.Battlement.Top
      },
      {
        Zone = "VisionNode_10",
        Doors = DoorSets.Battlement.SouthWest
      },
      {
        Zone = "VisionNode_11",
        Doors = DoorSets.Battlement.Garden
      }
    }
  }
}

InitH01 = function ()
  InitLincolnSeemless(spaces_data)
end

BridgeTreadwheel = {
  ActivatedBySword = function(actorSource)
    DrawBridgeRoom:ActivateDrawBridge(Locations["BridgeNoiseLoc_37"])
  end
}

