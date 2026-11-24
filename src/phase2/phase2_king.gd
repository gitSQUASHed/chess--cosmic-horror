class_name Phase2King
extends CharacterBody3D
## Phase 2 king: free movement on pillar surfaces and a jump. A physics body on the king layer
## that collides with pillars and walls. The jump keeps the current walking direction and speed
## and can clear a narrow gap. A hurtbox Area3D detects hand danger volumes.

## A falling top-down hand flattened the king.
signal crushed
## A guiding hand caught the king.
signal grabbed(by: Node3D)

## Base walking speed: 5 tiles per second. Guiding hands derive their speed from it.
const BASE_WALK_SPEED := 5.0 * Constants.PHASE2_TILE_SIZE
const WALK_SPEED := BASE_WALK_SPEED * Constants.PHASE2_KING_SPEED_MULTIPLIER
## Vertical take-off speed and gravity: a low, quick hop of about a third of a second that
## covers roughly two tiles at walking speed.
const JUMP_VELOCITY := 5.0
const GRAVITY := 30.0

var camera: CameraRig
var dead := false

var _visual: Node3D
var _facing := Vector3.FORWARD
var _animation := ""
var _hurtbox: Area3D


func setup(is_white: bool, camera_rig: CameraRig) -> void:
	camera = camera_rig
	collision_layer = Layers.KING
	collision_mask = Layers.PILLAR | Layers.WALL
	_visual = Placeholders.king(is_white)
	Placeholders.add_outline(_visual)
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
	_hurtbox = hurtbox


## Stops all control, e.g. while being carried off or at the end of a run.
func freeze() -> void:
	dead = true
	velocity = Vector3.ZERO
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired := Vector3(input.x, 0.0, input.y)
	if camera != null:
		desired = camera.screen_to_world_dir(input)
	var wants_move := desired.length() > 0.1
	# Moving hands (swipes) shove the king along; his own walking adds on top, so he can still
	# step out of the hand's path or get shoved off the pillars into the void.
	var horizontal := _apply_push(desired * WALK_SPEED, _push_velocity())
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if wants_move:
		_facing = desired.normalized()
		_visual.rotation.y = atan2(_facing.x, _facing.z)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y -= GRAVITY * delta
	var animation := "jump" if not is_on_floor() else ("walk" if wants_move else "idle")
	if animation != _animation:
		_animation = animation
		ModelAnimator.play(_visual, animation)
	move_and_slide()


## Flattens the king under the hand that landed on him.
func squash() -> void:
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector3(1.5, 0.08, 1.5), 0.08)


## While shoved, the king moves at least as fast as the hand along its direction, so walking or
## jumping against it cannot carry him through it. Sideways movement is unchanged.
func _apply_push(walk: Vector3, push: Vector3) -> Vector3:
	var push_speed := push.length()
	if push_speed < 0.01:
		return walk
	var direction := push / push_speed
	var along := walk.dot(direction)
	if along < push_speed:
		walk += direction * (push_speed - along)
	return walk


func _push_velocity() -> Vector3:
	var result := Vector3.ZERO
	for area in _hurtbox.get_overlapping_areas():
		if String(area.get_meta(AttackDefinition.EFFECT_META, "")) == AttackDefinition.EFFECT_PUSH:
			var push: Vector3 = area.get_meta(AttackDefinition.PUSH_VELOCITY_META, Vector3.ZERO)
			if push.length() > result.length():
				result = push
	return Vector3(result.x, 0.0, result.z)


func _on_area_entered(area: Area3D) -> void:
	if dead:
		return
	match String(area.get_meta(AttackDefinition.EFFECT_META, "")):
		AttackDefinition.EFFECT_CRUSH:
			dead = true
			crushed.emit()
		AttackDefinition.EFFECT_GRAB:
			dead = true
			grabbed.emit(area.get_parent())
