# Gameplay Overview

## Premise

A chess game has ended. Only a king and two other pieces remain on the board. The two players are called to dinner and begin clearing the game away. The king dodges the final hand, survives the cleanup, then falls with the collapsing board into a vast, fractured plane beyond it.

| Phase | Movement rule | Space | Primary pressure |
|---|---|---|---|
| 1 — The Board Cleanup | The king moves one tile in any of eight directions | A finite chessboard | A visible two-minute cleanup attack sequence |
| 2 — Beyond the Board | Free movement and jump-dashing | A generated field of pillars and void holes | Escalating attacks and delayed pursuit |

## Player rules

- The player controls the king.
- The king is randomly white or black at the start of a complete run.
- In Phase 1, movement remains tile-clipped and obeys king movement: one tile, including diagonals, per move.
- In Phase 2, movement is no longer grid-limited. The king can jump-dash narrow void gaps, with limited steering during the dash.
- Hands are threats; being caught by one causes the capture ending.
- Falling into the void causes the void ending.

## Minimal-interface rule

The game avoids a conventional HUD. It should not show health, minimap, score, or a normal objective marker. Information is communicated through the world:

- Phase 1's faint chess clock and approaching hands communicate time and attacks.
- Phase 2's light, static, distortion, sound, and camera response communicate pursuit-hand proximity.
- Cutscenes use a deliberate textbox, not temporary floating dialogue.

## Run structure

1. Opening cutscene and dialogue on the finished chessboard.
2. Phase 1: survive two minutes.
3. The board breaks apart; the king falls into darkness.
4. A short arrival cutscene establishes the new plane.
5. Phase 2: survive, escape, get captured, or fall.
6. Ending cutscene/text.
