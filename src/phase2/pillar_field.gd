class_name PillarField
extends Node3D
## Phase 2 terrain: individual tile pillars over a void. Generated deterministically from the
## run seed and tile coordinate, revealed only within a radius around the king, rising out of
## the void. Removed tiles are remembered for the whole run. A void area under the field
## reports when something falls.

signal void_entered(body: Node3D)

## Holes come from smooth value noise instead of independent per-tile chances, so they form
## connected blobs (about 2 to 8 tiles across) rather than scattered single tiles. A tile is a
## hole where the noise is below HOLE_THRESHOLD; with these values about 18% of tiles are holes.
## Tiles per noise cell of the large blobs.
const HOLE_SCALE := 6.0
## Tiles per noise cell of the detail layer that roughens blob edges.
const HOLE_DETAIL_SCALE := 2.5
## Weight of the detail layer (0 = smooth round blobs).
const HOLE_DETAIL_WEIGHT := 0.3
const HOLE_THRESHOLD := 0.34
## Tiles around the start that are always solid.
const SAFE_RADIUS := 2
const SURFACE_Y := 0.0
const TILE_SIZE := Constants.PHASE2_TILE_SIZE
## Pillars are cubes: as tall as a tile is wide.
const PILLAR_HEIGHT := TILE_SIZE
## Base height of a pillar before it rises; its top starts this far below the surface.
const HIDDEN_Y := SURFACE_Y - PILLAR_HEIGHT - 2.0

var seed_value := 0
var escape_side := 1
var reveal_radius := Constants.PILLAR_REVEAL_RADIUS

var _removed: Dictionary = {}
var _spine: Dictionary = {}
var _pillars: Dictionary = {}
var _center_tile := Vector2i(1000000, 1000000)
## Hidden pillars waiting to be moved to newly revealed tiles. Filled at setup with enough
## pillars for the whole revealed area, so walking only moves existing pillars; pillars that
## sink or are removed go back here.
var _pool: Array[Node3D] = []
## One collision shape shared by every pillar body.
var _pillar_shape: BoxShape3D


func setup(run_seed: int, escape_direction: int) -> void:
	seed_value = run_seed
	escape_side = escape_direction
	_build_spine()
	_build_void_area()
	_prebuild_pillars()


## x coordinate of the escape edge column.
func edge_x() -> int:
	return escape_side * GameConfig.field_half_size()


static func world_to_tile(position_3d: Vector3) -> Vector2i:
	return Vector2i(floori(position_3d.x / TILE_SIZE), floori(position_3d.z / TILE_SIZE))


## Centre of a tile's top surface.
static func tile_to_world(tile: Vector2i) -> Vector3:
	return Vector3((tile.x + 0.5) * TILE_SIZE, SURFACE_Y, (tile.y + 0.5) * TILE_SIZE)


## Deterministic terrain: same answer for the same seed and tile, minus removed tiles.
func is_solid(tile: Vector2i) -> bool:
	if _removed.has(tile):
		return false
	# The field is a square of config/field.cfg size; beyond its borders is void on every side.
	var half := GameConfig.field_half_size()
	if absi(tile.x) > half or absi(tile.y) > half:
		return false
	if absi(tile.x) <= SAFE_RADIUS and absi(tile.y) <= SAFE_RADIUS:
		return true
	if tile.x == edge_x():
		return true
	if _spine.has(tile):
		return true
	return _hole_noise(tile) >= HOLE_THRESHOLD


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


## Void removal warning: the pillars in the square go completely dark with a white outline
## until remove_area pulls them down.
func mark_area(first_tile: Vector2i, size: int) -> void:
	for x in range(first_tile.x, first_tile.x + size):
		for z in range(first_tile.y, first_tile.y + size):
			var cell := Vector2i(x, z)
			if not _pillars.has(cell):
				continue
			var pillar := _pillars[cell] as Node3D
			pillar.set_meta("marked", true)
			Placeholders.set_brightness(pillar, 0.0)
			Placeholders.add_outline(pillar)


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
	var tween := _tween_pillar(pillar).set_parallel(true)
	tween.tween_property(pillar, "position:y", HIDDEN_Y - 4.0, 1.2).set_ease(Tween.EASE_IN)
	var from_brightness := 0.0 if pillar.has_meta("marked") else 1.0
	# The attack is happening: the dark outlined warning is no longer shown.
	Placeholders.remove_outline(pillar)
	tween.tween_method(func(value: float) -> void: Placeholders.set_brightness(pillar, value), from_brightness, 0.0, 1.2)
	tween.chain().tween_callback(_recycle.bind(pillar))


## Pillars leaving the revealed radius sink down into the void, darken, and are freed.
func _sink(cell: Vector2i) -> void:
	var pillar := _pillars[cell] as Node3D
	_pillars.erase(cell)
	_disable_collision(pillar)
	var tween := _tween_pillar(pillar).set_parallel(true)
	tween.tween_property(pillar, "position:y", HIDDEN_Y - 2.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_method(func(value: float) -> void: Placeholders.set_brightness(pillar, value), 1.0, 0.0, 0.7)
	tween.chain().tween_callback(_recycle.bind(pillar))


## A fresh tween for `pillar` that replaces any still running on it (rising, sinking).
func _tween_pillar(pillar: Node3D) -> Tween:
	var previous := pillar.get_meta("tween", null) as Tween
	if previous != null and previous.is_valid():
		previous.kill()
	var tween := create_tween()
	pillar.set_meta("tween", tween)
	return tween


func _recycle(pillar: Node3D) -> void:
	pillar.visible = false
	if pillar.has_meta("marked"):
		pillar.remove_meta("marked")
	_pool.append(pillar)


func _disable_collision(pillar: Node3D) -> void:
	_set_collision(pillar, false)


func _set_collision(pillar: Node3D, enabled: bool) -> void:
	for child in pillar.get_children():
		if child is StaticBody3D:
			for shape in child.get_children():
				if shape is CollisionShape3D:
					shape.disabled = not enabled


func is_removed(tile: Vector2i) -> bool:
	return _removed.has(tile)


## True if a revealed, standing pillar is at `tile`.
func has_pillar(tile: Vector2i) -> bool:
	return _pillars.has(tile)


func pillar_count() -> int:
	return _pillars.size()


func _spawn(cell: Vector2i) -> void:
	var pillar: Node3D
	if _pool.is_empty():
		pillar = _build_pillar()
	else:
		pillar = _pool.pop_back()
		pillar.visible = true
		_set_collision(pillar, true)
	var shade := 0.82 + 0.18 * _noise(cell + Vector2i(7919, 104729))
	Placeholders.set_brightness(pillar, shade)
	# The pillar model's origin is its base; its top surface is at SURFACE_Y.
	pillar.position = tile_to_world(cell) + Vector3(0.0, HIDDEN_Y - SURFACE_Y, 0.0)
	_pillars[cell] = pillar
	var tween := _tween_pillar(pillar)
	tween.tween_property(pillar, "position:y", SURFACE_Y - PILLAR_HEIGHT, 0.6 + _noise(cell + Vector2i(31, 17)) * 0.4).set_ease(Tween.EASE_OUT)


## Builds every pillar the field can need at once: the revealed disc up to the sink limit, plus
## two rings for pillars still sinking out of view.
func _prebuild_pillars() -> void:
	var sink_limit := reveal_radius + 1.5
	var count := int(ceil(PI * sink_limit * sink_limit)) + 2 * int(ceil(TAU * sink_limit))
	for index in range(count):
		var pillar := _build_pillar()
		pillar.visible = false
		_set_collision(pillar, false)
		_pool.append(pillar)


## Builds one pillar. Only used at setup, or as a fallback if the prebuilt set ever runs out.
func _build_pillar() -> Node3D:
	var pillar := Placeholders.pillar(TILE_SIZE, PILLAR_HEIGHT, SURFACE_Y)
	if _pillar_shape == null:
		_pillar_shape = BoxShape3D.new()
		_pillar_shape.size = Vector3(TILE_SIZE, PILLAR_HEIGHT, TILE_SIZE)
	var body := StaticBody3D.new()
	body.collision_layer = Layers.PILLAR
	body.collision_mask = 0
	var shape_node := CollisionShape3D.new()
	shape_node.shape = _pillar_shape
	shape_node.position.y = PILLAR_HEIGHT * 0.5
	body.add_child(shape_node)
	pillar.add_child(body)
	add_child(pillar)
	return pillar


## Two layers of value noise in 0..1, deterministic per seed and tile.
func _hole_noise(tile: Vector2i) -> float:
	var large := _value_noise(Vector2(tile), HOLE_SCALE, 7919)
	var detail := _value_noise(Vector2(tile), HOLE_DETAIL_SCALE, 104729)
	return lerpf(large, detail, HOLE_DETAIL_WEIGHT)


## Smoothly interpolated random values on a grid of `scale` tiles; `salt` separates layers.
func _value_noise(point: Vector2, scale: float, salt: int) -> float:
	var scaled := point / scale
	var cell := Vector2i(floori(scaled.x), floori(scaled.y))
	var fraction := scaled - Vector2(cell)
	var tx := fraction.x * fraction.x * (3.0 - 2.0 * fraction.x)
	var ty := fraction.y * fraction.y * (3.0 - 2.0 * fraction.y)
	var offset := Vector2i(salt, salt * 7)
	var a := _noise(cell + offset)
	var b := _noise(cell + Vector2i(1, 0) + offset)
	var c := _noise(cell + Vector2i(0, 1) + offset)
	var d := _noise(cell + Vector2i(1, 1) + offset)
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)


func _noise(tile: Vector2i) -> float:
	var h := seed_value * 374761393 + tile.x * 668265263 + tile.y * 2246822519
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return float(h & 0x7fffffff) / 2147483647.0


## A guaranteed route of solid tiles from the start to the escape edge: a deterministic walk
## that changes row by at most one per column and joins diagonal steps orthogonally.
func _build_spine() -> void:
	_spine.clear()
	var row := 0
	for step in range(GameConfig.field_half_size() + 1):
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
	var extent := (GameConfig.field_size() + 40) * TILE_SIZE
	shape.size = Vector3(extent, 2.0, extent)
	shape_node.shape = shape
	# Deep enough that a falling king stays visible for about a second as he sinks into the mist.
	area.position = Vector3(0.0, -16.0, 0.0)
	area.add_child(shape_node)
	area.body_entered.connect(func(body: Node3D) -> void: void_entered.emit(body))
	add_child(area)
