# T-18 Art integration

## Scope
- Wire the loader from T-02: use `sprite_sheet.json` sheets from `src/assets/sprites/**` when present, fall back to the placeholder.
- Hand folders: `sweep`, `grabbing`, `wall`, `swipe`, `void-removal`, `punch` (each `-lvl1` and `-lvl2`) and `guiding-missile`; plus king, pillars, silhouettes.
- Eight-direction column selection from the facing direction.

## Acceptance criteria
- Adding a sheet to a folder replaces its placeholder with no code change.
- Missing sheets never crash; the placeholder with its name is shown.
