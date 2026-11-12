class_name ScreenEffects
extends Node
## Drives the screen shader per phase and from the guiding-hand threat value.
## Phase 1: light grain and static. Phase 2: vignette, grain, static, gentle fisheye, and a threat response
## (white bloom, denser static, camera shake, slightly larger pixels). Bloom is capped so the
## king stays readable. Each effect can be toggled for debugging (F5 to F8).

enum Mode { NONE, PHASE_ONE, PHASE_TWO }

const BLOOM_MAX := 0.8
const SMOOTHING := 4.0

## Debug switches: vignette, grain, fisheye, bloom.
var enabled := {"vignette": true, "grain": true, "fisheye": true, "bloom": true}

var _layer: PixelationLayer
var _camera: CameraRig
var _mode: Mode = Mode.NONE
var _threat := 0.0
var _vignette := 0.0
var _grain := 0.0
var _static := 0.0
var _fisheye := 0.0
var _bloom := 0.0
var _boost := 0.0


func setup(pixelation: PixelationLayer, camera: CameraRig) -> void:
	_layer = pixelation
	_camera = camera


func set_mode(mode: Mode) -> void:
	_mode = mode
	if mode != Mode.PHASE_TWO:
		_threat = 0.0


## 0 (calm) to 1 (immediate danger). Only used in Phase 2.
func set_threat(value: float) -> void:
	_threat = clampf(value, 0.0, 1.0)


func _process(delta: float) -> void:
	var target_vignette := 0.0
	var target_grain := 0.0
	var target_static := 0.0
	var target_fisheye := 0.0
	var target_bloom := 0.0
	var target_boost := 0.0
	match _mode:
		Mode.PHASE_ONE:
			target_grain = 0.04
			target_static = 0.2
		Mode.PHASE_TWO:
			target_vignette = 0.6 + 0.2 * _threat
			target_grain = 0.08 + 0.25 * _threat
			target_static = 0.3 + 0.4 * _threat
			target_fisheye = 1.0
			target_bloom = BLOOM_MAX * _threat * _threat
			target_boost = Presets.THREAT_BOOST * _threat
			if _threat > 0.35:
				_camera.shake(0.12 * _threat, 0.12)
	var blend := 1.0 - exp(-SMOOTHING * delta)
	_vignette = lerpf(_vignette, target_vignette, blend)
	_grain = lerpf(_grain, target_grain, blend)
	_static = lerpf(_static, target_static, blend)
	_fisheye = lerpf(_fisheye, target_fisheye, blend)
	_bloom = lerpf(_bloom, target_bloom, blend)
	_boost = lerpf(_boost, target_boost, blend)
	_layer.set_effect(&"vignette", _vignette if enabled["vignette"] else 0.0)
	_layer.set_effect(&"grain", _grain if enabled["grain"] else 0.0)
	_layer.set_effect(&"static_amount", _static if enabled["grain"] else 0.0)
	_layer.set_effect(&"fisheye", _fisheye if enabled["fisheye"] else 0.0)
	_layer.set_effect(&"bloom", _bloom if enabled["bloom"] else 0.0)
	_layer.set_effect(&"pixel_boost", _boost)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_F5:
			enabled["vignette"] = not enabled["vignette"]
		KEY_F6:
			enabled["grain"] = not enabled["grain"]
		KEY_F7:
			enabled["fisheye"] = not enabled["fisheye"]
		KEY_F8:
			enabled["bloom"] = not enabled["bloom"]
