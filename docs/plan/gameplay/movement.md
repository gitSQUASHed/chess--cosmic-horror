# Movement

## Phase 1 — King movement

- The king moves exactly one board tile per move in any of eight directions.
- Board edges and active walls block movement.
- Movement is intentionally rigid: the player reads attacks and chooses a legal chess-like escape square.

## Phase 2 — Free movement

- The king moves freely across existing pillar surfaces, twice as fast as the base speed, like everything else in Phase 2 (`Constants.PHASE2_SPEED_MULTIPLIER`). It is meant to feel hectic.
- Entering a missing tile while on the ground causes the void ending.
- The player can jump from a solid tile. The jump is a short, low hop that keeps the current walking direction and speed; there is no extra burst of speed.
- A jump clears narrow void gaps (about three tiles at walking speed), but it may also land the king in a hole, against a wall, or next to a hand. The player must choose the landing space.

## Counterplay intent

- Sharp regular movement changes exploit the slow high-speed turning of guiding missile hands.
- Jumps create a short answer to space denial, but introduce route risk.
- Walls, holes, and persistent tile destruction should make prior movement choices affect later routes.
