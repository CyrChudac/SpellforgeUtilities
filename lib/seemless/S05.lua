-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  church = {
    Interrior = {"Node_53"},
    Exterrior = {
      {
        Zone = "Node_47",
        Doors = DoorSets.Church.Main
      },
    }
  },
  castle_main_hall = {
    Interrior = {"Node_54"},
    Exterrior = {
      {
        Zone = "Node_44",
        Doors = DoorSets.CastleHall.Main
      },{
        Zone = "Node_45",
        Doors = DoorSets.CastleHall.FromHallway
      },{
        Zone = "Node_56",
        Doors = DoorSets.CastleHall.TowerBot
      },{
        Zone = "Node_57",
        Doors = DoorSets.CastleHall.TowerTop
      },
    }
  },
  castle_hallway = {
    Interrior = {"Node_45", "Node_55"},
    Exterrior = {
      {
        Zone = "Node_46",
        Doors = DoorSets.CastleHallway.Rampart
      },
    }
  },
  fall_gate_room = {
    Interrior = {"Node_58"},
    Exterrior = {
      {
        Zone = "Node_43",
        Doors = DoorSets.FallgateRoom.TheOnlyOne
      },
    },
  },
}

InitS05 = function ()
  InitYorkSeemless(spaces_data)
end