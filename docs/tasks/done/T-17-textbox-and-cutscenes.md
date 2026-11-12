# T-17 Textbox and cutscene runner

## Scope
- Bottom-covering pixel-font textbox. Pauses the game and advances on confirm.
- Cutscene runner plays steps (camera pose, placeholder staging, text lines).
- Placeholder cutscenes for opening, arrival, and each ending, with the lines from [endings](../plan/gameplay/endings.md) and [cutscenes](../plan/narrative/cutscenes.md).
- Not a persistent HUD element.

## Acceptance criteria
- Gameplay pauses while the textbox is open.
- Every cutscene is reachable from the flow in T-01.
