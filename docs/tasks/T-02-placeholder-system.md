# T-02 Placeholder system

## Goal
One reusable placeholder for all art so gameplay can be built before sprites exist.

## Scope
- `PlaceholderSprite` node: a coloured rectangle (size and colour exported) with a centred short label containing the placeholder name, e.g. `king_white`, `hand_grabbing_lvl1`, `pillar`, `silhouette_left`, `clock`.
- Facing support: the label shows the current direction (one of the eight) when the owner sets one, so direction logic can be verified visually.
- Helper `Placeholders.make(name, size, colour)` so scripts do not build nodes by hand.
- Palette from [colour plan](../plan/style/colors.md), provisional values in one file.
- Placeholder variants for: king (white/black), every hand action and level, guiding hand, pillar (rising/falling), hole, wall, board tile (light/dark), clock, silhouettes, textbox panel, cutscene background.
- Optional: loader that uses `src/assets/sprites/**/sprite_sheet.json` when present and falls back to the placeholder when missing. The loader is only wired in T-18.

## Acceptance criteria
- Every placeholder shows its own name as readable text.
- No gameplay script draws art directly; it asks for a placeholder.
