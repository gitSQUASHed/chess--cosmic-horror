class_name CameraRig
extends Node3D
## The single camera for both phases. Every angle is a runtime value that can be animated.
## Structure: rig (focus point, yaw) > pitch node (tilt) > Camera3D (distance, fov).

class Pose extends RefCounted:
	var focus := Vector3.ZERO
	var yaw_deg := 0.0
	var tilt_deg := 55.0
	var distance := 14.0
	var fov := 40.0

	func copy() -> Pose:
		var result := Pose.new()
		result.focus = focus
		result.yaw_deg = yaw_deg
		result.tilt_deg = tilt_deg
		result.distance = distance
		result.fov = fov
		return result

	static func blend(a: Pose, b: Pose, t: float) -> Pose:
		var result := Pose.new()
		result.focus = a.focus.lerp(b.focus, t)
		result.yaw_deg = lerpf(a.yaw_deg, b.yaw_deg, t)
		result.tilt_deg = lerpf(a.tilt_deg, b.tilt_deg, t)
		result.distance = lerpf(a.distance, b.distance, t)
		result.fov = lerpf(a.fov, b.fov, t)
		return result

var camera: Camera3D
var pose := Pose.new()
## How quickly the focus catches up with the followed node (higher is tighter).
var follow_smoothing := 8.0

var _pitch: Node3D
var _from: Pose
var _to: Pose
var _t := 1.0
var _duration := 0.0
var _follow: Node3D
var _shake_strength := 0.0
var _shake_left := 0.0
var _shake_total := 0.0
var _shake_offset := Vector3.ZERO


## Whole board plus the rear area where hands emerge. The board spans x and z from 0 to 8.
static func phase_one_pose() -> Pose:
	var result := Pose.new()
	result.focus = Vector3(4.0, 0.0, 4.0)
	result.yaw_deg = 0.0
	result.tilt_deg = 55.0
	result.distance = 14.0
	result.fov = 40.0
	return result


## Follows the king at a fixed distance with the tunable field rotation.
static func phase_two_pose(focus: Vector3) -> Pose:
	var result := Pose.new()
	result.focus = focus
	result.yaw_deg = Constants.PHASE2_YAW_DEG
	result.tilt_deg = 55.0
	result.distance = 12.0
	result.fov = 40.0
	return result


func _ready() -> void:
	_pitch = Node3D.new()
	add_child(_pitch)
	camera = Camera3D.new()
	_pitch.add_child(camera)
	camera.current = true
	_apply()


func _process(delta: float) -> void:
	if _t < 1.0:
		_t = minf(1.0, _t + delta / maxf(_duration, 0.001))
		var eased := _t * _t * (3.0 - 2.0 * _t)
		pose = Pose.blend(_from, _to, eased)
	if _follow != null and is_instance_valid(_follow):
		var follow_target := _follow.global_position
		pose.focus = pose.focus.lerp(follow_target, 1.0 - exp(-follow_smoothing * delta))
	if _shake_left > 0.0:
		_shake_left = maxf(0.0, _shake_left - delta)
		var falloff := _shake_left / maxf(_shake_total, 0.001)
		_shake_offset = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength * falloff
	else:
		_shake_offset = Vector3.ZERO
	_apply()


## Jumps to a pose immediately and cancels any running animation.
func snap_to(target: Pose) -> void:
	pose = target.copy()
	_t = 1.0
	_apply()


## Animates to a pose. A new call interrupts a running animation from the current pose.
func move_to(target: Pose, duration: float) -> void:
	if duration <= 0.0:
		snap_to(target)
		return
	_from = pose.copy()
	_to = target.copy()
	_duration = duration
	_t = 0.0


func shake(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_left = duration
	_shake_total = duration


func follow(target: Node3D) -> void:
	_follow = target


func release() -> void:
	_follow = null


func is_animating() -> bool:
	return _t < 1.0


## Converts a screen-space direction (x right, y down) to a world direction on the ground plane.
func screen_to_world_dir(screen_dir: Vector2) -> Vector3:
	return Vector3(screen_dir.x, 0.0, screen_dir.y).rotated(Vector3.UP, rotation.y)


func _apply() -> void:
	position = pose.focus + _shake_offset
	rotation.y = deg_to_rad(pose.yaw_deg)
	if _pitch != null:
		_pitch.rotation.x = -deg_to_rad(pose.tilt_deg)
		camera.position = Vector3(0.0, 0.0, pose.distance)
		camera.fov = pose.fov
