# T-01 Project structure and run config

## Goal
Create the folder layout and the shared run data so every later ticket has a home.

## Scope
- Create `src/core`, `src/actors`, `src/attacks`, `src/phase1`, `src/phase2`, `src/ui`, `src/fx`.
- `RunConfig` (autoload or resource): run seed, king colour (random white/black), escape side (left/right, chosen at run start), difficulty constants.
- `Constants`: board size 8, Phase 1 duration 120 s, Phase 2 endurance 600 s, tile size, escape distance (configurable, MVP uses 60).
- Keep `tests/mvp/main.tscn` as main scene until T-19; add `src/main.tscn` that starts the new flow behind a debug switch.
- Input map: reuse existing `move_*`, add `confirm` (Space), `jump_dash`, debug keys.

## Acceptance criteria
- Both the old MVP and the new `src/main.tscn` can be started.
- A run exposes seed, king colour, and escape side from one place.
