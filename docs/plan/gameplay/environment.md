# Environment

## Phase 1 — Chessboard

- The playable space is a finite 8×8 board of clear light and dark squares.
- It uses an angled top-down view; board edges are solid.
- A landed punch hand stands on the board for a few seconds and blocks the king like a wall.
- A faint chess clock stands behind the board, shifted toward one side. That side encodes the eventual Phase 2 escape direction without an explicit objective marker.
- At the end of Phase 1, the board collapses and transitions the king into Phase 2.

## Phase 2 — Pillar field and void

- The world is a persistent procedural field of individual tile pillars surrounded by void.
- Terrain is generated deterministically: revisiting an area preserves its pillar and hole layout.
- Only a limited radius around the king is revealed. Nearby pillars should emerge rather than visibly load.
- Missing pillars form holes. Falling into one ends the run.
- Void removal and smash actions permanently remove their affected pillars.
- Landed punch hands sit on top of the field and block movement without altering terrain.

## Escape space

- The correct escape direction is the horizontal side the Phase 1 chess clock is shifted toward.
- The final product targets an escape edge roughly 500 tiles away; its exact distance remains a balance parameter.
- The field must provide risky but possible routes to that edge rather than an explicit route marker.
