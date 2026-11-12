# Blender sprite-sheet rendering

> Legacy: this tool belongs to the earlier 2D-sprite plan. The game now renders 3D models live (see `docs/plan/technical/asset_pipeline.md`). It is kept for reference only.

`render_8dir_animation_sprites.py` renders an animated selected model to a
pixel-art sprite sheet that Godot can import.

## Use

1. Open the character or hand `.blend` file.
2. Select its root object. This is normally the Armature or a parent Empty—not
   an individual child mesh.
3. Open the **Scripting** workspace and load
   `render_8dir_animation_sprites.py` in the Text Editor.
4. Set `OUTPUT_PATH`; optionally adjust frame mode, pixel density, camera tilt,
   or direction labels at the top of the script.
5. Run the script.

The active Blender action is used. `ACTION_RANGE` (the default) renders each
whole frame from the action's start through end. `KEYFRAMES` renders only the
keyed frames. `TIME_INTERVAL` samples the action every
`SAMPLE_INTERVAL_SECONDS`; use `0.2` for one render every fifth of a second.
The interval respects the scene's FPS and can render fractional frames when a
fifth of a second does not land on a whole timeline frame. The sheet always has
eight columns—one per direction—and one row per animation frame. A neighboring
JSON file records the frame dimensions, direction order, and source frame
numbers.

The renderer uses the model's bounds across the full animation, so a moving arm
or hand cannot crop the sheet or make its frame placement jump. It restores the
active camera, current timeline frame, and render settings when it finishes.

The existing `model_to_sprite.paste_into_blender.v2.py.py` remains available
for the original still, eight-direction workflow.
