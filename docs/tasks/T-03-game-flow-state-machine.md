# T-03 Game flow state machine

## Goal
Run order from the [overview](../plan/gameplay/overview.md): opening cutscene, Phase 1, transition, arrival cutscene, Phase 2, ending cutscene.

## Scope
- `GameFlow` with states INTRO, PHASE_ONE, TRANSITION, ARRIVAL, PHASE_TWO, ENDING.
- Each state is a scene or node with `enter()`, `exit()`, and a `finished(result)` signal.
- Endings: CAPTURED, VOID, ESCAPED, ENDURANCE.
- Restart and debug jumps (R restart, F2 straight to Phase 2).

## Acceptance criteria
- State changes only through `GameFlow`.
- Skipping a state with a debug key produces a valid next state.
