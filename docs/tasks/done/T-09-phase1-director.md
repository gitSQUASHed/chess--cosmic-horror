# T-09 Phase 1 director

## Scope
Drives `Hands` through the two-minute schedule from the [enemy curve](../plan/gameplay/enemy_curve.md).

| Time | Change |
|---|---|
| 0:00 | 1 hand, sweep and grab level 1, interval about 4 s |
| 0:30 | 2nd hand, walls enabled |
| 1:00 | Sweep and grab to level 2 |
| 1:30 | 3rd hand |
| 2:00 | End Phase 1 |

- Chooses what to request, keeps the queue stocked, and updates cooldown and telegraph values over time.
- Emits `finished` at 2:00.

## Acceptance criteria
- The schedule matches the table in real time.
- Hands never violate the T-08 rules.
