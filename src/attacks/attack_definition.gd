class_name AttackDefinition
extends Resource
## Rules for one attack kind at one level, as data. Hand never contains these rules.
## World layout: tile (x, z) covers x..x+1, z..z+1 on the ground plane; y is up.

## Tiles per second a sweeping hand moves.
const SWEEP_SPEED := 5.5
const VOLUME_HEIGHT := 1.2
## Metres per second a swipe slides.
const SWIPE_SPEED := 6.0

@export var kind: String = ""
@export var level: int = 1
## Folder/model base name without the level suffix, e.g. "grabbing".
@export var asset_name: String = ""
## Width of a sweep, side of a grab, length of a wall or swipe, side of a void/punch area.
@export var size: int = 1
@export var is_circle: bool = false
@export var telegraph_base: float = 0.7
@export var active_duration: float = 1.0
@export var recovery: float = 0.35
## True if the active volume blocks the king (walls).
@export var blocks_movement: bool = false
## True if the active volume captures the king.
@export var damages: bool = true


func placeholder_name() -> String:
	return "hand/%s-lvl%d" % [asset_name, level]


## Collision shape of the effect volume, centred on rest_position().
func make_shape(command: HandCommand) -> Shape3D:
	if kind == "grab" and is_circle:
		var cylinder := CylinderShape3D.new()
		cylinder.radius = size / 2.0
		cylinder.height = VOLUME_HEIGHT
		return cylinder
	var box := BoxShape3D.new()
	box.size = volume_size(command)
	return box


## Footprint of the effect volume in metres (x, height, z).
func volume_size(command: HandCommand) -> Vector3:
	match kind:
		"sweep":
			if command.side == "left" or command.side == "right":
				return Vector3(1.0, VOLUME_HEIGHT, size)
			return Vector3(size, VOLUME_HEIGHT, 1.0)
		"wall":
			return Vector3(size, VOLUME_HEIGHT, 1.0) if command.horizontal else Vector3(1.0, VOLUME_HEIGHT, size)
		"swipe":
			# Width across the sliding direction; the hand node is rotated to its heading.
			return Vector3(size, VOLUME_HEIGHT, 1.0)
		_:
			return Vector3(size, VOLUME_HEIGHT, size)


## Centre of the effect before it moves: where the hand waits at the end of its emergence.
func rest_position(command: HandCommand) -> Vector3:
	var anchor := Vector2(command.anchor)
	match kind:
		"sweep":
			var lane_centre := _lane(command) + size / 2.0
			var last := float(Constants.BOARD_TILES) - 0.5
			match command.side:
				"left":
					return Vector3(0.5, 0.0, lane_centre)
				"right":
					return Vector3(last, 0.0, lane_centre)
				"top":
					return Vector3(lane_centre, 0.0, 0.5)
				_:
					return Vector3(lane_centre, 0.0, last)
		"grab":
			return Vector3(anchor.x + 0.5, 0.0, anchor.y + 0.5)
		"swipe":
			return command.start
		"wall":
			var half := size / 2.0
			if command.horizontal:
				return Vector3(anchor.x + half, 0.0, anchor.y + 0.5)
			return Vector3(anchor.x + 0.5, 0.0, anchor.y + half)
		_:
			return Vector3(anchor.x + size / 2.0, 0.0, anchor.y + size / 2.0)


func active_position(command: HandCommand, active_elapsed: float) -> Vector3:
	var rest := rest_position(command)
	if kind == "swipe":
		return rest + command.direction * SWIPE_SPEED * active_elapsed
	if kind != "sweep":
		return rest
	var travel := active_elapsed * SWEEP_SPEED
	match command.side:
		"left":
			return rest + Vector3(travel, 0.0, 0.0)
		"right":
			return rest - Vector3(travel, 0.0, 0.0)
		"top":
			return rest + Vector3(0.0, 0.0, travel)
		_:
			return rest - Vector3(0.0, 0.0, travel)


func _lane(command: HandCommand) -> float:
	if command.side == "left" or command.side == "right":
		return float(command.anchor.y)
	return float(command.anchor.x)
