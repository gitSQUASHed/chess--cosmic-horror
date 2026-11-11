# Phase 2 — Beyond the Board

## Arrival

After the board collapses, the king falls into blackness. He then lands on a near-unbounded plane of separated tile pillars. The background is pure void: there are no player silhouettes, chess clock, room, horizon, or visible floor.

The king briefly acknowledges the change: he feels no longer bound to chess rules, even though the new freedom is dangerous.

## Terrain

- The level is generated as a persistent procedural field: revisiting an area must preserve its holes and tile layout.
- Terrain is formed from individual pillars rather than a flat floor.
- Pillars exist and are only revealed within a limited radius around the king.
- As the player explores, nearby pillars rise out of the void. This should feel like the world emerging from darkness, not like an obvious loading boundary.
- Noise controls missing terrain. Holes may be a single tile or larger areas.
- When a hand removes a tile, the pillar falls back down, becomes progressively darker, and vanishes into the void.

## Player movement

- Movement is free and fast rather than tile-clipped.
- The king can jump-dash small gaps. The dash launches rapidly in the current movement direction and can only turn slowly while active, making it a strong evasive move that can also carry the king into a hole. See [movement](movement.md) for the full rule set.
- Falling into a hole ends the run with the void ending.

## Threats

All hands remain white, glowing celestial entities. Phase 2 attacks have less explicit warning than Phase 1, but must retain subtle readable physical cues.

- **Flat swipe:** a flat hand appears just inside the current camera frame, then physically slides across the field from every direction at arbitrary angles and only disappears after leaving the frame.
- **Top-down grab:** a hand descends from above and creates a readable square or circular danger area, depending on its upgrade state.
- **Void removal and top-down punch:** these actions unlock at 1:00 and permanently destroy their affected pillar tiles.
- **Wall placement:** a hand may create a temporary blocking line only while at least one other hand performs a non-wall action.
- **Guiding missile hand:** the first arrives at 1:00 and the second at 3:00. It accelerates slowly toward a maximum speed three times the king's normal speed, while its turn rate declines as it becomes faster.
- **Escalation:** the Phase 2 hand count and ability unlocks follow the [enemy curve](enemy_curve.md). Every hand remains limited to one action at a time; up to three hands may coordinate deliberate pressure in the final product.

## Guidance and escape

There is no Phase 2 arrow, terrain-colour gradient, distance counter, or other explicit indication of the escape route. The intended direction must be remembered from the side on which the Phase 1 chess clock appeared.

The escape edge lies roughly 500 tiles away in the correct horizontal direction. This value is a balancing target and may change after playtesting. Reaching the edge lets the king jump down and triggers the chess-clock ending.

The player can also survive for ten minutes for the endurance ending.
