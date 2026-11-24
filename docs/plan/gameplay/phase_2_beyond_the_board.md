# Phase 2 — Beyond the Board

## Arrival

After the board collapses, the king falls into blackness. He then lands on a near-unbounded plane of separated tile pillars. The background is pure void: there are no player silhouettes, chess clock, room, horizon, or visible floor.

The king briefly acknowledges the change: he feels no longer bound to chess rules, even though the new freedom is dangerous.

## Terrain

- The level is generated as a persistent procedural field: revisiting an area must preserve its holes and tile layout.
- Terrain is formed from individual pillars rather than a flat floor.
- Pillars are cubes, as tall as they are wide. Each pillar is twice as wide as a Phase 1 board tile while the king keeps his size. This gives more room to stay on a tile and makes the king look small. Attack sizes are counted in tiles, so they grow with the pillars, and movement and hand speeds scale too, so timing per tile matches Phase 1.
- Pillars exist and are only revealed within a limited radius around the king.
- As the player explores, nearby pillars rise out of the void. This should feel like the world emerging from darkness, not like an obvious loading boundary.
- Smooth noise controls missing terrain, so holes form connected areas of roughly 2 to 8 tiles across rather than scattered single tiles. About 18% of tiles are holes; a guaranteed route of solid tiles always leads to the escape edge.
- When a hand removes a tile, the pillar falls back down, becomes progressively darker, and vanishes into the void.

## Player movement

- Movement is free and fast rather than tile-clipped.
- The hands (attacks and guiding hands) move twice as fast as the base speed; the king only 1.2 times. Only the one-second attack telegraph stays the same.
- The king can jump small gaps. The jump keeps the current direction and speed, so it can also carry the king into a hole. See [movement](movement.md) for the full rule set.
- Falling into a hole ends the run with the void ending.

## Threats

All hands remain white, glowing celestial entities. Phase 2 attacks have less explicit warning than Phase 1, but must retain subtle readable physical cues.

- **Flat swipe:** a flat hand appears just inside the current camera frame, then physically slides across the field from every direction at arbitrary angles and only disappears after leaving the frame.
- **Top-down punch:** a hand falls from above onto its shadow, crushes the king on the way down, then stays as a temporary block (1×1, upgraded 2×2).
- **Void removal and smash:** these actions unlock at 1:00 and permanently destroy their affected pillar tiles.
- **Guiding missile hand:** the first arrives at 1:00 and the second at 3:00. It accelerates slowly toward a maximum speed three times the king's normal speed, while its turn rate declines as it becomes faster.
- **Escalation:** the Phase 2 hand count and ability unlocks follow the [enemy curve](enemy_curve.md). Every hand remains limited to one action at a time; up to three hands may coordinate deliberate pressure in the final product.

## Guidance and escape

There is no Phase 2 arrow, terrain-colour gradient, distance counter, or other explicit indication of the escape route. The intended direction must be remembered from the side the Phase 1 chess clock was shifted toward.

The field is a square of 500 × 500 tiles centred on the landing tile (`size` in `config/field.cfg`). Beyond its borders, 250 tiles away on both axes, there is only void. The escape edge is the border in the correct horizontal direction. There, the Phase 1 chess clock floats huge in the void below the field, in view once the king comes close. Jumping off the edge lands the king on top of it and triggers the chess-clock ending.

The player can also survive for ten minutes for the endurance ending.
