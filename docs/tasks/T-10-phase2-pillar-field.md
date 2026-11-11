# T-10 Phase 2 pillar field

## Scope
- Deterministic generation from `(seed, tile)` giving pillar or hole.
- Pillars are revealed within a limited radius around the king and emerge (rise animation placeholder) rather than pop in.
- Persistent removed-tile set (used by void removal and punch); removed pillars fall, darken, and vanish.
- Subdued per-pillar colour variation around one base green.
- Guarantee a risky but possible route toward the escape edge.

## Acceptance criteria
- Revisiting an area gives an identical layout, including removed tiles.
- No visible loading boundary: tiles inside the radius are always present.
