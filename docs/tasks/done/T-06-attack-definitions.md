# T-06 Attack definitions with levels

## Scope
- `AttackDefinition` resource per action and level: kind, shape, size, telegraph, active duration, recovery, effect (capture, block, destroy tile), availability.
- Values per the [catalogue](../plan/gameplay/enemy_mechanics.md):

| Kind | Level 1 | Level 2 |
|---|---|---|
| sweep | 1 tile wide | 3 wide |
| grab | 3×3 square | 5×5 circle |
| wall | 3×1 line | 5×1 line |
| swipe | 1×1 | 3×1 |
| void removal | 1 tile | 2×2 |
| punch | 1 tile | 3×3 |

- Each definition can create its collision volume (box or cylinder) for a given anchor and direction.
- Balance values live only in these resources.

## Acceptance criteria
- Each definition produces a volume with the correct footprint.
- Asset names match the placeholder naming `hand/<action>-lvl<N>`.
