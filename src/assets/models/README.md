# Models

Drop a model here and it replaces the matching coloured placeholder. No code change is needed.

## File names

`res://src/assets/models/<name>.glb` or `<name>.tscn`, where `<name>` is the placeholder name with `/` replaced by `_`.

| Placeholder name | File name |
|---|---|
| `king_white`, `king_black` | `king_white`, `king_black` |
| `hand/<action>-lvl<N>` | `hand_<action>-lvl<N>`, for example `hand_sweep-lvl1`, `hand_grabbing-lvl2`, `hand_void-removal-lvl1` |
| `hand/guiding-missile` | `hand_guiding-missile` |
| `tile_light`, `tile_dark` | same |
| `pillar`, `wall`, `clock` | same |
| `silhouette_left`, `silhouette_right` | same |
| `piece_<name>` | same |

Actions: `sweep`, `grabbing`, `wall`, `swipe`, `void-removal`, `punch`.

## Conventions

- The model origin is the centre of its base on the ground. Hands hover at a fixed height above their origin.
- Physics shapes are not part of the models. Gameplay volumes come from the attack definitions.
- If a file is missing or fails to load, the named placeholder is used.

## Animations

Put an `AnimationPlayer` in the model with these clip names; missing clips are skipped.

- Hands: `emerging`, `active`, `recovering` (loop `idle` is not used).
- King: `idle`, `move` (Phase 1), `walk`, `dash` (Phase 2).
