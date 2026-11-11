# T-20 Angled top-down view and Phase 2 field rotation

## Goal
One shared camera and projection for both phases, with Phase 2 rotating the field.

## Scope
- Shared angled top-down projection: world (x, y) tile coordinates map to screen with a fixed tilt. Used by Phase 1 and Phase 2, so sprites are authored once for one view angle.
- `Constants.PHASE2_FIELD_ROTATION_DEG` (default 30). Phase 2 applies this rotation around the vertical axis to the whole field. Phase 1 uses 0.
- All world/screen conversions go through one `WorldView` helper (tile to screen, screen to tile, depth sorting). No other script computes screen positions.
- Input is mapped relative to the screen so that "up" stays screen-up after the rotation; confirm in playtest and adjust if movement should follow the field instead.
- Rotation also applies to Phase 2 attack placement: camera-edge spawns for swipes and the rotated attack shapes (walls, sweeps) must line up with the visible field.
- Placeholder sprites show the current facing, so rotation correctness can be checked by eye.
- Changing the angle constant must not require code changes elsewhere.

## Acceptance criteria
- Phase 1 and Phase 2 use the same projection; Phase 2 differs only by the rotation value.
- Setting the rotation to 0, 30, or another value keeps tile hit tests, danger areas, and depth sorting correct.
- Camera-edge swipe spawns stay just inside the visible frame at any rotation.
