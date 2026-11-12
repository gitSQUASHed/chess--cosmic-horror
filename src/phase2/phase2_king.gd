class_name Phase2King
extends CharacterBody3D
## Phase 2 king: free movement on pillar surfaces and the jump-dash. A physics body on the king
## layer that collides with pillars and walls. The dash is a short burst with a slow turn
## rate; it can cross narrow gaps or end in one. A hurtbox Area3D detects hand danger volumes.

signal captured

const WALK_SPEED := 5.0
const DASH_SPEED := 9.0
const DASH_TIME := 0.32
const DASH_JUMP := 3.2
const DASH_COOLDOWN := 0.5
const GRAVITY := 20.0
## How fast the dash direction may turn (radians per second).
const DASH_TURN_RATE := 1.4

var camera: CameraRig
var dead := false

var _visual: Node3D
var _facing := Vector3.FORWARD
var _dash_left := 0.0
var _dash_dir := Vector3.FORWARD
var _cooldown := 0.0
var _animation := ""


func setup(is_white: bool, camera_rig: CameraRig) -> void:
	camera = camera_rig
	collision_layer = Layers.KING
	collision_mask = Layers.PILLAR | Layers.WALL
	_visual = Placeholders.king(is_white)
	add_child(_visual)
	var body_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 0.9
	body_shape.shape = capsule
	body_shape.position.y = 0.45
	add_child(body_shape)
	var hurtbox := Area3D.new()
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = Layers.HAND_DANGER
	hurtbox.monitoring = true
	hurtbox.monitorable = false
	var hurt_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.3
	hurt_shape.shape = sphere
	hurt_shape.position.y = 0.45
	hurtbox.add_child(hurt_shape)
	hurtbox.area_entered.connect(_on_area_entered)
	add_child(hurtbox)


func is_dashing() -> bool:
	return _dash_left > 0.0


## Stops all control, e.g. while being picked up or at the end of a run.
func freeze() -> void:
	dead = true
	velocity = Vector3.ZERO
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired := Vector3(input.x, 0.0, input.y)
	if camera != null:
		desired = camera.screen_to_world_dir(input)
	var wants_move := desired.length() > 0.1
	var horizontal := desired * WALK_SPEED
	if _dash_left > 0.0:
		_dash_left -= delta
		if wants_move:
			var angle := _dash_dir.signed_angle_to(desired.normalized(), Vector3.UP)
			_dash_dir = _dash_dir.rotated(Vector3.UP, clampf(angle, -DASH_TURN_RATE * delta, DASH_TURN_RATE * delta)).normalized()
		horizontal = _dash_dir * DASH_SPEED
		if _dash_left <= 0.0:
			_cooldown = DASH_COOLDOWN
	elif Input.is_action_just_pressed("jump_dash") and is_on_floor() and _cooldown <= 0.0:
		_dash_dir = desired.normalized() if wants_move else _facing
		_dash_left = DASH_TIME
		velocity.y = DASH_JUMP
		horizontal = _dash_dir * DASH_SPEED
	if wants_move:
		_facing = desired.normalized()
		_visual.rotation.y = atan2(_facing.x, _facing.z)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y -= GRAVITY * delta
	var animation := "dash" if _dash_left > 0.0 else ("walk" if wants_move else "idle")
	if animation != _animation:
		_animation = animation
		Placeholders.set_subtitle(_visual, "dash" if animation == "dash" else "")
		ModelAnimator.play(_visual, animation)
	move_and_slide()


func _on_area_entered(_area: Area3D) -> void:
	if not dead:
		dead = true
		captured.emit()
