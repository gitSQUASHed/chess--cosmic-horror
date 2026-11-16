class_name Hand
extends Node3D
## One enemy hand. A simple command executor: it runs exactly one HandCommand at a time
## (telegraph, act, recover) and reports back. It knows nothing about scheduling, cooldowns or
## other hands; Hands decides that.
##
## Hands stand directly on the field. During the telegraph a ground hand (sweep, swipe, wall)
## already stands where it will act; a top-down hand (grab, punch) stays hidden and only its
## outlined shadow marks where it lands; shadow and outline vanish when it lands. It then falls from above the top of the screen (DROPPING) and
## the attack starts when it lands. There are no other warnings.
##
## Physics: while ACTIVE, a damaging action enables an Area3D on the hand_danger layer and a
## blocking action (wall) enables a StaticBody3D on the wall layer.

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
var _effect_visual: Node3D
var _shadow: MeshInstance3D
var _danger: Area3D
var _wall: StaticBody3D
var _shapes: Array[CollisionShape3D] = []


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
	for shape in _shapes:
		shape.disabled = not active
	if _effect_visual != null:
		_effect_visual.visible = active
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
	_effect_visual = null
	_shadow = null
	_danger = null
	_wall = null
	_shapes.clear()


func _build_nodes() -> void:
	_clear_nodes()
	var definition := _command.definition
	var volume := definition.volume_size(_command)
	if definition.shows_hand:
		_visual = Placeholders.hand(definition.placeholder_name(), Vector3(volume.x, 0.3, volume.z))
		Placeholders.add_outline(_visual, outline_width)
		add_child(_visual)
	if definition.from_above:
		_shadow = Placeholders.shadow(Vector2(volume.x, volume.z), outline_width)
		add_child(_shadow)
	if not definition.damages and not definition.blocks_movement:
		return
	var shape_node := CollisionShape3D.new()
	shape_node.shape = definition.make_shape(_command)
	shape_node.position.y = AttackDefinition.VOLUME_HEIGHT * 0.5
	shape_node.disabled = true
	_shapes.append(shape_node)
	if definition.damages:
		_danger = Area3D.new()
		_danger.collision_layer = Layers.HAND_DANGER
		_danger.collision_mask = 0
		_danger.monitoring = false
		_danger.monitorable = true
		_danger.add_child(shape_node)
		add_child(_danger)
	elif definition.blocks_movement:
		_wall = StaticBody3D.new()
		_wall.collision_layer = Layers.WALL
		_wall.collision_mask = 0
		_wall.add_child(shape_node)
		add_child(_wall)
		_effect_visual = Placeholders.make("wall", "box", volume, Palette.WALL)
		_effect_visual.visible = false
		add_child(_effect_visual)


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
	visible = true


func _drop_time() -> float:
	return DROP_SECONDS / _command.speed_scale


func _ground(point: Vector3) -> Vector3:
	return Vector3(point.x, _command.surface_y, point.z)
