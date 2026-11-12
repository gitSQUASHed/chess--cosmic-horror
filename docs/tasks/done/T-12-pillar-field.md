# T-12 Phase 2 pillar field

## Scope
- Deterministic generation from seed and tile coordinate: pillar or hole.
- Pillars exist and are revealed only inside a radius around the king, and rise out of the void (animation) instead of popping in.
- Persistent removed-tile set for void removal and punch. Removed pillars fall, darken, and vanish.
- Subdued per-pillar color variation around one base gray or white placeholder color.
- Void detection volume under the field. A guaranteed risky but possible route toward the escape edge.

## Acceptance criteria
- Revisiting an area gives an identical layout including removed tiles.
- No visible loading boundary inside the revealed radius.
