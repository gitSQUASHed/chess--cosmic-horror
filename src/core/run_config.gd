class_name RunConfig
extends RefCounted
## Everything decided once per run: seed, king colour and escape side.

var run_seed: int
var king_is_white: bool
## -1 = the Phase 1 clock (and the Phase 2 escape edge) is on the left, 1 = right.
var escape_side: int
var rng: RandomNumberGenerator


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		run_seed = seed_value
	else:
		var seeder := RandomNumberGenerator.new()
		seeder.randomize()
		run_seed = seeder.randi()
	rng = RandomNumberGenerator.new()
	rng.seed = run_seed
	escape_side = -1 if rng.randi_range(0, 1) == 0 else 1
	king_is_white = rng.randi_range(0, 1) == 0
