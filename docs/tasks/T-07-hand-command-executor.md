# T-07 Hand: single-action command executor

## Goal
`Hand` is one hand. It receives a command, runs it, and reports back.

## Design
- `HandCommand`: attack definition, anchor, direction or side, telegraph time, origin position.
- States: IDLE, EMERGING (telegraph: the hand moves toward the target and brightens), ACTIVE (danger or wall volume enabled), RECOVERING, back to IDLE.
- API: `execute(command)`, `is_busy()`, `current_kind()`, `cancel()`.
- Signals: `action_started`, `action_became_active`, `action_finished`, `command_refused`.
- Refuses a command while busy. The one-action-per-hand rule lives here only.
- Contains no scheduling, cooldown, counting, or knowledge of other hands.
- The danger volume is on the hand_danger layer and only enabled while ACTIVE. A wall volume is on the wall layer.

## Acceptance criteria
- All four states run in order for every action kind.
- A second `execute` while busy is refused and reported.
