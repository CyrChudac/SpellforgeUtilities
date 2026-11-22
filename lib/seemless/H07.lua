-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_61"},
    Exterrior = {
      {
        Zone = "Node_60",
        Doors = DoorSets.Church.Garden
      },{
        Zone = "Node_36",
        Doors = DoorSets.Church.Main
      },{
        Zone = "Node_37",
        Doors = DoorSets.Church.Side
      }
    }
  },
  prison_north = {
    Interrior = {"Node_67", "Node_68"},
    Exterrior = {
      {
        Zone = "Node_38",
        Doors = DoorSets.NorthPrison.South
      },{
        Zone = "Node_39",
        Doors = DoorSets.NorthPrison.North
      },{
        Zone = "Node_65",
        Doors = DoorSets.NorthPrison.Roof
      }
    }
  },
  fallgate_room = {
    Interrior = {"Node_66"},
    Exterrior = {
      {
        Zone = "Node_42",
        Doors = DoorSets.FallGate.TheOnlyOne
      }
    },
  },
  prison_south = {
    Interrior = {"Node_72", "Node_73", "Node_74", "Node_75"},
    Exterrior = {
      {
        Zone = "Node_40",
        Doors = DoorSets.SouthPrison.Side
      },{
        Zone = "Node_63",
        Doors = DoorSets.SouthPrison.Roof
      },{
        Zone = "Node_64",
        Doors = DoorSets.SouthPrison.Main
      }
    }
  },
  castle_room = {
    Interrior = {"Node_69", "Node_70", "Node_71"},
    Exterrior = {
      {
        Zone = "Node_34",
        Doors = DoorSets.CastleRoom.Main
      },{
        Zone = "Node_62",
        Doors = DoorSets.CastleRoom.Tower
      },{
        Zone = "Node_35",
        Doors = DoorSets.CastleRoom.Side
      },{
        Zone = "Node_47",
        Doors = DoorSets.CastleRoom.Balcony
      }
    }
  }
}

InitH07 = function ()
  InitNottinghamSeemless(spaces_data)
end