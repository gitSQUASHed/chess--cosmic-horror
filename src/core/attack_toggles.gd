class_name AttackToggles
extends RefCounted
## Debug switches for each attack per phase, read from res://config/attacks.cfg. A missing
## file, section or key counts as enabled.

const PATH := "res://config/attacks.cfg"

static var _config: ConfigFile


## Re-reads the file. Called at the start of every run.
static func reload() -> void:
	_config = ConfigFile.new()
	var error := _config.load(PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_warning("Could not read %s (error %d); all attacks enabled." % [PATH, error])


## `phase` is "phase1" or "phase2", `kind` an attack kind or "guiding_hand".
static func is_enabled(phase: String, kind: String) -> bool:
	if _config == null:
		reload()
	return bool(_config.get_value(phase, kind, true))


## The entries of `kinds` that are enabled for `phase`.
static func filter(phase: String, kinds: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for kind in kinds:
		if is_enabled(phase, kind):
			result.append(kind)
	return result
