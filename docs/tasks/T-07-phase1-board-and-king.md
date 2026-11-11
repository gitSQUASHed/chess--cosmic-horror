# T-07 Phase 1 board, king, clock

## Scope
- 8x8 board scene with clear light and dark squares in the shared angled top-down view (see T-20). The board is not rotated.
- King placeholder with one-square, eight-direction movement; board edges and active walls block it.
- King colour from `RunConfig`.
- Faint chess clock placeholder on the side from `RunConfig.escape_side`; no explicit objective marker.
- Capture check against `Hands.active_danger_areas()`.

## Acceptance criteria
- The king cannot leave the board or enter a wall tile.
- Standing in an active danger cell ends the run as CAPTURED.
