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
	return ["sweep", "grab", "wall", "swipe", "void_removal", "punch"]


static func _build(kind: String, level: int) -> AttackDefinition:
	var upgraded := level >= 2
	var definition := AttackDefinition.new()
	definition.kind = kind
	definition.level = clampi(level, 1, 2)
	match kind:
		"sweep":
			definition.asset_name = "sweep"
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 1.55
			definition.recovery = 0.35
		"grab":
			definition.asset_name = "grabbing"
			definition.from_above = true
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 0.48
			definition.recovery = 0.4
		"wall":
			definition.asset_name = "wall"
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 3.7
			definition.recovery = 0.3
			definition.blocks_movement = true
			definition.damages = false
		"swipe":
			definition.asset_name = "swipe"
			definition.size = 3 if upgraded else 1
			definition.telegraph_base = 1.0
			definition.active_duration = 2.0
			definition.recovery = 0.3
		"void_removal":
			definition.asset_name = "void-removal"
			# Pulls pillars down from below: no hand on screen, the marked tiles are the warning.
			definition.shows_hand = false
			definition.size = 2 if upgraded else 1
			definition.damages = false
			definition.telegraph_base = 1.0
			definition.active_duration = 0.4
			definition.recovery = 0.4
		"punch":
			definition.asset_name = "punch"
			definition.from_above = true
			definition.size = 3 if upgraded else 1
			definition.damages = false
			definition.telegraph_base = 1.0
			definition.active_duration = 0.4
			definition.recovery = 0.4
		_:
			push_error("Unknown attack kind: %s" % kind)
	return definition
