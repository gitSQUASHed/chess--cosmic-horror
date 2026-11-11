# Sprite and Asset Pipeline

## Sprite requirements

- King and hands are rendered as 2D gameplay sprites from 3D source models.
- Each animated asset has eight directional views.
- Each direction has all required animation frames.
- The game uses the resulting sheets rather than live 3D models at runtime.

## Blender renderer

The first asset tool is [`tools/blender/render_8dir_animation_sprites.py`](../../../tools/blender/render_8dir_animation_sprites.py).

It renders the selected model root using the active action. The generated PNG sheet has one direction per column and one animation frame per row. A JSON file next to the PNG provides the sheet layout, source frames, dimensions, and direction labels for Godot import.

The source model's full animated bounds are calculated before rendering. This keeps every frame stable and prevents a moving hand from being cropped.

Read the [tool instructions](../../../tools/blender/README.md) before generating the first king or hand assets.

## Planned asset groups

- White-side king: idle, movement, jump, fall, and story reactions.
- Black-side king: equivalent animation set, using the dark/rim-lit colour treatment.
- Celestial hand: sweep, top-down grab, flat wall placement, void emergence, pursuing grab, retreat, and idle/approach states as needed.
- Two player silhouettes: restrained idle poses and occasional subtle gestures.
- Pillars: tile surface, rising state, falling/removal state, and hole visuals.
