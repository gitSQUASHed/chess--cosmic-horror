# Chess — After the Game Ends: Design Plan

This directory is the current source of truth for the game plan. The game is a minimal-UI cosmic-horror survival game about a chess king who discovers that the chess players above his board are godlike beings.

## Design pillars

1. **Chess is a physical world.** Phase 1 follows the rigid movement rules of a king on a board.
2. **The player is small.** Humans are dark silhouettes; their glowing white hands are incomprehensible celestial threats.
3. **Information belongs in the world.** Backgrounds, sound, light, animation, and dialogue replace conventional UI whenever possible.
4. **Freedom is frightening.** Phase 2 removes chess rules but becomes faster, darker, and more dangerous.

## Gameplay planning

The gameplay documents define the product rules. The MVP is a validation build that follows them where practical; it is not the source of truth.

## Contents

- [Gameplay overview](gameplay/overview.md)
- [Phase 1: The Board Cleanup](gameplay/phase_1_board_cleanup.md)
- [Phase 2: Beyond the Board](gameplay/phase_2_beyond_the_board.md)
- [Enemy mechanics](gameplay/enemy_mechanics.md)
- [Enemy curve](gameplay/enemy_curve.md)
- [Movement](gameplay/movement.md)
- [Environment](gameplay/environment.md)
- [Endings](gameplay/endings.md)
- [Narrative and cutscenes](narrative/cutscenes.md)
- [Visual direction](style/visual_direction.md)
- [Colour palette](style/colors.md)
- [Shader and screen-effect plan](style/shaders.md)
- [Interface, text, and audio-visual feedback](style/interface_and_feedback.md)
- [Rendering and asset pipeline](technical/asset_pipeline.md)

## Intentionally undecided

- Exact model designs beyond the agreed retro-green, pixelated direction.
- Exact camera angles, pixelation levels, and field rotation (all are tunable values, see the [visual direction](style/visual_direction.md)).
- How gameplay logic and 3D collision relate (see the [rendering pipeline](technical/asset_pipeline.md)).
- Exact movement speed, jump distance, attack cooldowns, and tile radius.
- Whether Phase 2 begins at a checkpoint after the player has reached it once.
- Exact dialogue and sound design.
