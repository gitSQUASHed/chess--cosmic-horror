# AGENTS.md

Godot 4 (3D) cosmic-horror survival game: a chess king survives hands that clear the board. The game is a live 3D scene with a full-resolution pixelation shader on top. Design: [docs/plan](docs/plan/README.md). Tickets: [docs/tasks](docs/tasks/README.md).

`tests/mvp/` is an untouched 2D proof of concept used for gameplay testing. Do not change it.

## Directory map

| Path | Purpose |
|---|---|
| `src/main.tscn` | Main scene; its script is `GameFlow` |
| `src/core/` | `GameFlow` (state machine), `GameContext`, `RunConfig`, `Constants`, `Layers` (physics layers), `Palette`, `CameraRig`, `InputSetup` |
| `src/actors/` | `Hand` (single-action command executor), `Hands` (organiser), `GuidingHand`, `CaptureSequence` |
| `src/attacks/` | `AttackDefinition` and `AttackCatalogue` (all attack data), `HandCommand` |
| `src/models/` | `Placeholders` (the single model factory), `ModelAnimator` |
| `src/phase1/` | Phase 1 scene, king, director, silhouettes |
| `src/phase2/` | Phase 2 scene, king, director, `PillarField` |
| `src/fx/` | `screen.gdshader`, `PixelationLayer`, `ScreenEffects`, `Presets` |
| `src/ui/` | `Textbox`, cutscenes, `CutsceneRunner`, `StubState` |
| `src/assets/models/` | Real models (see its README for names) |
| `docs/plan/` | Product design | 
| `docs/tasks/` | Tickets; move finished ones to `done/` |
| `tests/mvp/` | Untouched 2D prototype |
| `tools/blender/` | Legacy sprite renderer (not used) |

## Architecture rules

- **Hand vs Hands:** `Hand` runs one `HandCommand` at a time and has no scheduling logic. `Hands` owns the hand count, action queue, cooldowns, placement, and every coordination rule. Directors (`Phase1Director`, `Phase2Director`) decide what to request.
- **Attack data** lives only in `AttackCatalogue`. Sizes and timings are not hard-coded elsewhere.
- **Physics drives logic.** Use the layers in `Layers`. Danger volumes are Area3D on `HAND_DANGER`, walls are bodies on `WALL`, pillars on `PILLAR`.
- **All models come from `Placeholders`.** Never build meshes in gameplay code. Placeholders: hands red, king green, tiles and pillars white or gray, each with its name as a floating label.
- **Camera and pixel size are runtime values** (`CameraRig`, `PixelationLayer`, `Presets`). Do not hard-code angles outside `CameraRig` and `Constants`.
- State changes go through `GameFlow.change_state`.

## Entry points

- Add or change an attack: `src/attacks/attack_catalogue.gd`, then request it from a director and, if it needs special placement, handle it in `Hands._place_on_board` or Phase 2's `_place`.
- Change a phase schedule: `src/phase1/phase1_director.gd` or `src/phase2/phase2_director.gd`.
- Add a screen effect: a uniform in `src/fx/screen.gdshader`, then drive it in `src/fx/screen_effects.gd`.
- Add a cutscene: `src/ui/cutscenes.gd`.
- Replace a placeholder: drop a model into `src/assets/models/` (naming in its README).

## Commands

- Run: open the project in Godot 4.3 or newer and press Run (main scene is `src/main.tscn`).
- Syntax check without Godot: `pip install gdtoolkit` then `gdparse src/*/*.gd`.
- Debug keys: R restart, F2 jump to Phase 2, F3 skip time, F10 hide debug text, `[`/`]` pixel size, F5 to F8 toggle vignette, grain and static, fisheye, bloom, F9 toggles the green palette.

## Style

GDScript with tabs, typed variables and functions, `class_name` per file, doc comments with `##`.
