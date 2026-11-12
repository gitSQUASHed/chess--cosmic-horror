class_name Textbox
extends CanvasLayer
## Bottom-covering pixel-font textbox for cutscenes and important story text. While it is
## open it can pause the game; Space (confirm) advances. Not a persistent HUD element.
## A pixel font dropped at res://src/assets/fonts/pixel.ttf is used automatically.

signal finished

const FONT_PATH := "res://src/assets/fonts/pixel.ttf"

var pause_game := true

var _lines: Array[String] = []
var _index := 0
var _panel: ColorRect
var _label: Label
var _hint: Label
var _open := false


func _ready() -> void:
	layer = 130
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = ColorRect.new()
	_panel.color = Color(0.02, 0.05, 0.03, 0.95)
	_panel.anchor_left = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.72
	_panel.anchor_bottom = 1.0
	_panel.visible = false
	add_child(_panel)
	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_left = 48.0
	_label.offset_top = 32.0
	_label.offset_right = -48.0
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 28)
	_label.add_theme_color_override("font_color", Color("b6e8bd"))
	if ResourceLoader.exists(FONT_PATH):
		_label.add_theme_font_override("font", load(FONT_PATH) as Font)
	_panel.add_child(_label)
	_hint = Label.new()
	_hint.text = "Space"
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -120.0
	_hint.offset_top = -48.0
	_hint.offset_right = -24.0
	_hint.offset_bottom = -16.0
	_hint.add_theme_font_size_override("font_size", 16)
	_hint.add_theme_color_override("font_color", Color("2f6b3f"))
	_panel.add_child(_hint)


func is_open() -> bool:
	return _open


## Shows the lines one after another. Emits `finished` after the last one is confirmed.
func play(lines: Array[String]) -> void:
	if lines.is_empty():
		finished.emit()
		return
	_lines = lines
	_index = 0
	_open = true
	_panel.visible = true
	_show_line()
	if pause_game:
		get_tree().paused = true


func _show_line() -> void:
	_label.text = _lines[_index]


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed("confirm"):
		return
	get_viewport().set_input_as_handled()
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_line()


func _close() -> void:
	_open = false
	_panel.visible = false
	if pause_game:
		get_tree().paused = false
	finished.emit()


func _exit_tree() -> void:
	if _open and pause_game and get_tree() != null:
		get_tree().paused = false
