class_name GameConfig
extends RefCounted
## Reads the editable config files in res://config/ (attacks.cfg, field.cfg, schedule.cfg,
## timing.cfg).
## They are re-read at the start of every run, so R picks up changes. A missing file, section
## or key falls back to the default the caller passes, which is the current design value.

const DIR := "res://config/"
const FILES: Array[String] = ["attacks", "field", "schedule", "timing"]

static var _files: Dictionary = {}


static func reload() -> void:
	_files.clear()
	for file_name in FILES:
		var config := ConfigFile.new()
		var path := DIR + file_name + ".cfg"
		var error := config.load(path)
		if error != OK and error != ERR_FILE_NOT_FOUND:
			push_warning("Could not read %s (error %d); using defaults." % [path, error])
		_files[file_name] = config


## Value of `key` in `[section]` of config/<file_name>.cfg, or `default`.
static func value(file_name: String, section: String, key: String, default: Variant) -> Variant:
	if _files.is_empty():
		reload()
	var config := _files.get(file_name) as ConfigFile
	if config == null:
		return default
	return config.get_value(section, key, default)


## Phase 2 field: square of this many tiles per side, centred on the start tile.
static func field_size() -> int:
	return maxi(int(value("field", "phase2", "size", 500)), 2 * PillarField.SAFE_RADIUS + 2)


## Tiles from the start to every border, including the escape edge.
static func field_half_size() -> int:
	return field_size() / 2


## Seconds into `phase` at which `kind` starts being requested (negative: never).
static func attack_from(phase: String, kind: String, default: float) -> float:
	return float(value("schedule", phase, kind + "_from", default))


## Seconds into `phase` at which `kind` is upgraded to level 2 (negative: never).
static func attack_upgrade_at(phase: String, kind: String, default: float) -> float:
	return float(value("schedule", phase, kind + "_upgrade_at", default))


## How many entries of `key` (a list of seconds) have been reached at `elapsed`.
static func count_reached(phase: String, key: String, default: Array, elapsed: float) -> int:
	var times: Array = value("schedule", phase, key, default)
	var count := 0
	for time in times:
		if elapsed >= float(time):
			count += 1
	return count


## A timing value from config/timing.cfg at `elapsed` seconds into `phase`: it moves linearly
## from `<from_key>` to `<to_key>` over `<name>_ramp_seconds`, then holds. `defaults` is
## [from, to, ramp seconds].
static func ramp(phase: String, name: String, from_key: String, to_key: String, defaults: Array, elapsed: float) -> float:
	var start := float(value("timing", phase, "%s_%s" % [name, from_key], defaults[0]))
	var end := float(value("timing", phase, "%s_%s" % [name, to_key], defaults[1]))
	var seconds := float(value("timing", phase, name + "_ramp_seconds", defaults[2]))
	var progress := 1.0 if seconds <= 0.0 else clampf(elapsed / seconds, 0.0, 1.0)
	return lerpf(start, end, progress)
