# T-15 Textbox and cutscene runner

## Scope
- Bottom-covering textbox placeholder; pauses the game; advances on `confirm` (Space).
- Cutscene runner plays a list of steps (background placeholder + lines).
- Placeholder cutscenes: opening, arrival, and one for each ending, with the lines from [endings](../plan/gameplay/endings.md) and [cutscenes](../plan/narrative/cutscenes.md).
- Not a persistent HUD element.

## Acceptance criteria
- Gameplay is paused while the box is open.
- Every cutscene name appears on screen as its placeholder label.
