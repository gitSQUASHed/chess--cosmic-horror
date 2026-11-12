# T-01 Project setup, run config, and game flow

## Goal
A 3D project skeleton that every other ticket builds on.

## Scope
- New main scene (3D) and folder layout, for example `src/core`, `src/actors`, `src/attacks`, `src/phase1`, `src/phase2`, `src/ui`, `src/fx`. Do not touch `tests/mvp/`.
- `RunConfig`: run seed, king colour (random white or black), escape side (left or right), shared RNG.
- `Constants`: board size 8, Phase 1 duration 120 s, Phase 2 endurance 600 s, escape distance, minimum telegraph 0.5 s.
- Named physics layers: floor, pillar, void, king, hand_danger, wall, trigger. One list in one place.
- Input actions: move up, down, left, right, confirm, jump-dash.
- `GameFlow` state machine: INTRO, PHASE_ONE, TRANSITION, ARRIVAL, PHASE_TWO, ENDING. States are scenes with `enter`, `exit`, and a `finished(result)` signal. Endings: CAPTURED, VOID, ESCAPED, ENDURANCE. Unfinished states are labelled stubs.

## Acceptance criteria
- Running the project starts the flow at INTRO and advances through every state.
- State changes happen only through `GameFlow`.
- Run seed, king colour, and escape side are readable from one place.
