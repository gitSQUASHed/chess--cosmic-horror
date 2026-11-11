# T-05 Hands: organiser, queue, placement

## Goal
`Hands` owns every hand and all coordination, following [enemy mechanics](../plan/gameplay/enemy_mechanics.md).

## Scope
- Owns the set of `Hand` nodes. `set_hand_count(n)` adds or removes hands; removal waits for the hand to go idle.
- Action queue: `request(action_kind, params)`; each tick assigns queued requests to idle hands that are ready.
- Per-hand cooldown and global interval curves, never below zero. Telegraph time shrinks but never below 0.5 s.
- Coordination rules:
  - A wall may only start while at least one other hand runs a non-wall action.
  - Phase 2: two simultaneous actions may not share a centre tile; effect areas may overlap.
  - Planned combos use at most three hands.
- Placement: chooses spawn side and anchor for each command (side for sweeps, above for grabs and walls, camera-edge for swipes), including the Phase 1 rear-silhouette origins.
- Queries for the phases: `active_danger_areas()`, `active_walls()`, `busy_hands()`.
- Configuration is injected by the directors (T-08, T-14), so `Hands` has no phase knowledge.
- Guiding hands are not managed here; see T-13.

## Acceptance criteria
- With one hand and a queue of three requests, requests run one after another, never overlapping.
- A queued wall waits until another hand is in a non-wall action.
- Telegraph time never drops below 0.5 s and cooldown never below 0 s, checked with a debug fast-forward.
