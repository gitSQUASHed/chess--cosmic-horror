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
## Metadata on every Area3D on the hand_danger layer: what touching it does to the king.
const EFFECT_META := &"effect"
## Metadata on push volumes: the world velocity (Vector3) the king is shoved with.
const PUSH_VELOCITY_META := &"push_velocity"
## Flattens the king (punch, smash).
const EFFECT_CRUSH := "crush"
## Shoves the king along with the hand; he can still move out of it (sweep, swipe).
const EFFECT_PUSH := "push"
## Picks the king up and carries him off (guiding hand).
const EFFECT_GRAB := "grab"

@export var kind: String = ""
@export var level: int = 1
## Folder/model base name without the level suffix, e.g. "punch".
@export var asset_name: String = ""
## Width of a sweep, length of a swipe line, side of a punch, void-removal or smash square.
@export var size: int = 1
## Top-down attacks (punch, smash): the hand stays hidden before the attack and only its
## shadow shows where it will land.
@export var from_above: bool = false
## False for attacks without a visible hand (void removal pulls from below).
@export var shows_hand: bool = true
@export var active_duration: float = 1.0
@export var recovery: float = 0.35
## True if the hand blocks the king once it stands on the field (punch).
@export var blocks_movement: bool = false
## True if the hand crushes the king while it falls (top-down hands).
@export var damages: bool = false
## True if the active hand shoves the king along with it (ground hands).
@export var pushes: bool = false


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


## World velocity of a moving hand while active (zero for hands that do not move).
func active_velocity(command: HandCommand) -> Vector3:
	var speed := command.speed_scale * command.tile_size
	match kind:
		"swipe":
			return command.direction * SWIPE_SPEED * speed
		"sweep":
			match command.side:
				"left":
					return Vector3(SWEEP_SPEED * speed, 0.0, 0.0)
				"right":
					return Vector3(-SWEEP_SPEED * speed, 0.0, 0.0)
				"top":
					return Vector3(0.0, 0.0, SWEEP_SPEED * speed)
				_:
					return Vector3(0.0, 0.0, -SWEEP_SPEED * speed)
	return Vector3.ZERO


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
