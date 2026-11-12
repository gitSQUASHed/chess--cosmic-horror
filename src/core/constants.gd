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
## Default Phase 2 camera rotation around the vertical axis. Tuned in playtest.
const PHASE2_YAW_DEG := 30.0
## Pillars farther than this from the king sink into the void; closer ones rise out of it.
const PILLAR_REVEAL_RADIUS := 5
