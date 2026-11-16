class_name Phase2King
extends CharacterBody3D
## Phase 2 king: free movement on pillar surfaces and a jump. A physics body on the king layer
## that collides with pillars and walls. The jump keeps the current walking direction and speed
## and can clear a narrow gap. A hurtbox Area3D detects hand danger volumes.

signal captured

## Walking speed scales with the tile size (same tiles per second as before) and with the
## Phase 2 speed multiplier.
const WALK_SPEED := 5.0 * Constants.PHASE2_TILE_SIZE * Constants.PHASE2_SPEED_MULTIPLIER
## Vertical take-off speed and gravity: a low, quick hop of about a third of a second that
## covers roughly three tiles at walking speed.
const JUMP_VELOCITY := 5.0
const GRAVITY := 30.0

var camera: CameraRig
var dead := false

var _visual: Node3D
var _facing := Vector3.FORWARD
var _animation := ""


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


## Stops all control, e.g. while being picked up or at the end of a run.
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
	var horizontal := desired * WALK_SPEED
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


func _on_area_entered(_area: Area3D) -> void:
	if not dead:
		dead = true
		captured.emit()
