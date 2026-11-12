class_name Phase1King
extends Node3D
## The Phase 1 king: exact tile positions with a short move animation. A physics point query
## at the target tile decides whether a move is allowed (board edges and walls are bodies on
## the wall layer). A hurtbox Area3D detects overlaps with hand danger volumes.

signal captured

var tile := Constants.KING_START_TILE
var is_moving := false
var dead := false

var _visual: Node3D
var _hurtbox: Area3D
var _tween: Tween


func setup(is_white: bool) -> void:
	_visual = Placeholders.king(is_white)
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


## Tries a one-tile move in one of eight directions. Returns true if the move started.
func try_move(direction: Vector2i) -> bool:
	if is_moving or dead or direction == Vector2i.ZERO:
		return false
	var target := tile + direction
	if target.x < 0 or target.x >= Constants.BOARD_TILES or target.y < 0 or target.y >= Constants.BOARD_TILES:
		return false
	if _is_blocked(target):
		return false
	tile = target
	is_moving = true
	Placeholders.set_subtitle(_visual, _direction_name(direction))
	ModelAnimator.play(_visual, "move")
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", tile_to_world(target), Constants.KING_MOVE_SECONDS)
	_tween.finished.connect(_on_move_finished)
	return true


## Stops any movement, e.g. when the king is picked up.
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


func _on_area_entered(_area: Area3D) -> void:
	if not dead:
		dead = true
		captured.emit()


func _direction_name(direction: Vector2i) -> String:
	var names := {
		Vector2i(0, -1): "up", Vector2i(1, -1): "up-right", Vector2i(1, 0): "right",
		Vector2i(1, 1): "down-right", Vector2i(0, 1): "down", Vector2i(-1, 1): "down-left",
		Vector2i(-1, 0): "left", Vector2i(-1, -1): "up-left",
	}
	return String(names.get(direction, ""))
