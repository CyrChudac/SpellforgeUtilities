-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@return {[string]: HiddenSpace}
---@param data {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
local GetConcealedAreas = function (data)
  local result = {}

  return {
    south_bridge = GetBaseObject(
      data.south_bridge.Interrior,
      data.south_bridge.Exterrior,
      DrawBridgeRoomSouth
    ),
    east_tower = GetBaseObject(
      data.east_tower.Interrior,
      data.east_tower.Exterrior,
      TowersEast
    ),
    cell_tower = GetBaseObject(
      data.cell_tower.Interrior,
      data.cell_tower.Exterrior,
      CellTower
    ),
    prison = GetBaseObject(
      data.prison.Interrior,
      data.prison.Exterrior,
      Cell
    ),
    north_tower = GetBaseObject(
      data.north_tower.Interrior,
      data.north_tower.Exterrior,
      TowerNorth
    ),
    chimney_room = GetBaseObject(
      data.chimney_room.Interrior,
      data.chimney_room.Exterrior,
      ChimneyRoom
    ),
    bedroom = GetBaseObject(
      data.bedroom.Interrior,
      data.bedroom.Exterrior,
      BedRoom
    ),
    hallway = GetBaseObject(
      data.hallway.Interrior,
      data.hallway.Exterrior,
      Hallway
    )
  }
end

DoorSets = {
  SouthBridgeRoom = {
    East = {"Door_10", "Door_11"},
    West = {"Door_11", "Door_12"},
    Any = {"Door_10", "Door_11", "Door_12"}
  },
  EastTower = {
    Stairs = {},
    EastBottom = {}
  },
  CellTower = {
    Outer = {},
    Cell = {"Door_55"}
  },
  Prison = {
    TheOnlyOne = {"Door_55"}
  },
  NorthTower = {
    TheOnlyOne = {}
  },
  ChimneyRoom = {
    East = {},
    West = {},
    Balcony = {}
  },
  Bedroom = {
    TheOnlyOne = {} --has patch vert, don't know how to incorporate it
  },
  Hallway = {
    Courtyard = {}, -- another patch vert
    Balcony = {},
    Bridge = {}
  }
}

---@param interriorExterriorDefinitions {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
InitLeicesterSeemless = function (interriorExterriorDefinitions)
  InitializeLeicester()
  HiddenSpaces = GetConcealedAreas(interriorExterriorDefinitions)
  InitSeemless(HiddenSpaces)
end

RevealDrawBridgeRoomSouth = function()
  HiddenSpaces.south_bridge:Reveal({})
end

RevealTowersEast = function()
  HiddenSpaces.east_tower:Reveal({})
end

RevealCellTower = function ()
  HiddenSpaces.cell_tower:Reveal({})
end

RevealTowerNorth = function ()
  HiddenSpaces.north_tower:Reveal({})
end

RevealChimneyRoom = function ()
  HiddenSpaces.chimney_room:Reveal({})
end

RevealHallway = function ()
  HiddenSpaces.hallway:Reveal({})
end

RevealBedroom = function ()
  HiddenSpaces.bedroom:Reveal({})
end

RevealPrison = function ()
  HiddenSpaces.prison:Reveal({})
end

local RevealDrawBridgeRoomSouthDoored = function(doors)
  HiddenSpaces.south_bridge:Reveal(doors)
end

local RevealTowersEastDoored = function(doors)
  HiddenSpaces.east_tower:Reveal(doors)
end

local RevealCellTowerDoored = function (doors)
  HiddenSpaces.cell_tower:Reveal(doors)
end

local RevealTowerNorthDoored = function (doors)
  HiddenSpaces.north_tower:Reveal(doors)
end

local RevealChimneyRoomDoored = function (doors)
  HiddenSpaces.chimney_room:Reveal(doors)
end

local RevealHallwayDoored = function (doors)
  HiddenSpaces.hallway:Reveal(doors)
end

local RevealBedroomDoored = function (doors)
  HiddenSpaces.bedroom:Reveal(doors)
end

local RevealPrisonDoored = function (doors)
  HiddenSpaces.prison:Reveal(doors)
end

--Zones
SouthBridgeRevealEast = {
  Enter = function(actor)
    if actor.is_hero then
      RevealDrawBridgeRoomSouthDoored(DoorSets.SouthBridgeRoom.East)
    end
  end
}
SouthBridgeRevealWest = {
  Enter = function(actor)
    if actor.is_hero then
      RevealDrawBridgeRoomSouthDoored(DoorSets.SouthBridgeRoom.West)
    end
  end
}
SouthBridgeRevealAny = {
  Enter = function(actor)
    if actor.is_hero then
      RevealDrawBridgeRoomSouthDoored(DoorSets.SouthBridgeRoom.Any)
    end
  end
}


EastTowerRevealStairsTop = {
  Enter = function(actor)
    if actor.is_hero then
      RevealTowersEastDoored(DoorSets.EastTower.Stairs)
    end
  end
}
EastTowerRevealStairs = {
  Enter = function(actor)
    if actor.is_hero then
      RevealTowersEastDoored(DoorSets.EastTower.Stairs)
    end
  end
}
EastTowerRevealInnerBridge = {
  Enter = function(actor)
    if actor.is_hero then
      RevealTowersEastDoored(DoorSets.EastTower.EastBottom)
    end
  end
}
EastTowerRevealOuterBridge = {
  Enter = function(actor)
    if actor.is_hero then
      RevealTowersEastDoored(DoorSets.EastTower.EastBottom)
    end
  end
}


HallwayRevealCourtyard = {
  Enter = function(actor)
    if actor.is_hero then
      RevealHallwayDoored(DoorSets.Hallway.Courtyard)
    end
  end
}
HallwayRevealWest = {
  Enter = function(actor)
    if actor.is_hero then
      RevealHallwayDoored(DoorSets.Hallway.Bridge)
    end
  end
}


CellTowerRevealOuter = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCellTowerDoored(DoorSets.CellTower.Outer)
    end
  end
}
CellTowerRevealCell = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCellTowerDoored(DoorSets.CellTower.Cell)
    end
  end
}


PrisonReveal = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonDoored(DoorSets.Prison.TheOnlyOne)
    end
  end
}


BedroomReveal = {
  Enter = function(actor)
    if actor.is_hero then
      RevealBedroomDoored(DoorSets.Bedroom.TheOnlyOne)
    end
  end
}


NorthTowerReveal = {
  Enter = function(actor)
    if actor.is_hero then
      RevealTowerNorthDoored(DoorSets.NorthTower.TheOnlyOne)
    end
  end
}


ChimneyRoomRevealWest = {
  Enter = function(actor)
    if actor.is_hero then
      RevealChimneyRoomDoored(DoorSets.ChimneyRoom.West)
    end
  end
}
ChimneyRoomRevealEast = {
  Enter = function(actor)
    if actor.is_hero then
      RevealChimneyRoomDoored(DoorSets.ChimneyRoom.East)
    end
  end
}