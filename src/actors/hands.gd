class_name Hands
extends Node3D
## Organiser for all enemy hands. Owns the Hand nodes, the action queue, per-hand cooldowns,
## hand placement and every coordination rule. Hand itself stays a dumb command executor.
##
## Directors decide WHAT is requested (request) and tune the numbers below; Hands decides
## WHICH hand runs it, WHERE it goes and WHEN it may start.

signal hand_count_changed(count: int)
## Emitted when any hand's action becomes active (e.g. to remove pillars).
signal action_activated(hand: Hand, command: HandCommand)

## Deliberate combos use at most this many hands at once.
const MAX_COMBO_HANDS := 3

## Seconds a hand waits after finishing an action before it may start the next one.
var action_cooldown := 4.0
## Seconds subtracted from every telegraph time. Telegraphs never drop below Constants.MIN_TELEGRAPH.
var telegraph_reduction := 0.0
## Phase 2 rule: two simultaneous actions may not share an anchor tile.
var forbid_shared_centers := false
## World positions the hands emerge from (the rear silhouettes).
var origins: Array[Vector3] = [Vector3(1.5, 0.0, -3.5), Vector3(6.5, 0.0, -3.5)]
## Phase 2: returns a placement for the request, or null to use the board placement.
var placement_override: Callable = Callable()

var rng: RandomNumberGenerator

var _hands: Array[Hand] = []
var _cooldowns: Array[float] = []
var _queue: Array[Dictionary] = []
var _target_count := 0


func setup(random: RandomNumberGenerator) -> void:
	rng = random


func hand_count() -> int:
	return _hands.size()


## Changes the number of hands. Extra hands are only removed once they are idle.
func set_hand_count(count: int, new_hand_delay: float = 1.0) -> void:
	_target_count = maxi(count, 0)
	while _hands.size() < _target_count:
		var hand := Hand.new()
		hand.action_finished.connect(_on_action_finished)
		hand.action_became_active.connect(_on_action_activated)
		add_child(hand)
		_hands.append(hand)
		_cooldowns.append(new_hand_delay)
		hand_count_changed.emit(_hands.size())


func request(kind: String, level: int) -> void:
	_queue.append({"kind": kind, "level": level})


func queue_size() -> int:
	return _queue.size()


func has_queued(kind: String) -> bool:
	for entry in _queue:
		if String(entry["kind"]) == kind:
			return true
	return false


func clear() -> void:
	_queue.clear()
	for hand in _hands:
		hand.cancel()


func tick(delta: float) -> void:
	for index in range(_hands.size()):
		var hand := _hands[index]
		hand.tick(delta)
		if not hand.is_busy():
			_cooldowns[index] = maxf(0.0, _cooldowns[index] - delta)
	_assign_requests()
	_remove_surplus_hands()


func busy_hands() -> Array[Hand]:
	var result: Array[Hand] = []
	for hand in _hands:
		if hand.is_busy():
			result.append(hand)
	return result


func all_hands() -> Array[Hand]:
	return _hands


## True while any hand is running the given kind of action.
func is_running(kind: String) -> bool:
	for hand in _hands:
		if hand.is_busy() and hand.current_kind() == kind:
			return true
	return false


func _on_action_activated(hand: Hand, command: HandCommand) -> void:
	action_activated.emit(hand, command)


func _on_action_finished(hand: Hand, _command: HandCommand) -> void:
	var index := _hands.find(hand)
	if index >= 0:
		_cooldowns[index] = action_cooldown


func _assign_requests() -> void:
	for index in range(_hands.size()):
		var hand := _hands[index]
		if hand.is_busy() or _cooldowns[index] > 0.0:
			continue
		for queue_index in range(_queue.size()):
			if not _can_start(_queue[queue_index]):
				continue
			var command := _place(_queue[queue_index], index)
			if command == null:
				continue
			if forbid_shared_centers and _shares_center(command):
				continue
			_queue.remove_at(queue_index)
			hand.execute(command)
			break


## Rule: a wall may only start while another hand performs a non-wall action.
func _can_start(entry: Dictionary) -> bool:
	if String(entry["kind"]) != "wall":
		return true
	for hand in _hands:
		if hand.is_busy() and hand.current_kind() != "wall":
			return true
	return false


func _shares_center(command: HandCommand) -> bool:
	for hand in _hands:
		if hand.is_busy() and hand.current_command().anchor == command.anchor:
			return true
	return false


func _remove_surplus_hands() -> void:
	while _hands.size() > _target_count:
		var last := _hands.size() - 1
		if _hands[last].is_busy():
			return
		_hands[last].queue_free()
		_hands.remove_at(last)
		_cooldowns.remove_at(last)
		hand_count_changed.emit(_hands.size())


func _place(entry: Dictionary, hand_index: int) -> HandCommand:
	var definition := AttackCatalogue.get_definition(String(entry["kind"]), int(entry["level"]))
	var command: HandCommand = null
	if placement_override.is_valid():
		command = placement_override.call(definition, hand_index) as HandCommand
	if command == null:
		command = _place_on_board(definition)
	command.definition = definition
	command.telegraph_time = maxf(Constants.MIN_TELEGRAPH, definition.telegraph_base - telegraph_reduction)
	if command.origin == Vector3.ZERO and not origins.is_empty():
		command.origin = origins[hand_index % origins.size()]
	return command


func _place_on_board(definition: AttackDefinition) -> HandCommand:
	var command := HandCommand.new()
	var board := Constants.BOARD_TILES
	match definition.kind:
		"sweep":
			var sides := ["left", "right", "top", "bottom"]
			command.side = sides[rng.randi_range(0, sides.size() - 1)]
			var lane := rng.randi_range(0, board - definition.size)
			match command.side:
				"left":
					command.anchor = Vector2i(0, lane)
				"right":
					command.anchor = Vector2i(board - 1, lane)
				"top":
					command.anchor = Vector2i(lane, 0)
				_:
					command.anchor = Vector2i(lane, board - 1)
		"grab":
			var radius := int(definition.size / 2.0)
			command.anchor = Vector2i(
				rng.randi_range(radius, board - radius - 1),
				rng.randi_range(radius, board - radius - 1))
		_:
			command.horizontal = rng.randi_range(0, 1) == 0
			var span_x := definition.size if command.horizontal else 1
			var span_y := 1 if command.horizontal else definition.size
			command.anchor = Vector2i(
				rng.randi_range(0, board - span_x),
				rng.randi_range(0, board - span_y))
	return command
