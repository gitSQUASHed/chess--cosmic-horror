# T-04 Hand: single-action command executor

## Goal
`Hand` is one hand. It does nothing on its own. It receives a command, runs it, and reports back.

## Design
- `HandCommand` (resource or dictionary): attack definition, level, anchor position (tile or world), direction, telegraph time, and an optional start delay.
- States: IDLE, EMERGING (telegraph, hand moves and brightens), ACTIVE (area is dangerous or wall exists), RECOVERING, back to IDLE.
- API: `execute(command)`, `is_busy()`, `current_action_kind()`, `current_area()` (cells or shape that are dangerous right now), `cancel()`.
- Signals: `action_started`, `action_became_active`, `action_finished`.
- A busy hand rejects `execute()`. The one-action-per-hand rule lives here and nowhere else.
- Contains no scheduling, cooldown, counting, or knowledge of other hands.
- Visual: a `PlaceholderSprite` named for the action and level, moved and brightened during EMERGING per [phase 1 hand language](../plan/gameplay/phase_1_board_cleanup.md).

## Acceptance criteria
- A test scene sends each action kind to a hand and sees all four states in order.
- A second `execute()` while busy is refused and reported.
