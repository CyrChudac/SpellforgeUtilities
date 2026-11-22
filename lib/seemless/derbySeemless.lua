-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@return {[string]: HiddenSpace}
---@param data {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
local CreateInterriors = function (data)
  return {
    main_hall = GetBaseObject(
      data.main_hall.Interrior,
      data.main_hall.Exterrior,
      MainHall
    ),
    dining_hall = GetBaseObject(
      data.dining_hall.Interrior,
      data.dining_hall.Exterrior,
      DiningHall
    ),
    prison = GetBaseObject(
      data.prison.Interrior,
      data.prison.Exterrior,
      PrisonRoom
    ),
    bridge_room = GetBaseObject(
      data.bridge_room.Interrior,
      data.bridge_room.Exterrior,
      DrawBridgeRoom
    )
  }
end

DoorSets = {
  MainHall = {
    Main = {"Door_23", "Door_22"},
    East = {"Door_22", "Door_21"},
    North = {"Door_29", "Door_30"}
  },
  DiningHall = {
    Main = {"Door_24"},
    Top = {"Door_27"},
    Balcony = {}
  },
  Prison = {
    Top = {"Door_14", "Door_15"},
    Bottom = {"Door_13", "Door_15"}
  },
  BridgeRoom = {
    East = {"Door_8"},
    West = {"Door_9"},
    Top = {}
  }
}

---@param interriorExterriorDefinitions {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
InitDerbySeemless = function (interriorExterriorDefinitions)
  InitializeDerby()
  HiddenSpaces = CreateInterriors(interriorExterriorDefinitions)
  InitSeemless(HiddenSpaces)
end

RevealMainHall = function()
  HiddenSpaces.main_hall:Reveal({})
end

RevealDiningHall = function()
  HiddenSpaces.dining_hall:Reveal({})
end

RevealPrison = function()
  HiddenSpaces.prison:Reveal({})
end

RevealBridgeRoom = function()
  HiddenSpaces.bridge_room:Reveal({})
end


local RevealMainHallDoored = function(doors)
  HiddenSpaces.main_hall:Reveal(doors)
end

local RevealDiningHallDoored = function(doors)
  HiddenSpaces.dining_hall:Reveal(doors)
end

local RevealPrisonDoored = function(doors)
  HiddenSpaces.prison:Reveal(doors)
end

local RevealBridgeRoomDoored = function(doors)
  HiddenSpaces.bridge_room:Reveal(doors)
end

--Zones
DiningHallRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealDiningHallDoored(DoorSets.DiningHall.Main)
    end
  end
}
DiningHallRevealTop = {
  Enter = function(actor)
    if actor.is_hero then
      RevealDiningHallDoored(DoorSets.DiningHall.Top)
    end
  end
}


MainHallRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealMainHallDoored(DoorSets.MainHall.Main)
    end
  end
}
MainHallRevealEast = {
  Enter = function(actor)
    if actor.is_hero then
      RevealMainHallDoored(DoorSets.MainHall.East)
    end
  end
}
MainHallRevealNorthImmediate = {
  Enter = function(actor)
    if actor.is_hero then
      RevealMainHallDoored(DoorSets.MainHall.North)
    end
  end
}
MainHallRevealNorthFar = {
  Enter = function(actor)
    if actor.is_hero then
      RevealMainHallDoored(DoorSets.MainHall.North)
    end
  end
}


PrisonRevealTop = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonDoored(DoorSets.Prison.Top)
    end
  end
}
PrisonRevealBottom = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonDoored(DoorSets.Prison.Bottom)
    end
  end
}


BridgeRevealEast = {
  Enter = function(actor)
    if actor.is_hero then
      RevealBridgeRoomDoored(DoorSets.BridgeRoom.East)
    end
  end
}
BridgeRevealWest = {
  Enter = function(actor)
    if actor.is_hero then
      RevealBridgeRoomDoored(DoorSets.BridgeRoom.West)
    end
  end
}
BridgeRevealTop = {
  Enter = function(actor)
    if actor.is_hero then
      RevealBridgeRoomDoored(DoorSets.BridgeRoom.Top)
    end
  end
}