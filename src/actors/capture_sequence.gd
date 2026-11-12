class_name CaptureSequence
extends Node
## The physical capture sequence: a grabbing hand picks the king up while the camera moves in
## and the pixel size animates. Every capture type (sweep, grab, guiding hand) uses it.

signal finished

var _playing := false


## Creates and starts the sequence. `scene_root` receives the grabbing hand model.
static func start(scene_root: Node3D, context: GameContext, subject: Node3D) -> CaptureSequence:
	var sequence := CaptureSequence.new()
	scene_root.add_child(sequence)
	sequence.play(scene_root, context, subject)
	return sequence


func play(scene_root: Node3D, context: GameContext, subject: Node3D) -> void:
	if _playing:
		return
	_playing = true
	var base := subject.global_position
	var grabber := Placeholders.hand("hand/grabbing-lvl1", Vector3(1.6, 0.4, 1.6))
	scene_root.add_child(grabber)
	grabber.global_position = base + Vector3(0.0, 5.0, 0.0)
	var closeup := CameraRig.Pose.new()
	closeup.focus = base + Vector3(0.0, 1.0, 0.0)
	closeup.yaw_deg = context.camera.pose.yaw_deg
	closeup.tilt_deg = 35.0
	closeup.distance = 6.5
	closeup.fov = 40.0
	context.camera.release()
	context.camera.move_to(closeup, 0.9)
	context.pixelation.animate_pixel_size(Presets.GRAB, 1.8)
	var tween := create_tween()
	tween.tween_property(grabber, "global_position", base + Vector3(0.0, 1.3, 0.0), 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: context.camera.shake(0.25, 0.4))
	tween.tween_property(grabber, "global_position", base + Vector3(0.0, 4.3, 0.0), 0.9)
	tween.parallel().tween_property(subject, "global_position", base + Vector3(0.0, 3.0, 0.0), 0.9)
	tween.tween_interval(0.5)
	tween.tween_callback(func() -> void: finished.emit())
