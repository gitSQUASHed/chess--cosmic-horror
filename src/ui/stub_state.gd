class_name StubState
extends Node3D
## Labelled stand-in for a game state that is not implemented yet (or a cutscene placeholder).
## Confirm continues. With `ending_menu` the keys 1 to 4 pick an ending.

signal finished(result: String)

var state_name := "stub"
var hint := "Space: continue"
var ending_menu := false
var context: GameContext
## If above zero, the stub continues by itself after this many seconds.
var auto_seconds := 0.0


func setup(game_context: GameContext, placeholder_name: String, hint_text: String = "Space: continue", with_ending_menu: bool = false) -> void:
	context = game_context
	state_name = placeholder_name
	hint = hint_text
	ending_menu = with_ending_menu


func _ready() -> void:
	context.camera.snap_to(CameraRig.phase_one_pose())
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var label := Label.new()
	label.text = "%s\n%s" % [state_name, hint]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 24)
	layer.add_child(label)
	var marker := Placeholders.make(state_name, "box", Vector3(2, 2, 2), Palette.PROP)
	marker.position = Vector3(4, 0, 4)
	add_child(marker)
	if auto_seconds > 0.0:
		get_tree().create_timer(auto_seconds).timeout.connect(func() -> void: finished.emit("continue"))


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if ending_menu:
		match (event as InputEventKey).keycode:
			KEY_1:
				finished.emit("captured")
			KEY_2:
				finished.emit("void")
			KEY_3:
				finished.emit("escaped")
			KEY_4:
				finished.emit("endurance")
	elif event.is_action_pressed("confirm"):
		finished.emit("continue")
