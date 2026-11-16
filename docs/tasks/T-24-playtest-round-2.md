# T-24 Playtest round 2 fixes

## Scope
- Strong calm fisheye (0.75) with the Phase 2 camera pulled back to 36 × tile size.
- Escape edge at 500 tiles.
- Stronger depth mist starting just below the pillar tops, so holes read as dark gaps.
- Swipes start on the first revealed pillar along their path (`Phase2._first_solid_spot`).
- All name labels removed (`Placeholders.make`); the clock keeps a time readout (`Placeholders.set_clock_time`).
- Phase 1: silhouettes at z −3 so their lower bodies show at the top of the frame; clock behind the board, shifted toward the escape side; light squares darker.
- Void fall: the camera stops following when the king drops below the surface, and the void trigger is deeper.

## Acceptance criteria
- Centre tiles in Phase 2 look about twice as big as tiles at the island edge, and the island still fits on screen.
- Holes are easy to spot as dark gaps.
- No swipe hand starts over the void when a pillar lies on its path.
- No name text anywhere; the clock time is readable.
- Phase 1 shows the players' lower bodies at the top and the clock behind the board, leaning toward the good-ending side.
- Falling into a hole shows the king sinking into the mist before the fade.
