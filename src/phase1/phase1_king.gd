class_name Phase1King
extends Node3D
## The Phase 1 king: exact tile positions with a short move animation. A physics point query
## at the target tile decides whether a move is allowed (board edges and landed punch hands are
## bodies on the wall layer). A hurtbox Area3D detects hand volumes: a falling punch crushes
## him; a sweep shoves him one tile at a time ahead of it, off the board if he does not step out
## of its lane, or crushes him against a landed punch.

## A falling punch flattened the king, or a sweep pinned him against a landed punch.
signal crushed
## A sweep shoved the king off the board.
signal fell_off

var tile := Constants.KING_START_TILE
var is_moving := false
var dead := false

var _visual: Node3D
var _hurtbox: Area3D
var _tween: Tween


func setup(is_white: bool) -> void:
	_visual = Placeholders.king(is_white)
	Placeholders.add_outline(_visual, Placeholders.OUTLINE_WIDTH_BOARD)
	add_child(_visual)
	_hurtbox = Area3D.new()
	_hurtbox.collision_layer = Layers.KING
	_hurtbox.collision_mask = Layers.HAND_DANGER
	_hurtbox.monitoring = true
	_hurtbox.monitorable = false
	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.3
	shape_node.shape = shape
	shape_node.position.y = 0.45
	_hurtbox.add_child(shape_node)
	_hurtbox.area_entered.connect(_on_area_entered)
	add_child(_hurtbox)
	position = tile_to_world(tile)


static func tile_to_world(tile_pos: Vector2i) -> Vector3:
	return Vector3(tile_pos.x + 0.5, 0.0, tile_pos.y + 0.5)


## Called every frame with the player's input. While a sweep overlaps the king he is shoved
## ahead of it; stepping in any other direction is still allowed and is how he escapes.
func update(player_input: Vector2i) -> void:
	if dead:
		return
	var push := _push_direction()
	if push == Vector2i.ZERO:
		try_move(player_input)
		return
	if is_moving:
		return
	# Escaping is any step that does not go back against the shove.
	var against := player_input.x * push.x + player_input.y * push.y < 0
	if player_input != Vector2i.ZERO and player_input != push and not against and try_move(player_input):
		return
	var target := tile + push
	if target.x < 0 or target.x >= Constants.BOARD_TILES or target.y < 0 or target.y >= Constants.BOARD_TILES:
		_fall_off(push)
	elif _is_blocked(target):
		dead = true
		crushed.emit()
	else:
		_move_to(target)


## Tries a one-tile move in one of eight directions. Returns true if the move started.
func try_move(direction: Vector2i) -> bool:
	if is_moving or dead or direction == Vector2i.ZERO:
		return false
	var target := tile + direction
	if target.x < 0 or target.x >= Constants.BOARD_TILES or target.y < 0 or target.y >= Constants.BOARD_TILES:
		return false
	if _is_blocked(target) or _against_sweep(target, direction):
		return false
	_move_to(target)
	return true


## True if a sweep on `target` moves toward the king, i.e. stepping there would pass through it.
func _against_sweep(target: Vector2i, direction: Vector2i) -> bool:
	var query := PhysicsPointQueryParameters3D.new()
	query.position = tile_to_world(target) + Vector3(0.0, 0.45, 0.0)
	query.collision_mask = Layers.HAND_DANGER
	query.collide_with_bodies = false
	query.collide_with_areas = true
	for hit in get_world_3d().direct_space_state.intersect_point(query, 8):
		var area := hit["collider"] as Area3D
		if area == null or String(area.get_meta(AttackDefinition.EFFECT_META, "")) != AttackDefinition.EFFECT_PUSH:
			continue
		var push: Vector3 = area.get_meta(AttackDefinition.PUSH_VELOCITY_META, Vector3.ZERO)
		if direction.x * push.x + direction.y * push.z < 0.0:
			return true
	return false


func _move_to(target: Vector2i) -> void:
	tile = target
	is_moving = true
	ModelAnimator.play(_visual, "move")
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", tile_to_world(target), Constants.KING_MOVE_SECONDS)
	_tween.finished.connect(_on_move_finished)


## Stops any movement, e.g. when the king is crushed.
func freeze() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	is_moving = false
	dead = true


func _is_blocked(target: Vector2i) -> bool:
	var query := PhysicsPointQueryParameters3D.new()
	query.position = tile_to_world(target) + Vector3(0.0, 0.5, 0.0)
	query.collision_mask = Layers.WALL
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return not get_world_3d().direct_space_state.intersect_point(query, 1).is_empty()


func _on_move_finished() -> void:
	is_moving = false
	ModelAnimator.play(_visual, "idle")


## Flattens the king under the hand that landed on him (or pinned him).
func squash() -> void:
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector3(1.5, 0.08, 1.5), 0.08)


## Grid direction of the strongest sweep overlapping the king, or zero.
func _push_direction() -> Vector2i:
	var strongest := Vector3.ZERO
	for area in _hurtbox.get_overlapping_areas():
		if String(area.get_meta(AttackDefinition.EFFECT_META, "")) == AttackDefinition.EFFECT_PUSH:
			var push: Vector3 = area.get_meta(AttackDefinition.PUSH_VELOCITY_META, Vector3.ZERO)
			if push.length() > strongest.length():
				strongest = push
	if strongest.length() < 0.01:
		return Vector2i.ZERO
	if absf(strongest.x) >= absf(strongest.z):
		return Vector2i(int(signf(strongest.x)), 0)
	return Vector2i(0, int(signf(strongest.z)))


## Shoved over the board edge: slides off and drops into the dark.
func _fall_off(direction: Vector2i) -> void:
	dead = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var edge := position + Vector3(direction.x, 0.0, direction.y)
	_tween = create_tween()
	_tween.tween_property(self, "position", edge, Constants.KING_MOVE_SECONDS)
	_tween.tween_property(self, "position", edge + Vector3(direction.x, -12.0, direction.y), 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fell_off.emit()


func _on_area_entered(area: Area3D) -> void:
	if not dead and String(area.get_meta(AttackDefinition.EFFECT_META, "")) == AttackDefinition.EFFECT_CRUSH:
		dead = true
		crushed.emit()

