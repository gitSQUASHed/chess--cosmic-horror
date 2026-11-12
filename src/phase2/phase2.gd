class_name Phase2
extends Node3D
## Phase 2 "Beyond the Board": the pillar field, free movement, hands, guiding hands and the
## four endings (captured, void, escaped, endurance).

signal finished(result: String)

## Half size of the visible ground area, in camera-aligned metres (x across, y down the screen).
const VIEW_HALF := Vector2(11.0, 8.0)

var context: GameContext
## Highest threat value of all guiding hands, 0 to 1 (used by the screen effects).
var threat := 0.0

var _field: PillarField
var _king: Phase2King
var _hands: Hands
var _director := Phase2Director.new()
var _guiding: Array[GuidingHand] = []
var _ended := false
var _debug_label: Label


func setup(game_context: GameContext) -> void:
	context = game_context


func _ready() -> void:
	var start := Vector3(0.5, 8.0, 0.5)
	context.camera.release()
	context.camera.snap_to(CameraRig.phase_two_pose(Vector3(0.5, 0.0, 0.5)))
	_field = PillarField.new()
	add_child(_field)
	_field.setup(context.run_config.run_seed, context.run_config.escape_side)
	_field.void_entered.connect(_on_void_entered)
	_king = Phase2King.new()
	_king.setup(context.run_config.king_is_white, context.camera)
	_king.position = start
	_king.captured.connect(_on_captured)
	add_child(_king)
	context.camera.follow(_king)
	context.effects.set_mode(ScreenEffects.Mode.PHASE_TWO)
	_hands = Hands.new()
	_hands.setup(context.run_config.rng)
	_hands.forbid_shared_centers = true
	_hands.placement_override = Callable(self, "_place")
	_hands.action_activated.connect(_on_action_activated)
	add_child(_hands)
	_director.setup(_hands, context.run_config.rng, context.upgrades)
	_director.endurance_reached.connect(func() -> void: _finish_with_fade("endurance"))
	_field.update_around(start)
	context.pixelation.set_fade(1.0)
	context.pixelation.animate_fade(0.0, 1.2)
	_build_debug_label()


func _process(delta: float) -> void:
	if _ended:
		return
	_director.tick(delta)
	_hands.tick(delta)
	_field.update_around(_king.global_position)
	while _guiding.size() < _director.guiding_hands_wanted():
		_spawn_guiding_hand()
	threat = 0.0
	for guiding in _guiding:
		threat = maxf(threat, guiding.threat(_king.global_position))
	context.effects.set_threat(threat)
	if Input.is_action_just_pressed("jump_dash") and _at_escape_edge():
		_escape()
	_debug_label.text = "DEBUG phase 2  t=%d s  hands=%d  guiding=%d  threat=%.2f  pillars=%d  edge in %d tiles\nWASD move | Space dash (at the edge: jump down) | F3 +60s | F10 hide | R restart | [ ] pixel size" % [
		int(_director.elapsed), _hands.hand_count(), _guiding.size(), threat, _field.pillar_count(), _tiles_to_edge()]


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_F3:
			_director.skip_forward(60.0)
		KEY_F10:
			_debug_label.visible = not _debug_label.visible


func _tiles_to_edge() -> int:
	var tile := PillarField.world_to_tile(_king.global_position)
	return maxi(0, Constants.PHASE_TWO_ESCAPE_TILES - tile.x * context.run_config.escape_side)


func _at_escape_edge() -> bool:
	return _tiles_to_edge() == 0 and _king.is_on_floor()


## Camera-aligned placement for Phase 2 actions around the king.
func _place(definition: AttackDefinition, _hand_index: int) -> HandCommand:
	var rng := context.run_config.rng
	var king_position := _king.global_position
	var right := context.camera.screen_to_world_dir(Vector2.RIGHT)
	var down := context.camera.screen_to_world_dir(Vector2.DOWN)
	var command := HandCommand.new()
	command.definition = definition
	if definition.kind == "swipe":
		_place_swipe(command, king_position, right, down, rng)
		return command
	var offset := Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(-5.0, 5.0))
	if definition.kind != "grab" and rng.randf() < 0.5:
		offset = Vector2(rng.randf_range(-1.5, 1.5), rng.randf_range(-1.5, 1.5))
	var target := PillarField.world_to_tile(king_position + right * offset.x + down * offset.y)
	command.anchor = target
	if definition.kind == "wall":
		command.horizontal = rng.randi_range(0, 1) == 0
	elif definition.kind != "grab":
		command.anchor = target - Vector2i(int(definition.size / 2.0), int(definition.size / 2.0))
	command.origin = definition.rest_position(command) + Vector3(0.0, 8.0, 0.0)
	return command


## A flat hand appears just inside the frame and slides across at any angle until it leaves it.
func _place_swipe(command: HandCommand, king_position: Vector3, right: Vector3, down: Vector3, rng: RandomNumberGenerator) -> void:
	var edge := rng.randi_range(0, 3)
	var spot := Vector2.ZERO
	var inward := Vector2.ZERO
	match edge:
		0:
			spot = Vector2(-VIEW_HALF.x, rng.randf_range(-VIEW_HALF.y, VIEW_HALF.y))
			inward = Vector2.RIGHT
		1:
			spot = Vector2(VIEW_HALF.x, rng.randf_range(-VIEW_HALF.y, VIEW_HALF.y))
			inward = Vector2.LEFT
		2:
			spot = Vector2(rng.randf_range(-VIEW_HALF.x, VIEW_HALF.x), -VIEW_HALF.y)
			inward = Vector2.DOWN
		_:
			spot = Vector2(rng.randf_range(-VIEW_HALF.x, VIEW_HALF.x), VIEW_HALF.y)
			inward = Vector2.UP
	var screen_dir := inward.rotated(rng.randf_range(-1.0, 1.0))
	command.start = king_position + right * spot.x + down * spot.y
	command.start.y = 0.0
	command.direction = (right * screen_dir.x + down * screen_dir.y).normalized()
	command.heading = atan2(command.direction.x, command.direction.z)
	var travel := _exit_distance(spot, screen_dir, VIEW_HALF) + 2.0
	command.active_override = travel / AttackDefinition.SWIPE_SPEED
	command.origin = command.start - command.direction * 2.0


func _exit_distance(spot: Vector2, direction: Vector2, half: Vector2) -> float:
	var distance := INF
	if direction.x > 0.001:
		distance = minf(distance, (half.x - spot.x) / direction.x)
	elif direction.x < -0.001:
		distance = minf(distance, (-half.x - spot.x) / direction.x)
	if direction.y > 0.001:
		distance = minf(distance, (half.y - spot.y) / direction.y)
	elif direction.y < -0.001:
		distance = minf(distance, (-half.y - spot.y) / direction.y)
	return maxf(distance, 1.0) if distance != INF else 1.0


func _on_action_activated(_hand: Hand, command: HandCommand) -> void:
	var kind := command.definition.kind
	if kind == "void_removal" or kind == "punch":
		_field.remove_area(command.anchor, command.definition.size)


func _spawn_guiding_hand() -> void:
	var angle := context.run_config.rng.randf_range(0.0, TAU)
	var start := _king.global_position + Vector3(cos(angle), 0.0, sin(angle)) * 22.0
	start.y = 0.0
	var guiding := GuidingHand.new()
	guiding.setup(_king, start)
	add_child(guiding)
	_guiding.append(guiding)


func _on_captured() -> void:
	if _ended:
		return
	_stop_everything()
	_king.freeze()
	var sequence := CaptureSequence.start(self, context, _king)
	sequence.finished.connect(func() -> void: finished.emit("captured"))


func _on_void_entered(body: Node3D) -> void:
	if body == _king:
		_finish_with_fade("void")


func _escape() -> void:
	if _ended:
		return
	_stop_everything()
	context.camera.release()
	var forward := context.camera.screen_to_world_dir(Vector2(float(context.run_config.escape_side), 0.0))
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_king, "global_position", _king.global_position + forward * 3.0 + Vector3(0.0, -6.0, 0.0), 1.2).set_ease(Tween.EASE_IN)
	_king.freeze()
	_finish_with_fade("escaped", false)


func _finish_with_fade(result: String, stop: bool = true) -> void:
	if _ended and stop:
		return
	if stop:
		_stop_everything()
	context.pixelation.animate_pixel_size(Presets.ENDING, 1.4)
	context.pixelation.animate_fade(1.0, 1.0)
	await get_tree().create_timer(1.3).timeout
	if is_inside_tree():
		finished.emit(result)


func _stop_everything() -> void:
	_ended = true
	_hands.clear()
	for guiding in _guiding:
		guiding.set_physics_process(false)


func _build_debug_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	_debug_label = Label.new()
	_debug_label.position = Vector2(16, 12)
	_debug_label.add_theme_font_size_override("font_size", 14)
	layer.add_child(_debug_label)
