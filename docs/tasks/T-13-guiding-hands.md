# T-13 Guiding missile hands

## Scope
- Separate pursuit entity (not an action): slow acceleration to 3x the king's normal speed, turn rate highest at low speed and falling toward a minimum as speed rises.
- First spawns at Phase 2 1:00, second at 3:00.
- Exposes a threat value 0 to 1 from distance to the king, for T-17.

## Acceptance criteria
- Sharp direction changes make the hand overshoot; a straight run does not escape it.
- Catching the king ends the run as CAPTURED.
