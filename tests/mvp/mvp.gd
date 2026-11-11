extends Node2D

## Functional, deliberately plain gameplay prototype.
## Every gameplay object is drawn as a coloured square or simple line.

const BOARD_TILES := 8
const PHASE_ONE_SECONDS := 120.0
const TILE_SIZE := 56.0
const PHASE_TWO_ESCAPE_TILES := 60 # Reduced from the planned long-run distance for repeatable MVP tests.
const PHASE_TWO_ENDURANCE_SECONDS := 600.0

enum GameState { PHASE_ONE, TRANSITION, PHASE_TWO, WON, LOST }

var state := GameState.PHASE_ONE
var rng := RandomNumberGenerator.new()
var run_seed := 0
var escape_direction := 1
var player_is_white := true

# Phase 1
var grid_player := Vector2i(3, 4)
var phase_one_elapsed := 0.0
var grid_move_cooldown := 0.0
var attack_cooldown := 1.4
var phase_one_attacks: Array[Dictionary] = []

# Transition
var transition_elapsed := 0.0

# Phase 2
var world_player := Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
var jump_remaining := 0.0
var jump_requested := false
var dash_remaining := 0.0
var dash_direction := Vector2.RIGHT
var player_facing := Vector2.RIGHT
var phase_two_elapsed := 0.0
var guiding_hands: Array[Dictionary] = []
var phase_two_attackers: Array[Dictionary] = []
var removed_tiles: Dictionary = {}

var end_title := ""
var end_detail := ""

var font: Font


func _ready() -> void:

	font = ThemeDB.fallback_font
	rng.randomize()
	start_phase_one()
	queue_redraw()


func _process(delta: float) -> void:
	match state:
		GameState.PHASE_ONE:
			update_phase_one(delta)
		GameState.TRANSITION:
			update_transition(delta)
		GameState.PHASE_TWO:
			update_phase_two(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			jump_requested = true
		match event.keycode:
			KEY_R, KEY_F1:
				start_phase_one()
			KEY_F2:
				start_phase_two()
			KEY_F3:
				if state == GameState.PHASE_TWO:
					# Lets testers inspect the one-minute escalation without waiting.
					phase_two_elapsed = maxf(phase_two_elapsed, 60.0)
					ensure_guiding_hands()
					ensure_phase_two_attackers()
					trigger_all_attackers()
			KEY_F7:
				if state == GameState.PHASE_TWO:
					# Lets testers inspect the 2:00 punch and void upgrades without waiting.
					phase_two_elapsed = maxf(phase_two_elapsed, 120.0)
					ensure_guiding_hands()
					ensure_phase_two_attackers()
					trigger_all_attackers()
			KEY_F4:
				if state == GameState.PHASE_TWO:
					finish_run("ESCAPED", "MVP test: escape condition reached.")
			KEY_F5:
				if state == GameState.PHASE_TWO:
					finish_run("CAPTURED", "MVP test: hand collision.")
			KEY_F6:
				if state == GameState.PHASE_TWO:
					finish_run("FELL", "MVP test: void collision.")


func start_phase_one() -> void:
	run_seed = rng.randi()
	escape_direction = -1 if rng.randi_range(0, 1) == 0 else 1
	player_is_white = rng.randi_range(0, 1) == 0
	state = GameState.PHASE_ONE
	grid_player = Vector2i(3, 4)
	phase_one_elapsed = 0.0
	grid_move_cooldown = 0.0
	attack_cooldown = 1.4
	phase_one_attacks.clear()
	end_title = ""
	end_detail = ""


func update_phase_one(delta: float) -> void:
	phase_one_elapsed += delta
	grid_move_cooldown -= delta
	if grid_move_cooldown <= 0.0:
		var move := get_grid_input()
		if move != Vector2i.ZERO:
			try_grid_move(move)
			grid_move_cooldown = 0.14

	attack_cooldown -= delta
	if attack_cooldown <= 0.0 and can_spawn_phase_one_attack():
		spawn_phase_one_attack()
		attack_cooldown = phase_one_attack_interval()

	update_phase_one_attacks(delta)
	if phase_one_elapsed >= PHASE_ONE_SECONDS:
		state = GameState.TRANSITION
		transition_elapsed = 0.0


func get_grid_input() -> Vector2i:
	return Vector2i(
		key_axis(KEY_D, KEY_RIGHT) - key_axis(KEY_A, KEY_LEFT),
		key_axis(KEY_S, KEY_DOWN) - key_axis(KEY_W, KEY_UP)
	)


func get_free_input() -> Vector2:
	return Vector2(
		key_axis(KEY_D, KEY_RIGHT) - key_axis(KEY_A, KEY_LEFT),
		key_axis(KEY_S, KEY_DOWN) - key_axis(KEY_W, KEY_UP)
	).normalized()


func key_axis(letter: int, arrow: int) -> int:
	return 1 if Input.is_key_pressed(letter) or Input.is_key_pressed(arrow) else 0


func try_grid_move(move: Vector2i) -> void:
	var target := grid_player + move
	if target.x < 0 or target.x >= BOARD_TILES or target.y < 0 or target.y >= BOARD_TILES:
		return
	if phase_one_wall_cells().has(target):
		return
	grid_player = target
	if phase_one_danger_cells().has(grid_player):
		finish_run("CAPTURED", "A clearing hand reached the king on the board.")


func phase_one_attack_interval() -> float:
	if phase_one_elapsed < 30.0:
		return 4.2
	if phase_one_elapsed < 60.0:
		return 3.7
	if phase_one_elapsed < 90.0:
		return 3.0
	return maxf(0.0, 2.1 - (phase_one_elapsed - 90.0) / 50.0)


func can_spawn_phase_one_attack() -> bool:
	return phase_one_attacks.size() < phase_one_hand_count()


func phase_one_hand_count() -> int:
	if phase_one_elapsed < 30.0:
		return 1
	if phase_one_elapsed < 90.0:
		return 2
	return 3


func append_phase_one_action(action: Dictionary) -> void:
	# Each item is one occupied hand. A hand gets a new action only after this one ends.
	for hand_id in range(phase_one_hand_count()):
		var occupied := false
		for active_action in phase_one_attacks:
			if active_action.get("hand_id", -1) == hand_id:
				occupied = true
				break
		if not occupied:
			action["hand_id"] = hand_id
			phase_one_attacks.append(action)
			return


func spawn_phase_one_attack() -> void:
	var attack_type := "sweep"
	if phase_one_elapsed >= 30.0:
		var options := ["sweep", "grab"]
		if phase_one_has_non_wall_action():
			options.append("wall")
		attack_type = options[rng.randi_range(0, options.size() - 1)]
	if phase_one_elapsed < 30.0 and rng.randi_range(0, 1) == 1:
		attack_type = "grab"

	match attack_type:
		"sweep":
			var side: String = ["left", "right", "top", "bottom"][rng.randi_range(0, 3)]
			var width := 1 if phase_one_elapsed < 60.0 else 3
			append_phase_one_action({
				"type": "sweep", "side": side, "lane": rng.randi_range(0, BOARD_TILES - width),
				"width": width, "age": 0.0, "telegraph": phase_one_telegraph(0.72), "duration": 1.55
			})
		"grab":
			var radius := 1 if phase_one_elapsed < 60.0 else 2
			append_phase_one_action({
				"type": "grab", "center": Vector2i(rng.randi_range(radius, BOARD_TILES - radius - 1), rng.randi_range(radius, BOARD_TILES - radius - 1)),
				"radius": radius, "age": 0.0, "telegraph": phase_one_telegraph(0.92), "duration": 0.48
			})
		"wall":
			var horizontal := rng.randi_range(0, 1) == 0
			var start := Vector2i(rng.randi_range(0, 5), rng.randi_range(0, 5))
			append_phase_one_action({
				"type": "wall", "start": start, "horizontal": horizontal,
				"age": 0.0, "telegraph": phase_one_telegraph(0.70), "duration": 3.7
			})


func phase_one_has_non_wall_action() -> bool:
	for action in phase_one_attacks:
		if action["type"] != "wall":
			return true
	return false


func phase_one_telegraph(base_time: float) -> float:
	return maxf(0.5, base_time - phase_one_elapsed / PHASE_ONE_SECONDS * 0.3)


func update_phase_one_attacks(delta: float) -> void:
	for index in range(phase_one_attacks.size() - 1, -1, -1):
		var attack := phase_one_attacks[index]
		attack["age"] = float(attack["age"]) + delta
		phase_one_attacks[index] = attack
		if attack_is_active(attack) and phase_one_attack_cells(attack).has(grid_player):
			finish_run("CAPTURED", "A clearing hand reached the king on the board.")
			return
		if float(attack["age"]) >= float(attack["telegraph"]) + float(attack["duration"]):
			phase_one_attacks.remove_at(index)


func attack_is_active(attack: Dictionary) -> bool:
	var age := float(attack["age"])
	return age >= float(attack["telegraph"]) and age < float(attack["telegraph"]) + float(attack["duration"])


func phase_one_danger_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for attack in phase_one_attacks:
		if attack.get("type") != "wall" and attack_is_active(attack):
			for cell in phase_one_attack_cells(attack):
				if not cells.has(cell):
					cells.append(cell)
	return cells


func phase_one_wall_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for attack in phase_one_attacks:
		if attack.get("type") == "wall" and attack_is_active(attack):
			cells.append_array(phase_one_attack_cells(attack))
	return cells


func phase_one_attack_cells(attack: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	match attack.get("type"):
		"sweep":
			var step := clampi(int((float(attack["age"]) - float(attack["telegraph"])) / 0.18), 0, BOARD_TILES - 1)
			for offset in range(int(attack["width"])):
				var lane := int(attack["lane"]) + offset
				match attack["side"]:
					"left": cells.append(Vector2i(step, lane))
					"right": cells.append(Vector2i(BOARD_TILES - 1 - step, lane))
					"top": cells.append(Vector2i(lane, step))
					"bottom": cells.append(Vector2i(lane, BOARD_TILES - 1 - step))
		"grab":
			var center: Vector2i = attack["center"]
			var radius := int(attack["radius"])
			for x in range(center.x - radius, center.x + radius + 1):
				for y in range(center.y - radius, center.y + radius + 1):
					var relative := Vector2i(x - center.x, y - center.y)
					var in_square := radius == 1
					var in_circle := radius > 1 and relative.length_squared() <= radius * radius
					if in_square or in_circle:
						cells.append(Vector2i(x, y))
		"wall":
			var start: Vector2i = attack["start"]
			for offset in range(3):
				cells.append(start + (Vector2i(offset, 0) if attack["horizontal"] else Vector2i(0, offset)))
	return cells


func update_transition(delta: float) -> void:
	transition_elapsed += delta
	if transition_elapsed >= 1.6:
		start_phase_two()


func start_phase_two() -> void:
	state = GameState.PHASE_TWO
	world_player = Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	jump_remaining = 0.0
	jump_requested = false
	dash_remaining = 0.0
	dash_direction = Vector2.RIGHT
	player_facing = Vector2.RIGHT
	phase_two_elapsed = 0.0
	phase_two_attackers.clear()
	add_phase_two_attacker()
	add_phase_two_attacker()
	removed_tiles.clear()
	guiding_hands.clear()
	end_title = ""
	end_detail = ""


func update_phase_two(delta: float) -> void:
	phase_two_elapsed += delta
	var input_direction := get_free_input()
	if jump_requested and jump_remaining <= 0.0 and is_solid_tile(world_to_tile(world_player)):
		jump_remaining = 0.56
		dash_remaining = 0.26
		dash_direction = input_direction if input_direction != Vector2.ZERO else player_facing
	jump_requested = false

	var movement_direction := input_direction
	var movement_speed := 245.0
	if dash_remaining > 0.0:
		if input_direction != Vector2.ZERO:
			var dash_turn_angle := dash_direction.angle_to(input_direction)
			dash_direction = dash_direction.rotated(clampf(dash_turn_angle, -2.4 * delta, 2.4 * delta)).normalized()
		movement_direction = dash_direction
		movement_speed = 440.0
		player_facing = dash_direction
		dash_remaining = maxf(0.0, dash_remaining - delta)
	elif input_direction != Vector2.ZERO:
		player_facing = input_direction
	var next_position := world_player + movement_direction * movement_speed * delta
	if not phase_two_wall_contains(next_position):
		world_player = next_position
	jump_remaining = maxf(0.0, jump_remaining - delta)

	if jump_remaining <= 0.0 and not is_solid_tile(world_to_tile(world_player)):
		finish_run("FELL", "The king stepped into the void.")
		return

	update_guiding_hands(delta)
	ensure_guiding_hands()
	for hand in guiding_hands:
		var hand_position: Vector2 = hand["position"]
		if world_player.distance_to(hand_position) < TILE_SIZE * 0.44:
			finish_run("CAPTURED", "A guiding missile hand caught the king.")
			return

	update_phase_two_attacks(delta)
	if state != GameState.PHASE_TWO:
		return

	var tile := world_to_tile(world_player)
	if tile.x * escape_direction >= PHASE_TWO_ESCAPE_TILES:
		finish_run("ESCAPED", "The king reached the remembered clock side.")
	elif phase_two_elapsed >= PHASE_TWO_ENDURANCE_SECONDS:
		finish_run("ENDURED", "The king survived the endurance timer.")


func make_guiding_hand(position: Vector2) -> Dictionary:
	var initial_direction := (world_player - position).normalized()
	return {
		"position": position,
		"direction": initial_direction,
		"speed": 0.0,
		"acceleration": 52.0,
		"max_speed": 735.0,
		"min_turn_rate": 0.34,
		"max_turn_rate": 1.35
	}


func ensure_guiding_hands() -> void:
	var desired_count := 0
	if phase_two_elapsed >= 60.0:
		desired_count = 1
	if phase_two_elapsed >= 180.0:
		desired_count = 2
	while guiding_hands.size() < desired_count:
		var offset := Vector2(-6.5 * TILE_SIZE, 2.5 * TILE_SIZE) if guiding_hands.is_empty() else Vector2(7.5 * TILE_SIZE, -4.0 * TILE_SIZE)
		guiding_hands.append(make_guiding_hand(world_player + offset))


func update_guiding_hands(delta: float) -> void:
	for index in range(guiding_hands.size()):
		var hand := guiding_hands[index]
		var position: Vector2 = hand["position"]
		var direction: Vector2 = hand["direction"]
		var to_player := world_player - position
		var current_speed := float(hand["speed"])
		if to_player.length() > 0.1:
			var target_direction := to_player.normalized()
			var turning_angle := direction.angle_to(target_direction)
			var speed_ratio := clampf(current_speed / float(hand["max_speed"]), 0.0, 1.0)
			var turn_rate := lerpf(float(hand["max_turn_rate"]), float(hand["min_turn_rate"]), speed_ratio)
			direction = direction.rotated(clampf(turning_angle, -turn_rate * delta, turn_rate * delta)).normalized()
		var speed := minf(float(hand["max_speed"]), current_speed + float(hand["acceleration"]) * delta)
		hand["direction"] = direction
		hand["speed"] = speed
		hand["position"] = position + direction * speed * delta
		guiding_hands[index] = hand


func add_phase_two_attacker() -> void:
	phase_two_attackers.append({
		"cooldown": 1.1 + rng.randf() * 1.4,
		"attack": {}
	})


func ensure_phase_two_attackers() -> void:
	# The curve pauses at 1:00 for new abilities, then caps at seven attack hands.
	var desired_count := 2
	if phase_two_elapsed >= 30.0:
		desired_count = 3
	if phase_two_elapsed >= 90.0:
		desired_count = 4
	if phase_two_elapsed >= 120.0:
		desired_count = 5
	if phase_two_elapsed >= 150.0:
		desired_count = 6
	if phase_two_elapsed >= 180.0:
		desired_count = 7
	while phase_two_attackers.size() < desired_count:
		add_phase_two_attacker()


func trigger_all_attackers() -> void:
	for index in range(phase_two_attackers.size()):
		var attacker := phase_two_attackers[index]
		attacker["cooldown"] = 0.0
		phase_two_attackers[index] = attacker


func update_phase_two_attacks(delta: float) -> void:
	ensure_phase_two_attackers()
	apply_phase_two_upgrade_state()
	for index in range(phase_two_attackers.size()):
		var attacker := phase_two_attackers[index]
		var attack: Dictionary = attacker["attack"]
		if attack.is_empty():
			attacker["cooldown"] = float(attacker["cooldown"]) - delta
			if float(attacker["cooldown"]) <= 0.0:
				attacker["attack"] = make_phase_two_attack()
				attacker["cooldown"] = phase_two_attack_interval()
		else:
			attack["age"] = float(attack["age"]) + delta
			var age := float(attack["age"])
			var action_finished := false
			if age >= float(attack["telegraph"]):
				if attack["type"] == "sweep":
					if sweep_hits_player(attack):
						finish_run("CAPTURED", "A directional sweep crossed the king.")
						return
					if sweep_is_outside_view(attack):
						action_finished = true
				elif not attack["resolved"]:
					resolve_phase_two_attack(attack)
					attack["resolved"] = true
			if attack["type"] != "sweep" and age >= float(attack["telegraph"]) + float(attack["duration"]):
				action_finished = true
			if action_finished:
				attacker["attack"] = {}
			else:
				attacker["attack"] = attack
		phase_two_attackers[index] = attacker


func apply_phase_two_upgrade_state() -> void:
	if phase_two_elapsed < 120.0:
		return
	for index in range(phase_two_attackers.size()):
		var attacker := phase_two_attackers[index]
		var action: Dictionary = attacker["attack"]
		if action.is_empty():
			continue
		if action["type"] == "void":
			action["remove_size"] = 2
		elif action["type"] == "punch":
			action["punch_size"] = 3
		attacker["attack"] = action
		phase_two_attackers[index] = attacker


func phase_two_attack_interval() -> float:
	if phase_two_elapsed < 30.0:
		return 4.2
	if phase_two_elapsed < 60.0:
		return 3.2
	if phase_two_elapsed < 120.0:
		return 2.25
	if phase_two_elapsed < 180.0:
		return 1.55
	return maxf(0.0, 1.0 - (phase_two_elapsed - 180.0) / 180.0)


func phase_two_telegraph() -> float:
	return maxf(0.5, 0.90 - phase_two_elapsed / 450.0)


func make_phase_two_attack() -> Dictionary:
	var options: Array[String] = ["sweep", "grab"]
	if phase_two_elapsed >= 60.0:
		options.append_array(["void", "punch"])
	if phase_two_has_non_wall_action():
		options.append("wall")
	var type: String = options[rng.randi_range(0, options.size() - 1)]
	var center_tile := random_phase_two_center_tile()
	var target := tile_to_world_center(center_tile)
	var direction := Vector2.from_angle(rng.randf_range(0.0, TAU))
	# Phase 1 upgrades persist across the transition into Phase 2.
	var sweep_width := 3
	var grab_radius := 2.5 # Phase 1's grab upgrade persists into Phase 2.
	var remove_size := 2 if phase_two_elapsed >= 120.0 else 1
	var punch_size := 3 if phase_two_elapsed >= 120.0 else 1
	var wall_length := 5
	var horizontal := rng.randi_range(0, 1) == 0
	var duration := 1.05 if type == "sweep" else 0.35
	if type == "wall":
		duration = 3.5
	var sweep_start := target
	if type == "sweep":
		sweep_start = world_player - direction * (phase_two_view_edge_distance(direction) - TILE_SIZE * 0.65)
	return {
		"type": type, "target": target, "direction": direction, "horizontal": horizontal,
		"center_tile": center_tile, "sweep_width": sweep_width, "grab_radius": grab_radius,
		"remove_size": remove_size, "punch_size": punch_size, "wall_length": wall_length,
		"sweep_start": sweep_start, "sweep_speed": 390.0,
		"age": 0.0, "telegraph": phase_two_telegraph(), "duration": duration, "resolved": false
	}


func phase_two_has_non_wall_action() -> bool:
	for hand in phase_two_attackers:
		var action: Dictionary = hand["attack"]
		if not action.is_empty() and action["type"] != "wall":
			return true
	return false


func random_phase_two_center_tile() -> Vector2i:
	var player_tile := world_to_tile(world_player)
	for attempt in range(12):
		var candidate := player_tile + Vector2i(rng.randi_range(-3, 3), rng.randi_range(-3, 3))
		if phase_two_center_is_available(candidate):
			return candidate
	return player_tile


func phase_two_center_is_available(candidate: Vector2i) -> bool:
	for hand in phase_two_attackers:
		var action: Dictionary = hand["attack"]
		if not action.is_empty() and action.get("center_tile", Vector2i(99999, 99999)) == candidate:
			return false
	return true


func resolve_phase_two_attack(attack: Dictionary) -> void:
	var type: String = attack["type"]
	var target: Vector2 = attack["target"]
	match type:
		"grab":
			if world_player.distance_to(target) < TILE_SIZE * float(attack["grab_radius"]):
				finish_run("CAPTURED", "A descending hand found the king.")
		"void":
			remove_tile_area(world_to_tile(target), int(attack["remove_size"]))
		"punch":
			remove_tile_area(world_to_tile(target), int(attack["punch_size"]))


func remove_tile_area(start_tile: Vector2i, size: int) -> void:
	for x in range(size):
		for y in range(size):
			removed_tiles[start_tile + Vector2i(x, y)] = true


func sweep_center(attack: Dictionary) -> Vector2:
	var time_since_swipe := maxf(0.0, float(attack["age"]) - float(attack["telegraph"]))
	var start: Vector2 = attack["sweep_start"]
	var direction: Vector2 = attack["direction"]
	return start + direction * float(attack["sweep_speed"]) * time_since_swipe


func sweep_hits_player(attack: Dictionary) -> bool:
	var direction: Vector2 = attack["direction"]
	var relative := world_player - sweep_center(attack)
	var cross_distance := absf(relative.dot(direction.rotated(PI * 0.5)))
	var along_distance := absf(relative.dot(direction))
	var half_width := TILE_SIZE * float(attack["sweep_width"]) * 0.5
	return cross_distance < half_width and along_distance < TILE_SIZE * 0.5


func phase_two_view_edge_distance(direction: Vector2) -> float:
	var half_viewport := get_viewport_rect().size * 0.5
	var x_distance := 100000.0 if absf(direction.x) < 0.001 else half_viewport.x / absf(direction.x)
	var y_distance := 100000.0 if absf(direction.y) < 0.001 else half_viewport.y / absf(direction.y)
	return minf(x_distance, y_distance)


func sweep_is_outside_view(attack: Dictionary) -> bool:
	var relative := sweep_center(attack) - world_player
	var half_viewport := get_viewport_rect().size * 0.5
	var hand_radius := TILE_SIZE * maxf(1.0, float(attack["sweep_width"])) * 0.8
	return absf(relative.x) > half_viewport.x + hand_radius or absf(relative.y) > half_viewport.y + hand_radius


func phase_two_wall_contains(position: Vector2) -> bool:
	for hand in phase_two_attackers:
		var action: Dictionary = hand["attack"]
		if not action.is_empty() and action["type"] == "wall" and attack_is_active(action):
			if phase_two_wall_rect(action).grow(TILE_SIZE * 0.20).has_point(position):
				return true
	return false


func phase_two_wall_rect(action: Dictionary) -> Rect2:
	var target: Vector2 = action["target"]
	var length := float(action.get("wall_length", 3))
	if action["horizontal"]:
		return Rect2(target - Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5), Vector2(TILE_SIZE * length, TILE_SIZE))
	return Rect2(target - Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5), Vector2(TILE_SIZE, TILE_SIZE * length))


func world_to_tile(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x / TILE_SIZE), floori(position.y / TILE_SIZE))


func tile_to_world_center(tile: Vector2i) -> Vector2:
	return (Vector2(tile) + Vector2(0.5, 0.5)) * TILE_SIZE


func is_solid_tile(tile: Vector2i) -> bool:
	if removed_tiles.has(tile):
		return false
	# A safe entry zone and a sparse, deterministic pillar field.
	if abs(tile.x) <= 3 and abs(tile.y) <= 3:
		return true
	var noise := sin(float(tile.x) * 12.9898 + float(tile.y) * 78.233 + float(run_seed % 10000) * 0.013) * 43758.5453
	var fraction: float = noise - floor(noise)
	return fraction > 0.19


func finish_run(title: String, detail: String) -> void:
	state = GameState.WON if title == "ESCAPED" or title == "ENDURED" else GameState.LOST
	end_title = title
	end_detail = detail


func _draw() -> void:
	match state:
		GameState.PHASE_ONE:
			draw_phase_one()
		GameState.TRANSITION:
			draw_transition()
		GameState.PHASE_TWO:
			draw_phase_two()
		GameState.WON, GameState.LOST:
			draw_end_screen()


func draw_phase_one() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("10131a"))
	var geometry := board_geometry()
	var origin: Vector2 = geometry["origin"]
	var square: float = geometry["square"]
	for x in range(BOARD_TILES):
		for y in range(BOARD_TILES):
			var cell := Vector2i(x, y)
			var color := Color("2e3a44") if (x + y) % 2 == 0 else Color("1e252c")
			if phase_one_wall_cells().has(cell):
				color = Color("626a70")
			elif phase_one_danger_cells().has(cell):
				color = Color("d65454")
			elif phase_one_telegraph_cells().has(cell):
				color = Color("b89c42")
			draw_rect(Rect2(origin + Vector2(x * square, y * square), Vector2(square - 1.0, square - 1.0)), color)

	# The white marker at a board side is the only direction memory used by phase 2.
	var clock_x := origin.x - 78.0 if escape_direction < 0 else origin.x + square * BOARD_TILES + 18.0
	draw_rect(Rect2(Vector2(clock_x, origin.y + square * 2.6), Vector2(60.0, 100.0)), Color("38424a"))
	draw_rect(Rect2(Vector2(clock_x + 8.0, origin.y + square * 2.6 + 8.0), Vector2(44.0, 84.0)), Color("172028"))
	draw_string(font, Vector2(clock_x + 12.0, origin.y + square * 2.6 + 53.0), format_time(PHASE_ONE_SECONDS - phase_one_elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d8e0e4"))

	draw_phase_one_hand_indicators(origin, square)
	var king_color := Color("e7edf0") if player_is_white else Color("24313b")
	draw_rect(Rect2(origin + Vector2(grid_player) * square + Vector2(7, 7), Vector2(square - 14, square - 14)), king_color)
	if not player_is_white:
		draw_rect(Rect2(origin + Vector2(grid_player) * square + Vector2(7, 7), Vector2(square - 14, square - 14)), Color("9ad5ed"), false, 2.0)
	draw_string(font, Vector2(24, 34), "PHASE 1  /  GRID SURVIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("d8e0e4"))
	draw_string(font, Vector2(24, 61), "Move: WASD or arrow keys (diagonals supported)", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("98a7b2"))
	draw_string(font, Vector2(24, get_viewport_rect().size.y - 24), "R restart  •  F2 test Phase 2", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6e7c86"))


func phase_one_telegraph_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for attack in phase_one_attacks:
		if not attack_is_active(attack):
			for cell in phase_one_attack_cells(attack):
				if not cells.has(cell):
					cells.append(cell)
	return cells


func draw_phase_one_hand_indicators(origin: Vector2, square: float) -> void:
	for attack in phase_one_attacks:
		var color := Color("dce8ed") if attack_is_active(attack) else Color("8999a1")
		match attack.get("type"):
			"sweep":
				var side: String = attack["side"]
				var lane := float(attack["lane"])
				var width := float(attack["width"])
				var hand_rect := Rect2(origin + Vector2(-square * 0.78, lane * square), Vector2(square * 0.56, width * square - 4.0))
				if side == "right":
					hand_rect.position.x = origin.x + BOARD_TILES * square + square * 0.22
				elif side == "top":
					hand_rect = Rect2(origin + Vector2(lane * square, -square * 0.78), Vector2(width * square - 4.0, square * 0.56))
				elif side == "bottom":
					hand_rect = Rect2(origin + Vector2(lane * square, BOARD_TILES * square + square * 0.22), Vector2(width * square - 4.0, square * 0.56))
				draw_rect(hand_rect, color)
			"grab":
				var grab_center: Vector2i = attack["center"]
				draw_rect(Rect2(origin + (Vector2(grab_center) + Vector2(0.2, 0.2)) * square, Vector2(square * 0.6, square * 0.6)), color)
			"wall":
				var wall_start: Vector2i = attack["start"]
				draw_rect(Rect2(origin + (Vector2(wall_start) + Vector2(0.25, 0.25)) * square, Vector2(square * 0.5, square * 0.5)), color)


func draw_transition() -> void:
	var fade := clampf(transition_elapsed / 1.6, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.02, 0.025, 0.035, 1.0))
	var center := get_viewport_rect().size * 0.5
	for index in range(12):
		var offset := Vector2((index % 4) - 1.5, floori(index / 4.0) - 1.0) * (36.0 + fade * 230.0)
		draw_rect(Rect2(center + offset, Vector2(30.0, 30.0)), Color("3d5662").lerp(Color("11151d"), fade))
	draw_string(font, center + Vector2(-80, 120), "ENTERING FIELD", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("aebbc3"))


func draw_phase_two() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("05070b"))
	var viewport := get_viewport_rect().size
	var center := viewport * 0.5
	var player_tile := world_to_tile(world_player)
	var radius_x := int(viewport.x / TILE_SIZE / 2.0) + 3
	var radius_y := int(viewport.y / TILE_SIZE / 2.0) + 3
	for x in range(player_tile.x - radius_x, player_tile.x + radius_x + 1):
		for y in range(player_tile.y - radius_y, player_tile.y + radius_y + 1):
			var tile := Vector2i(x, y)
			if is_solid_tile(tile):
				var screen_position := center + tile_to_world_center(tile) - world_player
				var variance := 0.72 + 0.18 * sin(float(x * 17 + y * 11))
				var color := Color(0.16 * variance, 0.29 * variance, 0.34 * variance)
				draw_rect(Rect2(screen_position - Vector2(TILE_SIZE * 0.46, TILE_SIZE * 0.46), Vector2(TILE_SIZE * 0.92, TILE_SIZE * 0.92)), color)

	for attacker in phase_two_attackers:
		var attack: Dictionary = attacker["attack"]
		if not attack.is_empty():
			draw_phase_two_attack(center, attack)
	for index in range(guiding_hands.size()):
		var hand := guiding_hands[index]
		var hand_position: Vector2 = hand["position"]
		var hand_direction: Vector2 = hand["direction"]
		var hand_screen := center + hand_position - world_player
		var hand_color := Color("e6edf0") if index == 0 else Color("d2e5ec")
		draw_rect(Rect2(hand_screen - Vector2(TILE_SIZE * 0.62, TILE_SIZE * 0.62), Vector2(TILE_SIZE * 1.24, TILE_SIZE * 1.24)), hand_color)
		draw_line(hand_screen, hand_screen + hand_direction * TILE_SIZE * 0.82, Color("5a7a86"), 3.0)
	var player_color := Color("e7edf0") if player_is_white else Color("24313b")
	if dash_remaining > 0.0:
		player_color = Color("ffbf69")
	elif jump_remaining > 0.0:
		player_color = Color("fff2a3")
	draw_rect(Rect2(center - Vector2(TILE_SIZE * 0.28, TILE_SIZE * 0.28), Vector2(TILE_SIZE * 0.56, TILE_SIZE * 0.56)), player_color)
	if not player_is_white and jump_remaining <= 0.0:
		draw_rect(Rect2(center - Vector2(TILE_SIZE * 0.28, TILE_SIZE * 0.28), Vector2(TILE_SIZE * 0.56, TILE_SIZE * 0.56)), Color("9ad5ed"), false, 2.0)
	draw_string(font, Vector2(24, 34), "PHASE 2  /  FREE MOVEMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("d8e0e4"))
	draw_string(font, Vector2(24, 61), "Move: WASD or arrow keys  •  Jump-dash: Space", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("98a7b2"))
	draw_string(font, Vector2(24, viewport.y - 24), "R restart  •  F3 test 1:00  •  F7 test 2:00 upgrades  •  F4/F5/F6 endings", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6e7c86"))


func draw_phase_two_attack(center: Vector2, attack: Dictionary) -> void:
	var target: Vector2 = attack["target"]
	var position := center + target - world_player
	var active := float(attack["age"]) >= float(attack["telegraph"])
	var color := Color("ec5d5d") if active else Color("b89c42")
	match attack["type"]:
		"grab":
			draw_arc(position, TILE_SIZE * float(attack["grab_radius"]), 0.0, TAU, 32, color, 3.0)
		"sweep":
			var direction: Vector2 = attack["direction"]
			var sweep_position := center + sweep_center(attack) - world_player
			draw_colored_polygon(sweep_polygon(sweep_position, direction, int(attack["sweep_width"])), color)
		"wall":
			var world_rect := phase_two_wall_rect(attack)
			var screen_rect := Rect2(center + world_rect.position - world_player, world_rect.size)
			var wall_color := Color("6b7478") if active else Color("b89c42")
			draw_rect(screen_rect, wall_color)
		"void":
			var size := float(attack["remove_size"])
			draw_rect(Rect2(position - Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5), Vector2(TILE_SIZE * size, TILE_SIZE * size)), color, false, 3.0)
		"punch":
			var punch_size := float(attack["punch_size"])
			draw_rect(Rect2(position - Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5), Vector2(TILE_SIZE * punch_size, TILE_SIZE * punch_size)), color)


func sweep_polygon(center: Vector2, direction: Vector2, width: int) -> PackedVector2Array:
	var normal := direction.rotated(PI * 0.5)
	var half_length := TILE_SIZE * 0.5
	var half_width := TILE_SIZE * float(width) * 0.5
	return PackedVector2Array([
		center - direction * half_length - normal * half_width,
		center + direction * half_length - normal * half_width,
		center + direction * half_length + normal * half_width,
		center - direction * half_length + normal * half_width
	])


func draw_end_screen() -> void:
	var won := state == GameState.WON
	var background := Color("10251d") if won else Color("2d1317")
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), background)
	var center := get_viewport_rect().size * 0.5
	var result_color := Color("91e6b2") if won else Color("ff8e8e")
	draw_rect(Rect2(center - Vector2(42, 42), Vector2(84, 84)), result_color)
	draw_string(font, center + Vector2(-78, 88), end_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("f0f4f6"))
	draw_string(font, center + Vector2(-175, 118), end_detail, HORIZONTAL_ALIGNMENT_CENTER, 350, 16, Color("ccd5d9"))
	draw_string(font, center + Vector2(-105, 165), "R or F1: restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("a9b7bd"))


func board_geometry() -> Dictionary:
	var viewport := get_viewport_rect().size
	var square := minf(64.0, minf((viewport.y - 145.0) / BOARD_TILES, (viewport.x - 260.0) / BOARD_TILES))
	return {
		"square": square,
		"origin": Vector2((viewport.x - square * BOARD_TILES) * 0.5, (viewport.y - square * BOARD_TILES) * 0.5 + 18.0)
	}


func format_time(seconds: float) -> String:
	var whole: int = max(0, ceili(seconds))
	return "%02d:%02d" % [whole / 60, whole % 60]
