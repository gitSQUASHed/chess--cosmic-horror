# Environment

## Phase 1 — Chessboard

- The playable space is a finite 8×8 board of clear light and dark squares.
- It uses a top-down view; board edges are solid.
- Temporary hand-created walls occupy board squares and block the king.
- A faint chess clock appears on one board side. That side encodes the eventual Phase 2 escape direction without an explicit objective marker.
- At the end of Phase 1, the board collapses and transitions the king into Phase 2.

## Phase 2 — Pillar field and void

- The world is a persistent procedural field of individual tile pillars surrounded by void.
- Terrain is generated deterministically: revisiting an area preserves its pillar and hole layout.
- Only a limited radius around the king is revealed. Nearby pillars should emerge rather than visibly load.
- Missing pillars form holes. Falling into one ends the run.
- Void removal and top-down punch actions permanently remove their affected pillars.
- Temporary walls sit on top of the field and block movement without altering terrain.

## Escape space

- The correct escape direction is the horizontal side indicated by the Phase 1 chess clock.
- The final product targets an escape edge roughly 500 tiles away; its exact distance remains a balance parameter.
- The field must provide risky but possible routes to that edge rather than an explicit route marker.
