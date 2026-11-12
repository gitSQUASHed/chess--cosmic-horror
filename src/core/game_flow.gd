class_name GameFlow
extends Node
## Runs the game in order: intro, Phase 1, transition, arrival, Phase 2, ending.
## States change only through change_state(). Unfinished states are labelled StubStates.

enum State { INTRO, PHASE_ONE, TRANSITION, ARRIVAL, PHASE_TWO, ENDING }

var state: State = State.INTRO
var context := GameContext.new()
var ending := ""

var _current: Node


func _ready() -> void:
	InputSetup.ensure()
	_build_stage()
	start_run()


func start_run(first_state: State = State.INTRO) -> void:
	context.run_config = RunConfig.new()
	ending = ""
	context.pixelation.set_pixel_size(Presets.NORMAL)
	context.pixelation.set_fade(0.0)
	context.upgrades = {"sweep": 1, "grab": 1, "wall": 1}
	change_state(first_state)


func change_state(new_state: State) -> void:
	if _current != null:
		remove_child(_current)
		_current.queue_free()
		_current = null
	state = new_state
	context.effects.set_mode(ScreenEffects.Mode.NONE)
	_current = _build_state(new_state)
	_current.finished.connect(_on_state_finished.bind(new_state))
	add_child(_current)


func _build_stage() -> void:
	context.flow = self
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Palette.VOID_BLACK
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.6, 0.6)
	environment.ambient_light_energy = 0.45
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60.0, 25.0, 0.0)
	sun.light_energy = 0.8
	add_child(sun)
	context.camera = CameraRig.new()
	add_child(context.camera)
	context.pixelation = PixelationLayer.new()
	add_child(context.pixelation)
	context.effects = ScreenEffects.new()
	context.effects.setup(context.pixelation, context.camera)
	add_child(context.effects)


func _build_state(which: State) -> Node:
	match which:
		State.INTRO:
			return _cutscene("opening")
		State.PHASE_ONE:
			var phase := Phase1.new()
			phase.setup(context)
			return phase
		State.TRANSITION:
			var hold := _stub("transition_black_hold", "")
			hold.auto_seconds = 1.2
			return hold
		State.ARRIVAL:
			return _cutscene("arrival")
		State.PHASE_TWO:
			var phase_two := Phase2.new()
			phase_two.setup(context)
			return phase_two
		_:
			return _cutscene("ending_" + ending, "(Space: new run)")


func _cutscene(cutscene_name: String, hint_after: String = "") -> CutsceneRunner:
	var runner := CutsceneRunner.new()
	runner.setup(context, cutscene_name, hint_after)
	return runner


func _stub(placeholder_name: String, hint: String, ending_menu: bool = false) -> StubState:
	var stub := StubState.new()
	stub.setup(context, placeholder_name, hint, ending_menu)
	return stub


func _on_state_finished(result: String, from_state: State) -> void:
	# Deferred so a state is never freed from inside its own signal emission.
	call_deferred("_advance", from_state, result)


func _advance(from_state: State, result: String) -> void:
	if from_state != state:
		return
	match from_state:
		State.INTRO:
			change_state(State.PHASE_ONE)
		State.PHASE_ONE:
			if result == "survived":
				change_state(State.TRANSITION)
			elif result == "continue":
				change_state(State.TRANSITION)
			else:
				ending = result
				change_state(State.ENDING)
		State.TRANSITION:
			change_state(State.ARRIVAL)
		State.ARRIVAL:
			change_state(State.PHASE_TWO)
		State.PHASE_TWO:
			ending = result
			change_state(State.ENDING)
		State.ENDING:
			start_run()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_R:
			start_run(State.PHASE_ONE)
		KEY_F2:
			context.upgrades = {"sweep": 2, "grab": 2, "wall": 2}
			change_state(State.PHASE_TWO)
		KEY_BRACKETLEFT:
			context.pixelation.set_pixel_size(context.pixelation.get_pixel_size() - 1.0)
		KEY_BRACKETRIGHT:
			context.pixelation.set_pixel_size(context.pixelation.get_pixel_size() + 1.0)
