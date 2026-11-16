# Enemy Mechanics

This document defines the product enemy vocabulary. Exact values are balancing parameters; the action rules and progression relationships are product rules.

## Hand entity model

- Every enemy hand is an independent entity.
- A hand owns at most one action at a time. It cannot begin a second action until its current action ends.
- Hands may act concurrently. Planned coordination may combine at most three hands in one deliberate setup.
- A hand's action cooldown decreases as its phase progresses and never drops below zero.
- Every action except the guiding missile hand has a telegraph of at least one second between the warning appearing and the attack. The telegraph never shrinks; instead, the attacks themselves get faster as the phase progresses (movement, strikes and recovery; walls keep their blocking time).
- In Phase 2, simultaneous action centres may not occupy the same tile. Their effect areas may overlap.
- A wall can only be placed while at least one other hand is performing a non-wall action.

## Action catalogue

| Action | Availability | Basic form | Upgrade |
|---|---|---|---|
| Side sweep | Phase 1 | A 1-tile-wide hand sweeps across one board lane. | 3 tiles wide. |
| Top-down grab | Both phases | 1×1 danger area. | 3×1 horizontal or vertical danger line. |
| Wall | Both phases | Temporary 1×1 blocking tile. | Temporary 3×1 horizontal or vertical blocking line. |
| Flat swipe | Phase 2 | A 1×1 hand appears just inside the camera frame, slides in any direction or angle, and persists until it leaves the frame. | 3×1 swipe. |
| Void removal | Phase 2 | Removes one tile pillar. | Removes a 2×2 tile area. |
| Top-down punch | Phase 2 | Destroys one tile beneath the impact point. | Destroys a 3×3 tile area. |

## Attack warnings

These are the only warnings. There are no ground markers, labels or glow changes.

- Hands stand directly on the field, never floating above it.
- **Ground hands** (side sweep, flat swipe, wall) appear on the field where they will act, wait for the telegraph, then act.
- **Top-down hands** (grab, punch) are not on screen before the attack. During the telegraph only their shadow shows on the field where they will land; then the hand falls from above the top of the screen onto the shadow, and the attack takes effect when it lands.
- **Void removal** has no visible hand. The pillars it will remove go completely dark with an outline for one second, then are pulled down; the outline disappears as they go.
- In both phases the king and every hand, including guiding hands and the capturing hand, have a solid white outline that light and shadow do not affect.

## Guiding missile hands

- A guiding missile hand is a continuous pursuit entity, not a normal action.
- It accelerates slowly to a maximum speed equal to three times the player's normal movement speed.
- Its turn rate is highest at low velocity and falls toward a defined minimum as velocity rises.
- Sharp movement changes are therefore the intended counterplay; an uninterrupted straight escape is not.

## Planned coordination

The product should turn independently readable actions into combinations without violating the one-action-per-hand rule:

- Place walls to reduce viable dodge routes.
- Send a swipe through the remaining open route.
- Put a grab at a predicted exit point.
- Destroy pillars beside or behind a jumping player.
- Use guiding missile pressure to steer the player toward active areas.

The system must avoid unavoidable traps: action telegraphs, hand ownership, and the three-hand coordination ceiling preserve a skillful response window.
