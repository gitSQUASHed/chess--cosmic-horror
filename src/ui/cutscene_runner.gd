class_name CutsceneRunner
extends Node3D
## Plays one placeholder cutscene: stages a few placeholder models, then shows the lines in the
## textbox. Used for the opening, the arrival and every ending.

signal finished(result: String)

var cutscene_name := ""
var context: GameContext
var closing_hint := ""

## Hands come down from this height to snatch a prop and leave the frame upward again.
const SNATCH_HEIGHT := 10.0
const SNATCH_DOWN_SECONDS := 0.35
const SNATCH_UP_SECONDS := 0.5
## Delay between two snatches of the same action.
const SNATCH_STAGGER := 0.7

var _textbox: Textbox
var _props: Dictionary = {}
var _actions: Dictionary = {}


func setup(game_context: GameContext, name_value: String, hint_after: String = "") -> void:
	context = game_context
	cutscene_name = name_value
	closing_hint = hint_after


func _ready() -> void:
	var data := Cutscenes.get_cutscene(cutscene_name)
	context.camera.release()
	context.camera.snap_to(CameraRig.cutscene_pose())
	if String(data.get("stage", "")) == "board":
		# The same board as Phase 1.
		add_child(Placeholders.board())
	else:
		# Board-sized stage, top surface at y 0.
		var backdrop := Placeholders.make("cutscene_" + cutscene_name, "box", Vector3(8.0, 0.2, 8.0), Palette.PROP.darkened(0.5))
		backdrop.position = Vector3(4.0, -0.2, 4.0)
		add_child(backdrop)
	for prop in data["props"]:
		var model := _make_prop(String(prop[0]))
		model.position = prop[1]
		add_child(model)
		_props[String(prop[0])] = model
	_actions = data.get("actions", {})
	_textbox = Textbox.new()
	_textbox.pause_game = false
	add_child(_textbox)
	var lines: Array[String] = []
	for line in data["lines"]:
		lines.append(String(line))
	if closing_hint != "":
		lines.append(closing_hint)
	_textbox.finished.connect(func() -> void: finished.emit("continue"))
	_textbox.line_shown.connect(_on_line_shown)
	_textbox.play(lines)


func _on_line_shown(index: int) -> void:
	for action in _actions.get(index, []):
		if String(action[0]) == "snatch":
			for order in range(1, action.size()):
				_snatch(String(action[order]), (order - 1) * SNATCH_STAGGER)


## A hand comes straight down onto the prop, closes on it and lifts it out of the frame.
func _snatch(prop_name: String, delay: float) -> void:
	var prop := _props.get(prop_name) as Node3D
	if prop == null:
		return
	_props.erase(prop_name)
	var hand := Placeholders.hand("hand/snatch", Vector3(0.8, 0.3, 0.8))
	Placeholders.add_outline(hand, Placeholders.OUTLINE_WIDTH_BOARD)
	var base := prop.position
	hand.position = base + Vector3(0.0, SNATCH_HEIGHT, 0.0)
	add_child(hand)
	var lifted := base + Vector3(0.0, SNATCH_HEIGHT, 0.0)
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(hand, "position", base + Vector3(0.0, 0.9, 0.0), SNATCH_DOWN_SECONDS).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void: prop.reparent(hand))
	tween.tween_property(hand, "position", lifted, SNATCH_UP_SECONDS).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(hand.queue_free)


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
