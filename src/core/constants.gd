class_name Constants
extends RefCounted
## Shared values. Balance numbers that belong to one attack live in AttackCatalogue.

const BOARD_TILES := 8
const PHASE_ONE_SECONDS := 120.0
const PHASE_TWO_ENDURANCE_SECONDS := 600.0
## Tiles from the start to the escape edge (the planned long-run target).
const PHASE_TWO_ESCAPE_TILES := 500
## Seconds between a hand appearing (or its shadow / marked tile) and its attack. Never shorter,
## and it does not shrink over time; attacks get faster through Hands.speed_scale instead.
const MIN_TELEGRAPH := 1.0
const KING_MOVE_SECONDS := 0.14
const KING_START_TILE := Vector2i(3, 4)
## Width of one Phase 2 tile pillar in metres. Twice a Phase 1 board tile: the field is easier
## to stay on, and the unchanged king looks tiny against it. Attack sizes stay in tiles, and
## Phase 2 speeds and distances scale with this value so timing per tile stays the same.
const PHASE2_TILE_SIZE := 2.0
## Phase 2 hands (attacks and guiding hands) move this much faster than the base speed, to make
## it hectic. The 1 s attack telegraph is not affected.
const PHASE2_HAND_SPEED_MULTIPLIER := 2.0
## The king speeds up less than the hands, so they outpace him.
const PHASE2_KING_SPEED_MULTIPLIER := 1.2
## Phase 2 camera rotation around the vertical axis. 45 makes tiles read as symmetric diamonds,
## as in docs/plan/style/reference/phase2_target.png.
const PHASE2_YAW_DEG := 45.0
## Phase 2 camera tilt above the horizon (lower = flatter). About 32 gives the reference's
## roughly 2:1 tile diamonds.
const PHASE2_TILT_DEG := 32.0
## Phase 2 vertical field of view. Narrow, so the view is close to isometric with only mild
## perspective.
const PHASE2_FOV_DEG := 25.0
## Phase 2 camera distance. Pulled back so the island still fits under the strong calm fisheye,
## which magnifies the centre and squeezes the edges.
const PHASE2_DISTANCE := 36.0 * PHASE2_TILE_SIZE
## Pillars farther than this from the king sink into the void; closer ones rise out of it.
const PILLAR_REVEAL_RADIUS := 8
