# T-04 Pixelation canvas layer

## Goal
Pixelate the whole 3D scene with a full-resolution post-process shader.

## Scope
- `CanvasLayer` above the game with a full-screen shader reading the screen texture.
- Shader snaps the image to a pixel grid. `pixel_size` is a runtime parameter (any value, animatable).
- Palette mapping to the retro green palette (provisional values from [colors](../plan/style/colors.md)), toggleable.
- API: `set_pixel_size(value)`, `animate_pixel_size(to, duration)`.
- The UI layers (textbox) can be placed above or below the effect.

## Acceptance criteria
- Pixel size can be changed at runtime and animates without flicker.
- Pixel size 1 gives a nearly unmodified image.
- The effect does not distort input, UI placement, or physics.
