# T-11 Board collapse and fall into Phase 2

## Scope
- At 2:00 the board tiles fall away as physics bodies, the king falls into darkness, and the camera and pixelation animate (see [shader plan](../plan/style/shaders.md)).
- The arrival textbox line is shown through T-17 when available.
- Phase 1 state carries over: king colour, escape side, hand upgrade levels.

## Acceptance criteria
- The transition cannot be interrupted by a capture.
- Phase 2 starts with the carried-over values.
