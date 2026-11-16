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

- The model origin is the centre of its base on the ground. Hands stand on the ground at their origin; top-down hands drop in from above when they attack.
- Physics shapes are not part of the models. Gameplay volumes come from the attack definitions.
- If a file is missing or fails to load, the named placeholder is used.

## Animations

Put an `AnimationPlayer` in the model with these clip names; missing clips are skipped.

- Hands: `emerging`, `dropping` (top-down hands falling in), `active`, `recovering` (loop `idle` is not used).
- King: `idle`, `move` (Phase 1), `walk`, `jump` (Phase 2).
