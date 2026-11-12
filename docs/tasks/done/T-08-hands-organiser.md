# T-08 Hands: organiser, queue, placement

## Goal
`Hands` owns every hand and all coordination, following [enemy mechanics](../plan/gameplay/enemy_mechanics.md).

## Scope
- Owns the `Hand` nodes. `set_hand_count(n)` adds hands or removes idle ones.
- Action queue: `request(kind, level)`. Idle hands whose cooldown elapsed take the first startable request.
- Per-hand cooldown after each action, never below zero. Telegraph time reduces with progress, never below 0.5 s.
- Rules: a wall starts only while another hand performs a non-wall action. Phase 2: no two simultaneous actions share a centre tile. At most three hands in one deliberate combo.
- Placement: chooses sweep side and lane, grab centre, wall position and orientation, and Phase 1 rear emergence origins. Phase 2 placement is relative to the camera frame.
- Configuration is injected by the directors; Hands has no phase knowledge.
- Guiding hands are not managed here (T-15).

## Acceptance criteria
- Queued requests run one after another per hand and never overlap on one hand.
- A queued wall waits until another hand is in a non-wall action.
- Telegraph never drops below 0.5 s and cooldown never below zero.
