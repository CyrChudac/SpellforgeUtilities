-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@type {[string]: InterriorExterriorData}
local spaces_data = {
  weapon_room = {
    Interrior = {"Node_31"},
    Exterrior = {
      {
        Zone = "Node_22",
        Doors = DoorSets.WeaponRoom.SouthEast
      },
      {
        Zone = "Node_28",
        Doors = DoorSets.WeaponRoom.NorthEast
      },
      {
        Zone = "Node_29",
        Doors = DoorSets.WeaponRoom.SouthWest
      },
      {
        Zone = "Node_30",
        Doors = DoorSets.WeaponRoom.Tower
      }
    }
   },
  staircase = {
    Interrior = {"Node_46", "Node_47"},
    Exterrior = {
      {
        Zone = "Node_21",
        Doors = DoorSets.ThroneRoom.NorthWest
      },
      {
        Zone = "Node_24",
        Doors = DoorSets.Staircase.Bottom
      },
      {
        Zone = "Node_23",
        Doors = DoorSets.Staircase.Top
      },
      {
        Zone = "Node_32",
        Doors = DoorSets.ThroneRoom.SouthEast
      }
    }
  },
  dungeon_tower = {
    Interrior = {"Node_14", "Node_40", "Node_41", "Node_42", "Node_43", "Node_44"},
    Exterrior = {
      {
        Zone = "Node_15",
        Doors = DoorSets.DungeonTower.Rampart
      },
      {
        Zone = "Node_35",
        Doors = DoorSets.DungeonTower.Prison
      }
    }
  },
  prison = {
    Interrior = {"Node_26", "Node_35", "Node_36"},
    Exterrior = {
      {
        Zone = "Node_14",
        Doors = DoorSets.Prison.TheOnlyOne
      }
    }
  },
  bedroom = {
    Interrior = {"Node_37"},
    Exterrior = {
      {
        Zone = "Node_19",
        Doors = DoorSets.Bedroom.Ivy
      },
      {
        Zone = "Node_20",
        Doors = DoorSets.Bedroom.Rampart
      }
    }
  },
  throne_room = {
    Interrior = {"Node_45"},
    Exterrior = {
      {
        Zone = "Node_21",
        Doors = DoorSets.ThroneRoom.NorthWest
      },
      {
        Zone = "Node_32",
        Doors = DoorSets.ThroneRoom.SouthEast
      }
    }
  },
  bridge_room = {
    Interrior = {"Node_38"},
    Exterrior = {
      {
        Zone = "Node_16",
        Doors = DoorSets.BridgeRoom.Rampart
      },
      {
        Zone = "Node_33",
        Doors = DoorSets.BridgeRoom.Tower
      }
    }
  },
  battlement = {
    Interrior = {"Node_39"},
    Exterrior = {
      {
        Zone = "Node_17",
        Doors = DoorSets.Battlement.Top
      },
      {
        Zone = "Node_18",
        Doors = DoorSets.Battlement.SouthWest
      },
      {
        Zone = "Node_34",
        Doors = DoorSets.Battlement.Garden
      }
    }
  }
}

InitH05 = function ()
  InitLincolnSeemless(spaces_data)
end

--Targets
mecanisme_pont_levis_800001c7 = {
  ActivatedBySword = function (actorSource)
    if not DrawBridgeRoom.drawBridge.applied then
      DrawBridgeRoom:ActivateDrawBridge(Locations["Node_13"])
    end
  end
}