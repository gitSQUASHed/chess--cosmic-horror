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
## Seconds the hand spends emerging before the action becomes active.
var telegraph_time := 0.7
## World position the hand emerges from, e.g. a rear silhouette.
var origin := Vector3.ZERO
## Moving hands (swipe): where the hand starts, which way it slides, and its yaw.
var start := Vector3.ZERO
var direction := Vector3.ZERO
var heading := 0.0
## If above zero, replaces the definition's active duration (e.g. until a swipe leaves the frame).
var active_override := -1.0


func active_time() -> float:
	return active_override if active_override > 0.0 else definition.active_duration
