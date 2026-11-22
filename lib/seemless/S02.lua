-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  south_bridge = {
    Interrior = {"Node_51"},
    Exterrior = {
      {
        Zone = "Node_34",
        Doors = DoorSets.SouthBridgeRoom.West
      },
      {
        Zone = "Node_35",
        Doors = DoorSets.SouthBridgeRoom.East
      },
      {
        Zone = "Node_36",
        Doors = DoorSets.SouthBridgeRoom.Any
      },
    }
  },
  east_tower = {
    Interrior = {"Node_69", "Node_70", "Node_71", "Node_75", "Node_72", "Node_73", "Node_74"},
    Exterrior = {
      {
        Zone = "Node_30",
        Doors = DoorSets.EastTower.EastBottom
      },
      {
        Zone = "Node_31",
        Doors = DoorSets.EastTower.EastBottom
      },
      {
        Zone = "Node_32",
        Doors = DoorSets.EastTower.Stairs
      },
      {
        Zone = "Node_33",
        Doors = DoorSets.EastTower.Stairs
      },
      {
        Zone = "Node_64",
        Doors = DoorSets.EastTower.EastBottom
      },
    }
  },
  cell_tower = {
    Interrior = {"Node_65", "Node_66", "Node_67"},
    Exterrior = {
      {
        Zone = "Node_29",
        Doors = DoorSets.CellTower.Outer
      },
      {
        Zone = "Node_68",
        Doors = DoorSets.CellTower.prison
      }
    }
  },
  prison = {
    Interrior = {"Node_39", "Node_68"},
    Exterrior = {
      {
        Zone = "Node_65",
        Doors = DoorSets.Prison.TheOnlyOne
      },
      {
        Zone = "Node_66",
        Doors = DoorSets.Prison.TheOnlyOne
      },
      {
        Zone = "Node_67",
        Doors = DoorSets.Prison.TheOnlyOne
      }
    }
  },
  north_tower = {
    Interrior = {"Node_54", "Node_55"},
    Exterrior = {
      {
        Zone = "Node_27",
        Doors = DoorSets.NorthTower.TheOnlyOne
      }
    }
  },
  chimney_room = {
    Interrior = {"Node_57"},
    Exterrior = {
      {
        Zone = "Node_26",
        Doors = DoorSets.ChimneyRoom.East
      },
      {
        Zone = "Node_56",
        Doors = DoorSets.ChimneyRoom.West
      },
      {
        Zone = "Node_63",
        Doors = DoorSets.ChimneyRoom.Balcony
      }
    }
  },
  bedroom = {
    Interrior = {"Node_53"},
    Exterrior = {
      {
        Zone = "Node_52",
        Doors = DoorSets.Bedroom.TheOnlyOne
      }
    }
  },
  hallway = {
    Interrior = {"Node_58", "Node_59", "Node_60"},
    Exterrior = {
      {
        Zone = "Node_28",
        Doors = DoorSets.Hallway.Courtyard
      },
      {
        Zone = "Node_61",
        Doors = DoorSets.Hallway.Bridge
      },
      {
        Zone = "Node_62",
        Doors = DoorSets.Hallway.Balcony
      }
    }
  }
}

InitS02 = function ()
  InitLeicesterSeemless(spaces_data)
end