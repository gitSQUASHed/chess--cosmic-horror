# Phase 1 — The Board Cleanup

## Goal

Survive for two minutes as the players try to clear the chessboard.

## Player movement

- The board uses clear light and dark chess squares.
- The king moves one square at a time in eight directions, exactly as a chess king can.
- The board edge blocks movement.
- The player's king colour matches the randomly selected side: a light king for white or a darker, rim-lit king for black.

## Background and lore layer

The board is seen from a clean, non-isometric top-down angle. Behind it are two large, dark chess-player silhouettes. They only use restrained idle animation: breathing, posture changes, head turns, or a small arm movement.

A large, faint two-minute chess clock sits subtly to one side of the board. It is readable if the player looks for it but is not a conventional HUD. Its side secretly records the escape direction for Phase 2. The game does not explain this connection.

The silhouettes occasionally speak short, mundane lines. They establish that the silhouettes are living people and that the king is hearing the conversation around his world. Examples are intentionally placeholders:

> “Did you put the pieces back?”

> “Not yet. Just one second.”

> “Don’t forget the clock.”

The dialogue should be sparse rather than continuous, and should not explain the cosmic horror directly.

## Hand visual language

Every hand is a glowing white celestial entity, never naturalistic human skin. Before an attack it emerges from a silhouette in the rear layer, then moves toward and over the foreground board. The hand brightens as it gets closer.

Each hand is a distinct entity. A hand can perform exactly one action at a time: it cannot begin a sweep, grab, or wall placement until its current action has resolved and recovered.

| Approach and pose | Meaning |
|---|---|
| Hand rises from the left or right board side | Sweep from that side |
| Curved/reaching hand from above | Grab attack |
| Flat open hand from above | Temporary wall / blocked line |

The background must telegraph attacks. The player should understand which attack is coming from the hand's direction, pose, brightness, and forward movement without coloured ground markers or HUD icons.

## Escalation schedule

| Time | Attack changes |
|---|---|
| 0:00–0:30 | One hand performs single-tile sweeps and 3×3 square grabs. |
| 0:30–1:00 | A second hand enters. It may place a temporary 3×1 wall only while another hand performs a non-wall action. |
| 1:00–1:30 | Sweeps widen to three tiles and grabs become 5×5 circles. |
| 1:30–2:00 | A third hand enters. Cooldown and telegraph time continue to decrease within their defined limits. |

At 2:00 the board begins to break apart, initiating the transition cutscene.
