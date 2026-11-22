---@meta _

-- ============================================================================
-- Robin Hood: The Legend of Sherwood - Lua mission scripts (RhMod)
-- ============================================================================
--
-- Everything a mission script can use. VS Code's Lua extension (LuaLS,
-- https://luals.github.io/wiki/) reads this file when it is in the folder you work in (a copy is
-- in the game's SpellForge folder, which holds the campaigns and their scripts): it completes
-- names, shows these descriptions and warns about wrong arguments.
--
-- A mission script is Data/Levels/<mission>.lua next to <mission>.rhm, and it is one file: it
-- cannot load other files. The tables of constants in this file (AiState.sleeping, ...) are real:
-- RhMod defines them for every mission script. Everything else here only describes what the game
-- and RhMod provide.
--
-- The objects of the mission are looked up by the names SpellForge gives them, and they have
-- methods (called with ':') and properties (read and set with '.'):
--
--   local robin = Heroes.Robin
--   robin:SetProperty(PersistentProperty.apples, 3)
--   robin.health = robin.health - 10
--   if Actors.Guard.out_of_action then
--       Patches.Drawbridge:Apply()
--   end
--   for name, actor in pairs(Actors) do ... end
--
-- Errors stop the event they happen in and are written to rhmod.log next to the game, like the
-- output of print() and LogInfo(): a name the mission does not have (Actors.Nobody), a member an
-- object does not have, setting a property that can only be read. A call with an argument it does
-- not take (nil where an object must be given, a number out of range, the wrong kind of object) is
-- skipped with a warning in rhmod.log instead. A property set to a value it does not take (an AI
-- state the NPC cannot take, ...) stays as it was, with a warning, and a sequence step that is not
-- possible is skipped with a warning.

-- ===== Objects of the mission ================================================

---A point on the map, in map pixels.
---@class Position
---@field x number
---@field y number

---A character, animal, target, item, scroll or other element of the mission. Look it up by its
---name with Actors.Name (items with Items.Name, scrolls with Scrolls.Name), or the heroes with
---Heroes.Robin, ...; events and some properties pass actors too. Two actors are the same element
---when a == b.
---@class Actor
---@field name string? Read only: the name SpellForge gave it (what Actors looks up); nil for an element without one.
---@field index integer Read only: its number in the mission's list of script elements (Sequence:Action expects it for a target); -1 when it is not in the list.
---@field posture Posture A human's body posture; Posture.unknown for postures it does not report, -1 (with an error) for a non-human. Setting it changes it at once, without an animation: upright (also wakes them), lying, tied, crouched, dead, sitting, knocked_out or anonymous_archer; knocking out or tying up an NPC makes his friends notice it. on_ladder, siesta, carried, flying, climbing and carrying_corpse are refused.
---@field direction ActorDirection The direction it faces, 0-15 clockwise from up the screen. Setting it turns the element at once, without a turning animation (a cart turns with all its parts).
---@field location Location? Read: a new point location at the element's position (with its floor and area), for Sequence:Move, DistanceTo, JumpCameraTo and the like. Set: teleports the element to a point location on walkable ground; nil removes it from the map (it becomes inactive and leaves any sword fight, a hero becomes unplayable, an NPC's AI is locked), and placing it on a point brings it back.
---@field action_state ActionState What a human is doing, as a broad state; -1 (with an error) for anything else. Setting it puts him into that state at once (for example sleeping or sword drawn) and lets him wait in it.
---@field current_action ActorAction Read only: the animation a character or object is playing; 0 (with an error) for other elements.
---@field running boolean Read only: whether a character is running at the moment.
---@field health integer A human's life points (PersistentProperty.life_points); -1 for anything else. Setting it changes them without a reaction (see Damage).
---@field alert AlertStatus How alert an NPC is. Setting it takes green, yellow and red; heroes are refused.
---@field ai_state AiState What an NPC's AI is doing. Setting it takes default (back to normal duty), seeking (soldiers only), fleeing and script_driven; sleeping, wondering, menacing and attacking are refused.
---@field attitude AiAttitude Read only: which side an NPC is on (fixed in the profiles).
---@field rank SoldierRank Read only: a soldier's rank (soldier for a non-soldier, with an error).
---@field animation_active boolean Whether an animation or target element is active (visible and playing). Setting it switches it on or off.
---@field invisible boolean Whether Prince John's soldiers cannot see the human as an enemy. Setting it makes him invisible or visible again.
---@field revealed boolean Read only: whether a character is revealed, no longer drawn as an anonymous 'blip' figure on maps with fog (see Actor:Reveal).
---@field active boolean Read only: whether the element is present in the game (not deactivated or removed).
---@field selected boolean Read only: whether the player has this hero selected.
---@field action_selected boolean Read only: whether this selected hero is in an action mode (aiming, about to throw an apple, ...).
---@field pc_type PcType Read only: which hero a player character is; -1 (with an error) for anything else.
---@field ai_locked boolean Read only: whether a soldier's own AI is switched off (LockAi); false with a warning for anything else.
---@field is_animation boolean Read only: whether it is an animation element; targets are animation elements too.
---@field is_object boolean Read only: whether it is an object: an item, bonus, scroll or projectile.
---@field is_character boolean Read only: whether it is a character: a human (hero, soldier, civilian) or an animal.
---@field is_hero boolean Read only: whether it is a hero (a player character).
---@field is_npc boolean Read only: whether it is an NPC, a soldier or a civilian.
---@field is_soldier boolean Read only: whether it is a soldier, of either side.
---@field is_civilian boolean Read only: whether it is a civilian.
---@field is_animal boolean Read only: whether it is an animal (horses included).
---@field is_mobile_element boolean Read only: whether it is a cart or another mobile element that moves along a fixed path.
---@field is_rider boolean Read only: whether it is a mounted soldier (a rider).
---@field dead boolean Read only: whether a human is dead (false, with an error, for anything else).
---@field knocked_out boolean Read only: whether a human is knocked out (unconscious).
---@field tied boolean Read only: whether a human is tied up.
---@field out_of_action boolean Read only: whether a human is dead, knocked out or tied up.
local Actor = {}

---Brings an element back into play: a hero becomes playable, a cart or any other element appears
---and acts again.
---@return boolean # true when done, false (with an error) for an unknown object.
function Actor:Activate() end

---Takes an element out of play. A hero becomes unplayable (stays in the world, cannot be
---controlled, loses its quick actions); a cart disappears with all its parts; anything else
---disappears from the map and stops acting.
---@return boolean # true when done, false (with an error) for an unknown handle.
function Actor:Deactivate() end

---Checks whether one of a hero's action slots is currently enabled (not disabled by the game or
---temporarily).
---@param slot integer action slot on the hero's portrait, 0-2
---@return boolean # true when the action is enabled; false when disabled or (with an error) for a non-hero.
function Actor:IsActionAvailable(slot) end

---Reads a counter of a character: arrows, money, life points, knock-out amount, or a hero's stock
---of items.
---@param property PersistentProperty arrows (humans; 0 without a bow), money (NPCs), life_points (humans; also the health property), concussion (humans), purses to wasp_nests (heroes only); name cannot be read
---@return integer # The amount, or -1 (with an error) when the property does not apply.
function Actor:GetProperty(property) end

---Sets a counter of a character: arrows, money, life points, knock-out amount, or a hero's stock
---of items; for merry men it can also pick their name.
---@param property PersistentProperty as for GetProperty; name (heroes) takes a PeasantName
---@param amount integer the new amount
---@return boolean # true when set; false (with an error) for a property the character does not have or an invalid name number; false without error for arrows when the human has no bow.
function Actor:SetProperty(property, amount) end

---Hurts a character right away, as if hit. With stun the hit also knocks the character out.
---@param amount integer damage in life points
---@param stun boolean true adds a knock-out effect of 100 to the damage, false only takes life points
---@return boolean # true when the damage was applied, false (with an error) when this is not a character.
function Actor:Damage(amount, stun) end

---Stops what a character is doing (walking, an action) at once.
---@return boolean # true when done, false (with an error) for an element that is not a character.
function Actor:Stop() end

---Checks whether an NPC can currently see a human, using the same sight test as the NPC's view
---cone.
---@param target Actor a human character (hero or NPC)
---@return boolean # true when the NPC sees the target; false otherwise or (with an error) for invalid handles.
function Actor:Sees(target) end

---Shows an NPC's view cone on screen, as if the player had picked that NPC with the view cone
---tool.
function Actor:ShowViewCone() end

---Calls the FilterAiEvent function of this NPC's script class with the given event, so several
---classes can share one filter. ThisActor() stays the NPC that got the event.
---@param source Actor the actor that caused the event
---@param event AiEvent the event, as FilterAiEvent receives it
---@return boolean # This NPC's answer: true to react to the event, false to ignore it.
function Actor:FilterAiEvent(source, event) end

---Restarts an animation or target element from its first frame.
---@return boolean # true when done; false for elements that are not animations.
function Actor:ResetAnimation() end

---Checks whether an element is inside a script zone, by its actual position (so it also works
---right after a teleport). Inactive objects count as outside.
---@param zone Location a zone, i.e. a location that is an area
---@return boolean # true when the element stands in the zone; false otherwise, for nil, or (with a warning) when the location is not a zone.
function Actor:IsInside(zone) end

---Checks whether a character is inside a particular building, or inside any building.
---@param building Building? a building, or nil for 'any building'
---@return boolean # true when the character is in that building (or in any building for nil).
function Actor:IsInsideBuilding(building) end

---Reveals a 'blipped' character: on maps with fog, characters the heroes have not seen yet are
---drawn as an anonymous figure; this shows their real look at once.
---@return boolean # true when the character was hidden and is now revealed; false when it already was revealed or (with an error) the handle is unknown.
function Actor:Reveal() end

---Gives an NPC a new patrol path to follow; it heads there unless its AI is locked. With nil the
---NPC gives up its path and guards the spot where it stands, facing the way he faces, or sits down
---there with sitDown.
---@param patrol Patrol? a patrol; nil = no patrol
---@param sitDown? boolean With nil for patrol: sit down at the spot instead of guarding it.
function Actor:AssignPatrol(patrol, sitDown) end

---Gives an NPC a fixed guard post instead of a patrol path: it goes there and faces the given
---direction (unless its AI is locked).
---@param post Location a point location; a zone does not work here
---@param direction ActorDirection the direction to face there
function Actor:AssignPost(post, direction) end

---Switches off an NPC's or animal's AI so the script alone controls it: it stops what it is doing
---and ignores what it sees and hears. Use UnlockAi to give it back.
---@param rememberEvents boolean NPCs: true keeps what happened while locked and reacts to it after UnlockAi, false forgets it
function Actor:LockAi(rememberEvents) end

---Switches an NPC's or animal's AI back on after LockAi; an NPC returns to its duty and an animal
---starts walking again.
function Actor:UnlockAi() end

---Forces what a soldier does in its next fight decision (for example flee, observe or shoot),
---once or permanently. Only soldiers take it.
---@param decision BattleDecision add 100 to keep it for every decision instead of just the next; BattleDecision.none gives the decisions back to the soldier
function Actor:ForceBattleDecision(decision) end

---Freezes a hero: he does nothing until he is unfrozen (freeze = false). It has no effect on an
---NPC (use LockAi, or FreezeAll for everyone).
---@param freeze boolean true to freeze, false to let him act again.
function Actor:Freeze(freeze) end

---Changes how an element is shown on the minimap, and gives it the outline colors of that kind
---of character (hero, enemy or civilian). Use it to hide someone from the map or to show a
---disguised character as a friend or foe.
---@param dot MinimapDot the *_auto dots (which follow the state) for humans only
function Actor:SetMinimapDot(dot) end

---Takes a character out of the building it is in, before you teleport it (setting location).
---@return boolean # true when done; false (with an error) when this is not a character or it is not in a building.
function Actor:CleanFromBuildingBeforeTeleport() end

---Signs a character out of a script zone it is registered in (running the zone's Exit event),
---before you teleport it away (setting location).
---@param zone Location a zone, i.e. a location that is an area
---@return boolean # true when done; false for a location that is not a zone, a non-character, or a character not registered in the zone.
function Actor:CleanFromZoneBeforeTeleport(zone) end

---Runs the zone's Enter event again for a character the zone already counts as inside; a character
---it does not count as inside is not added. To react to a teleport into a zone, call your zone
---class's Enter function from Lua instead.
---@param zone Location a zone, i.e. a location that is an area
---@return boolean # true when the Enter event was run; false for a location that is not a zone, a non-character, or a character not registered in the zone.
function Actor:AddToZoneAfterTeleport(zone) end

---Puts a character inside a building at once: it disappears from the map and is placed at the
---building's first door. A hero's actions are disabled while inside.
---@param building Building
function Actor:PutInBuilding(building) end

---Sets a soldier's company number, which decides who fights first in a group: a soldier holds
---back in reserve while enough comrades with a lower number are fighting, and 100 makes him the
---last reserve.
---@param number integer company number; 0 means no reserve behavior, 100 last reserve
function Actor:SetCompanyNumber(number) end

---Keeps a soldier permanently attentive (on guard), or returns him to normal behavior. A calm
---soldier made attentive becomes suspicious.
---@param attentive boolean true keeps him attentive, false resets him
function Actor:SetAlwaysAttentive(attentive) end

---Makes a soldier a Sherwood combat trainer: the merry men can train fighting with him, and he
---becomes invulnerable.
function Actor:DeclareAsCombatTrainer() end

---Gives an NPC a scroll to hand over: a speech bubble appears over him. With nil the scroll is
---taken away again.
---@param scroll Scroll? a scroll, or nil to remove it
function Actor:AttachScroll(scroll) end

---Shows a symbol over an NPC's head for a while, or removes it.
---@param emoticon ActorEmoticon ActorEmoticon.none removes the symbol
---@param time integer how long to show it, in frames (25 frames = 1 second)
function Actor:SetEmoticon(emoticon, time) end

---Takes all the money an NPC carries and adds it to the ransom money of Robin's gang. Does
---nothing for heroes.
function Actor:ConfiscateMoney() end

---Reads one of the 10 numbers a script can store on an NPC.
---@param index integer value number, 0-9
---@return integer # The stored number, or -1 (with an error) for an invalid index or handle.
function Actor:GetCustomValue(index) end

---Stores one of the 10 numbers a script can store on an NPC, for example to remember what it has
---already done.
---@param index integer value number, 0-9
---@param value integer the number to store
function Actor:SetCustomValue(index, value) end

---Checks whether a hero has an ability, as a normal or a situation-dependent action.
---@param action PcAction
---@return boolean # true when the hero has it; false otherwise or (with an error) for a non-hero or unknown code.
function Actor:HasPcAction(action) end

---Adds a hero to Robin's gang in the campaign, for example a character freed in this mission.
function Actor:AddToGang() end

---Sets a hero's sword and bow skills.
---@param sword integer sword skill, 0-100
---@param bow integer bow skill, 0-100
function Actor:SetExperiences(sword, bow) end

---Turns a target that heroes operate by hand (such as a lever) into one they pick up.
function Actor:MakeTakeTarget() end

---Makes a hero crouch; a hero who is moving goes on moving crouched.
function Actor:Crouch() end

---Selects or deselects this hero (Select(PcSelection.all) or Select(PcSelection.none) for every
---hero).
---@param selected boolean true selects, false deselects
function Actor:Select(selected) end

---Links an animation to this target so that the animation lights up when the player points at
---the target, showing what the target operates (for example a gate a lever opens).
---@param fx Actor an animation element (for example a patch's animation)
function Actor:LinkFx(fx) end

---Stops an NPC from saying one of the remarks the AI makes him say (or allows it again).
---@param remark NpcRemark
---@param forbid boolean true forbids the remark, false allows it again
function Actor:ForbidRemark(remark, forbid) end

---Makes an NPC a member of this NPC's patrol squad, so it follows him as its leader.
---@param subordinate Actor the NPC to add; it must not already be in a squad or lead one
function Actor:AddSquadMember(subordinate) end

---Breaks up this leader's squad: every member leaves it and returns to its own duty.
function Actor:RemoveAllSquadMembers() end

---Makes a soldier change to his alert patrol path (set in the mission editor), as if the alarm had
---been raised; a soldier without one just returns to duty.
function Actor:SwitchToAlertPatrol() end

---Makes the character walk or run along its patrol.
---@param style MovementStyle walking or running
function Actor:SetPatrolStyle(style) end

---Sends a soldier walking or running to a point on the map through its AI; it may stop on the way.
---Only for soldiers: for anything else it logs a warning and does nothing.
---@param position Position the destination (a table with x and y, like GetMousePosition returns)
---@param run boolean true to run, false to walk
function Actor:CheatMoveTo(position, run) end

---An item lying in the mission: a bonus, a relic, a blazon, ... It is an element of the mission
---too, with everything an Actor has. Look it up with Items.Name.
---@class Item : Actor
---@field picked_up boolean Read only: whether a bonus item (such as a relic or blazon) has been picked up; false (with an error) for an item that is not a bonus.
---@field blazon_won boolean Read only: whether a blazon has been won (its item is no longer active).
local Item = {}

---Counts a blazon as won: the blazon item disappears and its value is added to the campaign's
---blazons. In an attack mission, reaching the required number wins the mission.
function Item:WinBlazon() end

---Takes back a won blazon: the blazon item reappears and, in the campaign, its value is
---subtracted again.
function Item:LoseBlazon() end

---A scroll the heroes can pick up (and NPCs can hand over, Actor:AttachScroll). It is an element
---of the mission too, with everything an Actor has. Look it up with Scrolls.Name.
---@class Scroll : Actor
---@field state ScrollState Whether the scroll is hidden, visible, taken or opened. Setting it changes that, for example to make a hidden scroll appear.

---A location: a script node (a point or a line) or a script zone of the mission, or a point a
---property or function gave (actor.location, Location:PointBetween). Look it up with
---Locations.Name.
---@class Location
---@field name string? Read only: the name SpellForge gave it; nil for a point made by a property or function.
---@field index integer Read only: its number in the mission's list of script locations; -1 when it is not one.
---@field position Position Read only: where a script node lies on the map (for a zone the numbers mean nothing).
---@field any_actor_inside Actor? Read only: the first character registered in a zone; nil when the zone is empty, or (with a warning) for a location that is not a zone.
---@field actors_inside Actor[] Read only: the characters registered in a zone (those that entered it and did not leave); empty for a location that is not a zone (with a warning).
---@field all_pcs_inside boolean Read only: whether every hero of the mission stands in this zone, dead heroes included.
---@field all_pcs_alive_inside boolean Read only: whether every living hero stands in this zone; dead heroes are ignored. Typical victory check for reaching an exit.
---@field all_enemies_out_of_action boolean Read only: whether all of Prince John's soldiers registered in this zone are dead, knocked out, tied up or carried away (also true when it holds none).
local Location = {}

---The straight-line distance between two points, ignoring floors and obstacles.
---@param other Location another point location
---@return integer # The distance in map pixels, rounded down; 0 (with a warning) when one of them is not a point.
function Location:DistanceTo(other) end

---Makes a noise at this point that NPCs nearby hear and react to.
---@param noise NoiseType
function Location:MakeNoise(noise) end

---A new point on the line from this point to another, for example half way between them.
---@param other Location a second point on the same floor and in the same area
---@param lambda number position on the line: 0 gives this point, 1 the other, 0.5 the middle; values outside 0-1 go beyond
---@return Location? # The new point, or nil (with a warning) when one of them is not a point, or (with an error) when they lie on different floors or areas.
function Location:PointBetween(other, lambda) end

---Places an invisible point here that pushes walking characters away, so they walk around it.
---Returns an ID for DeleteRepulsivePoint.
---@param radius number radius in map pixels that characters are pushed out of
---@param actionRadius number extra distance in map pixels beyond radius over which the push fades out
---@param targets integer who is pushed: RepulsiveTarget values combined with |
---@return integer # The ID of the new point, or 0 (with a warning) when this location is not a point.
function Location:AddRepulsivePoint(radius, actionRadius, targets) end

---Turns this zone into a low-ceiling zone: thrown things (stones, apples, purses) and arrows inside
---it may not arc higher than the given height. Use it for vaults, tunnels or rooms under a low
---roof. Only for a zone that has no script class of its own.
---@param apexHeight integer highest allowed height of a throw's arc, in map pixels
function Location:DefineFlatTrajectory(apexHeight) end

---A patrol: a path characters walk along (Actor:AssignPatrol). Look it up with Patrols.Name.
---@class Patrol
---@field name string? Read only: the name SpellForge gave it.
---@field index integer Read only: its number in the mission's list of patrols.

---A door of the location: a building's door, a single door or a lift's door. Look it up with
---Doors.Name.
---@class Door
---@field name string? Read only: the name SpellForge gave it (what Doors looks up); in a location saved without names "Door_8" for the door with index 8.
---@field index integer Read only: its number in the mission's list of doors; -1 when it is not a known door.
---@field locked_for_pcs boolean Whether the door is locked for the heroes. Setting it locks or unlocks it; unlocking also makes the door usable again if it was inactive.
---@field unlockable boolean Whether a hero who picks locks can open the door while it is locked for the heroes. Setting it allows or forbids that.
---@field locked_for_civilians boolean Whether the door is locked for civilians. Setting it locks or unlocks it; unlocking also makes the door usable again if it was inactive.
---@field locked_for_villains boolean Whether the door is locked for soldiers (riders can never use building doors). Setting it locks or unlocks it; unlocking also makes the door usable again if it was inactive.
local Door = {}

---Despite its name, it lets no hero through: once called, a door locked for the heroes stays shut
---to every hero, lock pickers included.
---@param hero Actor a hero (has no effect)
---@param inward boolean which way through the door (has no effect)
function Door:SpecialAutorisation(hero, inward) end

---Switches the door's clickable area on or off, so the player can or cannot send heroes through it
---by clicking.
---@param clickable boolean true makes the door clickable, false not
function Door:SetClickable(clickable) end

---A map patch: a part of the background that can be switched (an opened gate, a lit window, ...),
---of the location or of the mission. Look it up with Patches.Name.
---@class Patch
---@field name string? Read only: the name SpellForge gave it (what Patches looks up); in a file saved without names "Patch_3" for the patch with index 3.
---@field index integer Read only: its number in the mission's list of patches; -1 when it is not a known patch.
---@field applied boolean Read only: whether the patch is applied (the background shows its changed state, for example an open gate).
local Patch = {}

---Applies the patch: the background changes to the patched state (with its transition animation,
---if any), and the doors and objects tied to it change with it. Calling it again on a reversible
---patch that is already applied switches it back, like a toggle.
---@return boolean # Always true.
function Patch:Apply() end

---Puts the patch back to its original state at once.
---@return boolean # Always true.
function Patch:Reset() end

---Locks or unlocks a clickable patch: while locked, heroes refuse to go through it when the player
---clicks it.
---@param locked boolean true locks, false unlocks
function Patch:Lock(locked) end

---Switches the animation belonging to the patch on or off (refused with a warning for a patch
---without one).
---@param active boolean true shows and plays the animation, false hides it
function Patch:SetAnimationActive(active) end

---An ambient sound source placed in the location. Look it up with SoundSources.Name; it has only
---those that play in the mission's ambience (day, night, ...).
---@class SoundSource
---@field name string? Read only: the name SpellForge gave it (what SoundSources looks up); in a location saved without names "Sound_2" for the sound source with index 2.
---@field index integer Read only: its number in the mission's list of sound sources; -1 when it is unknown (with an error) or the game's sound is not running.
local SoundSource = {}

---Switches the sound source on.
---@return boolean # Always true.
function SoundSource:Activate() end

---Switches the sound source off.
---@return boolean # Always true.
function SoundSource:Deactivate() end

---Removes the sound source for good.
---@return boolean # Always true.
function SoundSource:Destroy() end

---A building of the location the characters can enter. Look it up with Buildings.Name.
---@class Building
---@field name string? Read only: the name SpellForge gave it (what Buildings looks up); in a location saved without names "Building_0" for the building with index 0.
---@field index integer Read only: its number in the mission's list of buildings; -1 when it is not a known building.
local Building = {}

---Opens or closes the building's doors for everyone: inactive doors cannot be used.
---@param active boolean true makes the doors usable, false closes them
function Building:SetActive(active) end

---A mobile element of the mission: a cart that drives along its path (Sequence:StartMobileElement).
---It is an element of the mission too, with everything an Actor has. Look it up with
---MobileElements.Name.
---@class MobileElement : Actor

---An animation of the location or of a patch (a flag, smoke, a waterwheel, ...): Animations.Name.
---@class Animation : Actor

-- ===== The mission's objects by name =========================================
-- Actors.Guard, Locations["Gate 2"]: a name the mission does not have is an error. Look objects up
-- in Initialize or later (the mission is read after the script's top level has run). pairs() goes
-- through all of them: for name, actor in pairs(Actors) do ... end. The location's doors, patches,
-- sound sources and buildings have the names SpellForge gave them; a location saved without names
-- (the game's own) names them by their numbers in the location: Door_8, Patch_3, Sound_2,
-- Building_0. The location's animations are Animation_0, Animation_1, ...

---Every character, animal and target of the mission by its name (soldiers, civilians, heroes,
---targets).
---@type table<string, Actor>
Actors = {}

---Every item of the mission by its name.
---@type table<string, Item>
Items = {}

---Every scroll of the mission by its name.
---@type table<string, Scroll>
Scrolls = {}

---Every script node (point or line) and script zone of the mission by its name.
---@type table<string, Location>
Locations = {}

---Every patrol of the mission by its name.
---@type table<string, Patrol>
Patrols = {}

---Every door of the location by its name: buildings' doors, single doors and lifts' doors.
---@type table<string, Door>
Doors = {}

---Every map patch by its name: the location's and the mission's.
---@type table<string, Patch>
Patches = {}

---Every sound source of the location by its name (those the mission's ambience plays).
---@type table<string, SoundSource>
SoundSources = {}

---Every building of the location by its name.
---@type table<string, Building>
Buildings = {}

---Every mobile element (cart) of the mission by its name.
---@type table<string, MobileElement>
MobileElements = {}

---The location's animations (Animation_0, Animation_1, ... in the location's order) and the
---patches' animations (under their patch's name: Animations.Gate is the animation of the patch
---Gate). Switch one on or off with Activate / Deactivate or animation_active.
---@type table<string, Animation>
Animations = {}

---The heroes with a character of their own. A hero who is not in the mission is nil (pairs()
---skips him); the merry men are many: GetPc(i).
---@class HeroList
---@field Robin Actor Robin Hood, in any of his outfits (nil when not in the mission).
---@field LittleJohn Actor Little John (nil when not in the mission).
---@field FriarTuck Actor Friar Tuck (nil when not in the mission).
---@field Stuteley Actor Will Stutely (nil when not in the mission).
---@field WillScarlet Actor Will Scarlet (nil when not in the mission).
---@field Marian Actor Lady Marian (nil when not in the mission).

---The heroes of the mission: Heroes.Robin, Heroes.LittleJohn, Heroes.FriarTuck, Heroes.Stuteley,
---Heroes.WillScarlet, Heroes.Marian (nil for a hero who is not in it).
---@type HeroList
Heroes = {}

-- ===== Constants =============================================================

---What CheckVictoryCondition returns.
---@enum MissionResult
MissionResult = {
    ---The mission goes on.
    playing = 0,
    ---The heroes have won the mission.
    won = 1,
    ---The heroes have lost the mission.
    lost = 2,
}

---The zoom factors the game allows (SetZoomLevel, Sequence:SetZoomLevel).
---@enum ZoomLevel
ZoomLevel = {
    ---Zoomed out (ignored on maps too small for it).
    far = 0.5,
    ---Normal view (the zoom a mission starts with).
    default = 1.0,
    ---Zoomed in.
    close = 2.0,
}

---How an actor moves in a recorded sequence. Values 2 and 3 are only accepted by Sequence:Move,
---Sequence:MoveNear and Sequence:MoveIntoBuilding.
---@enum MovementStyle
MovementStyle = {
    walking = 0,
    running = 1,
    ---Walk; the move gets script priority so the player/AI cannot interrupt it (Sequence:Move,
    ---Sequence:MoveNear, Sequence:MoveIntoBuilding only).
    walking_uninterruptible = 2,
    ---Run; the move gets script priority so the player/AI cannot interrupt it (Sequence:Move,
    ---Sequence:MoveNear, Sequence:MoveIntoBuilding only).
    running_uninterruptible = 3,
}

---Alert level of an NPC (and the highest level over all soldiers / civilians).
---@enum AlertStatus
AlertStatus = {
    ---Calm, nothing noticed.
    green = 0,
    ---Suspicious, searching.
    yellow = 1,
    ---Alarm, the NPC knows about the enemy.
    red = 2,
}

---Top-level state of an NPC's AI. Actor.ai_state can be set to default, seeking (soldiers only),
---fleeing and script_driven; it never reads script_driven (a script-driven NPC reports
---default).
---@enum AiState
AiState = {
    ---Asleep or unconscious. Cannot be set by script.
    sleeping = 0,
    ---Normal duty: patrol, post or script-driven.
    default = 1,
    ---Curious or puzzled (watching something, reacting to an apple, money, ale, whistling). Cannot be
    ---set by script.
    wondering = 2,
    ---Searching for an enemy. Can only be set for soldiers.
    seeking = 3,
    ---Threatening a knocked-out PC. Cannot be set by script.
    menacing = 4,
    ---Running away / panicking.
    fleeing = 5,
    ---Fighting. Cannot be set by script.
    attacking = 6,
    ---Hand the NPC to the script (set only).
    script_driven = 7,
}

---Which side an NPC is on. Read it with Actor.attitude; scripts cannot change it (attitudes are
---fixed in the profiles).
---@enum AiAttitude
AiAttitude = {
    ---Royalist side (Robin's friends).
    friendly = 0,
    ---Lacklandist side (Prince John's men).
    hostile = 1,
}

---Body posture of a human actor. Actor.posture reads unknown (666) for postures it does not
---map (tied, stuck under a net, on someone's shoulders, leaning out, simulating a beggar, hidden
---archer, ...) and -1 for an invalid actor. Setting Actor.posture cannot set carried, flying, climbing,
---on_ladder, carrying_corpse or siesta.
---@enum Posture
Posture = {
    ---Standing (setting it also wakes the actor up).
    upright = 0,
    ---Lying on the ground, conscious.
    lying = 2,
    ---On a ladder (get only).
    on_ladder = 4,
    ---Napping (get only).
    siesta = 5,
    ---Carried by someone, alive (get only).
    carried = 6,
    ---Tied up (set only; Actor.posture reads unknown for tied actors).
    tied = 7,
    ---In the air, e.g. jumping (get only).
    flying = 8,
    ---Climbing a wall (get only).
    climbing = 9,
    ---Crouched.
    crouched = 10,
    ---Carrying a body (get only).
    carrying_corpse = 11,
    ---Dead (also returned for a carried dead body); setting it kills the actor.
    dead = 15,
    sitting = 16,
    ---Unconscious.
    knocked_out = 17,
    ---Hidden archer disguise that can still shoot (set only).
    anonymous_archer = 100,
    ---Read from Actor.posture for a posture it does not map.
    unknown = 666,
}

---What a human actor is doing (Actor.action_state), which reads -1 for an
---invalid or non-human actor.
---@enum ActionState
ActionState = {
    ---Standing still.
    waiting = 0,
    ---Standing still, playing idle animations.
    bored = 1,
    ---Walking.
    moving = 2,
    ---Running.
    moving_fast = 3,
    aiming_bow = 4,
    aiming_bow_up = 5,
    aiming_bow_down = 6,
    ---Sword drawn, standing.
    waiting_sword = 7,
    ---Sword drawn, walking.
    moving_sword = 8,
    ---Sword drawn, running.
    moving_fast_sword = 9,
    parrying_sword = 10,
    parrying_sword_low = 11,
    holding_shield = 12,
    parrying_shield = 13,
    moving_shield = 14,
    ---Threatening someone.
    menacing = 15,
    sleeping = 16,
    listening = 17,
}

---Battle behavior a soldier is forced to take (Actor:ForceBattleDecision). Add 100 to keep it for
---every decision instead of just the next one.
---@enum BattleDecision
BattleDecision = {
    ---Panic and run away.
    flee = 0,
    ---Attack the nearest enemy.
    fight = 1,
    ---Stay near the fight and watch.
    observe = 2,
    ---Wait in reserve, facing the enemy.
    reserve = 3,
    ---Archer shoots (runs for arrows when out of ammunition).
    shoot = 7,
    ---Archer backs off to a good shooting distance.
    archer_step_back = 8,
    ---Run to an officer for help (flees if there is none).
    look_for_help = 9,
    ---Keep a distance and watch instead of attacking.
    too_proud_to_attack = 12,
    ---Tower guard points at the enemy and raises the alarm.
    tower_guard_alert = 13,
    ---Tower guard watches the enemy.
    tower_guard_observe = 14,
    ---Archer draws the bow and watches.
    archer_observe = 15,
    ---Remove the forced decision; the soldier decides by himself again.
    none = 99,
}

---Command for Sequence:Action(actor, command, value). The value is an ActorDirection for turn, and
---the target's actor index (Actor.index) for shoot, enter_sword_fight and the sword strikes;
---other commands ignore it.
---@enum ScriptCommand
ScriptCommand = {
    ---Stop and wait.
    wait = 0,
    ---Turn to the direction given as value (ActorDirection, taken modulo 16).
    turn = 1,
    ---Draw the bow and aim.
    aim = 2,
    ---Raise the bow to aim upwards.
    aim_up = 3,
    ---Shoot one arrow at the actor whose index is the value.
    shoot = 4,
    ---Start a sword fight with the actor whose index is the value.
    enter_sword_fight = 5,
    leave_sword_fight = 6,
    ---Parry with the sword.
    parry = 7,
    ---Sword strike A: straight thrust at the actor whose index is the value.
    strike_straight = 8,
    ---Sword strike B: strong straight thrust.
    strike_straight_strong = 9,
    ---Sword strike C: executing blow.
    strike_execute = 10,
    ---Sword strike D.
    strike_left = 11,
    ---Sword strike E.
    strike_right = 12,
    ---Sword strike F: half-circle swing to the left.
    strike_half_round_left = 13,
    ---Sword strike G: half-circle swing to the right.
    strike_half_round_right = 14,
    ---Sword strike H: full-circle swing to the left.
    strike_round_left = 15,
    ---Sword strike I: full-circle swing to the right.
    strike_round_right = 16,
    ---Soldiers only.
    look_left = 17,
    ---Soldiers only.
    look_right = 18,
    ---Put the bow away.
    unequip_bow = 19,
    crouch_down = 20,
}

---Noise a script can make at a location (Location:MakeNoise); NPCs nearby hear it.
---@enum NoiseType
NoiseType = {
    ---Rolling logs in the forest.
    logs = 0,
    ---A drawbridge crashing down.
    drawbridge = 1,
}

---Symbol shown above an NPC (Actor:SetEmoticon); none clears it.
---@enum ActorEmoticon
ActorEmoticon = {
    ---Remove the emoticon.
    none = 0,
    ---Puzzled.
    question_mark = 1,
    ---Alarmed.
    exclamation_mark = 2,
    ---Sleeping.
    zzz = 3,
    ---Disappointed.
    cloud = 4,
    ---Happy.
    sun = 5,
    ---Angry.
    thunderstorm = 6,
    ---Drunk.
    drunken = 7,
}

---Property read or written with Actor:GetProperty / Actor:SetProperty. money is for NPCs only; arrows,
---life_points and concussion for humans; the other amounts for PCs only; name can only be set.
---GetProperty returns -1 on error.
---@enum PersistentProperty
PersistentProperty = {
    ---Arrows of a human with a bow (0 without a bow).
    arrows = 0,
    ---Money an NPC carries (NPCs only).
    money = 1,
    life_points = 2,
    ---Knock-out value (how long a human stays unconscious).
    concussion = 3,
    purses = 4,
    stones = 5,
    apples = 6,
    ales = 7,
    ---Legs of lamb (the eat action).
    lamb_legs = 8,
    ---Healing plants (herbs).
    plants = 9,
    nets = 10,
    wasp_nests = 11,
    ---Display name of a merry man PC (set only); the amount is a PeasantName.
    name = 12,
}

---Name given to a merry man PC with actor:SetProperty(PersistentProperty.name, name).
---@enum PeasantName
PeasantName = {
    ---The first special merry man name (menu text 250).
    a = 0,
    ---The second special merry man name (menu text 251).
    b = 1,
    ---The third special merry man name (menu text 252).
    c = 2,
}

---Facing direction in 16 steps, clockwise, 0 pointing up on the screen (north).
---@enum ActorDirection
ActorDirection = {
    ---Up on the screen.
    north = 0,
    north_north_east = 1,
    north_east = 2,
    east_north_east = 3,
    ---Right on the screen.
    east = 4,
    east_south_east = 5,
    south_east = 6,
    south_south_east = 7,
    ---Down on the screen.
    south = 8,
    south_south_west = 9,
    south_west = 10,
    west_south_west = 11,
    ---Left on the screen.
    west = 12,
    west_north_west = 13,
    north_west = 14,
    north_north_west = 15,
}

---State of a scroll (Scroll.state).
---@enum ScrollState
ScrollState = {
    ---Hidden, not revealed yet (no minimap dot).
    invisible = 0,
    ---Revealed; can be picked up.
    visible = 1,
    ---Taken by a PC.
    taken = 2,
    ---Opened by a PC but not taken (the scroll's Taken script refused); still visible.
    opened = 3,
}

---How an element appears on the minimap (Actor:SetMinimapDot). The *_lying dots use the
---knocked-out symbol; the *_auto dots follow the actor's state (alive, knocked out, dead) and are
---only allowed for humans. Actor:SetMinimapDot does not take the VIP (400-444) and horse (777)
---dots.
---@enum MinimapDot
MinimapDot = {
    ---Not shown.
    invisible = 0,
    ---Chosen by the game from the element type and state.
    default = 1,
    pc = 100,
    ---PC knocked out.
    pc_lying = 101,
    pc_dead = 102,
    ---PC dot that follows the actor's state (humans only).
    pc_auto = 111,
    ---Enemy.
    enemy = 200,
    ---Enemy knocked out.
    enemy_lying = 201,
    enemy_dead = 202,
    ---Enemy dot that follows the actor's state (humans only).
    enemy_auto = 222,
    civilian = 300,
    ---Civilian knocked out.
    civilian_lying = 301,
    civilian_dead = 302,
    ---Civilian dot that follows the actor's state (humans only).
    civilian_auto = 333,
    item = 500,
    animal = 666,
}

---Action a PC can have, for Actor:HasPcAction and the HasAny...PcAction functions (contextual actions
---count too).
---@enum PcAction
PcAction = {
    ---Shoot arrows.
    bow = 0,
    ---Punch (knock out).
    hit = 1,
    ---Strong punch.
    hit_hard = 2,
    ---Throw a purse of money.
    purse = 3,
    ---Throw a stone.
    stone = 4,
    shield = 5,
    big_shield = 6,
    strangle = 7,
    ---Use a lever (move carts and lever targets).
    lever = 8,
    ---Give another PC a leg up.
    help_to_climb = 9,
    ---Throw an apple.
    apple = 10,
    ---Put down ale to lure soldiers.
    ale = 11,
    ---Eat a leg of lamb.
    eat = 12,
    ---Leg of lamb variant of eat (same tooltip).
    guzzle = 13,
    ---Eavesdrop.
    listen = 14,
    ---Heal with plants.
    heal = 15,
    ---Throw a net.
    net = 16,
    ---Disguise as a beggar.
    beggar = 17,
    ---Throw a wasp nest.
    wasp_nest = 18,
    ---Whistle to attract NPCs.
    whistle = 19,
    ---Climb walls (contextual).
    climb = 20,
    ---Jump (contextual).
    jump = 21,
    ---Search a knocked-out body (contextual).
    search = 23,
    ---Revive a knocked-out ally (contextual).
    resuscitate = 24,
    ---Carry a body, Little John style (contextual).
    little_john_carry = 25,
    ---Carry a body, merry man style (contextual).
    farmer_carry = 26,
    ---Tie up a knocked-out enemy (contextual).
    tie = 27,
    ---Pick locks.
    lockpick = 28,
    ---Finish off a knocked-out enemy (contextual).
    execute = 29,
}

---Which character a PC is (Actor.pc_type, from the profile file name); -1 for an invalid actor or
---unknown profile.
---@enum PcType
PcType = {
    ---Robin Hood (profiles RobinHood and RobinTown).
    robin = 0,
    little_john = 1,
    friar_tuck = 2,
    ---Will Stutely (profile Stuteley).
    stuteley = 3,
    will_scarlet = 4,
    ---Lady Marian.
    marian = 5,
    ---Merry man A (profile MerryManA).
    farmer_a = 6,
    ---Merry man B (profile MerryManB).
    farmer_b = 7,
    ---Merry man C (profile MerryManC).
    farmer_c = 8,
}

---Type of merry man AddFarmerToGang adds. With 50% chance a returning reservist joins instead.
---@enum FarmerType
FarmerType = {
    ---Random merry man type.
    random = 0,
    ---Merry man A.
    a = 1,
    ---Merry man B.
    b = 2,
    ---Merry man C.
    c = 3,
}

---Royal relic looked up with GetRelic (returns the first active relic object of that kind, or
---nil).
---@enum Relic
Relic = {
    ampulla = 0,
    coronation_spoon = 1,
    ---King Richard's crown.
    richards_crown = 2,
    royal_seal = 3,
    royal_sceptre = 4,
    domesday_book = 5,
    sword_of_state = 6,
}

---What a Sherwood production sector makes or trains (RegisterAsProductionSector,
---AddProductionPoint).
---@enum ProductionType
ProductionType = {
    arrows = 0,
    purses = 1,
    stones = 2,
    apples = 3,
    ale = 4,
    lamb_legs = 5,
    ---Healing plants.
    plants = 6,
    nets = 7,
    wasp_nests = 8,
    ---Archery training.
    train_bow = 9,
    ---Sword / hand-to-hand training.
    train_hand_to_hand = 10,
    ---Healing of wounded merry men.
    heal = 11,
    relic = 12,
}

---Rank of a soldier (Actor.rank; also 0 for a non-soldier).
---@enum SoldierRank
SoldierRank = {
    soldier = 0,
    officer = 1,
    knight = 2,
    none = 3,
}

---Difficulty of the active player profile (GetDifficultyLevel).
---@enum DifficultyLevel
DifficultyLevel = {
    easy = 0,
    medium = 1,
    hard = 2,
}

---Codes for Select(code). Only these two are supported; other codes only log a script error.
---@enum PcSelection
PcSelection = {
    ---Unselect all PCs.
    none = 0,
    ---Select all PCs.
    all = 31,
}

---AI stimulus codes passed to an actor script's FilterAiEvent callback and to
---Actor:FilterAiEvent (return false to ignore the event). Stimuli without a code are passed as
---other (-2).
---@enum AiEvent
AiEvent = {
    ---Stimulus without a script code (e.g. hit by a stone, arrow launched at a shield bearer,
    ---conversation timing).
    other = -2,
    ---The NPC sees a PC.
    view = 0,
    ---A PC leaves the NPC's view.
    out_of_view = 1,
    ---Hears something.
    hear = 2,
    ---Reached a point.
    reach_point = 3,
    ---Could not reach a point.
    couldnt_reach_point = 4,
    ---A non-motion action is done.
    done = 5,
    ---A non-motion action could not be done.
    impossible = 6,
    ---The AI timer ran out.
    timer = 7,
    ---Sees a dead, unconscious or netted NPC.
    sees_body = 8,
    ---Sees an object.
    sees_object = 9,
    ---Sees a soldier and wants to tell him something.
    sees_soldier = 10,
    ---Sees another NPC in a fight.
    sees_friend_in_trouble = 11,
    ---Wakes up.
    fit_again = 12,
    ---Hit but still conscious.
    got_hit = 13,
    ---Loses consciousness.
    lose_consciousness = 14,
    ---Misses the comrade ("Charly") it checks for.
    misses_charly = 15,
    ---Someone took the object it wants.
    object_away = 16,
    ---Sees the comrade ("Charly") it checks for.
    sees_charly = 17,
    ---The checked comrade ("Charly") reached his waypoint.
    sync_charly = 18,
    ---Continue the path after a script.
    after_script_go_on = 19,
    ---Forced back to duty (e.g. by a script).
    return_to_duty = 20,
    ---A civilian is forced to panic.
    panic = 21,
    enter_sword_fight = 22,
    quit_sword_fight = 23,
    ---An opponent starts a sword strike against it.
    sword_strike = 24,
    ---Attacked by wasps.
    wasp = 25,
    ---Wasp attack over.
    wasp_away = 26,
    ---Hit by an apple.
    apple = 27,
    ---Caught under a net.
    net = 28,
    ---Free from the net.
    net_away = 29,
    ---Sees a beggar while searching.
    sees_beggar = 30,
    ---Hurt by an arrow.
    get_arrow = 31,
    ---An officer sees a brawl over money.
    sees_brawl = 32,
    ---Alerted by another NPC.
    call_alert = 33,
    ---Alerted by an officer: fight immediately.
    call_combat_alert = 34,
    ---An officer ends a brawl.
    call_finish_brawl = 35,
    ---Stopped by someone who wants to tell it something.
    call_hey = 36,
    ---A tower guard raises the alarm.
    call_tower_guard_alert = 37,
    ---A tower guard raises the alarm and this NPC must fetch help.
    call_tower_guard_calls_me = 38,
    ---Told where to search.
    call_hint = 39,
    ---A soldier gets instructions.
    call_instruction = 40,
    ---Told to look at a place.
    call_look_there = 41,
    ---Coordinating interactions.
    call_coordinate = 42,
    ---Receiving a report.
    call_report = 43,
    ---A found comrade ("Charly") is told to report to an officer.
    call_go_to_officer = 44,
    ---The missing comrade ("Charly") tells the officer he is back.
    call_i_am_back = 45,
    ---Someone reports that the missing comrade is alive.
    call_charly_is_back = 46,
    ---Patrol position instruction.
    call_patrol_coordinate = 47,
    ---A soldier chases this child.
    call_you_just_wait = 48,
    ---A soldier chases another child.
    apple_chase_near = 49,
    ---A fight starts in front of a door.
    door_combat = 50,
    ---A galloping rider reached the end of his loop.
    gallop_loop_end = 51,
    ---Sees something strange it cannot identify yet.
    sees_shadow = 52,
    ---Internal test whether the actor script is empty.
    test_missile = 99,
    ---AI state changes to sleeping.
    state_change_to_sleeping = 100,
    ---AI state changes to default.
    state_change_to_default = 101,
    ---AI state changes to wondering.
    state_change_to_wondering = 102,
    ---AI state changes to seeking.
    state_change_to_seeking = 103,
    ---AI state changes to attacking (source actor = the target).
    state_change_to_attacking = 104,
    ---AI state changes to menacing (source actor = the target).
    state_change_to_menacing = 105,
    ---AI state changes to fleeing (source actor = the target).
    state_change_to_fleeing = 106,
}

---NPC speech line (Actor:ForbidRemark, and Sequence:Speak on an NPC). Values must be below 120.
---The quotes give the gist of each remark; the actual voice line depends on the NPC. civilian_*
---lines are for civilians, vip_* for VIPs.
---@enum NpcRemark
NpcRemark = {
    ---"Are you all right?"
    sees_body = 0,
    ---"Get up!"
    awakens_sleeper = 1,
    ---"He's dead!"
    finds_dead_body = 2,
    ---"Identify yourself!"
    sees_enemy = 3,
    ---"Halt!"
    hunts_enemy = 4,
    ---"Defend yourself!"
    starts_combat = 5,
    ---"Come on!"
    provokes_combat = 6,
    ---"Hahaaa!"
    good_strike_combat = 7,
    ---"Gallows bird!"
    combat_insult = 8,
    ---"Attack!"
    war_cry = 9,
    ---"One less!"
    killed_adversary = 10,
    ---"He's too strong!"
    flees = 11,
    ---"Sire!"
    calls_officer = 12,
    ---"Sire, a body, Sire!"
    tells_officer_body = 13,
    ---"Sire, enemies, Sire!"
    tells_officer_enemy = 14,
    ---"Sire, a problem, Sire!"
    tells_officer_other = 15,
    ---"Sire, a guard is missing, Sire!"
    tells_officer_charly_away = 16,
    ---"Sire, over there, Sire!"
    tells_officer_where = 17,
    ---"Sire, at your orders, Sire!"
    awaits_orders = 18,
    ---"Sire, there is nothing, Sire!"
    tells_officer_nothing = 19,
    ---"Sire, I..."
    charly_defends_himself = 20,
    ---"Where is he?"
    misses_charly = 21,
    ---"I can't find him!"
    didnt_find_charly = 22,
    ---"Where were you?"
    found_charly = 23,
    ---"The officer wants to see you!"
    sends_charly_to_officer = 24,
    ---"Blasted wasp!"
    wasp_sting = 25,
    ---"Help! Get me out of here!"
    under_net = 26,
    ---"Let's help them!"
    sees_friend_under_net = 27,
    ---"What's that?"
    arrow = 28,
    ---"Ouch!"
    wounded = 29,
    dies = 30,
    strangled = 31,
    ---Muffled cry.
    tied_up = 32,
    ---"What's this?"
    sees_object = 33,
    ---"How kind!" (takes the ale)
    ale_yes = 34,
    ---"No drinking on duty!"
    ale_no = 35,
    ---Drunk: "No drinking on *hic* duty!"
    drunken = 36,
    ---"Who threw that?"
    hit_by_apple = 37,
    ---"Those brats again!"
    chases_child = 38,
    ---"Now you'll see, rascal!"
    caught_child = 39,
    ---"Ah, gold!"
    gold_yes = 40,
    ---"This money isn't mine!"
    gold_no = 41,
    ---"Hey! That's mine!"
    gold_brawl = 42,
    ---"So he had it!"
    searching_soldier_gold = 43,
    ---"It wasn't him..."
    searching_soldier_nothing = 44,
    ---"I must go back to my post..."
    ends_search = 45,
    ---"Let's get help!"
    panic = 46,
    ---"Who goes there?"
    hears_noise = 47,
    ---"Inspection!"
    controls_beggar = 48,
    ---"Got one!"
    menaces_knocked_out_pc = 49,
    ---"Sire, he insulted you, Sire!"
    bad_excuse = 50,
    ---"Alarm! Alarm!"
    cry_alert = 51,
    ---"Take cover! They have bows!"
    shield_bearer_covers = 52,
    ---"Form a line!"
    shield_bearers_line_formation = 53,
    ---"Archers, behind!"
    archers_behind_shield_bearers = 54,
    ---"Show me what you can do!"
    proud_dont_fight = 55,
    ---"I'll show you..."
    proud_finally_fight = 56,
    ---"What are they doing now?"
    officer_sees_brawl = 57,
    ---"Ahem!"
    officer_ends_brawl = 58,
    ---"Halt!"
    officer_stops_patrol = 59,
    ---"Forward, march!"
    officer_starts_patrol = 60,
    ---"Bunch of incompetents!"
    officer_complains = 61,
    ---"What is it, soldier?"
    officer_asks_whats_up = 62,
    ---"Where?"
    officer_asks_where = 63,
    ---"Dismissed!"
    officer_ends_conversation = 64,
    ---"Soldier!"
    officer_calls_soldier = 65,
    ---"Go and look over there."
    officer_sends_out_soldier = 66,
    ---"Guards, to me!"
    officer_calls_group = 67,
    ---"Search the area!"
    officer_sends_out_group = 68,
    ---"Find me that shirker!"
    officer_sends_out_group_for_charly = 69,
    ---"So? Leaving your post?"
    officer_rebukes_charly = 70,
    ---"Three days in the cells!"
    officer_rebukes_charly_end = 71,
    ---"Soldiers! Attack!"
    officer_gives_attack_order = 72,
    ---"I'm out of arrows!"
    out_of_ammunition = 73,
    ---Laughs.
    special_action = 74,
    ---For scripts: "So that's what it looks like?"
    admires_object = 75,
    ---For scripts: "Blast! It's gone!"
    misses_object = 76,
    ---"On my way!"
    give_or_receive_order = 77,
    ---"Oh, the poor man!"
    civilian_sees_body = 78,
    ---"But he's dead!"
    civilian_sees_dead_body = 79,
    ---"Hey, guard!"
    civilian_calls_soldier = 80,
    ---"They went that way!"
    civilian_denounces = 81,
    ---"Isn't he handsome!"
    civilian_admires_robin = 82,
    ---"Help!"
    civilian_panic = 83,
    ---"Mercy!"
    civilian_wounded = 84,
    civilian_dies = 85,
    ---"Oh, thank you, thank you."
    civilian_thanks = 86,
    ---"It's horrible, horrible."
    civilian_cries = 87,
    ---"A good pint warms you up..."
    civilian_beer_yes = 88,
    ---"No, it would go to my head..."
    civilian_beer_no = 89,
    ---"Well? Caught one at last?"
    civilian_sees_soldiers_under_net = 90,
    ---"Who did this?"
    civilian_under_net = 91,
    ---"Oh, you naughty little boy!"
    civilian_apple = 92,
    ---"Help, wasps!"
    civilian_wasps = 93,
    ---"Stop it, my husband will hear you!"
    civilian_whistling = 94,
    ---"What a bunch of brutes!"
    civilian_sees_brawl = 95,
    ---"Oh! What luck!"
    civilian_gold_yes = 96,
    ---"Money doesn't buy happiness..."
    civilian_gold_no = 97,
    ---"Alms, good sir, alms!"
    beggar_begging = 98,
    ---"Thank you! Let me tell you..."
    beggar_gives_info = 99,
    ---"A few more coins, my lord?"
    beggar_wants_more = 100,
    ---"My last piece of advice..."
    beggar_gives_last_info = 101,
    ---"Oh, thank you!"
    beggar_thanks = 102,
    ---"There, there."
    beggar_identifies_himself = 103,
    ---"It wasn't me!"
    child_caught_by_soldier = 104,
    ---"You won't catch me!"
    child_chased_by_soldier = 105,
    ---"Cut him to pieces!"
    vip_proud_dont_fight = 106,
    ---"Out of my way, you incompetents!"
    vip_proud_finally_fight = 107,
    ---"I'll crush you!"
    vip_starts_combat = 108,
    ---"Argh!"
    vip_wounded = 109,
    ---"Dark... all is so dark..."
    vip_dies = 110,
    ---"That hurts, doesn't it?"
    vip_good_strike_combat = 111,
    ---"I won't kill you right away..."
    vip_war_cry = 112,
    ---"Pff, too easy."
    vip_victory = 113,
    ---"A battle! Give me a battle!"
    vip_speaks_to_himself = 114,
    ---"Warm beer! I'll have that insolent whipped!"
    vip_ale_no = 115,
    ---"Ha! What a grotesque idea!"
    vip_net_no = 116,
    ---"An apple? I asked for venison, dammit!"
    vip_apple_no = 117,
    ---"Wasps? Hmm, that's an idea..."
    vip_wasps_no = 118,
    ---"If a servant picks it up, I'll have him whipped..."
    vip_gold_no = 119,
}

---PC speech line (Sequence:SpeakPc, and Sequence:Speak on a PC). The sound comes from the PC's
---exclamation set; the variant argument of Sequence:SpeakPc picks a recording (255 = random).
---@enum PcRemark
PcRemark = {
    provoke_duel = 0,
    provoke_opponent = 1,
    successful_blow = 2,
    swear_at = 3,
    war_cry = 4,
    stun_enemy = 5,
    provoke_vip = 6,
    killed_opponent = 7,
    hurt = 8,
    ---Soldiers are shooting at the PC.
    soldiers_firing_at = 9,
    die = 10,
    ---Answer when selected.
    select = 11,
    accept_command = 12,
    done_command = 13,
    ---Cannot do what was ordered.
    unable_to_do = 14,
    ---Up high and sees an enemy.
    perched_sees_enemy = 15,
    give_money = 16,
    get_bonus_a = 17,
    get_bonus_c = 18,
    ---Uses a four-leaf clover.
    use_leaf_clover = 19,
    get_money = 20,
    find_money = 21,
    healed = 22,
    ---Wakes up after being knocked out.
    recover = 23,
    out_of_ammo = 24,
    caught_by_net = 25,
    ---Line 1 reserved for mission scripts.
    script_1 = 26,
    ---Line 2 reserved for mission scripts.
    script_2 = 27,
    ---Line 3 reserved for mission scripts.
    script_3 = 28,
    ---Line 4 reserved for mission scripts.
    script_4 = 29,
    ---Line 5 reserved for mission scripts.
    script_5 = 30,
    ---Line 6 reserved for mission scripts.
    script_6 = 31,
}

---Animation (sprite row) of an actor, target or object. 0-282 are animations that
---Sequence:PlayAnim / Loop / Freeze and Sequence:ReplaceAnim can play when the element's sprite
---sheet has them (a sheet row's id must be below 283). 283 and above are not animations:
---Actor.current_action and the ActionChange callback report the actor's current order, which can be
---one of them. For targets the id is simply a row of the target's own sheet.
---@enum ActorAction
ActorAction = {
    ---Standing idle, bored.
    waiting_bored = 0,
    ---Random idle animation.
    waiting_bored_random = 1,
    bored_to_waiting = 2,
    ---Standing.
    waiting = 3,
    waiting_to_bored = 4,
    ---Start walking.
    waiting_to_walking = 5,
    walking = 6,
    walking_stairs = 7,
    ---Stop walking.
    walking_to_waiting = 8,
    walking_to_running = 9,
    running = 10,
    running_to_walking = 11,
    ---Stop running.
    running_to_waiting = 12,
    crouching_down = 13,
    waiting_crouched = 14,
    waiting_crouched_to_walking_crouched = 15,
    walking_crouched = 16,
    walking_crouched_to_waiting_crouched = 17,
    ---Stand up from crouching.
    crouching_up = 18,
    start_climbing_wall_up = 19,
    climbing_wall_up = 20,
    climbing_wall_down = 21,
    end_climbing_wall_up = 22,
    end_climbing_wall_down = 23,
    start_climbing_wall_down = 24,
    start_jumping_up = 25,
    jumping_up = 26,
    end_jumping_up = 27,
    start_jumping_down = 28,
    jumping_down = 29,
    end_jumping_down = 30,
    start_jumping_long = 31,
    jumping_long = 32,
    end_jumping_long = 33,
    start_climbing_ladder_up = 34,
    climbing_ladder_up = 35,
    end_climbing_ladder_up = 36,
    start_climbing_ladder_down = 37,
    climbing_ladder_down = 38,
    end_climbing_ladder_down = 39,
    ---Hit by an arrow, pulling it out.
    extracting_arrow = 40,
    dying = 41,
    extracting_arrow_crouched = 42,
    dying_crouched = 43,
    ---Falling on the back (also used for dying).
    falling_back = 44,
    ---Lying dead on the back.
    dead_fallen_back = 45,
    falling_back_crouched = 46,
    ---Lying dead.
    dead = 47,
    ---Lying knocked out.
    unconscious = 48,
    standing_up = 49,
    turning = 50,
    ---Start running.
    waiting_to_running = 51,
    raising_sword = 52,
    lowering_sword = 53,
    ---Standing with the sword drawn.
    waiting_sword = 54,
    walking_sword = 55,
    walking_backwards_sword = 56,
    strafing_right_sword = 57,
    strafing_left_sword = 58,
    ---Sword fight exchange.
    striking_right_smalltalk = 59,
    ---Sword fight exchange.
    striking_left_smalltalk = 60,
    ---Sword fight exchange.
    parrying_right_smalltalk = 61,
    ---Sword fight exchange.
    parrying_left_smalltalk = 62,
    ---Sword fight exchange.
    striking_low_right_smalltalk = 63,
    ---Sword fight exchange.
    striking_low_left_smalltalk = 64,
    ---Sword fight exchange.
    parrying_low_right_smalltalk = 65,
    ---Sword fight exchange.
    parrying_low_left_smalltalk = 66,
    ---Sword strike A.
    striking_straight_sword = 67,
    ---Sword strike B.
    striking_straight_strong_sword = 68,
    ---Sword strike E.
    striking_right_sword = 69,
    ---Sword strike D.
    striking_left_sword = 70,
    ---Sword strike I.
    striking_round_right_sword = 71,
    ---Sword strike H.
    striking_round_left_sword = 72,
    ---Sword strike G.
    striking_half_round_right_sword = 73,
    ---Sword strike F.
    striking_half_round_left_sword = 74,
    ---Sword strike C.
    executing_sword = 75,
    start_parrying_sword = 76,
    parrying_sword = 77,
    end_parrying_sword = 78,
    parrying_low_sword = 79,
    walking_to_walking_crouched = 81,
    walking_crouched_to_walking = 82,
    running_to_walking_crouched = 83,
    walking_crouched_to_running = 84,
    equipping_bow = 85,
    unequipping_bow = 86,
    loading_bow = 87,
    unloading_bow = 88,
    aiming_bow = 89,
    ---Raise the bow to aim upwards.
    raising_bow = 90,
    lowering_bow = 91,
    aiming_bow_up = 92,
    shooting_bow = 93,
    shooting_bow_up = 94,
    ---Sword provocation.
    provoking = 96,
    start_jumping_long_sword = 97,
    end_jumping_long_sword = 98,
    jumping_long_sword = 99,
    striking_down_sword = 100,
    ---Exhausted in a sword fight.
    weak_sword = 101,
    hit_sword = 102,
    stunned_sword = 103,
    extracting_arrow_sword = 104,
    dying_sword = 105,
    dead_sword = 106,
    falling_back_sword = 107,
    unconscious_sword = 108,
    dead_fallen_back_sword = 109,
    standing_up_sword = 110,
    extracting_arrow_bow = 111,
    dying_bow = 112,
    dead_bow = 113,
    falling_back_bow = 114,
    unconscious_bow = 115,
    dead_fallen_back_bow = 116,
    standing_up_bow = 117,
    ---Body being lifted by Little John.
    lifted_by_little_john = 118,
    ---Body carried by Little John.
    carried_by_little_john = 119,
    ---Body being lifted by merry man C.
    lifted_by_farmer_c = 120,
    ---Body carried by merry man C.
    carried_by_farmer_c = 121,
    searching = 122,
    ---Punch.
    hitting = 123,
    throwing_purse = 124,
    paying = 125,
    ---Picking something up.
    taking = 126,
    rolling = 127,
    climbing_up_on_shoulders = 128,
    climbing_down_from_shoulders = 129,
    waiting_on_shoulders = 130,
    jumping_up_from_shoulders = 131,
    jumping_long_from_shoulders = 132,
    wriggling_under_net = 133,
    ---Hidden under the cape.
    waiting_cape = 134,
    cape_to_waiting = 135,
    waiting_hidden = 136,
    hidden_to_waiting = 137,
    ---Using a target by hand.
    handling_target = 138,
    hitting_target = 139,
    waiting_alerted = 140,
    waiting_to_alerted = 141,
    alerted_to_waiting = 142,
    walking_alerted = 143,
    waiting_alerted_to_walking_alerted = 144,
    waiting_alerted_to_running_alerted = 145,
    walking_alerted_to_waiting_alerted = 146,
    running_alerted_to_walking_alerted = 147,
    running_alerted_to_waiting_alerted = 148,
    walking_alerted_to_running_alerted = 149,
    turning_alerted = 150,
    walking_stairs_alerted = 151,
    menacing = 152,
    waiting_sword_to_menacing = 153,
    menacing_to_waiting_sword = 154,
    charging = 156,
    sitting_down = 158,
    sitting = 159,
    getting_up_from_sitting = 160,
    ---Falling asleep standing (halberdiers, lancers).
    start_sleeping = 161,
    ---Sleeping standing.
    sleeping = 162,
    ---Waking up from sleeping standing.
    sleeping_to_waiting = 163,
    strangled = 164,
    drinking_ale = 165,
    getting_free_from_wasps = 166,
    throwing_net = 168,
    taking_net = 169,
    raising_shield = 170,
    waiting_shield = 171,
    parrying_shield = 172,
    lowering_shield = 173,
    walking_shield = 174,
    walking_backwards_shield = 175,
    strafing_right_shield = 176,
    strafing_left_shield = 177,
    dropped_by_little_john = 178,
    dropped_by_farmer_c = 179,
    ---Start giving a leg up.
    start_helping_climb = 180,
    end_helping_climb = 181,
    waiting_helping_climb = 182,
    helping_climb_up = 183,
    using_lever = 184,
    start_carrying_corpse = 185,
    waiting_with_corpse = 186,
    walking_with_corpse = 187,
    end_carrying_corpse = 188,
    waking_up = 189,
    ---Bonus item / object animation 1.
    bonus_1 = 190,
    ---Bonus item / object animation 2.
    bonus_2 = 191,
    ---Bonus item / object animation 3 (opened scroll).
    bonus_3 = 192,
    ---Bonus item / object animation 4.
    bonus_4 = 193,
    ---Bonus item / object animation 5.
    bonus_5 = 194,
    object_lying = 195,
    object_flying = 196,
    object_bursting = 197,
    waiting_carrying_on_shoulders = 199,
    helping_climb_down = 200,
    walking_carrying_on_shoulders = 201,
    looking_right = 202,
    looking_left = 203,
    looking_right_alerted = 204,
    looking_left_alerted = 205,
    pointing = 206,
    start_leaning_out = 207,
    end_leaning_out = 208,
    leaning_out = 209,
    ---Target animation 1: a row of a target's own sheet (levers, gates, ...).
    target_1 = 210,
    ---Target animation 2.
    target_2 = 211,
    ---Target animation 3.
    target_3 = 212,
    ---Target animation 4.
    target_4 = 213,
    ---Target animation 5.
    target_5 = 214,
    falling_in_hole = 215,
    gathering_soldiers = 216,
    healing = 217,
    throwing_apple = 218,
    ---Being tied up.
    tied = 219,
    throwing_stone = 220,
    ---Net object.
    net_unfolding = 221,
    ---Net object.
    net_moving = 222,
    ---Net object.
    net_taken = 223,
    ---Net object.
    net_unfolding_crumpled = 224,
    ---Net object.
    net_lying_crumpled = 225,
    ---Net object.
    net_taken_crumpled = 226,
    start_climbing_ladder_up_alerted = 227,
    climbing_ladder_up_alerted = 228,
    end_climbing_ladder_up_alerted = 229,
    start_climbing_ladder_down_alerted = 230,
    climbing_ladder_down_alerted = 231,
    end_climbing_ladder_down_alerted = 232,
    ---Officer variant.
    alerted_to_waiting_officer = 233,
    lowering_bow_leaning_out = 234,
    raising_bow_leaning_out = 235,
    aiming_bow_leaning_out = 236,
    shooting_bow_leaning_out = 237,
    eating = 238,
    unlocking_door = 239,
    ---Tying someone up.
    tying = 240,
    dropping_ale = 241,
    ---Disguised as a beggar.
    simulating_beggar = 242,
    throwing_wasp_nest = 243,
    strangling = 244,
    raising_to_strangle = 245,
    start_simulating_beggar = 246,
    end_simulating_beggar = 247,
    taking_crouched = 248,
    ---The carried PC jumped off.
    end_carrying_on_shoulders = 249,
    weeping = 250,
    start_listening = 251,
    listening = 252,
    end_listening = 253,
    whistling = 254,
    end_climbing_wall_up_crenel = 255,
    start_climbing_wall_down_crenel = 256,
    ---Beggar.
    receiving_purse = 264,
    ---Beggar.
    waiting_with_purse = 265,
    ---Beggar.
    end_waiting_with_purse = 266,
    beggar_showing_face = 267,
    ---Character-specific special animation.
    start_special = 268,
    end_special = 269,
    ---Character-specific special animation.
    special = 270,
    unlocking_trap = 271,
    ---Hidden archer variant.
    equipping_bow_anonymous = 272,
    ---Hidden archer variant.
    unequipping_bow_anonymous = 273,
    ---Hidden archer variant.
    loading_bow_anonymous = 274,
    ---Hidden archer variant.
    unloading_bow_anonymous = 275,
    ---Hidden archer variant.
    aiming_bow_anonymous = 276,
    ---Hidden archer variant.
    raising_bow_anonymous = 277,
    ---Hidden archer variant.
    lowering_bow_anonymous = 278,
    ---Hidden archer variant.
    aiming_bow_up_anonymous = 279,
    ---Hidden archer variant.
    shooting_bow_anonymous = 280,
    ---Hidden archer variant.
    shooting_bow_up_anonymous = 281,
    searching_crouched = 282,
    ---Not an animation: reported when the actor has no current order.
    no_action = 283,
    ---Not an animation: a script animation (Sequence:PlayAnim) is playing.
    playing_custom = 284,
    ---Not an animation: Sequence:PlayAnimLoop is playing.
    playing_custom_looped = 285,
    ---Not an animation: Sequence:PlayAnimFreeze is playing.
    playing_custom_freeze = 286,
    ---Not an animation: frozen on the last frame after Sequence:PlayAnimFreeze.
    playing_custom_frozen = 287,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    plouf = 288,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    explode = 289,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    rider_charging = 290,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    invalid = 291,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    freezing = 292,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    waiting_free_lift = 293,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    running_stairs = 294,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    passing_door = 295,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    climbing_ladder_up_fast = 296,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    climbing_ladder_down_fast = 297,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    climbing_wall_up_fast = 298,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    climbing_wall_down_fast = 299,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_ladder_wall = 300,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_shoulders = 301,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    crossing_road = 302,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    walking_with_sword = 303,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    running_with_sword = 304,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    walking_with_shield = 305,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    select = 306,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit = 307,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_bow = 308,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_sword = 309,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_crouched = 310,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_harder = 311,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_harder_bow = 312,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_harder_sword = 313,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_hit_harder_crouched = 314,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_pushed = 315,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_pushed_bow = 316,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_pushed_sword = 317,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    falling_pushed_crouched = 318,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    hiding_behind_shield = 319,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    start_parrying_sword_low = 320,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    dropping_ammo = 321,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    dropping_ammo_crouched = 322,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    dropping_ale_crouched = 323,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    lying_stuck_under_net = 324,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    getting_wounded = 325,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    waiting_cape_anonymous_archer = 326,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    taking_target = 327,
    ---Not an animation: only reported by Actor.current_action / ActionChange, cannot be played.
    refreshing_seek = 328,
}

---How a character moves when it follows another one with Sequence:SeekActor: 1 walks, every other
---value runs (the reverse of MovementStyle).
---@enum SeekStyle
SeekStyle = {
    running = 0,
    walking = 1,
}

---Who a repulsive point keeps away (Location:AddRepulsivePoint); combine them with |.
---@enum RepulsiveTarget
RepulsiveTarget = {
    ---The point repels PCs.
    pcs = 1,
    ---The point repels soldiers.
    soldiers = 2,
    ---The point repels civilians.
    civilians = 4,
    ---The point repels animals.
    animals = 8,
}

-- ===== Saved state ===========================================================

---The script's state that survives savegames. Entries are matched by name when a savegame is
---loaded, so entries the script adds later keep their default. Values: booleans, numbers, strings,
---tables of those, and the mission's objects: actors, items, scrolls, locations, patrols, doors,
---patches, sound sources, buildings and mobile elements (saved by their name).
---Other Lua variables start from scratch when a savegame is loaded.
---
---```lua
---Globals = { alarm = false, visits = 0 }
---```
---@type table<string, any>?
Globals = nil

-- ===== Mission events ========================================================
-- The mission script defines these global functions; the game calls them.

---Called once when the mission starts.
---@param seed integer A random number, different for every start of the mission.
function Initialize(seed) end

---Called after Initialize once the mission is set up: assign patrols and start the intro here.
function PostInitialize() end

---Called every second.
---@param seconds integer Seconds since the mission started.
function Timer(seconds) end

---Called every three seconds to ask whether the mission is over.
---@param seconds integer Seconds since the mission started.
---@return MissionResult result
function CheckVictoryCondition(seconds) end

---Called when the mission script gets a message: SendMessage(God(), ...) or a sequence's
---Sequence:SendMessage(God(), ...).
---@param message integer The message number the sender chose.
---@param argument integer The first number of SendMessageWithArguments (0 otherwise).
---@param extended integer The second number of SendMessageWithArguments (0 otherwise).
function ProcessMessage(message, argument, extended) end

---Called when the mission ends.
---@param value integer 0 or 1 (meaning unknown).
function Finalize(value) end

---Called once when a key goes down while the mission runs (not in the pause menu, the save and
---load screens, the map or the debriefing). Keys the game uses (Escape, F5, ...) are reported too.
---@param scanCode integer The key's DirectInput scan code, e.g. 57 for the space bar, the same as in Desperados
---(https://learn.microsoft.com/en-us/previous-versions/windows/desktop/bb321074(v=vs.85)).
function KeyPressed(scanCode) end

-- ===== Script classes ========================================================
-- An element whose script class is "Guard" runs the functions of the global table Guard when
-- something happens to it. Declare the table with the matching class to get completion:
--
--   ---@type ActorScriptEvents
--   Guard = {}
--
--   function Guard.ActionChange(action, oldAction)
--       ...
--   end
--
-- ThisActor() (ThisScroll() for scrolls) returns the element whose event runs.

---Events of a character with a script class.
---@class ActorScriptEvents
---@field Initialize? fun() Called once when the mission starts.
---@field ActionChange? fun(action: ActorAction, oldAction: ActorAction) Called when the character starts another action (its current order: an animation id, or 283 and above for orders without one).
---@field FilterAiEvent? fun(actorSource: Actor?, event: AiEvent): boolean? Called for everything the character notices (a noise, a body, ...); return false to make it ignore this one.
---@field ProcessMessage? fun(message: integer, argument: integer, extended: integer) Called when the character gets a message (SendMessage, Sequence:SendMessage).

---Events of a target (something the heroes use) with a script class.
---@class TargetScriptEvents
---@field Initialize? fun() Called once when the mission starts.
---@field ActivatedByApple? fun(actorSource: Actor?) Called when a hero uses an apple on it.
---@field ActivatedByArrow? fun(actorSource: Actor?) Called when an arrow hits it.
---@field ActivatedByHand? fun(actorSource: Actor?) Called when a hero uses it by hand.
---@field ActivatedByHeal? fun(actorSource: Actor?) Called when a hero heals it.
---@field ActivatedByLever? fun(actorSource: Actor?) Called when a hero pulls its lever.
---@field ActivatedByMoney? fun(actorSource: Actor?) Called when a hero gives it money.
---@field ActivatedBySearch? fun(actorSource: Actor?) Called when a hero searches it.
---@field ActivatedByStone? fun(actorSource: Actor?) Called when a stone hits it.
---@field ActivatedBySword? fun(actorSource: Actor?) Called when a sword hits it.
---@field ActivatedByListenable? fun(actorSource: Actor?) Called when a hero listens to it.

---Events of a scroll with a script class.
---@class ScrollScriptEvents
---@field Initialize? fun() Called once when the mission starts.
---@field Taken? fun(actorSource: Actor?): boolean Called when a hero picks the scroll up: return true to let him take it; false, nothing or no Taken leaves the scroll opened where it lies (ScrollState.opened, logged as a warning when nothing answers).
---@field Timer? fun(seconds: integer) Called every second.

---Events of a script zone with a script class.
---@class ZoneScriptEvents
---@field Initialize? fun() Called once when the mission starts.
---@field Enter? fun(actor: Actor) Called when a character enters the zone.
---@field Exit? fun(actor: Actor) Called when a character leaves the zone.

---Events of a patrol waypoint with a script class.
---@class PatrolScriptEvents
---@field Initialize? fun() Called once when the mission starts.
---@field ReachPoint? fun(actor: Actor) Called when a character reaches the waypoint.

-- ===== RhMod functions =======================================================
-- Written in RhMod, not in the game.

---Where the mouse cursor points on the map.
---@return Position position
function GetMousePosition() end

---Runs one of the game's cheats as if the player typed it into the game's console (the ` key); case
---and extra spaces do not matter, words after the cheat's own are its arguments ("wappen 3"). Every
---cheat the console knows runs (with RhMod also the developers' ones), except ASSERTFALSE and
---CAMPAIGN, which cannot be run from a script. LEVEL TEXT needs the text's number, and WAPPEN takes
---a number, not a word. CHROMA recolors the selected hero ("chroma 0 60 120 100 100": the colors
---with a hue from 0 to 60 turned by 120, their saturation and brightness kept at 100 percent);
---it needs a selected hero and all five numbers. A cheat that switches on switches off when called
---again.
---@param name string The cheat, e.g. "goldeneye" or "cash".
---@return boolean ran false (with a warning) for an unknown or refused cheat, or outside a mission.
function Cheat(name) end

---Whether a cheat that switches on and off is on: GOLDENEYE, AI, BABYLON, FREEZE, PAMELA ANDERSON
---(PAM), SEEKANDDESTROY, MOTION, EULER, ELEVATION, BIG BROTHER, NOISE, EINSTEIN, PROJECTION,
---RAILROAD, COMPANIES, SHADOW, SPHERE, ANIM, LIGHT, PCSIGHT, CESTLAZONE. Use it with Cheat to set a
---state: if not IsCheatOn("goldeneye") then Cheat("goldeneye") end.
---@param name string The cheat, e.g. "pam".
---@return boolean on false (with a warning) for an unknown cheat or one that does its work at once.
function IsCheatOn(name) end

-- Game rules: where RhMod changes how the game plays, a mission can switch back to the game's own
-- behavior (or on). Every mission starts with the defaults; what the script sets holds for the
-- mission and comes back with its savegames. Call them in Initialize (or at the top of the script).

---Friendly fire: whether the heroes can attack soldiers of their own side: punch them (hit and hit
---hard), target them with the bow, apples and stones (their arrows hurt them as they hurt enemies),
---and tie them up when knocked out. The soldiers take it without hitting back and stay on the
---heroes' side. Off by default: the heroes cannot attack their own soldiers, as in the game, and
---cannot tie them up either. Nets catch anyone either way, and wasps only go after enemies.
---@param enabled boolean true lets the heroes attack and tie up their own soldiers
function SetFriendlyFire(enabled) end

---Whether friendly fire is on (SetFriendlyFire).
---@return boolean enabled
function IsFriendlyFireEnabled() end

---Whether soldiers of the heroes' side finish off knocked-out enemies, as they do in the game. Off
---by default: they leave knocked-out enemies lying and go on fighting the others.
---@param enabled boolean true gives back the game's behavior
function SetFriendlyExecution(enabled) end

---Whether soldiers of the heroes' side finish off knocked-out enemies (SetFriendlyExecution).
---@return boolean enabled
function IsFriendlyExecutionEnabled() end

---Smart archery: archers and crossbowmen of both sides do not shoot at those their arrows cannot
---hurt (knights, riders and any other soldier immune to arrows), and when they cannot take a
---shot they move to a place with a clear one instead of standing with the bow drawn: a place from
---where they still see the target and no friend stands in the line of fire. A shield bearer
---covering one goes along and covers him there. On by default.
---@param enabled boolean false gives back the game's archers
function SetSmartArchery(enabled) end

---Whether smart archery is on (SetSmartArchery).
---@return boolean enabled
function IsSmartArcheryEnabled() end

---Writes a line to rhmod.log (and the console when it is open).
---@param message string
function LogDebug(message) end

---Writes a line to rhmod.log (and the console when it is open).
---@param message string
function LogInfo(message) end

---Writes a warning to rhmod.log (and the console when it is open).
---@param message string
function LogWarn(message) end

---Writes an error to rhmod.log (and the console when it is open).
---@param message string
function LogError(message) end

-- ===== Camera, map and screen ==================================================

---Shows the mission dialog with this ID right away in the dialog window; the game waits until
---the player has gone through it. Inside a cutscene use Sequence:PlayDialog, which waits for its
---turn in the sequence.
---@param dialog integer dialog number in the mission's dialog list, from 0 (an invalid number only logs a warning)
function StartDialog(dialog) end

---Starts scrolling the camera so that it centers on a point, speeding up as it goes (clamped at
---the map edges). It does not wait for the camera to arrive; in a cutscene use
---Sequence:ScrollCameraTo.
---@param position Location a point location (Locations.Name); a zone does not work here
---@return boolean # true when the scroll was started, false for nil.
function ScrollCameraTo(position) end

---Like ScrollCameraTo, but with a chosen starting speed.
---@param position Location a point location (Locations.Name); a zone does not work here
---@param speed number starting scroll speed in map pixels per frame (25 frames per second); ScrollCameraTo uses 2
---@return boolean # true when the scroll was started, false for nil.
function ScrollCameraSlowlyTo(position, speed) end

---Moves the camera instantly so that it centers on a point (clamped at the map edges).
---@param position Location a point location (Locations.Name); a zone does not work here
---@return boolean # true when the camera moved, false for nil.
function JumpCameraTo(position) end

---Sets the camera zoom right away.
---@param zoomLevel ZoomLevel the zoom factor: ZoomLevel.far, ZoomLevel.default or ZoomLevel.close (other values are refused)
---@return boolean # true when the zoom was set, false (with an error) for another value.
function SetZoomLevel(zoomLevel) end

---Opens or closes the map (the large minimap view).
---@param on boolean true opens the map, false closes it
---@return boolean # Always true.
function DisplayMap(on) end

---Opens the game's debug console. For testing only.
function DisplayConsole() end

---Removes a point placed with Location:AddRepulsivePoint.
---@param id integer the ID Location:AddRepulsivePoint returned
function DeleteRepulsivePoint(id) end

---Fades the screen to black and back in. The game stands still while it runs.
---@param speed integer length of each half (fade out, fade in) in screen refreshes; a negative one is refused with a warning
function FadeToBlack(speed) end

-- ===== Objectives and texts ====================================================

---Adds an objective to the mission's objective list (the short briefing shown in the pause menu).
---Adding one that is already there does nothing.
---@param id integer text ID of the objective in the mission's short briefing texts
---@param primary boolean true for a main objective, false for a secondary one
function AddObjective(id, primary) end

---Marks an objective in the objective list as done. Does nothing for an ID that was never added.
---@param id integer text ID of the objective, as given to AddObjective
function CompleteObjective(id) end

---Chooses which debriefing text is shown when the mission ends, won or lost. Call it just before
---the mission ends (for example in CheckVictoryCondition).
---@param id integer debriefing text ID of the mission
function ChooseVictoryDefeatText(id) end

---Makes the game call CheckVictoryCondition at the next full second instead of waiting for the
---regular three-second check.
function ForceCheckVictory() end

---Shows a text from the mission's popup texts in a scroll window right away (the game waits until
---the player closes it).
---@param popupTextId integer popup text ID of the mission
function DisplayPopupText(popupTextId) end

-- ===== Sequences ===============================================================
-- A sequence is a little scene the game plays over time: characters walk and speak, the camera
-- moves. Sequence() starts one, each step records at once and returns the sequence (so the steps
-- chain with ':'), and Start() plays it while the script goes on. Steps between two Then() happen
-- at the same time; a step after Then() waits until the steps before it are done.
--
--   Sequence()
--     :LockUser()
--     :Move(guard, Locations.Gate, MovementStyle.walking)
--     :Then()
--     :Wait(2)
--     :Then()
--     :Call("GuardAtGate", guard)
--     :UnlockUser()
--     :Start()
--
-- A sequence can be built in parts too (local sequence = Sequence() ... sequence:Start()), with
-- ifs and loops in between. One sequence is recorded at a time: Sequence() while another is still
-- open is an error. Several can play at once. A sequence an event records but never starts is
-- started when the event ends, with a warning in rhmod.log; a step that is not possible is skipped
-- with a warning naming its line.

---Starts recording a sequence. Add its steps with ':' and play it with Start().
---@return Sequence sequence
function Sequence() end

---A sequence being recorded (Sequence()). Each step records at once and returns the sequence.
---@class Sequence
local Sequence = {}

---Starts the next step: everything recorded after Then() waits until everything recorded since the
---previous Then() has finished; steps between two Then() calls happen at the same time. Several
---Then() in a row without a step in between count as one.
---@return Sequence
function Sequence:Then() end

---Waits: what comes after the next Then() starts this much later.
---@param seconds number Time to wait in seconds (the game runs 25 frames a second, so 0.04 is the shortest wait).
---@return Sequence
function Sequence:Wait(seconds) end

---Runs a Lua function when the sequence gets there. Call("Name", ...) calls the global function
---Name (or "Table.Name") with the arguments and survives savegames; a function value only survives a
---quickload in the same game session.
---@param callback function|string The function, or the name of a global function.
---@param ... any Arguments for a named function, saved like Globals values.
---@return Sequence
function Sequence:Call(callback, ...) end

---Finishes recording and plays the sequence. The script goes on at once while the sequence plays
---over time; no steps can be added afterward.
---@return boolean played true; an empty sequence is dropped (still true).
function Sequence:Start() end

-- ===== Sequence steps: camera and screen =======================================

---A camera scroll to a point; the step ends when the camera has arrived.
---@param location Location a point location (Locations.Name); a zone does not work here
---@return Sequence
function Sequence:ScrollCameraTo(location) end

---An instant camera jump to a point.
---@param location Location a point location (Locations.Name); a zone does not work here
---@return Sequence
function Sequence:JumpCameraTo(location) end

---A camera scroll to a point at a constant speed; the step ends when the camera has arrived.
---@param location Location a point location (Locations.Name); a zone does not work here
---@param speed integer scroll speed in map pixels per frame (25 frames per second); 0 uses the normal accelerating scroll
---@return Sequence
function Sequence:MoveCameraTo(location, speed) end

---A zoom change: the camera zooms when the sequence gets there.
---@param zoomValue ZoomLevel the zoom factor: ZoomLevel.far, ZoomLevel.default or ZoomLevel.close (other values are refused)
---@return Sequence
function Sequence:SetZoomLevel(zoomValue) end

---Opening or closing the map.
---@param display boolean true opens the map, false closes it
---@return Sequence
function Sequence:DisplayMap(display) end

---Graying out or re-enabling one of a hero's action buttons on the portrait bar.
---@param actor Actor a hero (PC); nil is refused with a warning
---@param action integer action slot on the hero's portrait, 0-2
---@param available boolean true enables the button, false grays it out
---@return Sequence
function Sequence:ActionAvailable(actor, action, available) end

---Making a hero playable or unplayable: an unplayable hero cannot be selected or controlled but
---stays in the world.
---@param actor Actor a hero (PC); other characters are not supported and nil is refused with a warning
---@param available boolean true makes the hero playable, false takes control away
---@return Sequence
function Sequence:CharacterAvailable(actor, available) end

---Locking the camera on an actor: it follows that actor until Sequence:ClearCameraLock.
---@param actor Actor an actor (Actors.Name, ThisActor(), GetPc(i), ...); nil is refused with a warning
---@return Sequence
function Sequence:LockCameraOn(actor) end

---Releasing a camera lock set with Sequence:LockCameraOn.
---@return Sequence
function Sequence:ClearCameraLock() end

---Showing a mission dialog; the step ends when the dialog is closed.
---@param dialogId integer dialog number in the mission's dialog list, from 0
---@return Sequence
function Sequence:PlayDialog(dialogId) end

---Freezing or unfreezing the whole level (see FreezeAll).
---@param freeze boolean true freezes, false lets everything run again
---@return Sequence
function Sequence:FreezeAll(freeze) end

---Showing a popup text scroll; the step ends when the player closes it.
---@param popupTextId integer popup text ID of the mission
---@return Sequence
function Sequence:DisplayPopupText(popupTextId) end

-- ===== Sequence steps: characters ==============================================

---Sending a message: when the sequence gets there, the ProcessMessage function of the actor's
---script class runs with (messageCode, 0, 0); with God() the level script's ProcessMessage runs.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
---@return Sequence
function Sequence:SendMessage(actor, messageCode) end

---Like Sequence:SendMessage, but ProcessMessage receives two extra numbers.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
---@param argument1 integer first number passed to ProcessMessage
---@param argument2 integer second number passed to ProcessMessage
---@return Sequence
function Sequence:SendMessageWithArguments(actor, messageCode, argument1, argument2) end

---A character walking or running to a point along a computed path; the step ends on arrival. The
---path is planned when you record it, starting from where the character is, or from where an
---earlier move of this sequence left it.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@return Sequence
function Sequence:Move(actor, location, style) end

---A character walking or running to a point, stopping as soon as it is within the given distance of
---it; otherwise like Sequence:Move.
---@param actor Actor a character (human or animal); nil is refused with a warning
---@param location Location a point location (Locations.Name); a zone does not work here
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@param tolerance integer distance in map pixels at which the character may stop
---@return Sequence
function Sequence:MoveNear(actor, location, style, tolerance) end

---A character entering the map from its edge: the character is placed outside the map behind the
---point and walks in to it. Also brings back a character that was sent away with actor.location =
---nil.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here (nil is refused with a warning)
---@param direction ActorDirection direction the character walks in, 0-15 (ActorDirection), or -1 for the way it currently faces
---@param style MovementStyle 0 walk, 1 run
---@return Sequence
function Sequence:EnterLevel(actor, location, direction, style) end

---A character walking to a point and then on in a direction until it has left the map.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here, the last point before the exit (nil is refused with a warning)
---@param direction ActorDirection direction in which the character leaves, 0-15 (ActorDirection), or -1 for the way it currently faces
---@param style MovementStyle 0 walk, 1 run
---@return Sequence
function Sequence:LeaveLevel(actor, location, direction, style) end

---A character turning to face a point.
---@param actor Actor a character (human or animal)
---@param location Location a point location (Locations.Name); a zone does not work here
---@return Sequence
function Sequence:TurnTo(actor, location) end

---A character or target playing one of its animations once.
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return Sequence
function Sequence:PlayAnim(actor, id) end

---A character or target playing an animation once and then holding its last frame (for example
---lying down or sitting).
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return Sequence
function Sequence:PlayAnimFreeze(actor, id) end

---A character or target playing one of its animations over and over.
---@param actor Actor a character or a target
---@param id ActorAction animation ID
---@return Sequence
function Sequence:PlayAnimLoop(actor, id) end

---Switching off a character's AI (like Actor:LockAi without remembering events): an NPC stops
---reacting to what it sees and hears so the sequence can move it freely.
---@param actor Actor an NPC or an animal
---@return Sequence
function Sequence:LockAi(actor) end

---Switching a character's AI back on; an NPC then returns to its duty.
---@param actor Actor an NPC or an animal
---@return Sequence
function Sequence:UnlockAi(actor) end

---Taking control away from the player: mouse and interface stop reacting and the heroes are
---deselected. Always record Sequence:UnlockUser at the end.
---@return Sequence
function Sequence:LockUser() end

---Giving control back to the player after Sequence:LockUser.
---@return Sequence
function Sequence:UnlockUser() end

---A character going after another (possibly moving) actor until it is within the given distance.
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style SeekStyle 1 walk, any other value run (the reverse of MovementStyle!)
---@param distance number distance in map pixels at which the character stops
---@return Sequence
function Sequence:SeekActor(actor, target, style, distance) end

---A character performing a scripted action such as turning, aiming, shooting, sword fighting or
---looking around.
---@param actor Actor a character
---@param id ScriptCommand action: 0 wait, 1 turn to direction number, 2 aim bow, 3 aim bow upwards, 4 shoot at actor number, 5 start a sword fight with actor number, 6 leave the sword fight, 7 parry, 8-16 sword thrusts A-I against actor number, 17 look left (soldiers only), 18 look right (soldiers only), 19 put the bow away, 20 crouch
---@param number integer for 1: direction 0-15; for 4, 5 and 8-16: the index of the target actor (Actor.index); ignored otherwise
---@return Sequence
function Sequence:Action(actor, id, number) end

---Replacing one of a character's animations with another (for example walking with a limp instead
---of walking) until Sequence:RestoreAnim.
---@param actor Actor a character
---@param oldAnim ActorAction animation ID to replace
---@param newAnim ActorAction animation ID to play instead
---@return Sequence
function Sequence:ReplaceAnim(actor, oldAnim, newAnim) end

---Undoing a Sequence:ReplaceAnim for one animation.
---@param actor Actor a character
---@param oldAnim ActorAction the animation ID that was replaced
---@return Sequence
function Sequence:RestoreAnim(actor, oldAnim) end

---A hero saying one of the hero remarks, in a chosen variant.
---@param actor Actor a hero (PC); nil is refused with a warning
---@param id PcRemark hero remark ID
---@param variant integer variant of the remark (which recording)
---@return Sequence
function Sequence:SpeakPc(actor, id, variant) end

---A character walking into a building: the door nearest to the point (within 300 map pixels) is
---used, and the character walks through it.
---@param actor Actor a character
---@param location Location a point location (Locations.Name); a zone does not work here near the building's door (nil is refused with a warning)
---@param style MovementStyle 0 walk, 1 run, 2 walk without letting the AI interrupt, 3 run without letting the AI interrupt
---@return Sequence
function Sequence:MoveIntoBuilding(actor, location, style) end

---A hero who can carry bodies (Little John or a merry man) going to a body and picking it up.
---@param taker Actor a hero with the carry action
---@param corpse Actor the knocked-out, tied or dead character to carry
---@param style MovementStyle 0 walk, any other value run
---@return Sequence
function Sequence:TakeCorpse(taker, corpse, style) end

---A hero putting down the body he is carrying.
---@param actor Actor a hero with the carry action (Little John or a merry man)
---@return Sequence
function Sequence:LeaveCorpse(actor) end

---Starting a cart (a mobile element) moving along its path.
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return Sequence
function Sequence:StartMobileElement(mobileElement) end

---Stopping a cart (a mobile element).
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return Sequence
function Sequence:StopMobileElement(mobileElement) end

---A character saying a remark: an NPC says an NPC remark, a hero says the hero remark with that ID
---(first variant). The remark is always spoken.
---@param actor Actor a human (NPC or hero); nil is refused with a warning
---@param id NpcRemark remark ID, below the number of NPC remarks
---@return Sequence
function Sequence:Speak(actor, id) end

---A character going after another actor until it is within the given distance, then sending a
---message to a script (as Sequence:SendMessage does).
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style MovementStyle 0 walk, any other value run
---@param distance number distance in map pixels at which the character stops
---@param actorEvent Actor receiver of the message: an actor with a script class, or God() for the level script
---@param id integer message number passed to ProcessMessage
---@return Sequence
function Sequence:SeekActorMessage(actor, target, style, distance, actorEvent, id) end

---Like Sequence:SeekActorMessage, with two extra numbers passed to ProcessMessage.
---@param actor Actor the character that moves
---@param target Actor the actor to go to
---@param style MovementStyle 0 walk, any other value run
---@param distance number distance in map pixels at which the character stops
---@param actorEvent Actor receiver of the message: an actor with a script class, or God() for the level script
---@param id integer message number, 1000 or more (up to 10000; RhMod uses 10001 and above)
---@param arg1 integer first number passed to ProcessMessage
---@param arg2 integer second number passed to ProcessMessage
---@return Sequence
function Sequence:SeekActorMessageWithArguments(actor, target, style, distance, actorEvent, id, arg1, arg2) end

---Making a cart (a mobile element) appear and take part in the game again.
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return Sequence
function Sequence:ActivateMobileElement(mobileElement) end

---Removing a cart (a mobile element) from the game (hidden and inactive).
---@param mobileElement MobileElement the cart (MobileElements.Name)
---@return Sequence
function Sequence:DeactivateMobileElement(mobileElement) end

---Revealing a 'blipped' character (see Actor:Reveal).
---@param actor Actor a character
---@return Sequence
function Sequence:Reveal(actor) end

-- ===== Characters ==============================================================

---Returns the element the current script event belongs to: the actor whose class event runs, the
---actor entering or leaving a zone, the actor reaching a waypoint, or the actor that received a
---message.
---@return Actor # That element, or nil when the event has none (for example in some level script events).
function ThisActor() end

---Returns how many elements the script element list has (characters, targets, items, scrolls,
---animations, carts); Actor.index runs from 0 to this number minus 1.
---@return integer # The number of script elements.
function GetNumberOfActorsInEngine() end

---Tells whether characters hidden behind walls and roofs are drawn as outlines.
---@return boolean # true when hidden characters are drawn as outlines.
function GetOutlineDisplay() end

---Switches drawing hidden characters as outlines on or off (the game's outline toggle).
---@param display boolean true shows outlines of hidden characters, false hides them
function SetOutlineDisplay(display) end

---Sends a message right away: the ProcessMessage function of the actor's script class runs with
---(messageCode, 0, 0); with God() the level script's ProcessMessage runs.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
function SendMessage(actor, messageCode) end

---Like SendMessage, but ProcessMessage receives two extra numbers.
---@param actor Actor? the receiving actor (it needs a script class), or God() (nil) for the level script
---@param messageCode integer your message number, up to 10000 (RhMod uses 10001 and above for Sequence:Call)
---@param argument1 integer first number passed to ProcessMessage
---@param argument2 integer second number passed to ProcessMessage
function SendMessageWithArguments(actor, messageCode, argument1, argument2) end

---Returns the 'level script' receiver: nil that makes SendMessage and Sequence:SendMessage deliver
---to the level script's ProcessMessage.
---@return nil
function God() end

-- ===== Heroes ==================================================================

---Selects all heroes or deselects all heroes.
---@param code PcSelection 31 selects all heroes, 0 deselects all; other values only log an error
---@return boolean # Always true.
function Select(code) end

---Checks whether any hero in the level has an ability, whether playable or not.
---@param actionCode PcAction action code: 0 bow, 1 punch, 2 hard punch, 3 money purse, 4 stone, 5 shield, 6 big shield, 7 strangle, 8 lever, 9 help climbing, 10 apple, 11 ale, 12 eat (lamb leg), 13 guzzle, 14 listen, 15 heal, 16 net, 17 beggar, 18 wasp nest, 19 whistle, 20 climb, 21 jump, 23 search, 24 resuscitate, 25 Little John's carry, 26 merry man's carry, 27 tie up, 28 pick locks, 29 execute
---@return boolean # true when at least one hero has it; false otherwise or (with an error) for an unknown code.
function HasAnyPcAction(actionCode) end

---Checks whether any playable hero in the level has an ability.
---@param actionCode PcAction action code: 0 bow, 1 punch, 2 hard punch, 3 money purse, 4 stone, 5 shield, 6 big shield, 7 strangle, 8 lever, 9 help climbing, 10 apple, 11 ale, 12 eat (lamb leg), 13 guzzle, 14 listen, 15 heal, 16 net, 17 beggar, 18 wasp nest, 19 whistle, 20 climb, 21 jump, 23 search, 24 resuscitate, 25 Little John's carry, 26 merry man's carry, 27 tie up, 28 pick locks, 29 execute
---@return boolean # true when a playable hero has it; false otherwise or (with an error) for an unknown code.
function HasAnyActivePcAction(actionCode) end

---Returns how many heroes the level has (dead and unplayable ones included).
---@return integer # The number of heroes; GetPc takes 0 to this number minus 1.
function GetNumberOfPcs() end

---Returns a hero of the level by number.
---@param i integer hero number, 0 to GetNumberOfPcs() - 1
---@return Actor # The hero.
function GetPc(i) end

-- ===== NPCs and their AI =======================================================

---Checks whether any civilian in the level has been killed.
---@return boolean # true when at least one civilian is dead.
function IsAnyCivilianDead() end

---Checks whether any soldier in the level has been killed. Soldiers of both sides count, friendly
---ones included.
---@return boolean # true when at least one soldier is dead.
function IsAnyEnemyDead() end

---Returns the highest alert state of all living soldiers (both sides count).
---@return AlertStatus # 0 calm, 1 suspicious, 2 alarmed (AlertStatus).
function GetOverallEnemyAlert() end

---Returns the highest alert state of all living civilians.
---@return AlertStatus # 0 calm, 1 suspicious, 2 alarmed (AlertStatus).
function GetOverallCivilianAlert() end

---Freezes or unfreezes the whole level: all animations stop and NPCs stop thinking. Use it for
---dramatic pauses in cutscenes.
---@param freeze boolean true freezes, false lets everything run again
function FreezeAll(freeze) end

---Sets how far all NPCs can see, at once for every NPC of the level.
---@param radius integer view distance in map pixels (the game uses 400 by day and 300 at night)
function SetViewRadius(radius) end

-- ===== Sounds ==================================================================

---Pauses all ambient sound sources of the level.
---@return boolean # Always true.
function SuspendAllSoundSources() end

---Resumes the ambient sound sources paused with SuspendAllSoundSources.
---@return boolean # Always true.
function ResumeAllSoundSources() end

-- ===== Buildings and script zones ==============================================

---Returns the 'nowhere' location, nil: actor.location = NoWhere() removes an element from the map
---(like actor.location = nil).
---@return nil
function NoWhere() end

-- ===== Helpers =================================================================

---Returns a random whole number from 0 to maximum - 1.
---@param maximum integer upper limit, 1 or more (0 is refused with a warning)
---@return integer # A random number from 0 to maximum - 1.
function Rand(maximum) end

---Prints a number to the game's debug console. In a Lua mission, print() or LogInfo() (to
---rhmod.log) is more useful.
---@param value integer the number to print
function PrintConsole(value) end

---Returns the bitwise AND of two integers. Lua 5.5 also has the & operator.
---@param i integer first integer
---@param j integer second integer
---@return integer # i AND j.
function BitwiseAnd(i, j) end

---Returns the bitwise OR of two integers. Lua 5.5 also has the | operator.
---@param i integer first integer
---@param j integer second integer
---@return integer # i OR j.
function BitwiseOr(i, j) end

---Returns the bitwise exclusive OR of two integers. Lua 5.5 also has the ~ operator.
---@param i integer first integer
---@param j integer second integer
---@return integer # i XOR j.
function BitwiseXor(i, j) end

-- ===== Sherwood and the campaign ===============================================

---Returns how many heroes are in the team chosen for the next mission. Meant for the Sherwood
---camp between missions.
---@return integer # The number of heroes in the mission team.
function GetSizeOfMissionTeam() end

---Returns a hero of the team chosen for the next mission. Meant for the Sherwood camp between
---missions.
---@param pc integer position in the mission team, 0 to GetSizeOfMissionTeam() - 1
---@return Actor? # The hero, or nil (with a warning) for a position out of range.
function GetPcFromMissionTeam(pc) end

---Adds a hero to the team for the next mission and outlines it briefly. Meant for the Sherwood
---camp between missions.
---@param actor Actor a hero (PC) (nil is refused with a warning)
function AddPcToMissionTeam(actor) end

---Removes a hero from the team for the next mission. Meant for the Sherwood camp between missions.
---@param actor Actor a hero (PC) (nil is refused with a warning)
function RemovePcFromMissionTeam(actor) end

---Returns how many heroes the next mission requires (for example Robin himself). Meant for the
---Sherwood camp between missions.
---@return integer # The number of required heroes.
function GetNumberOfObligatoryPcsInMissionTeam() end

---Returns one of the heroes the next mission requires. Meant for the Sherwood camp between
---missions.
---@param pc integer position in the list of required heroes, 0 to GetNumberOfObligatoryPcsInMissionTeam() - 1
---@return Actor # The required hero.
function GetObligatoryPcFromMissionTeam(pc) end

---Checks whether the next mission requires this hero. Meant for the Sherwood camp between
---missions.
---@param actor Actor a hero (PC)
---@return boolean # true when the hero is required.
function IsPcObligatoryInMissionTeam(actor) end

---Checks whether the team for the next mission contains every required hero and every required
---action (for example someone who can pick locks). Meant for the Sherwood camp between missions.
---@return boolean # true when the team can start the next mission.
function IsMissionTeamValid() end

---Returns the ID of the mission played last.
---@return integer # The mission ID from the campaign's mission list, or 0 when none was played yet.
function GetLastPlayedMission() end

---Returns the ID of the mission chosen to be played next.
---@return integer # The mission ID from the campaign's mission list, or 0 when none is chosen.
function GetNextPlayedMission() end

---Tells whether the Sherwood camp is in the mode where the player has picked the next mission and
---is choosing the merry men to send (the start button is enabled).
---@return boolean # true while that mode is active.
function IsMenToBlazonConversionMode() end

---Returns one of the royal relics if it lies active in the level (mainly for the Sherwood camp).
---@param id Relic relic: 0 ampulla, 1 coronation spoon, 2 Richard's crown, 3 royal seal, 4 royal sceptre, 5 Domesday Book, 6 Sword of State
---@return Item? # The relic item, or nil when it is not in the level (or the ID is unknown).
function GetRelic(id) end

---Reads one of the 20 campaign-wide numbers that scripts can use to pass information from one
---mission to another.
---@param index integer value number, 0-19
---@return integer # The stored number, or 0 (with an error) for an invalid index.
function GetCustomCampaignValue(index) end

---Stores one of the 20 campaign-wide numbers that scripts can use to pass information from one
---mission to another.
---@param index integer value number, 0-19
---@param value integer the number to store
function SetCustomCampaignValue(index, value) end

---Turns a script zone into a Sherwood workshop of the given type: merry men put there produce
---items, train or heal between missions. Meant for the Sherwood camp between missions.
---@param type ProductionType workshop type: 0 arrows, 1 purses, 2 stones, 3 apples, 4 ale, 5 lamb legs, 6 healing plants, 7 nets, 8 wasp nests, 9 bow training, 10 sword training, 11 healing, 12 relics
---@param sector Location a zone, i.e. a location that is an area (Locations.Name) (nil is refused with a warning)
---@param productionSpeed integer production speed; the produced amount grows with it, with the number of workers and with the length of the last mission
function RegisterAsProductionSector(type, sector, productionSpeed) end

---Adds a working spot to a Sherwood workshop type: a point where a merry man stands while working
---there. Meant for the Sherwood camp between missions.
---@param type ProductionType workshop type, as for RegisterAsProductionSector (0-12)
---@param point Location a point location (Locations.Name); a zone does not work here (nil is refused with a warning)
function AddProductionPoint(type, point) end

---Adds a new merry man (a peasant) to Robin's gang with the given skills. When heroes are away on
---secret missions, there is a one-in-two chance that one of them comes back instead and gets
---these skills.
---@param type FarmerType kind of merry man: 1, 2 or 3 (merry man A, B or C)
---@param experienceSword integer sword skill, 0-100
---@param experienceBow integer bow skill, 0-100
function AddFarmerToGang(type, experienceSword, experienceBow) end

---Shows the Sherwood production report (what the workshops produced) in a popup scroll. Meant for
---the Sherwood camp between missions.
function DisplaySherwoodReport() end

---Returns the ransom money Robin's gang has collected in the campaign.
---@return integer # The amount of money, or -1 (with an error) outside the campaign.
function GetRansomMoney() end

---Sets the ransom money Robin's gang has collected in the campaign.
---@param ransomMoneyAmount integer the new amount of money
function SetRansomMoney(ransomMoneyAmount) end

---Returns the difficulty the player chose for the current profile.
---@return DifficultyLevel # 0 easy, 1 medium, 2 hard.
function GetDifficultyLevel() end

---Returns how many heroes of the level are alive (knocked-out ones count as alive).
---@return integer # The number of living heroes.
function GetNumberOfPcsAlive() end

---Returns how many heroes the player has selected.
---@return integer # The number of selected heroes.
function GetNumberOfSelectedPcs() end

---Returns one of the selected heroes.
---@param index integer position among the selected heroes, 0 to GetNumberOfSelectedPcs() - 1
---@return Actor # The hero, or nil (with an error) when the index is too high.
function GetSelectedPc(index) end

---Plays the short music jingle the game uses when a trap is triggered.
function PlayTrapJingle() end

---Checks whether an ability is available in this mission: a living hero has it, or a dead merry
---man had it and a replacement of his kind is still waiting in Sherwood.
---@param actionCode PcAction action code: 0 bow, 1 punch, 2 hard punch, 3 money purse, 4 stone, 5 shield, 6 big shield, 7 strangle, 8 lever, 9 help climbing, 10 apple, 11 ale, 12 eat (lamb leg), 13 guzzle, 14 listen, 15 heal, 16 net, 17 beggar, 18 wasp nest, 19 whistle, 20 climb, 21 jump, 23 search, 24 resuscitate, 25 Little John's carry, 26 merry man's carry, 27 tie up, 28 pick locks, 29 execute
---@return boolean # true when the ability is or can become available; false otherwise or (with an error) for an unknown code.
function HasAnyPcActionWhoIsInThisLevelOrCouldMaybeComeFromSherwood(actionCode) end

---Checks whether merry men who were away on a secret mission have come back to Sherwood. Meant
---for the Sherwood camp between missions.
---@return boolean # true when they are back.
function SecretAgentsAreBackInSherwood() end

-- ===== Placeholders ============================================================

---Returns how many hero start positions (placeholders) the next mission has, which limits how
---many heroes can be sent. Only works in the Sherwood camp.
---@return integer # The number of placeholders of the next mission; 5 when no mission is chosen; 0 (with an error) outside Sherwood.
function GetNumberOfPlaceholders() end

---Teleports the hero standing on a placeholder (a start position for the heroes chosen in
---Sherwood) to a point.
---@param index integer placeholder number, from 0
---@param location Location a point location (Locations.Name); a zone does not work here (nil is refused with a warning)
function MovePlaceholder(index, location) end

---Returns the hero that was placed on a placeholder (a start position for the heroes chosen in
---Sherwood) at the start of the mission.
---@param index integer placeholder number, from 0
---@return Actor? # The hero, or nil when no hero uses it or (with an error) the number is too high.
function GetActorForPlaceholder(index) end

-- ===== Blazons =================================================================

---Checks whether the heroes hold as many blazons as the current blazon mission requires (attack
---missions).
---@return boolean # true when enough blazons are won; false otherwise and outside the campaign.
function AreAllBlazonsWon() end

-- ===== Scrolls =================================================================

---Returns the scroll whose script event is running (in a scroll class event).
---@return Scroll? # The scroll, or nil outside scroll events.
function ThisScroll() end
