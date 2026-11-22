-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_18"},
    Exterrior = {
      {
        Zone = "Node_3",
        Doors = DoorSets.Church.Main
      },
      {
        Zone = "Node_4",
        Doors = DoorSets.Church.Side
      },
      {
        Zone = "Node_17",
        Doors = DoorSets.Church.Garden
      }
    }
  },
  prison_north = {
    Interrior = {"Node_25", "Node_26"},
    Exterrior = {
      {
        Zone = "Node_5",
        Doors = DoorSets.NorthPrison.South
      },
      {
        Zone = "Node_6",
        Doors = DoorSets.NorthPrison.North
      },
      {
        Zone = "Node_24",
        Doors = DoorSets.NorthPrison.Roof
      }
    }
  },
  fallgate_room = {
    Interrior = {"Node_10"},
    Exterrior = {
      {
        Zone = "Node_8",
        Doors = DoorSets.FallGate.TheOnlyOne
      }
    }
  },
  prison_south = {
    Interrior = {"Node_13", "Node_14", "Node_15", "Node_16"},
    Exterrior = {
      {
        Zone = "Node_7",
        Doors = DoorSets.SouthPrison.Side
      },
      {
        Zone = "Node_11",
        Doors = DoorSets.SouthPrison.Roof
      },
      {
        Zone = "Node_12",
        Doors = DoorSets.SouthPrison.Main
      }
    }
  },
  castle_room = {
    Interrior = {"Node_21", "Node_22", "Node_23"},
    Exterrior = {
      {
        Zone = "Node_1",
        Doors = DoorSets.CastleRoom.Main
      },
      {
        Zone = "Node_2",
        Doors = DoorSets.CastleRoom.Side
      },
      {
        Zone = "Node_19",
        Doors = DoorSets.CastleRoom.Tower
      },
      {
        Zone = "Node_20",
        Doors = DoorSets.CastleRoom.Balcony
      }
    }
  }
}

InitS01 = function ()
  InitNottinghamSeemless(spaces_data)
end