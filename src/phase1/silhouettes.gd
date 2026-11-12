class_name Silhouettes
extends Node3D
## The two player silhouettes behind the board: restrained idle motion (breathing, head turns)
## and sparse, non-pausing background lines shown above them. Hands emerge from their positions.

const LINES: Array[String] = [
	"Did you put the pieces back?",
	"Not yet. Just one second.",
	"Don't forget the clock.",
	"Is the food getting cold?",
	"Almost done here.",
]

var _models: Array[Node3D] = []
var _speech: Array[Label3D] = []
var _time := 0.0
var _next_line_at := 8.0
var _last_line := -1
var _rng: RandomNumberGenerator


func setup(rng: RandomNumberGenerator) -> void:
	_rng = rng


## World positions the hands emerge from, one per silhouette.
func origins() -> Array[Vector3]:
	return [Vector3(1.5, 0.0, -5.0), Vector3(6.5, 0.0, -5.0)]


func _ready() -> void:
	var sides := ["left", "right"]
	var positions := origins()
	for index in range(2):
		var model := Placeholders.silhouette(sides[index])
		model.position = positions[index]
		add_child(model)
		_models.append(model)
		var speech := Label3D.new()
		speech.font_size = 32
		speech.pixel_size = 0.01
		speech.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		speech.no_depth_test = true
		speech.outline_size = 10
		speech.position = positions[index] + Vector3(0.0, 6.2, 0.0)
		speech.visible = false
		add_child(speech)
		_speech.append(speech)


func _process(delta: float) -> void:
	_time += delta
	for index in range(_models.size()):
		var model := _models[index]
		# Breathing and a slow head turn.
		model.scale.y = 1.0 + 0.015 * sin(_time * 1.4 + index)
		model.rotation.y = 0.12 * sin(_time * 0.35 + index * 2.0)
	if _time >= _next_line_at:
		_say_random_line()
		_next_line_at = _time + _rng.randf_range(9.0, 16.0)


func _say_random_line() -> void:
	var line_index := _rng.randi_range(0, LINES.size() - 1)
	if line_index == _last_line:
		line_index = (line_index + 1) % LINES.size()
	_last_line = line_index
	var speaker := _speech[_rng.randi_range(0, _speech.size() - 1)]
	speaker.text = LINES[line_index]
	speaker.visible = true
	get_tree().create_timer(3.5).timeout.connect(func() -> void:
		if is_instance_valid(speaker):
			speaker.visible = false)
