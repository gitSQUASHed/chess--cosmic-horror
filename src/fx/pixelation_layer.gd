class_name PixelationLayer
extends CanvasLayer
## Full-screen canvas layer above the 3D view. Pixelates the whole image with a post-process
## shader. Pixel size is a runtime value and can be animated. Other screen effects are added
## to the same shader by the effects ticket.

const SHADER := preload("res://src/fx/screen.gdshader")

var _rect: ColorRect
var _material: ShaderMaterial
var _tween: Tween
var _fade_tween: Tween


func _ready() -> void:
	layer = 100
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.material = _material
	add_child(_rect)


func get_pixel_size() -> float:
	return float(_material.get_shader_parameter("pixel_size"))


func set_pixel_size(value: float) -> void:
	_kill_tween()
	_material.set_shader_parameter("pixel_size", clampf(value, 1.0, 64.0))


func animate_pixel_size(target: float, duration: float) -> void:
	_kill_tween()
	if duration <= 0.0:
		set_pixel_size(target)
		return
	_tween = create_tween()
	_tween.tween_method(_apply_pixel_size, get_pixel_size(), clampf(target, 1.0, 64.0), duration)


func set_fade(value: float) -> void:
	_kill_fade_tween()
	_material.set_shader_parameter("fade", clampf(value, 0.0, 1.0))


## Fades the whole image to black (1.0) or back (0.0).
func animate_fade(target: float, duration: float) -> void:
	_kill_fade_tween()
	if duration <= 0.0:
		set_fade(target)
		return
	_fade_tween = create_tween()
	_fade_tween.tween_method(_apply_fade, float(_material.get_shader_parameter("fade")), clampf(target, 0.0, 1.0), duration)


func set_palette_enabled(enabled: bool) -> void:
	_material.set_shader_parameter("palette_mix", 1.0 if enabled else 0.0)


## Access for the effects ticket and for presets.
func set_effect(parameter: StringName, value: Variant) -> void:
	_material.set_shader_parameter(parameter, value)


func _apply_pixel_size(value: float) -> void:
	_material.set_shader_parameter("pixel_size", value)


func _apply_fade(value: float) -> void:
	_material.set_shader_parameter("fade", value)


func _kill_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
