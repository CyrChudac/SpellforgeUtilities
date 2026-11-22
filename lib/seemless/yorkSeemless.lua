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
    castle_main_hall = GetBaseObject(
      data.castle_main_hall.Interrior,
      data.castle_main_hall.Exterrior,
      CastleMainHall
    ),
    castle_hallway = GetBaseObject(
      data.castle_hallway.Interrior,
      data.castle_hallway.Exterrior,
      CastleHallway
    ),
    fall_gate_room = GetBaseObject(
      data.fall_gate_room.Interrior,
      data.fall_gate_room.Exterrior,
      CastleFallGateRoom
    )
  }
end

DoorSets = {
  Church = {
    Main = {},
  },
  CastleHall = {
    Main = {"Door_15"},
    FromHallway = {"Door_17"},
    TowerTop = {"Door_23", "Door_24"},
    TowerBot = {},
  },
  CastleHallway = {
    FromMainHall = {"Door_17"},
    Rampart = {"Door_16"},
  },
  FallgateRoom = {
    TheOnlyOne = {},
  }
}

---@param interriorExterriorDefinitions {[string]: InterriorExterriorData} The data from which to create the hidden spaces.
InitYorkSeemless = function (interriorExterriorDefinitions)
  InitializeYork()
  HiddenSpaces = CreateInterriors(interriorExterriorDefinitions)
  InitSeemless(HiddenSpaces)

  table.insert(HiddenSpaces.castle_main_hall.OnRevealFuncs,
    function ()
      HiddenSpaces.castle_hallway:Reveal(DoorSets.CastleHallway.FromMainHall)
    end
  )
end


function RevealCathedral()
  HiddenSpaces.church:Reveal({})
end

function RevealCastleMainHall()
  HiddenSpaces.castle_main_hall:Reveal({})
end

function RevealCastleHallway()
  HiddenSpaces.castle_hallway:Reveal({})
end

function RevealFallGateRoom()
  HiddenSpaces.fall_gate_room:Reveal({})
end


local function RevealCathedralDoored(doors)
  HiddenSpaces.church:Reveal(doors)
end

local function RevealCastleMainHallDoored(doors)
  HiddenSpaces.castle_main_hall:Reveal(doors)
end

local function RevealCastleHallwayDoored(doors)
  HiddenSpaces.castle_hallway:Reveal(doors)
end

local function RevealFallGateRoomDoored(doors)
  HiddenSpaces.fall_gate_room:Reveal(doors)
end

--Zones
CathedralRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCathedralDoored(DoorSets.Church.Main)
    end
  end
}

CastleHallRevealMain = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleMainHallDoored(DoorSets.CastleHall.Main)
    end
  end
}
CastleHallRevealFromHallway = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleMainHallDoored(DoorSets.CastleHall.FromHallway)
    end
  end
}

CastleHallwayRevealRampart = {
  Enter = function(actor)
    if actor.is_hero then
      RevealCastleHallwayDoored(DoorSets.CastleHallway.Rampart)
    end
  end
}

FallGateRoomRevealTheOnlyOne = {
  Enter = function(actor)
    if actor.is_hero then
      RevealFallGateRoomDoored(DoorSets.FallgateRoom.TheOnlyOne)
    end
  end
}