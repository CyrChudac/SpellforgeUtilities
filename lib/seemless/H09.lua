-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_33"},
    Exterrior = {
      {
        Zone = "Node_30",
        Doors = DoorSets.Church.Garden
      },{
        Zone = "Node_9",
        Doors = DoorSets.Church.Main
      },{
        Zone = "Node_10",
        Doors = DoorSets.Church.Side
      }
    }
  },
  prison_north = {
    Interrior = {"Node_16", "Node_35", "Node_36"},
    Exterrior = {
      {
        Zone = "Node_11",
        Doors = DoorSets.NorthPrison.South
      },{
        Zone = "Node_12",
        Doors = DoorSets.NorthPrison.North
      },{
        Zone = "Node_29",
        Doors = DoorSets.NorthPrison.Roof
      }
    }
  },
  fallgate_room = {
    Interrior = {"Node_34"},
    Exterrior = {
      {
        Zone = "Node_14",
        Doors = DoorSets.FallGate.TheOnlyOne
      }
    },
  },
  prison_south = {
    Interrior = {"Node_15", "Node_37", "Node_38", "Node_39", "Node_40"},
    Exterrior = {
      {
        Zone = "Node_13",
        Doors = DoorSets.SouthPrison.Side
      },{
        Zone = "Node_28",
        Doors = DoorSets.SouthPrison.Roof
      },{
        Zone = "Node_27",
        Doors = DoorSets.SouthPrison.Main
      }
    }
  },
  castle_room = {
    Interrior = {"Node_41", "Node_42", "Node_43"},
    Exterrior = {
      {
        Zone = "Node_7",
        Doors = DoorSets.CastleRoom.Main
      },{
        Zone = "Node_32",
        Doors = DoorSets.CastleRoom.Tower
      },{
        Zone = "Node_8",
        Doors = DoorSets.CastleRoom.Side
      },{
        Zone = "Node_31",
        Doors = DoorSets.CastleRoom.Balcony
      }
    }
  }
}

InitH09 = function ()
  InitNottinghamSeemless(spaces_data)
end