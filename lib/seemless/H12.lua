-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_56"},
    Exterrior = {
      {
        Zone = "Node_50",
        Doors = DoorSets.Church.Garden
      },{
        Zone = "Node_34",
        Doors = DoorSets.Church.Main
      },{
        Zone = "Node_35",
        Doors = DoorSets.Church.Side
      }
    }
  },
  prison_north = {
    Interrior = {"Node_58", "Node_59"},
    Exterrior = {
      {
        Zone = "Node_36",
        Doors = DoorSets.NorthPrison.South
      },{
        Zone = "Node_37",
        Doors = DoorSets.NorthPrison.North
      },{
        Zone = "Node_51",
        Doors = DoorSets.NorthPrison.Roof
      }
    }
  },
  fallgate_room = {
    Interrior = {"Node_57"},
    Exterrior = {
      {
        Zone = "Node_39",
        Doors = DoorSets.FallGate.TheOnlyOne
      }
    },
  },
  prison_south = {
    Interrior = {"Node_60", "Node_61", "Node_62", "Node_63"},
    Exterrior = {
      {
        Zone = "Node_38",
        Doors = DoorSets.SouthPrison.Side
      },{
        Zone = "Node_53",
        Doors = DoorSets.SouthPrison.Roof
      },{
        Zone = "Node_52",
        Doors = DoorSets.SouthPrison.Main
      }
    }
  },
  castle_room = {
    Interrior = {"Node_41", "Node_64", "Node_65"},
    Exterrior = {
      {
        Zone = "Node_32",
        Doors = DoorSets.CastleRoom.Main
      },{
        Zone = "Node_55",
        Doors = DoorSets.CastleRoom.Tower
      },{
        Zone = "Node_33",
        Doors = DoorSets.CastleRoom.Side
      },{
        Zone = "Node_54",
        Doors = DoorSets.CastleRoom.Balcony
      }
    }
  }
}

InitH12 = function ()
  InitNottinghamSeemless(spaces_data)
end