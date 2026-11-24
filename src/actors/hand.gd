class_name Hand
extends Node3D
## One enemy hand. A simple command executor: it runs exactly one HandCommand at a time
## (telegraph, act, recover) and reports back. It knows nothing about scheduling, cooldowns or
## other hands; Hands decides that.
##
## Hands stand directly on the field. During the telegraph a ground hand (sweep, swipe) already
## stands where it will act; a top-down hand (punch, smash) stays hidden and only its outlined
## shadow marks where it lands. It then falls from above the top of the screen (DROPPING);
## shadow and outline vanish when it lands, and the action becomes active. There are no other
## warnings.
##
## Physics: a damaging action enables an Area3D on the hand_danger layer, while ACTIVE for
## ground hands and while falling for top-down hands (the area moves down with the hand, so it
## crushes what it falls on). A blocking action (punch) enables a StaticBody3D on the wall layer
## while ACTIVE: the landed hand is the wall.

signal action_started(hand: Hand, command: HandCommand)
signal action_became_active(hand: Hand, command: HandCommand)
signal action_finished(hand: Hand, command: HandCommand)
signal command_refused(hand: Hand, command: HandCommand)

enum State { IDLE, EMERGING, DROPPING, ACTIVE, RECOVERING }

## Top-down hands fall from this many tiles up, which is above the top of the screen in both
## phases.
const DROP_TILES := 20.0
## Seconds the fall takes at speed scale 1.
const DROP_SECONDS := 0.35
## Shadow opacity at the start and end of the telegraph.
const SHADOW_FAINT := 0.35
const SHADOW_FULL := 0.85

var state: State = State.IDLE
## Thickness of the hand model's white outline, set by Hands per phase.
var outline_width := Placeholders.OUTLINE_WIDTH_BOARD

var _command: HandCommand
var _elapsed := 0.0
var _visual: Node3D
var _shadow: MeshInstance3D
var _danger: Area3D
var _wall: StaticBody3D
var _danger_shape: CollisionShape3D
var _wall_shape: CollisionShape3D


func _ready() -> void:
	visible = false


func is_busy() -> bool:
	return state != State.IDLE


func current_command() -> HandCommand:
	return _command


## Kind of the running action, or "" while idle.
func current_kind() -> String:
	return _command.definition.kind if _command != null else ""


## Accepts a command only while idle. Returns false (and emits command_refused) otherwise.
func execute(command: HandCommand) -> bool:
	if is_busy():
		command_refused.emit(self, command)
		return false
	_command = command
	_build_nodes()
	rotation.y = command.heading
	_enter(State.EMERGING)
	action_started.emit(self, command)
	return true


func cancel() -> void:
	if not is_busy():
		return
	var finished_command := _command
	_finish()
	action_finished.emit(self, finished_command)


func tick(delta: float) -> void:
	if state == State.IDLE:
		return
	_elapsed += delta
	match state:
		State.EMERGING:
			if _elapsed >= _command.telegraph_time:
				if _command.definition.from_above:
					_enter(State.DROPPING)
				else:
					_enter(State.ACTIVE)
					action_became_active.emit(self, _command)
		State.DROPPING:
			if _elapsed >= _drop_time():
				_enter(State.ACTIVE)
				action_became_active.emit(self, _command)
		State.ACTIVE:
			if _elapsed >= _command.active_time():
				_enter(State.RECOVERING)
		State.RECOVERING:
			if _elapsed >= _command.recovery_time():
				var finished_command := _command
				_finish()
				action_finished.emit(self, finished_command)
				return
	_update_visual()


func _enter(new_state: State) -> void:
	state = new_state
	_elapsed = 0.0
	var active := new_state == State.ACTIVE
	if _danger_shape != null:
		var danger_state := State.DROPPING if _command.definition.from_above else State.ACTIVE
		_danger_shape.disabled = new_state != danger_state
	if _wall_shape != null:
		_wall_shape.disabled = not active
	if _visual != null:
		ModelAnimator.play(_visual, String(State.keys()[new_state]).to_lower())
	_update_visual()


func _finish() -> void:
	state = State.IDLE
	_command = null
	_elapsed = 0.0
	visible = false
	_clear_nodes()


func _clear_nodes() -> void:
	for child in get_children():
		child.queue_free()
	_visual = null
	_shadow = null
	_danger = null
	_wall = null
	_danger_shape = null
	_wall_shape = null


func _build_nodes() -> void:
	_clear_nodes()
	var definition := _command.definition
	var volume := definition.volume_size(_command)
	if definition.shows_hand:
		# A blocking hand stands as tall as its blocking volume, so it reads as a wall.
		var height := AttackDefinition.VOLUME_HEIGHT if definition.blocks_movement else 0.3
		_visual = Placeholders.hand(definition.placeholder_name(), Vector3(volume.x, height, volume.z))
		Placeholders.add_outline(_visual, outline_width)
		add_child(_visual)
	if definition.from_above:
		_shadow = Placeholders.shadow(Vector2(volume.x, volume.z), outline_width)
		add_child(_shadow)
	if definition.damages:
		_danger_shape = _make_shape(definition)
		_danger = Area3D.new()
		_danger.collision_layer = Layers.HAND_DANGER
		_danger.collision_mask = 0
		_danger.monitoring = false
		_danger.monitorable = true
		_danger.add_child(_danger_shape)
		add_child(_danger)
	if definition.blocks_movement:
		_wall_shape = _make_shape(definition)
		_wall = StaticBody3D.new()
		_wall.collision_layer = Layers.WALL
		_wall.collision_mask = 0
		_wall.add_child(_wall_shape)
		add_child(_wall)


func _make_shape(definition: AttackDefinition) -> CollisionShape3D:
	var shape_node := CollisionShape3D.new()
	shape_node.shape = definition.make_shape(_command)
	shape_node.position.y = AttackDefinition.VOLUME_HEIGHT * 0.5
	shape_node.disabled = true
	return shape_node


func _update_visual() -> void:
	if _command == null:
		return
	var definition := _command.definition
	var drop := 0.0
	match state:
		State.EMERGING:
			position = _ground(definition.rest_position(_command))
			if _shadow != null:
				var progress := clampf(_elapsed / maxf(_command.telegraph_time, 0.001), 0.0, 1.0)
				Placeholders.set_shadow_strength(_shadow, lerpf(SHADOW_FAINT, SHADOW_FULL, progress))
		State.DROPPING:
			position = _ground(definition.rest_position(_command))
			# Accelerating fall onto the shadow.
			var fall := clampf(_elapsed / _drop_time(), 0.0, 1.0)
			drop = DROP_TILES * _command.tile_size * (1.0 - fall * fall)
			if _shadow != null:
				Placeholders.set_shadow_strength(_shadow, SHADOW_FULL)
		State.ACTIVE:
			position = _ground(definition.active_position(_command, _elapsed))
		State.RECOVERING:
			position = _ground(definition.active_position(_command, _command.active_time()))
	if _shadow != null:
		_shadow.visible = state == State.EMERGING or state == State.DROPPING
	if _visual != null:
		# Top-down hands are not on screen before their attack.
		_visual.visible = not (definition.from_above and state == State.EMERGING)
		_visual.position.y = drop
	if _danger != null:
		# The crush volume falls with the hand.
		_danger.position.y = drop
	visible = true


func _drop_time() -> float:
	return DROP_SECONDS / _command.speed_scale


func _ground(point: Vector3) -> Vector3:
	return Vector3(point.x, _command.surface_y, point.z)
