# T-06 Attack definitions with levels

## Goal
All action rules as data, so `Hand` stays dumb and balance lives in one place.

## Scope
- `AttackDefinition` resource: kind, level, shape and size, base telegraph, active duration, recovery, effect (damage, block, destroy tile), availability phase.
- Definitions per the [catalogue](../plan/gameplay/enemy_mechanics.md):

| Kind | Level 1 | Level 2 |
|---|---|---|
| sweep | 1 tile wide | 3 wide |
| grab | 3x3 square | 5x5 circle |
| wall | 3x1 line | 5x1 line |
| swipe | 1x1 | 3x1 |
| void removal | 1 tile | 2x2 |
| punch | 1 tile | 3x3 |

- `area_for(command)` returns the affected cells or shape; used by hands, directors, and collision.
- Placeholder names match the asset folders under `src/assets/sprites/hand/` (`sweep-lvl1`, `grabbing-lvl1`, ...).

## Acceptance criteria
- Each definition returns the correct cell set for a sample anchor and direction.
- Balance values live only in these resources.
