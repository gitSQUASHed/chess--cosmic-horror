# Shader and Screen-Effect Plan

## Global pixel treatment

The 3D scene is rendered to a low-resolution target and then pixelated by a canvas layer on top of the game. That layer also carries the other screen effects (palette mapping, grain, vignette, fisheye, bloom). The effects should support readability, never obscure the king or immediate platform edges.

### Dynamic pixelation

Pixel size is a runtime value, not a fixed asset property. It can change smoothly to support moments such as:

- the king being grabbed, where the view can move closer or distort while the pixel size changes;
- falling into the void, including the Phase 1 to Phase 2 fall;
- the guiding hand's proximity, as an additional feedback channel.

Transitions between these moments are authored as camera, pixel-size, and effect animations over the live scene instead of as cuts between sprite animations.

## Phase 1 treatment

- Very light grain/static, if any.
- Preserve clean board readability and high contrast between chess squares.
- Hand glow increases as a hand travels out of a rear silhouette toward the board, functioning as attack indication.
- The faint background clock and silhouettes remain readable enough to reward attention.

## Phase 2 treatment

- Strong dark vignette to limit visible space.
- Constant low-level static/grain.
- Gentle fisheye distortion; it should be felt rather than make navigation disorienting by itself.
- Deep black/green void beyond the visible pillar radius.
- Pillars can use subdued per-instance colour variation around one base green.
- Rising terrain emerges from blackness; removed pillars descend, darken, and vanish into the void.

## Guiding-hand proximity response

The permanent guiding hand provides the Phase 2 danger feedback instead of a HUD. Its proximity should drive a continuous threat value from calm to extreme.

| Proximity | Visual response |
|---|---|
| Distant | Base darkness, low static, almost no distortion |
| Nearing | More white illumination, denser static, a low shake, stronger rumble |
| Immediate danger | Substantial white bloom, intense static, noticeable shake, severe pressure |

The white effect must not fully blind the player; at maximum pressure the player still needs enough local contrast to make an evasive decision. The response is the king's perception of an immense entity approaching, not a generic warning overlay.
