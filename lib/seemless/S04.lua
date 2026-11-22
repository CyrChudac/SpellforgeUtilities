-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  main_hall = {
    Interrior = {"Node_27", "Node_31"},
    Exterrior = {
      {
        Zone = "Node_19",
        Doors = DoorSets.MainHall.East
      },
      {
        Zone = "Node_20",
        Doors = DoorSets.MainHall.Main
      },
      {
        Zone = "Node_21", --only here because it was a zone in the original level, reusing it
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_33",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_34",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_42",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_43",
        Doors = DoorSets.MainHall.North
      },
      {
        Zone = "Node_44",
        Doors = DoorSets.MainHall.North
      },
    }
  },
  dining_hall = {
    Interrior = {"Node_40"},
    Exterrior = {
      {
        Zone = "Node_18",
        Doors = DoorSets.DiningHall.Main
      },
      {
        Zone = "Node_32",
        Doors = DoorSets.DiningHall.Top
      },
      {
        Zone = "Node_41",
        Doors = DoorSets.DiningHall.Balcony
      }
    }
  },
  prison = {
    Interrior = {"Node_39"},
    Exterrior = {
      {
        Zone = "Node_22",
        Doors = DoorSets.Prison.Bottom
      },
      {
        Zone = "Node_23",
        Doors = DoorSets.Prison.Top
      }
    }
  },
  bridge_room = {
    Interrior = {"Node_36", "Node_37"},
    Exterrior = {
      {
        Zone = "Node_24",
        Doors = DoorSets.BridgeRoom.East
      },
      {
        Zone = "Node_25",
        Doors = DoorSets.BridgeRoom.West
      },
      {
        Zone = "Node_35",
        Doors = DoorSets.BridgeRoom.Top
      },
      {
        Zone = "Node_38",
        Doors = DoorSets.BridgeRoom.Top
      }
    }
  }
}

InitS04 = function ()
  InitDerbySeemless(spaces_data)
end