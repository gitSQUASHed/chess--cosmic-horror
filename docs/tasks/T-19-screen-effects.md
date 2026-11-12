# T-19 Screen effects and pixelation presets

## Scope
- Phase 2 vignette, grain, gentle fisheye in the screen shader.
- Threat response from the guiding hand value (T-15): white bloom, denser static, shake. The king stays visible at maximum.
- Dynamic pixelation presets for grab, fall, and guiding-hand proximity, as in the [shader plan](../plan/style/shaders.md).
- Phase 1 gets light grain only.

## Acceptance criteria
- Effects scale continuously with threat and never fully blind the player.
- Each effect can be turned off for debugging.
