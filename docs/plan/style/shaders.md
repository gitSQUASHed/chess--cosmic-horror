# Shader and Screen-Effect Plan

## Global pixel treatment

The 3D scene is rendered to a low-resolution target and then pixelated by a canvas layer on top of the game. That layer also carries the other screen effects (palette mapping, grain, vignette, fisheye, bloom). The effects should support readability, never obscure the king or immediate platform edges.

### Dynamic pixelation

Pixel size is a runtime value, not a fixed asset property. It can change smoothly to support moments such as:

- the king being carried off by a guiding hand, where the pixel size grows while the camera stays behind;
- falling into the void, including the Phase 1 to Phase 2 fall;
- the guiding hand's proximity, as an additional feedback channel.

Transitions between these moments are authored as camera, pixel-size, and effect animations over the live scene instead of as cuts between sprite animations.

## Phase 1 treatment

- Light grain and static (a visible but restrained TV-style noise).
- Preserve clean board readability and high contrast between chess squares.
- Hands keep a constant glow; attack warnings come only from the hand waiting on the board or a top-down hand's shadow (see [attack warnings](../gameplay/enemy_mechanics.md#attack-warnings)).
- The faint background clock and silhouettes remain readable enough to reward attention.

## Phase 2 treatment

- Its own palette ramp (see [colours](colors.md)), swapped in when the phase starts.
- Visible film grain, stronger than in Phase 1 but never hiding the tiles. Its spread is proportional to brightness, so lit tiles are noisier than the void. It rises with the guiding-hand threat.
- Faint TV static at calm that grows with the threat.
- Almost no vignette at calm. It is applied before the palette mapping, so it can only darken the scene toward the void colour, and it closes in as the threat rises.
- Strong fisheye at calm (0.75): centre tiles look about twice as big as tiles at the edge of the revealed island. It grows with the threat. Tile edges must stay readable enough to navigate.
- A lifted gray void beyond the visible pillar radius.
- Dark depth mist below the pillar tops: pillar sides fade into the void colour toward their base, so holes read as dark gaps and neighbouring pillars separate. A king falling into a hole visibly sinks into it before the screen fades. It is part of the pillar material (`src/models/pillar.gdshader`): each pillar's colour fades to the void colour over `mist_depth` metres below the surface, so rising and sinking pillars are dark too.
- Pillars can use subdued per-instance colour variation around one base green.
- Rising terrain emerges from blackness; removed pillars descend, darken, and vanish into the void.

## Guiding-hand proximity response

The permanent guiding hand provides the Phase 2 danger feedback instead of a HUD. Its proximity should drive a continuous threat value from calm to extreme.

| Proximity | Visual response |
|---|---|
| Distant | The reference image: base grain, faint static, almost no vignette or distortion |
| Nearing | More white illumination, denser static, a low shake, stronger rumble |
| Immediate danger | Substantial white bloom, intense static, noticeable shake, severe pressure |

The threat value falls off with the square of the distance (`GuidingHand.threat`), so a hand at the island's edge, about ten tiles away, is still a mild threat. The calm and threat strengths live in `src/fx/screen_effects.gd`.

The white effect must not fully blind the player; at maximum pressure the player still needs enough local contrast to make an evasive decision. The response is the king's perception of an immense entity approaching, not a generic warning overlay.
