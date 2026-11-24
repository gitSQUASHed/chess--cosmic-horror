class_name AttackDefinition
extends Resource
## Rules for one attack kind at one level, as data. Hand never contains these rules.
## World layout: tile (x, z) covers x..x+1, z..z+1 times HandCommand.tile_size on the ground
## plane; y is up. Sizes and speeds are in tiles and scaled to metres per command.

## Tiles per second a sweeping hand moves.
const SWEEP_SPEED := 5.5
const VOLUME_HEIGHT := 1.2
## Tiles per second a swipe slides.
const SWIPE_SPEED := 6.0

@export var kind: String = ""
@export var level: int = 1
## Folder/model base name without the level suffix, e.g. "punch".
@export var asset_name: String = ""
## Width of a sweep, length of a swipe line, side of a punch, void-removal or smash square.
@export var size: int = 1
## Seconds between appearing and attacking; Hands never uses less than Constants.MIN_TELEGRAPH.
@export var telegraph_base: float = 1.0
## Top-down attacks (punch, smash): the hand stays hidden before the attack and only its
## shadow shows where it will land.
@export var from_above: bool = false
## False for attacks without a visible hand (void removal pulls from below).
@export var shows_hand: bool = true
@export var active_duration: float = 1.0
@export var recovery: float = 0.35
## True if the hand blocks the king once it stands on the field (punch).
@export var blocks_movement: bool = false
## True if the hand captures the king: while active for ground hands, while falling for
## top-down hands.
@export var damages: bool = true


func placeholder_name() -> String:
	return "hand/%s-lvl%d" % [asset_name, level]


## Collision shape of the effect volume, centred on rest_position().
func make_shape(command: HandCommand) -> Shape3D:
	var box := BoxShape3D.new()
	box.size = volume_size(command)
	return box


## Footprint of the effect volume in metres (x, height, z).
func volume_size(command: HandCommand) -> Vector3:
	var tiles := _footprint_tiles(command)
	return Vector3(tiles.x * command.tile_size, VOLUME_HEIGHT, tiles.z * command.tile_size)


## Centre of the effect before it moves, in metres: where the hand waits at the end of its emergence.
func rest_position(command: HandCommand) -> Vector3:
	if kind == "swipe":
		return command.start
	return _rest_tiles(command) * command.tile_size


func active_position(command: HandCommand, active_elapsed: float) -> Vector3:
	var rest := rest_position(command)
	if kind == "swipe":
		return rest + command.direction * SWIPE_SPEED * command.speed_scale * command.tile_size * active_elapsed
	if kind != "sweep":
		return rest
	var travel := active_elapsed * SWEEP_SPEED * command.speed_scale * command.tile_size
	match command.side:
		"left":
			return rest + Vector3(travel, 0.0, 0.0)
		"right":
			return rest - Vector3(travel, 0.0, 0.0)
		"top":
			return rest + Vector3(0.0, 0.0, travel)
		_:
			return rest - Vector3(0.0, 0.0, travel)


## Footprint in tiles (x, unused, z).
func _footprint_tiles(command: HandCommand) -> Vector3:
	match kind:
		"sweep":
			if command.side == "left" or command.side == "right":
				return Vector3(1.0, VOLUME_HEIGHT, size)
			return Vector3(size, VOLUME_HEIGHT, 1.0)
		"swipe":
			# Width across the sliding direction; the hand node is rotated to its heading.
			return Vector3(size, VOLUME_HEIGHT, 1.0)
		_:
			return Vector3(size, VOLUME_HEIGHT, size)


## Centre of the effect before it moves, in tiles.
func _rest_tiles(command: HandCommand) -> Vector3:
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
		_:
			return Vector3(anchor.x + size / 2.0, 0.0, anchor.y + size / 2.0)


func _lane(command: HandCommand) -> float:
	if command.side == "left" or command.side == "right":
		return float(command.anchor.y)
	return float(command.anchor.x)
