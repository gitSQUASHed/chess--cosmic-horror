# T-12 Phase 2 attacks

## Scope
- Flat swipe: spawns just inside the camera frame, slides at an arbitrary angle, disappears only after leaving the frame.
- Void removal and top-down punch: permanently remove pillars through T-10.
- Grabs and walls reuse level 2 definitions on the pillar field.
- Camera-relative placement lives in `Hands`; per-hand execution stays in `Hand`.

## Acceptance criteria
- Swipes are possible from any direction and angle.
- Removed tiles stay removed after leaving and returning to the area.
