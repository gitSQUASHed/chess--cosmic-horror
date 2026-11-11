# Implementation Tasks

Tickets for rebuilding the game from the [design plan](../plan/README.md) as structured Godot scenes. The prototype in `tests/mvp/` stays as the rules reference until [T-19](T-19-mvp-removal-and-docs.md).

## Architecture decisions

- **Hand** (`src/actors/hand.gd`): one enemy hand. A simple command executor. It owns at most one action at a time and has no scheduling logic.
- **Hands** (`src/actors/hands.gd`): the organiser. It owns the correct number of hands, the action queue, hand placement, and every coordination rule (wall only while another hand does a non-wall action, no shared centres in Phase 2, three-hand coordination ceiling, cooldown and telegraph curves).
- **Attack definitions** are data (per action, per level). Hands receive a command that references a definition; they do not know action rules themselves.
- **Placeholders everywhere.** Every sprite, textbox, and cutscene is a placeholder that shows its own name as text. Real art replaces them in [T-18](T-18-art-integration.md).
- Both phases use the same angled top-down camera. Phase 2 additionally rotates the field by about 30 degrees around the vertical axis. The angle is one configurable value (`Constants.PHASE2_FIELD_ROTATION_DEG`, default 30) because the final sprites decide it.

## Assumptions to confirm

- Phase 1 upgrades (wide sweep, 5x5 grab) carry into Phase 2, as in [enemy curve](../plan/gameplay/enemy_curve.md). The 5x1 wall upgrade is applied from Phase 2 start.
- Tests use plain manual playtesting plus debug keys until a test framework is chosen.

## Workflow

Open tickets live in this folder. When a ticket is finished, move it to [`done/`](done/) (`git mv T-xx-*.md done/`) and update its row in the table below to point at the new path.

## Tickets

| Ticket | Title | Depends on |
|---|---|---|
| [T-01](T-01-project-structure-and-run-config.md) | Project structure and run config | none |
| [T-02](T-02-placeholder-system.md) | Placeholder system | T-01 |
| [T-03](T-03-game-flow-state-machine.md) | Game flow state machine | T-01, T-02 |
| [T-04](T-04-hand-command-executor.md) | Hand: single-action command executor | T-02 |
| [T-05](T-05-hands-organiser.md) | Hands: organiser, queue, placement | T-04, T-06 |
| [T-06](T-06-attack-definitions.md) | Attack definitions with levels | T-01 |
| [T-07](T-07-phase1-board-and-king.md) | Phase 1 board, king, clock | T-02, T-03, T-20 |
| [T-08](T-08-phase1-director.md) | Phase 1 director and escalation | T-05, T-07 |
| [T-09](T-09-board-collapse-transition.md) | Board collapse transition | T-03, T-08 |
| [T-10](T-10-phase2-pillar-field.md) | Phase 2 pillar field | T-02, T-20 |
| [T-11](T-11-phase2-king-movement-dash.md) | Phase 2 king movement and jump-dash | T-10 |
| [T-12](T-12-phase2-attacks.md) | Phase 2 attacks | T-05, T-10 |
| [T-13](T-13-guiding-hands.md) | Guiding missile hands | T-10, T-11 |
| [T-14](T-14-phase2-director-and-endings.md) | Phase 2 director and endings | T-12, T-13 |
| [T-15](T-15-textbox-and-cutscenes.md) | Textbox and cutscene runner | T-02, T-03 |
| [T-16](T-16-silhouettes-and-dialogue.md) | Silhouettes and background dialogue | T-02, T-07 |
| [T-17](T-17-screen-effects.md) | Phase 2 screen effects | T-13 |
| [T-18](T-18-art-integration.md) | Art integration | all art-bearing tickets |
| [T-19](T-19-mvp-removal-and-docs.md) | MVP removal and documentation | all |
| [T-20](T-20-angled-view-and-field-rotation.md) | Angled view and Phase 2 field rotation | T-01 |
