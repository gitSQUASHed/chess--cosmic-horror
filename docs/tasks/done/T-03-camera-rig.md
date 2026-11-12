# T-03 Camera rig

## Goal
One camera setup shared by both phases, with every angle value tunable at runtime.

## Scope
- `CameraRig`: angled top-down camera, tilt, distance, field of view, follow target, and yaw (Phase 1 = 0, Phase 2 default about 30 degrees).
- Tunable values live in one place. Yaw and tilt can be animated.
- Animation API for other tickets: `move_to(pose, duration)`, `shake(strength, duration)`, `follow(target)`, `release()`.
- Phase 1 framing shows the whole board plus the rear area where hands emerge. Phase 2 follows the king at a fixed distance.

## Acceptance criteria
- Changing yaw rotates the view without changing gameplay.
- A pose animation runs smoothly from one pose to another and can be interrupted.
