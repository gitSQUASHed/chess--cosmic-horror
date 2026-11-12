class_name Phase1Director
extends RefCounted
## Drives Hands through the two-minute Phase 1 schedule (docs/plan/gameplay/enemy_curve.md).
## It decides what is requested and tunes Hands; Hands decides who, where and when.

signal finished

## Requests kept waiting so a blocked wall never starves the hands.
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


func hand_target() -> int:
	if elapsed < 30.0:
		return 1
	if elapsed < 90.0:
		return 2
	return 3


func attack_level() -> int:
	return 1 if elapsed < 60.0 else 2


func _apply_schedule() -> void:
	var target := hand_target()
	if target != _hands.hand_count():
		_hands.set_hand_count(target, FIRST_HAND_DELAY if _hands.hand_count() == 0 else LATER_HAND_DELAY)
	_hands.action_cooldown = _action_interval()
	_hands.telegraph_reduction = elapsed / Constants.PHASE_ONE_SECONDS * 0.3


func _action_interval() -> float:
	if elapsed < 30.0:
		return 4.2
	if elapsed < 60.0:
		return 3.7
	if elapsed < 90.0:
		return 3.0
	return maxf(0.0, 2.1 - (elapsed - 90.0) / 50.0)


func _stock_queue() -> void:
	while _hands.queue_size() < QUEUE_TARGET:
		var options: Array[String] = ["sweep", "grab"]
		if elapsed >= 30.0 and not _hands.has_queued("wall"):
			options.append("wall")
		var kind := options[_rng.randi_range(0, options.size() - 1)]
		_hands.request(kind, 1 if kind == "wall" else attack_level())
