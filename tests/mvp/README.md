# Gameplay MVP

This is a Godot 4.3+ gameplay prototype inside the repository's existing project. It contains only functional gameplay and uses coloured squares and lines for every actor, hazard, hand, wall, pillar, and player.

## Run

Open the repository root (`rpg---sped-up`) in Godot. The root `project.godot` starts `tests/mvp/main.tscn`, so the `tests/mvp` folder is visible in the existing project's **FileSystem** tab and pressing Run starts the MVP.

## Implemented loop

- Phase 1: one-square eight-direction king movement on an 8x8 board, board limits, temporary walls, telegraphed sweeps, grabs, escalating timing, capture, and a two-minute survival transition. One hand owns one action until that action ends; the second and third hands join at 0:30 and 1:30.
- Phase 2: continuous movement, jump-dashing over holes, persistent deterministic pillar terrain, void deaths, upgraded 3×1 flat swipes, 5×5 grabs, upgraded 5×1 walls, void removals, top-down punches, and capture, escape, and ten-minute endurance outcomes.
- Escalation: two attack hands are active at Phase 2 start. Additional attack hands follow the product curve and cap at seven. Void removal, top-down punches, and the first guiding missile hand arrive at 1:00; punch and void areas upgrade at 2:00, and the second guiding missile hand arrives at 3:00.
- The clock block appears on either the left or right in Phase 1; that same side is used for the Phase 2 escape condition. The MVP distance is 60 tiles rather than the eventual long-run target so it can be played through during testing.

## Controls

- `WASD` or arrow keys: move. In Phase 1 this moves one chess square at a time, including diagonals.
- `Space`: jump-dash in Phase 2. It launches quickly in your movement direction and can only turn slowly; it can clear a short gap or carry you into one.
- `R` or `F1`: restart at Phase 1.
- `F2`: enter Phase 2 immediately.
- `F3`: while in Phase 2, fast-forward to the one-minute escalation and immediately arm every attack hand.
- `F7`: while in Phase 2, fast-forward to the two-minute void/punch upgrades and immediately arm every attack hand.
- `F4`, `F5`, `F6`: while in Phase 2, force the escape, capture, and void end states respectively. These make each outcome testable without a long run.
