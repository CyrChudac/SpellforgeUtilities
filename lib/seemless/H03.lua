-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  main_hall = {
    Interrior = {"Node_25", "Node_30"},
    Exterrior = {
      {
        Zone = "Node_18",
        Doors = DoorSets.MainHall.East
      },
      {
        Zone = "Node_19",
        Doors = DoorSets.MainHall.Main
      },
      {
        Zone = "Node_20",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_34",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_35",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_36",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_37",
        Doors = DoorSets.MainHall.North
      },
    }
  },
  dining_hall = {
    Interrior = {"Node_31"},
    Exterrior = {
      {
        Zone = "Node_17",
        Doors = DoorSets.DiningHall.Main
      },
      {
        Zone = "Node_39",
        Doors = DoorSets.DiningHall.Top
      },
      {
        Zone = "Node_41",
        Doors = DoorSets.DiningHall.Balcony
      }
    }
  },
  prison = {
    Interrior = {"Node_27"},
    Exterrior = {
      {
        Zone = "Node_21",
        Doors = DoorSets.Prison.Bottom
      },
      {
        Zone = "Node_22",
        Doors = DoorSets.Prison.Top
      }
    }
  },
  bridge_room = {
    Interrior = {"Node_32", "Node_33"},
    Exterrior = {
      {
        Zone = "Node_23",
        Doors = DoorSets.BridgeRoom.East
      },
      {
        Zone = "Node_24",
        Doors = DoorSets.BridgeRoom.West
      },
      {
        Zone = "Node_40",
        Doors = DoorSets.BridgeRoom.Top
      },
      {
        Zone = "Node_41",
        Doors = DoorSets.BridgeRoom.Top
      }
    }
  }
}

InitH03 = function ()
  InitDerbySeemless(spaces_data)
end