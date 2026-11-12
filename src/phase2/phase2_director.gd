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
var _upgrades: Dictionary
var _done := false


func setup(hands: Hands, rng: RandomNumberGenerator, upgrades: Dictionary) -> void:
	_hands = hands
	_rng = rng
	_upgrades = upgrades
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


func hand_target() -> int:
	if elapsed < 30.0:
		return 2
	if elapsed < 90.0:
		return 3
	if elapsed < 120.0:
		return 4
	if elapsed < 150.0:
		return 5
	if elapsed < 180.0:
		return 6
	return 7


func guiding_hands_wanted() -> int:
	if elapsed < 60.0:
		return 0
	if elapsed < 180.0:
		return 1
	return 2


func _apply_schedule() -> void:
	var target := hand_target()
	if target != _hands.hand_count():
		_hands.set_hand_count(target, FIRST_HAND_DELAY if _hands.hand_count() == 0 else LATER_HAND_DELAY)
	_hands.action_cooldown = _action_interval()
	_hands.telegraph_reduction = elapsed / 450.0


func _action_interval() -> float:
	if elapsed < 30.0:
		return 4.2
	if elapsed < 60.0:
		return 3.2
	if elapsed < 120.0:
		return 2.25
	if elapsed < 180.0:
		return 1.55
	return maxf(0.0, 1.0 - (elapsed - 180.0) / 180.0)


func _stock_queue() -> void:
	while _hands.queue_size() < _hands.hand_count() + 1:
		var options: Array[String] = ["swipe", "grab"]
		if elapsed >= 60.0:
			options.append_array(["void_removal", "punch"])
		if not _hands.has_queued("wall"):
			options.append("wall")
		var kind := options[_rng.randi_range(0, options.size() - 1)]
		_hands.request(kind, _level_for(kind))


func _level_for(kind: String) -> int:
	match kind:
		"swipe":
			return 2
		"grab":
			return int(_upgrades.get("grab", 2))
		"wall":
			return int(_upgrades.get("wall", 2))
		_:
			return 2 if elapsed >= 120.0 else 1
