# T-05 Phase 1 board, king, and clock

## Scope
- 8×8 board of light and dark tiles with physics bodies, plus board edges.
- King with exact tile positions: eight-direction one-tile moves with a short move animation. Movement is blocked by board edges and active walls. A physics check at the target tile decides if a move is allowed.
- Capture detection: the king's body overlapping an active hand danger area ends the run as CAPTURED.
- Clock placeholder on the side from `RunConfig.escape_side`, no objective marker.
- King colour from `RunConfig`.

## Acceptance criteria
- The king cannot leave the board or enter a wall tile, and cannot move again until a move finishes.
- Overlapping a danger volume raises a `captured` event (consumed by T-10).
