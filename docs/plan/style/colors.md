# Colour Palette

## Direction

Use a restricted, heavily desaturated retro-green palette. Contrast relationships are more important than final colour picking. The screen shader maps scene brightness onto a ramp of four colours (void, deep, mid, light). Each phase has its own ramp in `Palette.SCREEN_PHASE_ONE` and `Palette.SCREEN_PHASE_TWO`, applied by `ScreenEffects.set_mode`.

| Ramp | Void | Deep | Mid | Light |
|---|---|---|---|---|
| Phase 1 | `#171a17` | `#2b362e` | `#546b57` | `#c7e6bd` |
| Phase 2 | `#262826` | `#3d443d` | `#617061` | `#d1e3c2` |

Phase 1 keeps a wide ramp so the board squares, clock and silhouettes stay distinct. Light squares are a light gray rather than white, so hands and outlines stay the brightest things on the board. Phase 2 takes the reference's lifted gray void and desaturated greens, but its tiles are brighter than the reference so the field stays readable.

| Role | Intended value | Use |
|---|---|---|
| Void black | Almost black, green-biased | Phase 2 background and deepest holes |
| Deep green | Very dark desaturated green | Dark tiles, silhouettes, pillar shadows |
| Mid green | Muted moss/CRT green | Most visible Phase 2 pillar surfaces |
| Light green | Pale phosphor green | Phase 1 light squares, clock, readable highlights |
| King light | Bright pale green | White-side king |
| King dark | Dark green with pale edge | Black-side king |
| Celestial white | Green-tinted near-white | Every hand, hand glow, strongest threat highlights |

## Measured target (Phase 2 reference)

Average colours sampled from [the reference](reference/phase2_target.png), including grain.

| Area | Colour | Note |
|---|---|---|
| Void | `#303130` | Lifted, almost neutral gray, also in the corners |
| Holes and pillar sides | `#373937` | Barely above the void |
| Lit tile tops | `#4b554b` | Green only about 9 levels above red and blue |
| King | `#6a745e` or brighter | Brighter than the tiles |
| Guiding hand glow | `#7a8472` or brighter | Brightest element in the frame |

## Rules

- Phase 1 must retain clear dark-versus-light chess-square readability.
- Phase 2 pillars vary slightly around the same dark base colour; do not use strong hue variation or colourful biomes.
- White hands are the brightest visible element in both phases. Placeholder hands emit a near-white light so they map to the light colour; the king has a faint self-light. The white-side king reads brighter than the tiles, the black-side king as a dark figure on them.
- Do not use red warning overlays or bright UI colours; danger is communicated through the hand's white light and screen response.
