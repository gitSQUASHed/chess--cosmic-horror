# T-15 Guiding missile hands

## Scope
- Separate pursuit entity (not an action): slow acceleration to three times the king's normal speed, turn rate highest at low speed and falling toward a minimum as speed rises.
- First spawns at Phase 2 1:00, the second at 3:00.
- Outputs a continuous threat value from 0 to 1 based on distance to the king (used by T-19).
- Catching the king starts the capture sequence (T-10).

## Acceptance criteria
- Sharp direction changes make it overshoot; a straight run does not escape it.
