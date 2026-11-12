# Implementation Tasks

Tickets for building the game as a real-time 3D scene with a pixelation layer on top. The design lives in the [plan](../plan/README.md). `tests/mvp/` is a 2D proof of concept for gameplay testing. It stays untouched and is not part of these tickets.

## Workflow

Open tickets live in this folder. When a ticket is finished, move it to [`done/`](done/) (`git mv`) and update its link in the table below. Tickets have no per-ticket test scenes. The whole build is playtested once the tickets are finished, and follow-up adjustment tickets come from that.

## Decisions

- **Rendering:** Godot 3D scene. A `CanvasLayer` on top runs a full-resolution post-process shader that pixelates and applies the other screen effects. Pixel size is a runtime value.
- **Logic:** 3D physics drives the logic. Hands, king, walls, pillars, and void are physics bodies and areas on named collision layers.
- **Phase 1 king:** exact tile positions with a short move animation. The physics check happens at the target tile, so movement stays chess-rigid.
- **Hand / Hands:** `Hand` is one hand and a simple command executor with at most one action at a time. `Hands` is the organiser: hand count, action queue, cooldowns, placement, and every coordination rule.
- **Attack definitions** are data per action and level. Hands receive commands that reference a definition.
- **Placeholders:** primitives with a floating name label. Hands red, king green, tiles and pillars white or gray.
- **Camera and pixelation** are tunable runtime values (camera angle, Phase 2 rotation about 30 degrees, pixel size).

## Tickets

| Ticket | Title | Depends on |
|---|---|---|
| [T-01](done/T-01-project-setup-and-game-flow.md) | Project setup, run config, and game flow | none |
| [T-02](done/T-02-placeholder-models.md) | Placeholder models | T-01 |
| [T-03](done/T-03-camera-rig.md) | Camera rig | T-01 |
| [T-04](done/T-04-pixelation-layer.md) | Pixelation canvas layer | T-01 |
| [T-05](done/T-05-phase1-board-and-king.md) | Phase 1 board, king, and clock | T-02, T-03 |
| [T-06](done/T-06-attack-definitions.md) | Attack definitions with levels | T-01 |
| [T-07](done/T-07-hand-command-executor.md) | Hand: single-action command executor | T-02, T-06 |
| [T-08](done/T-08-hands-organiser.md) | Hands: organiser, queue, placement | T-07 |
| [T-09](done/T-09-phase1-director.md) | Phase 1 director | T-05, T-08 |
| [T-10](done/T-10-capture-sequence.md) | Capture sequence | T-03, T-04, T-05, T-07 |
| [T-11](done/T-11-board-collapse-and-fall.md) | Board collapse and fall into Phase 2 | T-03, T-04, T-09 |
| [T-12](done/T-12-pillar-field.md) | Phase 2 pillar field | T-02, T-03 |
| [T-13](done/T-13-phase2-king-movement-and-dash.md) | Phase 2 king movement and jump-dash | T-12 |
| [T-14](done/T-14-phase2-attacks.md) | Phase 2 attacks | T-08, T-12 |
| [T-15](done/T-15-guiding-hands.md) | Guiding missile hands | T-12, T-13 |
| [T-16](done/T-16-phase2-director-and-endings.md) | Phase 2 director and endings | T-14, T-15 |
| [T-17](done/T-17-textbox-and-cutscenes.md) | Textbox and cutscene runner | T-01 |
| [T-18](done/T-18-silhouettes-and-dialogue.md) | Silhouettes and background dialogue | T-02, T-05, T-17 |
| [T-19](done/T-19-screen-effects.md) | Screen effects and pixelation presets | T-04, T-15 |
| [T-20](done/T-20-real-model-integration.md) | Real model integration | all placeholder tickets |
| [T-21](done/T-21-docs-and-project-map.md) | Docs and project map | all |
