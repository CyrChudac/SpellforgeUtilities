-- RHMOD MIGRATION: native-API rewrite (SOURCE REVIEW REQUIRED).
-- FUNCTIONAL CHANGE WARNING: original gameplay has NOT been verified in the new engine.
-- Every uncertainty and remaining old API call is logged in MIGRATION_AUDIT.md.

---@return {[string]: HiddenSpace}
---@param data {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
local CreateInterriors = function (data)
  return {
    church = GetBaseObject(
      data.church.Interrior,
      data.church.Exterrior,
      Church
    ),
    prison_north = GetBaseObject(
      data.prison_north.Interrior,
      data.prison_north.Exterrior,
      PrisonNorth
    ),
    fallgate_room = GetBaseObject(
      data.fallgate_room.Interrior,
      data.fallgate_room.Exterrior,
      FallGateRoom
    ),
    prison_south = GetBaseObject(
      data.prison_south.Interrior,
      data.prison_south.Exterrior,
      PrisonSouth
    ),
    castle_room = GetBaseObject(
      data.castle_room.Interrior,
      data.castle_room.Exterrior,
      Chateau
    )
  }
end

DoorSets = {
  Church = {
    Main = {"Door_55"},
    Side = {"Door_54"},
    Garden = {}
  },
  NorthPrison = {
    North = {"Door_74", "Door_76"},
    South = {"Door_59"},
    Roof = {"Door_74", "Door_75"}
  },
  FallGate = {
    TheOnlyOne = {}
  },
  CastleRoom = {
    Main = {"Door_87", "Door_88"},
    Tower = {"Door_87", "Door_89"},
    Side = {"Door_86"},
    Balcony = {}
  },
  SouthPrison = {
    Side = {"Door_81"},
    Main = {"Door_82"},
    Roof = {"Door_84", "Door_85"}
  }
}

---@param interriorExterriorDefinitions {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
InitNottinghamSeemless = function (interriorExterriorDefinitions)
  InitializeNottingham()
  HiddenSpaces = CreateInterriors(interriorExterriorDefinitions)
  InitSeemless(HiddenSpaces)
end

function RevealChurch()
  HiddenSpaces.church:Reveal({})
end

function RevealPrisonNorth()
  HiddenSpaces.prison_north:Reveal({})
end

function RevealCastleRoom()
  HiddenSpaces.castle_room:Reveal({})
end

function RevealPrisonSouth()
  HiddenSpaces.prison_south:Reveal({})
end

function RevealFallgateRoom()
  HiddenSpaces.fallgate_room:Reveal({})
end

local function RevealChurchDoored(doors)
  HiddenSpaces.church:Reveal(doors)
end

local function RevealPrisonNorthDoored(doors)
  HiddenSpaces.prison_north:Reveal(doors)
end

local function RevealCastleRoomDoored(doors)
  HiddenSpaces.castle_room:Reveal(doors)
end

local function RevealPrisonSouthDoored(doors)
  HiddenSpaces.prison_south:Reveal(doors)
end

local function RevealFallgateRoomDoored(doors)
  HiddenSpaces.fallgate_room:Reveal(doors)
end

ChurchRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealChurchDoored(DoorSets.Church.Main)
    end
  end
}
ChurchRevealSide = {
  Enter = function(actor)
    if actor.is_hero then
      RevealChurchDoored(DoorSets.Church.Side)
    end
  end
}
ChurchRevealGarden = {
  Enter = function(actor)
    if actor.is_hero then
      RevealChurchDoored(DoorSets.Church.Garden)
    end
  end
}


PrisonSouthRevealSide = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonSouthDoored(DoorSets.SouthPrison.Side)
    end
  end
}
PrisonSouthRevealRoof = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonSouthDoored(DoorSets.SouthPrison.Roof)
    end
  end
}
PrisonSouthRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonSouthDoored(DoorSets.SouthPrison.Main)
    end
  end
}


PrisonNorthRevealNorth = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonNorthDoored(DoorSets.NorthPrison.North)
    end
  end
}
PrisonNorthRevealSouth = {
  Enter = function(actor)
    if actor.is_hero then
      RevealPrisonNorthDoored(DoorSets.NorthPrison.South)
    end
  end
}


CastleRoomRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleRoomDoored(DoorSets.CastleRoom.Main)
    end
  end
}
CastleRoomRevealSide = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleRoomDoored(DoorSets.CastleRoom.Side)
    end
  end
}
CastleRoomRevealTower = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleRoomDoored(DoorSets.CastleRoom.Tower)
    end
  end
}


FallgateRoomReveal ={
  Enter = function(actor)
    if actor.is_hero then
      RevealFallgateRoomDoored(DoorSets.FallGate.TheOnlyOne)
    end
  end
}