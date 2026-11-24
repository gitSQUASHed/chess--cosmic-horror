class_name AttackToggles
extends RefCounted
## Debug switches for each attack per phase, from config/attacks.cfg (via GameConfig). A missing
## file, section or key counts as enabled.


## `phase` is "phase1" or "phase2", `kind` an attack kind or "guiding_hand".
static func is_enabled(phase: String, kind: String) -> bool:
	return bool(GameConfig.value("attacks", phase, kind, true))


## The entries of `kinds` that are enabled for `phase`.
static func filter(phase: String, kinds: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for kind in kinds:
		if is_enabled(phase, kind):
			result.append(kind)
	return result
