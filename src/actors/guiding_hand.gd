class_name GuidingHand
extends Node3D
## A guiding missile hand: a continuous pursuit entity, not a normal action. It accelerates
## slowly to three times the king's walking speed. Its turn rate is highest when slow and
## falls toward a minimum as it speeds up, so sharp direction changes make it overshoot.

const MAX_SPEED := Phase2King.WALK_SPEED * 3.0
const ACCELERATION := 0.93
const MIN_TURN_RATE := 0.34
const MAX_TURN_RATE := 1.35
## Distance at which the threat value reaches 1.
const THREAT_NEAR := 1.5
## Distance at which the threat value reaches 0.
const THREAT_FAR := 25.0

var target: Node3D
var speed := 0.0
var heading := Vector3.FORWARD

var _visual: Node3D


func setup(chase_target: Node3D, start: Vector3) -> void:
	target = chase_target
	position = start
	_visual = Placeholders.guiding_hand()
	add_child(_visual)
	var danger := Area3D.new()
	danger.collision_layer = Layers.HAND_DANGER
	danger.collision_mask = 0
	danger.monitoring = false
	danger.monitorable = true
	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.8
	shape_node.shape = shape
	shape_node.position.y = 0.6
	danger.add_child(shape_node)
	add_child(danger)
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > 0.01:
		heading = to_target.normalized()


## 0 (far) to 1 (touching distance).
func threat(from_position: Vector3) -> float:
	var distance := from_position.distance_to(global_position)
	return clampf(1.0 - (distance - THREAT_NEAR) / (THREAT_FAR - THREAT_NEAR), 0.0, 1.0)


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > 0.1:
		var angle := heading.signed_angle_to(to_target.normalized(), Vector3.UP)
		var speed_ratio := clampf(speed / MAX_SPEED, 0.0, 1.0)
		var turn_rate := lerpf(MAX_TURN_RATE, MIN_TURN_RATE, speed_ratio)
		heading = heading.rotated(Vector3.UP, clampf(angle, -turn_rate * delta, turn_rate * delta)).normalized()
	speed = minf(MAX_SPEED, speed + ACCELERATION * delta)
	global_position += heading * speed * delta
	_visual.rotation.y = atan2(heading.x, heading.z)
