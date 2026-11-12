class_name Phase1
extends Node3D
## Phase 1 "The Board Cleanup": 8x8 board, the king, the clock and the hands.

signal finished(result: String)

var context: GameContext

var _hands: Hands
var _director := Phase1Director.new()
var _king: Phase1King
var _clock: Node3D
var _silhouettes: Silhouettes
var _ended := false
var _debug_label: Label


func setup(game_context: GameContext) -> void:
	context = game_context


func _ready() -> void:
	context.camera.release()
	context.camera.snap_to(CameraRig.phase_one_pose())
	_build_board()
	_build_edges()
	_clock = Placeholders.clock()
	var clock_x := -1.8 if context.run_config.escape_side < 0 else Constants.BOARD_TILES + 1.8
	_clock.position = Vector3(clock_x, 0.0, 3.5)
	add_child(_clock)
	_king = Phase1King.new()
	_king.setup(context.run_config.king_is_white)
	_king.captured.connect(_on_captured)
	add_child(_king)
	_silhouettes = Silhouettes.new()
	_silhouettes.setup(context.run_config.rng)
	add_child(_silhouettes)
	_hands = Hands.new()
	_hands.setup(context.run_config.rng)
	_hands.origins = _silhouettes.origins()
	add_child(_hands)
	context.effects.set_mode(ScreenEffects.Mode.PHASE_ONE)
	_director.setup(_hands, context.run_config.rng)
	_director.finished.connect(_on_director_finished)
	_build_debug_label()


func _process(delta: float) -> void:
	if _ended:
		return
	_director.tick(delta)
	_hands.tick(delta)
	_king.try_move(_grid_input())
	Placeholders.set_subtitle(_clock, _format_time(Constants.PHASE_ONE_SECONDS - _director.elapsed))
	_debug_label.text = "DEBUG phase 1  t=%s  hands=%d  queue=%d\nWASD/arrows move | F3 +30s | F10 hide | R restart | [ ] pixel size | F2 phase 2" % [
		_format_time(_director.elapsed), _hands.hand_count(), _hands.queue_size()]


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_F3:
			_director.skip_forward(30.0)
		KEY_F10:
			_debug_label.visible = not _debug_label.visible


func _build_board() -> void:
	var board := Node3D.new()
	board.name = "Board"
	add_child(board)
	for x in range(Constants.BOARD_TILES):
		for z in range(Constants.BOARD_TILES):
			var tile := Placeholders.tile((x + z) % 2 == 0)
			tile.position = Vector3(x + 0.5, -0.1, z + 0.5)
			board.add_child(tile)
	var label := Label3D.new()
	label.text = "board (tile_light / tile_dark)"
	label.font_size = 32
	label.pixel_size = 0.008
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(4.0, 0.3, Constants.BOARD_TILES + 0.8)
	board.add_child(label)


## Invisible edge bodies on the wall layer so a physics query blocks moves off the board.
func _build_edges() -> void:
	var size := float(Constants.BOARD_TILES)
	var edges := [
		[Vector3(-0.5, 0.5, size / 2.0), Vector3(1.0, 1.0, size + 2.0)],
		[Vector3(size + 0.5, 0.5, size / 2.0), Vector3(1.0, 1.0, size + 2.0)],
		[Vector3(size / 2.0, 0.5, -0.5), Vector3(size + 2.0, 1.0, 1.0)],
		[Vector3(size / 2.0, 0.5, size + 0.5), Vector3(size + 2.0, 1.0, 1.0)],
	]
	for edge in edges:
		var body := StaticBody3D.new()
		body.collision_layer = Layers.WALL
		body.collision_mask = 0
		body.position = edge[0]
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = edge[1]
		shape_node.shape = shape
		body.add_child(shape_node)
		add_child(body)


func _build_debug_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	_debug_label = Label.new()
	_debug_label.position = Vector2(16, 12)
	_debug_label.add_theme_font_size_override("font_size", 14)
	layer.add_child(_debug_label)


func _grid_input() -> Vector2i:
	return Vector2i(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up")))


func _on_captured() -> void:
	if _ended:
		return
	_ended = true
	_hands.clear()
	_king.freeze()
	var sequence := CaptureSequence.start(self, context, _king)
	sequence.finished.connect(func() -> void: finished.emit("captured"))


func _on_director_finished() -> void:
	if _ended:
		return
	_ended = true
	_hands.clear()
	_king.freeze()
	context.upgrades = {"sweep": 2, "grab": 2, "wall": 2}
	_play_collapse()


## The board breaks apart, the king falls into darkness; camera and pixelation follow.
func _play_collapse() -> void:
	var rng := context.run_config.rng
	var tween := create_tween().set_parallel(true)
	for tile in get_node("Board").get_children():
		if not (tile is Node3D) or tile is Label3D:
			continue
		var delay := rng.randf() * 1.4
		tween.tween_property(tile, "position:y", -40.0, 1.6).set_delay(delay).set_ease(Tween.EASE_IN)
		tween.tween_property(tile, "rotation_degrees", Vector3(rng.randf_range(-90.0, 90.0), 0.0, rng.randf_range(-90.0, 90.0)), 1.6).set_delay(delay)
	tween.tween_property(_king, "position:y", -40.0, 2.4).set_delay(1.3).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(1.3).timeout
	if not is_inside_tree():
		return
	var falling := CameraRig.Pose.new()
	falling.focus = _king.position
	falling.tilt_deg = 70.0
	falling.distance = 16.0
	context.camera.follow(_king)
	context.camera.move_to(falling, 1.5)
	context.pixelation.animate_pixel_size(Presets.FALL, 2.0)
	await get_tree().create_timer(1.3).timeout
	if not is_inside_tree():
		return
	context.pixelation.animate_fade(1.0, 0.8)
	await get_tree().create_timer(0.9).timeout
	if is_inside_tree():
		finished.emit("survived")


func _format_time(seconds: float) -> String:
	var whole := maxi(0, ceili(seconds))
	return "%02d:%02d" % [whole / 60, whole % 60]
