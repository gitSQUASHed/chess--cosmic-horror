class_name PillarField
extends Node3D
## Phase 2 terrain: individual tile pillars over a void. Generated deterministically from the
## run seed and tile coordinate, revealed only within a radius around the king, rising out of
## the void. Removed tiles are remembered for the whole run. A void area under the field
## reports when something falls.

signal void_entered(body: Node3D)

## Share of tiles that are holes.
const HOLE_CHANCE := 0.19
## Tiles around the start that are always solid.
const SAFE_RADIUS := 2
const SURFACE_Y := 0.0
const PILLAR_HEIGHT := 0.6
const HIDDEN_Y := -2.0

var seed_value := 0
var escape_side := 1
var reveal_radius := Constants.PILLAR_REVEAL_RADIUS

var _removed: Dictionary = {}
var _spine: Dictionary = {}
var _pillars: Dictionary = {}
var _center_tile := Vector2i(1000000, 1000000)


func setup(run_seed: int, escape_direction: int) -> void:
	seed_value = run_seed
	escape_side = escape_direction
	_build_spine()
	_build_void_area()


## x coordinate of the escape edge column.
func edge_x() -> int:
	return escape_side * Constants.PHASE_TWO_ESCAPE_TILES


static func world_to_tile(position_3d: Vector3) -> Vector2i:
	return Vector2i(floori(position_3d.x), floori(position_3d.z))


static func tile_to_world(tile: Vector2i) -> Vector3:
	return Vector3(tile.x + 0.5, SURFACE_Y, tile.y + 0.5)


## Deterministic terrain: same answer for the same seed and tile, minus removed tiles.
func is_solid(tile: Vector2i) -> bool:
	if _removed.has(tile):
		return false
	if absi(tile.x) > Constants.PHASE_TWO_ESCAPE_TILES and _beyond_edge(tile.x):
		return false
	if absi(tile.x) <= SAFE_RADIUS and absi(tile.y) <= SAFE_RADIUS:
		return true
	if absi(tile.x) == Constants.PHASE_TWO_ESCAPE_TILES and tile.x == edge_x():
		return true
	if _spine.has(tile):
		return true
	return _noise(tile) > HOLE_CHANCE


## Reveals pillars near `center` and hides far ones. Cheap when the king stays on one tile.
func update_around(center: Vector3) -> void:
	var tile := world_to_tile(center)
	if tile == _center_tile:
		return
	_center_tile = tile
	for x in range(tile.x - reveal_radius, tile.x + reveal_radius + 1):
		for z in range(tile.y - reveal_radius, tile.y + reveal_radius + 1):
			var cell := Vector2i(x, z)
			if Vector2(cell - tile).length() > reveal_radius:
				continue
			if not _pillars.has(cell) and is_solid(cell):
				_spawn(cell)
	# Hysteresis of 1.5 tiles keeps pillars from flickering at the boundary.
	var sink_limit := reveal_radius + 1.5
	for cell in _pillars.keys():
		if Vector2(cell - tile).length() > sink_limit:
			_sink(cell)


## Permanently removes a square of tiles (void removal and punch).
func remove_area(first_tile: Vector2i, size: int) -> void:
	for x in range(first_tile.x, first_tile.x + size):
		for z in range(first_tile.y, first_tile.y + size):
			remove_tile(Vector2i(x, z))


func remove_tile(tile: Vector2i) -> void:
	_removed[tile] = true
	if not _pillars.has(tile):
		return
	var pillar := _pillars[tile] as Node3D
	_pillars.erase(tile)
	_disable_collision(pillar)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(pillar, "position:y", -6.0, 1.2).set_ease(Tween.EASE_IN)
	tween.tween_method(func(value: float) -> void: Placeholders.set_brightness(pillar, value), 1.0, 0.0, 1.2)
	tween.chain().tween_callback(pillar.queue_free)


## Pillars leaving the revealed radius sink down into the void, darken, and are freed.
func _sink(cell: Vector2i) -> void:
	var pillar := _pillars[cell] as Node3D
	_pillars.erase(cell)
	_disable_collision(pillar)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(pillar, "position:y", HIDDEN_Y - 2.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_method(func(value: float) -> void: Placeholders.set_brightness(pillar, value), 1.0, 0.0, 0.7)
	tween.chain().tween_callback(pillar.queue_free)


func _disable_collision(pillar: Node3D) -> void:
	for child in pillar.get_children():
		if child is StaticBody3D:
			for shape in child.get_children():
				if shape is CollisionShape3D:
					shape.disabled = true


func is_removed(tile: Vector2i) -> bool:
	return _removed.has(tile)


func pillar_count() -> int:
	return _pillars.size()


func _spawn(cell: Vector2i) -> void:
	var pillar := Placeholders.pillar()
	var shade := 0.82 + 0.18 * _noise(cell + Vector2i(7919, 104729))
	Placeholders.set_brightness(pillar, shade)
	var body := StaticBody3D.new()
	body.collision_layer = Layers.PILLAR
	body.collision_mask = 0
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.0, PILLAR_HEIGHT, 1.0)
	shape_node.shape = shape
	shape_node.position.y = PILLAR_HEIGHT * 0.5
	body.add_child(shape_node)
	pillar.add_child(body)
	# The pillar model's origin is its base; its top surface is at SURFACE_Y.
	pillar.position = Vector3(cell.x + 0.5, HIDDEN_Y, cell.y + 0.5)
	add_child(pillar)
	_pillars[cell] = pillar
	var tween := create_tween()
	tween.tween_property(pillar, "position:y", SURFACE_Y - PILLAR_HEIGHT, 0.6 + _noise(cell + Vector2i(31, 17)) * 0.4).set_ease(Tween.EASE_OUT)


func _noise(tile: Vector2i) -> float:
	var h := seed_value * 374761393 + tile.x * 668265263 + tile.y * 2246822519
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return float(h & 0x7fffffff) / 2147483647.0


func _beyond_edge(x: int) -> bool:
	return x * escape_side > Constants.PHASE_TWO_ESCAPE_TILES


## A guaranteed route of solid tiles from the start to the escape edge: a deterministic walk
## that changes row by at most one per column and joins diagonal steps orthogonally.
func _build_spine() -> void:
	_spine.clear()
	var row := 0
	for step in range(Constants.PHASE_TWO_ESCAPE_TILES + 1):
		var x := escape_side * step
		_spine[Vector2i(x, row)] = true
		var choice := int(_noise(Vector2i(step, 99991)) * 3.0) - 1
		var next_row := clampi(row + choice, -6, 6)
		if next_row != row:
			_spine[Vector2i(x, next_row)] = true
		row = next_row


func _build_void_area() -> void:
	var area := Area3D.new()
	area.collision_layer = Layers.VOID
	area.collision_mask = Layers.KING
	area.monitoring = true
	area.monitorable = false
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4000.0, 2.0, 4000.0)
	shape_node.shape = shape
	area.position = Vector3(0.0, -8.0, 0.0)
	area.add_child(shape_node)
	area.body_entered.connect(func(body: Node3D) -> void: void_entered.emit(body))
	add_child(area)
