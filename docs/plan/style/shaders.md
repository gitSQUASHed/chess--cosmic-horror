# Shader and Screen-Effect Plan

## Global pixel treatment

Sprites are rendered from 3D source models as pixel-art sheets, then shown as 2D gameplay sprites. The game may add a restrained CRT/static treatment on top. The effect should support readability, never obscure the king or immediate platform edges.

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
