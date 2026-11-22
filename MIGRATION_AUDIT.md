# RhMod native helper rewrite: audit

## Status

**INCOMPLETE, NOT GAME-READY.** Native conversions have been made across remaining helpers but unsupported constructs and semantics are explicitly recorded here. This does not claim full behavioral equivalence.

## Decisions
- Native handles instead of numeric-index function parameters where converted.
- Separate source modules; build-time concatenation required because `require` is unsupported.
- Preserve apparent legacy bugs; no deliberate bug fixes.

## File audit

### lib/ambush.lua

Rewrites: Actor.attitude; Actor.is_hero; Actor.is_rider; Actor.location; Actor:Activate; Actor:ConfiscateMoney; Actor:Deactivate; Actor:IsInside; Converted index field to native handle; Native PC count; Native PC lookup; Patch:Apply; Patch:SetAnimationActive; Removed runtime require statements; compile sources into the mission at build time; Unwrapped animation/actor handle; Unwrapped patch handle

Unresolved old API calls: Activate, AddRepulsivePoint, BitwiseOr, Deactivate, DealDamage, EndSequence, GetActor, GetActorName, GetDistance, GetLocation, GetNumberOfActorsInEngine, GetNumberOfActorsInSector, IsInside, IsNull, MakeNoise, NoWhere, SequenceCall, SequenceLockAI, SequenceMoveNear, SequencePlayAnimFreeze, SequenceTimer, SequenceUnlockAI, SetActorLocation, StartSequence, Then, UnlockAI

### lib/common.lua

Rewrites: No automated changes applied; needs manual review

Unresolved old API calls: GetCustomCampaignValue, GetRansomMoney, SetCustomCampaignValue, SetRansomMoney

### lib/derby.lua

Rewrites: Actor.location; Actor:Activate; Actor:Deactivate; Converted index field to native handle; Door:SetClickable; GetActor(literal name) -> Actors[name] (6); Location:MakeNoise; Patch:Apply; Patch:Reset; Removed runtime require statements; compile sources into the mission at build time; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: EndSequence, SequencePlayAnimFreeze, SetDoorLockedNPCVillain, StartSequence

### lib/enums.lua

Rewrites: No automated changes applied; needs manual review

Unresolved old API calls: None detected in static scan

### lib/leicester.lua

Rewrites: Actor.location; Actor:Activate; Actor:Deactivate; Converted index field to native handle; Door:SetClickable; GetActor(literal name) -> Actors[name] (8); Location:MakeNoise; Patch.applied; Patch:Apply; Removed runtime require statements; compile sources into the mission at build time; Unwrapped animation/actor handle; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: EndSequence, SequenceCall, SequencePlayAnimFreeze, StartSequence, Then

### lib/lincoln.lua

Rewrites: Actor:Activate; Actor:Deactivate; Converted index field to native handle; Door:SetClickable; GetActor(literal name) -> Actors[name] (3); Location:MakeNoise; Patch:Apply; Removed runtime require statements; compile sources into the mission at build time; Unwrapped animation/actor handle; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: EndSequence, SequenceCall, SequencePlayAnimFreeze, StartSequence, Then

### lib/nottingham.lua

Rewrites: Actor:Activate; Actor:Deactivate; Converted index field to native handle; Door:SetClickable; GetActor(literal name) -> Actors[name] (3); Location:MakeNoise; Patch:Apply; Removed runtime require statements; compile sources into the mission at build time; Unwrapped animation/actor handle; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: Activate, Deactivate, EndSequence, GetActor, SequenceCall, SequencePlayAnimFreeze, StartSequence, Then

### lib/seemless/H01.lua

Rewrites: GetLocation(literal name) -> Locations[name] (1); Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H02.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H03.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H04.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H05.lua

Rewrites: GetLocation(literal name) -> Locations[name] (1); Patch.applied; Removed runtime require statements; compile sources into the mission at build time; Unwrapped patch handle

Unresolved old API calls: None detected in static scan

### lib/seemless/H07.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H09.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H10.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/H12.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/S01.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/S02.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/S04.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/S05.lua

Rewrites: Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/derbySeemless.lua

Rewrites: Actor.is_hero; Converted DoorSets numeric references to native Door objects; Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/leicesterSeemless.lua

Rewrites: Actor.is_hero; Converted DoorSets numeric references to native Door objects; Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/lincolnSeemless.lua

Rewrites: Actor.is_hero; Converted DoorSets numeric references to native Door objects; Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/nottinghamSeemless.lua

Rewrites: Actor.is_hero; Converted DoorSets numeric references to native Door objects; Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/seemless/seemlessCommon.lua

Rewrites: Actor.active; Actor.is_npc; Actor:Activate; Actor:Deactivate; Actor:IsInside; Actor:UnlockAi; Door.locked_for_pcs; Door.unlockable; Native PC count; Native PC lookup; Patch.applied; Removed runtime require statements; compile sources into the mission at build time; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: GetAllActors, GetAllItems, GetAllScrolls, GetLocation, GetScrollState, IsActorTarget, LockAI, Reveal, SetCustomNPCValue

### lib/seemless/yorkSeemless.lua

Rewrites: Actor.is_hero; Converted DoorSets numeric references to native Door objects; Removed runtime require statements; compile sources into the mission at build time

Unresolved old API calls: None detected in static scan

### lib/typeDefinitions.lua

Rewrites: No automated changes applied; needs manual review

Unresolved old API calls: None detected in static scan

### lib/york.lua

Rewrites: Actor:Activate; Actor:Deactivate; Converted index field to native handle; Door:SetClickable; GetActor(literal name) -> Actors[name] (3); Location:MakeNoise; Patch.applied; Patch:Apply; Removed runtime require statements; compile sources into the mission at build time; Unwrapped animation/actor handle; Unwrapped door handle; Unwrapped patch handle

Unresolved old API calls: EndSequence, SequencePlayAnimFreeze, StartSequence

## Critical blockers

- Explicit `StartSequence` / `EndSequence` / `Then` recorder calls still present in ambush and must be manually rebuilt as `Sequence()` chains; no behavior-neutral mechanical rewrite can guarantee identical ordering.
- Several indexed patch and animation values and custom engine structures must be checked against the map and new API.
- Old names/constants in `lib/enums.lua` cannot replace engine-global native enums. Convert uses to engine names or distinct `Legacy...` names carefully.
- Some `ShowPersonInside` and target-detection semantics are not trivially equivalent and MUST be verified.
- `GetAllActors`, `GetAllItems`, `GetAllScrolls` have no verified enumeration equivalents for unnamed elements.
- The previously rewritten `lib/common.lua` contains a PC-loop change: revert or explicitly justify when touching it; the original behavior is preferred.
- Lua syntax and game runtime were not verified.
