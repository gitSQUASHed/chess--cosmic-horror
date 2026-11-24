class_name Phase1Director
extends RefCounted
## Drives Hands through the two-minute Phase 1 schedule (docs/plan/gameplay/enemy_curve.md).
## It decides what is requested and tunes Hands; Hands decides who, where and when.

signal finished

## Requests kept waiting so a free hand always has something to start.
const QUEUE_TARGET := 2
const FIRST_HAND_DELAY := 1.4
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
	if elapsed >= Constants.PHASE_ONE_SECONDS:
		_done = true
		finished.emit()


## Attacks this phase can request, with their default first time and upgrade time (seconds).
const ATTACKS := {"sweep": [0.0, 60.0], "punch": [0.0, 60.0]}


## Hand count and attack timings come from config/schedule.cfg [phase1].
func hand_target() -> int:
	return GameConfig.count_reached("phase1", "hands_at", [0, 30, 90], elapsed)


func level_for(kind: String) -> int:
	var upgrade_at := GameConfig.attack_upgrade_at("phase1", kind, float(ATTACKS[kind][1]))
	return 2 if upgrade_at >= 0.0 and elapsed >= upgrade_at else 1


func _apply_schedule() -> void:
	var target := hand_target()
	if target != _hands.hand_count():
		_hands.set_hand_count(target, FIRST_HAND_DELAY if _hands.hand_count() == 0 else LATER_HAND_DELAY)
	# Cooldown, telegraph and attack speed ramp as set in config/timing.cfg [phase1].
	_hands.action_cooldown = GameConfig.ramp("phase1", "cooldown", "max", "min", [4.2, 1.5, 120.0], elapsed)
	_hands.telegraph_time = GameConfig.ramp("phase1", "telegraph", "max", "min", [1.0, 1.0, 120.0], elapsed)
	_hands.speed_scale = GameConfig.ramp("phase1", "speed", "min", "max", [0.6, 1.4, 120.0], elapsed)


func _stock_queue() -> void:
	while _hands.queue_size() < QUEUE_TARGET:
		var options := AttackToggles.filter("phase1", _available())
		if options.is_empty():
			return
		var kind := options[_rng.randi_range(0, options.size() - 1)]
		_hands.request(kind, level_for(kind))


func _available() -> Array[String]:
	var result: Array[String] = []
	for kind in ATTACKS:
		var from := GameConfig.attack_from("phase1", kind, float(ATTACKS[kind][0]))
		if from >= 0.0 and elapsed >= from:
			result.append(String(kind))
	return result
