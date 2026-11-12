class_name CutsceneRunner
extends Node3D
## Plays one placeholder cutscene: stages a few placeholder models, then shows the lines in the
## textbox. Used for the opening, the arrival and every ending.

signal finished(result: String)

var cutscene_name := ""
var context: GameContext
var closing_hint := ""

var _textbox: Textbox


func setup(game_context: GameContext, name_value: String, hint_after: String = "") -> void:
	context = game_context
	cutscene_name = name_value
	closing_hint = hint_after


func _ready() -> void:
	var data := Cutscenes.get_cutscene(cutscene_name)
	var pose := CameraRig.phase_one_pose()
	pose.tilt_deg = 40.0
	pose.distance = 10.0
	context.camera.release()
	context.camera.snap_to(pose)
	var backdrop := Placeholders.make("cutscene_" + cutscene_name, "box", Vector3(3.0, 0.2, 3.0), Palette.PROP.darkened(0.5))
	backdrop.position = Vector3(4.0, -0.2, 4.0)
	add_child(backdrop)
	for prop in data["props"]:
		var model := _make_prop(String(prop[0]))
		model.position = prop[1]
		add_child(model)
	_textbox = Textbox.new()
	_textbox.pause_game = false
	add_child(_textbox)
	var lines: Array[String] = []
	for line in data["lines"]:
		lines.append(String(line))
	if closing_hint != "":
		lines.append(closing_hint)
	_textbox.finished.connect(func() -> void: finished.emit("continue"))
	_textbox.play(lines)


func _make_prop(prop_name: String) -> Node3D:
	match prop_name:
		"king":
			return Placeholders.king(context.run_config.king_is_white)
		"clock":
			return Placeholders.clock()
		"silhouette_left":
			return Placeholders.silhouette("left")
		"silhouette_right":
			return Placeholders.silhouette("right")
		_:
			return Placeholders.chess_piece(prop_name)
