class_name Constants
extends RefCounted
## Shared values. Balance numbers that belong to one attack live in AttackCatalogue.

const BOARD_TILES := 8
const PHASE_ONE_SECONDS := 120.0
const PHASE_TWO_ENDURANCE_SECONDS := 600.0
## The planned long-run target is about 500 tiles; kept short so a full run is testable.
const PHASE_TWO_ESCAPE_TILES := 60
const MIN_TELEGRAPH := 0.5
const KING_MOVE_SECONDS := 0.14
const KING_START_TILE := Vector2i(3, 4)
## Phase 2 camera rotation around the vertical axis. 45 makes tiles read as symmetric diamonds,
## as in docs/plan/style/reference/phase2_target.png.
const PHASE2_YAW_DEG := 45.0
## Phase 2 camera tilt above the horizon (lower = flatter). About 32 gives the reference's
## roughly 2:1 tile diamonds.
const PHASE2_TILT_DEG := 32.0
## Phase 2 vertical field of view. Narrow, so the view is close to isometric with only mild
## perspective.
const PHASE2_FOV_DEG := 25.0
## Phase 2 camera distance. With the fov above, about 12 tiles of ground fill the screen height
## after the calm fisheye magnification.
const PHASE2_DISTANCE := 31.0
## Pillars farther than this from the king sink into the void; closer ones rise out of it.
const PILLAR_REVEAL_RADIUS := 8
