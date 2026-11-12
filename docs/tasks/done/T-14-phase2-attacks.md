# T-14 Phase 2 attacks

## Scope
- Flat swipe: a hand appears just inside the camera frame, slides at an arbitrary angle, and disappears only after leaving the frame.
- Void removal and top-down punch: remove pillars permanently through T-12.
- Grab and wall at level 2 on the pillar field.
- Camera-frame placement lives in `Hands` (T-08); execution stays in `Hand`.

## Acceptance criteria
- Swipes can come from any direction and angle and stay in a physics-valid path.
- Removed tiles stay removed after leaving and returning.
