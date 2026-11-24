class_name Phase2Director
extends RefCounted
## Drives Hands through the Phase 2 schedule (docs/plan/gameplay/enemy_curve.md) and says how
## many guiding hands should exist. It decides what is requested; Hands decides who, where
## and when.

signal endurance_reached

const FIRST_HAND_DELAY := 1.5
const LATER_HAND_DELAY := 1.0

var elapsed := 0.0

var _hands: Hands
var _rng: RandomNumberGenerator
var _done := false


func setup(hands: Hands, rng: RandomNumberGenerator) -> void:
	_hands = hands
	_rng = rng
	_apply_schedule()


func skip_forward(seconds: float) -> void:
	elapsed += seconds


func tick(delta: float) -> void:
	if _done:
		return
	elapsed += delta
	_apply_schedule()
	_stock_queue()
	if elapsed >= Constants.PHASE_TWO_ENDURANCE_SECONDS:
		_done = true
		endurance_reached.emit()


## Attacks this phase can request, with their default first time and upgrade time (seconds).
## Punch and swipe start upgraded: Phase 2 carries forward the Phase 1 upgrades.
const ATTACKS := {
	"swipe": [0.0, 0.0],
	"punch": [0.0, 0.0],
	"void_removal": [60.0, 120.0],
	"smash": [60.0, 120.0],
}


## Hand counts and attack timings come from config/schedule.cfg [phase2].
func hand_target() -> int:
	return GameConfig.count_reached("phase2", "hands_at", [0, 0, 30, 90, 120, 150, 180], elapsed)


func guiding_hands_wanted() -> int:
	return GameConfig.count_reached("phase2", "guiding_hands_at", [60, 180], elapsed)


func _apply_schedule() -> void:
	var target := hand_target()
	if target != _hands.hand_count():
		_hands.set_hand_count(target, FIRST_HAND_DELAY if _hands.hand_count() == 0 else LATER_HAND_DELAY)
	# Cooldown, telegraph and attack speed ramp as set in config/timing.cfg [phase2].
	_hands.action_cooldown = GameConfig.ramp("phase2", "cooldown", "max", "min", [4.2, 0.0, 360.0], elapsed)
	_hands.telegraph_time = GameConfig.ramp("phase2", "telegraph", "max", "min", [1.0, 1.0, 450.0], elapsed)
	_hands.speed_scale = GameConfig.ramp("phase2", "speed", "min", "max", [2.0, 3.0, 450.0], elapsed)


func _stock_queue() -> void:
	while _hands.queue_size() < _hands.hand_count() + 1:
		var options := AttackToggles.filter("phase2", _available())
		if options.is_empty():
			return
		var kind := options[_rng.randi_range(0, options.size() - 1)]
		_hands.request(kind, _level_for(kind))


func _level_for(kind: String) -> int:
	var upgrade_at := GameConfig.attack_upgrade_at("phase2", kind, float(ATTACKS[kind][1]))
	return 2 if upgrade_at >= 0.0 and elapsed >= upgrade_at else 1


func _available() -> Array[String]:
	var result: Array[String] = []
	for kind in ATTACKS:
		var from := GameConfig.attack_from("phase2", kind, float(ATTACKS[kind][0]))
		if from >= 0.0 and elapsed >= from:
			result.append(String(kind))
	return result
