class_name HandCommand
extends RefCounted
## Everything a Hand needs to run one action. Created by Hands, consumed by Hand.

var definition: AttackDefinition
## Tile anchor (x, z). Sweep: first cell on the entry edge. Grab: centre cell. Wall/swipe: first
## cell of the line. Void removal/punch: first cell of the area.
var anchor := Vector2i.ZERO
## Sweep entry side: "left", "right", "top" (z = 0 side) or "bottom".
var side := "left"
## Wall and swipe orientation (true = along x).
var horizontal := true
## Seconds between the hand (or its shadow) appearing and the action becoming active.
var telegraph_time := 1.0
## Attack speed multiplier, rising with phase time. Speeds up movement, strikes and recovery,
## never the telegraph.
var speed_scale := 1.0
## Height of the ground surface the hand stands on.
var surface_y := 0.0
## Moving hands (swipe): where the hand starts, which way it slides, and its yaw.
var start := Vector3.ZERO
var direction := Vector3.ZERO
var heading := 0.0
## Metres per tile: 1 on the Phase 1 board, Constants.PHASE2_TILE_SIZE on the pillar field.
## Anchors and sizes are in tiles; positions, volumes and speeds are scaled by this.
var tile_size := 1.0
## If above zero, replaces the definition's active duration (e.g. until a swipe leaves the frame).
var active_override := -1.0


func active_time() -> float:
	if active_override > 0.0:
		return active_override / speed_scale
	# A wall's duration is how long it blocks, not how fast it moves.
	if definition.blocks_movement:
		return definition.active_duration
	return definition.active_duration / speed_scale


func recovery_time() -> float:
	return definition.recovery / speed_scale
