-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_27"},
    Exterrior = {
      {
        Zone = "Node_15",
        Doors = DoorSets.Church.Main
      },
    }
  },
  castle_main_hall = {
    Interrior = {"Node_18", "Node_16", "Node_17"},
    Exterrior = {
      {
        Zone = "Node_12",
        Doors = DoorSets.CastleHall.Main
      },{
        Zone = "Node_13",
        Doors = DoorSets.CastleHall.FromHallway
      },{
        Zone = "Node_24",
        Doors = DoorSets.CastleHall.TowerBot
      },{
        Zone = "Node_23",
        Doors = DoorSets.CastleHall.TowerTop
      },
    }
  },
  castle_hallway = {
    Interrior = {"Node_13", "Node_25"},
    Exterrior = {
      {
        Zone = "Node_14",
        Doors = DoorSets.CastleHallway.Rampart
      },
    }
  },
  fall_gate_room = {
    Interrior = {"Node_26"},
    Exterrior = {
      {
        Zone = "Node_11",
        Doors = DoorSets.FallgateRoom.TheOnlyOne
      },
    },
  },
}

InitH10 = function ()
  InitYorkSeemless(spaces_data)
end