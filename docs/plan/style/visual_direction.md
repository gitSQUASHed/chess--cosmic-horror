# Visual Direction

## Core look

The game uses pixel-art sprites and a retro green monochrome palette. It is dark, grainy, and cosmic-horror oriented. The visible world should feel small and fragile against vast, dark space.

The reference for Phase 2 is a dark angled top-down scene with strong vignette, heavy static/grain, small islands of green terrain, and a tiny character at its centre. The UI shown in that reference is not part of this game's direction.

## Phase contrast

### Phase 1

- Angled top-down board view (the camera looks down at a tilt, not straight from above). The board is not rotated.
- Black/dark and light chess tiles must be clearly distinct despite the green palette.
- The board, clock, and silhouettes give the scene physical context.
- The king colour corresponds to its chess side.
- White glowing hands move from background silhouettes into the foreground.

### Phase 2

- The same angled top-down view as Phase 1, with the field rotated by roughly 30 degrees around the vertical axis. The exact angle is set once the sprites are final and is a single configurable value. Gentle fisheye distortion on top.
- Pure void behind the world: no room, player silhouettes, clock, or horizon.
- Only a small radius of dark-green tile pillars is visible.
- The king is isolated in a small island of legibility.
- Celestial white hands provide the brightest light source.

## Hands

Hands are deliberately not rendered as ordinary human hands. They are blown-out white forms with glow, closer to a celestial presence than anatomy. Their light can affect nearby terrain. The contrast with the nearly invisible player silhouettes makes the humans feel physically present but incomprehensible.
