# T-22 Match Phase 2 to the reference image

## Scope
- Camera, scale and screen-effect values taken from measurements of [the reference](../plan/style/reference/phase2_target.png), listed in [visual direction](../plan/style/visual_direction.md#measured-from-the-reference).
- Phase 2 camera: yaw 45, tilt 32, fov 25, distance 31 (`Constants`), and the asymmetric `Phase2.VIEW_RECT_TILES` for swipe spawns re-derived from it.
- Phase 2 tiles are 2 m (`Constants.PHASE2_TILE_SIZE`). Pillars, attack footprints, camera distance, king and hand speeds, and threat distances scale with it; the king model does not.
- Pillar reveal radius 8. Models are the same in both phases.
- Per-phase palette ramps; Phase 2 gets a lifted, desaturated ramp. Brightness-proportional grain, vignette before the palette mapping, calm vignette almost off, strong calm fisheye (0.75), threat curve squared.
- Cutscenes use the Phase 1 lens from a low angle with a board-sized backdrop, so the silhouettes are in frame.
- Hands emit near-white light and the king a faint self-light so both map brighter than the tiles.

## Acceptance criteria
- Run the game in Godot and fix any console errors.
- A calm Phase 2 screenshot next to the reference shows the same tile diamond shape, island size, void gray, tile green and grain strength.
- Phase 1 light and dark squares are still clearly distinct under the new palette.
- With the guiding hand about ten tiles away, the screen looks like the reference; as it approaches, the screen gets brighter and grainier and the king stays readable.
- Hand swipes still appear just inside the frame with the new `VIEW_RECT_TILES`.
- The king can still clear a one-tile hole with a dash, and the guiding hand still feels as fast relative to the king.
- The opening cutscene shows both silhouettes and the pieces above the textbox at in-game scale.
