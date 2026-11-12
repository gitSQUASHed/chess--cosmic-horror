# Rendering and Asset Pipeline

## Approach

- The game is rendered as a live 3D scene. King, hands, board, pillars, clock, and silhouettes are 3D models.
- A canvas layer on top of the 3D view pixelates the image and applies the other screen effects. See the [shader plan](../style/shaders.md).
- There are no pre-rendered sprite sheets and no eight-direction animation sets. Facing and animation are handled by the models and the camera.

## Consequences

- The camera angle, the Phase 2 rotation, and the pixel size are runtime values and can be tuned or animated without re-exporting art.
- Models need real animations (hands: emerge, sweep, grab, wall placement, punch, retreat; king: idle, move, dash, fall, caught) instead of directional frame sets.
- Attack and collision shapes can use 3D collision volumes and physics queries, which the previous sprite approach could not.
- Grab and fall transitions can be built from camera moves and animated pixelation, with the models reacting in the same scene.

## Planned asset groups

- White-side king and black-side king: idle, movement, jump, fall, caught, and story reactions.
- Celestial hand: sweep, top-down grab, flat wall placement, flat swipe, top-down punch, void removal, void emergence, pursuing grab, retreat, and idle/approach states as needed. Separate level-1 and level-2 variants where the shape differs.
- Two player silhouettes: restrained idle poses and occasional subtle gestures.
- Chessboard, chess clock, and pieces for Phase 1.
- Pillars: surface, rising state, falling/removal state, and hole visuals.

## Legacy

The Blender sprite-sheet renderer in `tools/blender/` and the sprite-sheet folders on the `assets` branch belong to the earlier 2D-sprite plan. They are not part of the pipeline above.

## Open questions

- Model format and import path (for example glTF) and the naming and folder layout for models.
- Whether gameplay rules run on the tile grid with 3D used for presentation and collision checks, or whether 3D physics drives the logic directly.
- The render-target resolution strategy for the pixelation layer (fixed low resolution versus scaled).
