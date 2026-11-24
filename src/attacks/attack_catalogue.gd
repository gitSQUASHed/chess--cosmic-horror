class_name AttackCatalogue
extends RefCounted
## All attack definitions per kind and level. The only place with attack balance values.
## Sizes follow docs/plan/gameplay/enemy_mechanics.md.

static var _cache: Dictionary = {}


static func get_definition(kind: String, level: int) -> AttackDefinition:
	var key := "%s:%d" % [kind, level]
	if not _cache.has(key):
		_cache[key] = _build(kind, level)
	return _cache[key] as AttackDefinition


static func kinds() -> Array[String]:
	return ["sweep", "punch", "swipe", "void_removal", "smash"]


static func _build(kind: String, level: int) -> AttackDefinition:
	var upgraded := level >= 2
	var definition := AttackDefinition.new()
	definition.kind = kind
	definition.level = clampi(level, 1, 2)
	match kind:
		"sweep":
			definition.asset_name = "sweep"
			definition.pushes = true
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 1.55
			definition.recovery = 0.35
		"punch":
			# Falls from above and crushes the king on the way down, then stays on the field as
			# a wall for active_duration.
			definition.asset_name = "punch"
			definition.from_above = true
			definition.damages = true
			definition.size = 2 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 3.7
			definition.recovery = 0.3
			definition.blocks_movement = true
		"swipe":
			definition.asset_name = "swipe"
			definition.pushes = true
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 2.0
			definition.recovery = 0.3
		"void_removal":
			definition.asset_name = "void-removal"
			# Pulls pillars down from below: no hand on screen, the marked tiles are the warning.
			definition.shows_hand = false
			definition.size = 2 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 0.4
			definition.recovery = 0.4
		"smash":
			# Phase 2: crushes the king while falling and destroys the pillars it lands on.
			definition.asset_name = "smash"
			definition.from_above = true
			definition.damages = true
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 0.4
			definition.recovery = 0.4
		_:
			push_error("Unknown attack kind: %s" % kind)
	return definition
