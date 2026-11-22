# RhMod helper migration — FIRST PASS / NOT YET GAME-READY

Input: `rhmod.zip` (`new api.lua`, `Homecomming.lua`, `lib/old api.lua`, and old missions).

## Rewritten

- `lib/common.lua`: genuine object-API rewrite; uses `Actors`, `Locations`, `Buildings`, `Sequence()`, object properties and methods rather than replacement wrappers for the old global functions.
- **No old mission scripts have been rewritten or tested yet.** `lib/ambush.lua`, the location helpers, and the `lib/seemless/` helpers remain original and currently require migration. All original reference sources are retained.

## Explicit migration / functional-impact markers

1. **SIGNATURE CHANGE**: `SequenceWalkThrough`, `SequenceBeginCutscene`, `SequenceFinalizeCutscene`, and `SequenceWakeUp` now receive an explicit `sequence` parameter. RhMod no longer offers an implicitly open global sequence recorder. Call sites need updates.
2. **SIGNATURE CHANGE**: `ActivateDoors`, `DeactivateDoors`, `ActivateAnimations`, `DeactivateAnimations`, `LockDoorForAll`, `SetLockDoorForAll`, and `DoorLockedButUnlockable` now accept native Door/Animation objects rather than integers. Existing indices **must be mapped to concrete objects** in each mission. This is necessary to use the native API; not a deliberate gameplay change.
3. **STATE NAMING/SEMANTICS — VERIFY**: old `ScrollState.hidden/default/collected/persistent` map numerically to new `ScrollState.invisible/visible/taken/opened`. New documented meaning of `opened` should be checked against intended legacy use of `persistent`; `UpdateScrollState` retains numeric transition conditions.
4. **TIME UNITS**: old `SequenceTimer(frames)` -> `sequence:Wait(frames / 25)` (new API documents seconds and 25 frames/second). This preserves expected elapsed duration.
5. **CUTSCENE PC LOOP**: old `for i = 0, GetNumberOfPCs()` appears one beyond the valid zero-based PC range. Changed to `GetNumberOfPcs()-1` to avoid calling methods on nil; this is a **functional bug fix** and should be approved.
6. **PERCENTAGE COUNTS**: old `PercentOfEnemiesDeadExcept` iterated all actors by `GetNumberOfActorsInEngine()` / `GetActorScript`. Rewritten code iterates named `Actors`; unnamed engine actors may not be counted. **POTENTIAL FUNCTIONAL CHANGE**; needs mission verification.
7. **DEBUG OUTPUT**: `PrintAll` now prints named Actors rather than every engine actor. **POTENTIAL FUNCTIONAL CHANGE**; this debug function is not intended for gameplay.
8. **SEQUENCE SAVE/LOAD**: callbacks supplied as anonymous Lua closures can have different save-game survival properties in new RhMod (see new API docs at `Sequence:Call`). Existing callback style was retained; **requires verification** for long-running missions.
9. **SCROLL COLLECTION**: `UpdateScrollIfShownElseCollected` uses the new equivalent `ScrollState.taken`; no new game logic intended, but verify the new engine's collection state handling.
10. **WAKEUP**: use of `PersistentProperty.concussion`, `PcType.marian`, and `PcType.farmer_b` follows the new API enums; original wakeup frame intervals and animations are retained.

## Known blockers before use

- `require` is unsupported by new RhMod, per the top of `new api.lua`. Modules must be composed into a single mission Lua script at build time. Retaining separate helper *source* files is fine, but they cannot be loaded from mission Lua at runtime.
- Existing `lib/enums.lua` redeclares many globally provided RhMod enum tables, including incompatible keys. It **must not be executed unmodified** with the new API; it has not yet been rewritten because dependent old modules still use its old names.
- New API's native object references are by names (e.g. `Doors.Door_8`, `Animations.Animation_21`) or by object passed from an event, not general legacy `GetDoorScript(index)` / `GetActorScript(index)`. Mapping needs to be verified per mission, especially index-based arrays in location and seamless helpers.
- `lib/typeDefinitions.lua` is annotation-only; its pointer annotations will need updating for the native API.
- No live RhMod game runtime was available. Code has been source-reviewed, but there is no game integration test.

## Clarifications requested

1. Should the rewritten helper source signatures change from integer IDs to native Door/Patch/Animation/Actor objects (with all old script call sites eventually updated), or must existing helpers retain their old signatures? I recommend **native objects and updating callers**.
2. Should the `lib` files remain separate *source* files combined by a build script, or do you want one fully flattened Lua file per mission? I recommend separate sources plus a bundling step.
3. Should existing numeric bug fixes (such as the cutscene PC loop) be included only when required for compatibility, or preserved exactly until a separate behavior-review phase?
