-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  south_bridge = {
    Interrior = {"Node_34"},
    Exterrior = {
      {
        Zone = "Node_24",
        Doors = DoorSets.SouthBridgeRoom.West
      },
      {
        Zone = "Node_25",
        Doors = DoorSets.SouthBridgeRoom.East
      },
      {
        Zone = "Node_26",
        Doors = DoorSets.SouthBridgeRoom.Any
      },
    }
  },
  east_tower = {
    Interrior = {"Node_47", "Node_48", "Node_49", "Node_50", "Node_51", "Node_52", "Node_53"},
    Exterrior = {
      {
        Zone = "Node_21",
        Doors = DoorSets.EastTower.EastBottom
      },
      {
        Zone = "Node_20",
        Doors = DoorSets.EastTower.EastBottom
      },
      {
        Zone = "Node_22",
        Doors = DoorSets.EastTower.Stairs
      },
      {
        Zone = "Node_23",
        Doors = DoorSets.EastTower.Stairs
      },
      {
        Zone = "Node_30",
        Doors = DoorSets.EastTower.EastBottom
      },
    }
  },
  cell_tower = {
    Interrior = {" Node_37", "Node_38", "Node_39"},
    Exterrior = {
      {
        Zone = "Node_19",
        Doors = DoorSets.CellTower.Outer
      },
      {
        Zone = "Node_31",
        Doors = DoorSets.CellTower.prison
      }
    }
  },
  prison = {
    Interrior = {"Node_31", "Node_40"},
    Exterrior = {
      {
        Zone = " Node_37",
        Doors = DoorSets.Prison.TheOnlyOne
      },
      {
        Zone = "Node_38",
        Doors = DoorSets.Prison.TheOnlyOne
      },
      {
        Zone = "Node_39",
        Doors = DoorSets.Prison.TheOnlyOne
      }
    }
  },
  north_tower = {
    Interrior = {"Node_45", "Node_46"},
    Exterrior = {
      {
        Zone = "Node_16",
        Doors = DoorSets.NorthTower.TheOnlyOne
      }
    }
  },
  chimney_room = {
    Interrior = {"Node_35"},
    Exterrior = {
      {
        Zone = "Node_13",
        Doors = DoorSets.ChimneyRoom.East
      },
      {
        Zone = "Node_14",
        Doors = DoorSets.ChimneyRoom.West
      },
      {
        Zone = "Node_32",
        Doors = DoorSets.ChimneyRoom.Balcony
      }
    }
  },
  bedroom = {
    Interrior = {"Node_36"},
    Exterrior = {
      {
        Zone = "Node_15",
        Doors = DoorSets.Bedroom.TheOnlyOne
      }
    }
  },
  hallway = {
    Interrior = {"Node_42", "Node_43", "Node_44"},
    Exterrior = {
      {
        Zone = "Node_17",
        Doors = DoorSets.Hallway.Courtyard
      },
      {
        Zone = "Node_18",
        Doors = DoorSets.Hallway.Bridge
      },
      {
        Zone = "Node_33",
        Doors = DoorSets.Hallway.Balcony
      }
    }
  }
}

InitH04 = function ()
  InitLeicesterSeemless(spaces_data)
end