-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_14", "Node_16"},
    Exterrior = {
      {
        Zone = "Node_21",
        Doors = DoorSets.Church.Garden
      },{
        Zone = "Node_22",
        Doors = DoorSets.Church.Main
      },{
        Zone = "Node_23",
        Doors = DoorSets.Church.Side
      }
    }
  },
  prison_north = {
    Interrior = {"Node_25", "Node_26"},
    Exterrior = {
      {
        Zone = "Node_9",
        Doors = DoorSets.NorthPrison.South
      },{
        Zone = "Node_10",
        Doors = DoorSets.NorthPrison.North
      },{
        Zone = "Node_24",
        Doors = DoorSets.NorthPrison.Roof
      }
    }
  },
  fallgate_room = {
    Interrior = {"Node_27"},
    Exterrior = {
      {
        Zone = "Node_12",
        Doors = DoorSets.FallGate.TheOnlyOne
      }
    },
  },
  prison_south = {
    Interrior = {"Node_29", "Node_30", "Node_31", "Node_32"},
    Exterrior = {
      {
        Zone = "Node_11",
        Doors = DoorSets.SouthPrison.Side
      },{
        Zone = "Node_28",
        Doors = DoorSets.SouthPrison.Roof
      },{
        Zone = "Node_40",
        Doors = DoorSets.SouthPrison.Main
      }
    }
  },
  castle_room = {
    Interrior = {"Node_35", "Node_36", "Node_39"},
    Exterrior = {
      {
        Zone = "Node_33",
        Doors = DoorSets.CastleRoom.Main
      },{
        Zone = "Node_34",
        Doors = DoorSets.CastleRoom.Tower
      },{
        Zone = "Node_37",
        Doors = DoorSets.CastleRoom.Side
      },{
        Zone = "Node_38",
        Doors = DoorSets.CastleRoom.Balcony
      }
    }
  }
}

InitH02 = function ()
  InitNottinghamSeemless(spaces_data)
end