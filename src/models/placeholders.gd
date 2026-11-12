class_name Placeholders
extends RefCounted
## Single factory for every model. Today it builds coloured primitives with a floating name
## label. Real models replace them here (see try_real_model) without touching gameplay code.
## Hands are red, the king is green, tiles and pillars are white/gray.

const MODEL_DIR := "res://src/assets/models/"


## Builds a placeholder (or the real model, if present) for `placeholder_name`.
static func make(placeholder_name: String, shape: String, size: Vector3, colour: Color, with_label: bool = true) -> Node3D:
	var real := try_real_model(placeholder_name)
	if real != null:
		return real
	var root := Node3D.new()
	root.name = placeholder_name.replace("/", "_")
	var body := MeshInstance3D.new()
	body.name = "Body"
	match shape:
		"capsule":
			var capsule := CapsuleMesh.new()
			capsule.radius = minf(size.x, size.z) * 0.5
			capsule.height = size.y
			body.mesh = capsule
		"cylinder":
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = size.x * 0.5
			cylinder.bottom_radius = size.x * 0.5
			cylinder.height = size.y
			body.mesh = cylinder
		_:
			var box := BoxMesh.new()
			box.size = size
			body.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.9
	body.material_override = material
	body.position.y = size.y * 0.5
	root.add_child(body)
	if not with_label:
		return root
	var label := Label3D.new()
	label.name = "Label"
	label.text = placeholder_name
	label.font_size = 32
	label.pixel_size = 0.008
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.outline_size = 8
	label.position.y = size.y + 0.25
	root.add_child(label)
	return root


## Hook for T-20: returns an instance of res://src/assets/models/<name>.tscn or .glb if it exists.
static func try_real_model(placeholder_name: String) -> Node3D:
	var base := MODEL_DIR + placeholder_name.replace("/", "_")
	for extension in [".tscn", ".glb"]:
		if ResourceLoader.exists(base + extension):
			var scene := load(base + extension) as PackedScene
			if scene != null:
				var instance := scene.instantiate() as Node3D
				if instance != null:
					return instance
	return null


static func set_subtitle(model: Node3D, subtitle: String) -> void:
	var label := model.get_node_or_null("Label") as Label3D
	if label != null:
		var base := String(model.get_meta("base_name", label.text.get_slice("\n", 0)))
		model.set_meta("base_name", base)
		label.text = base if subtitle == "" else base + "\n" + subtitle


static func set_brightness(model: Node3D, brightness: float) -> void:
	var body := model.get_node_or_null("Body") as MeshInstance3D
	if body != null and body.material_override is StandardMaterial3D:
		var material := body.material_override as StandardMaterial3D
		if not model.has_meta("base_colour"):
			model.set_meta("base_colour", material.albedo_color)
		var base: Color = model.get_meta("base_colour")
		material.albedo_color = Color(base.r * brightness, base.g * brightness, base.b * brightness, base.a)
		if model.has_meta("glow"):
			# Hands are celestial: always emissive, so they stay the brightest thing on screen.
			material.emission_enabled = true
			material.emission = base
			material.emission_energy_multiplier = brightness * 1.2
		else:
			material.emission_enabled = brightness > 1.0
			material.emission = base


static func king(is_white: bool) -> Node3D:
	var colour := Palette.KING_WHITE_SIDE if is_white else Palette.KING_BLACK_SIDE
	return make("king_white" if is_white else "king_black", "capsule", Vector3(0.5, 0.9, 0.5), colour)


static func hand(asset_label: String, size: Vector3 = Vector3(1.0, 0.5, 1.0)) -> Node3D:
	var model := make(asset_label, "box", size, Palette.HAND)
	model.set_meta("glow", true)
	set_brightness(model, 1.0)
	return model


static func guiding_hand() -> Node3D:
	var model := make("hand/guiding-missile", "box", Vector3(1.2, 0.8, 1.2), Palette.HAND)
	model.set_meta("glow", true)
	set_brightness(model, 1.0)
	return model


static func tile(is_light: bool) -> Node3D:
	return make("tile_light" if is_light else "tile_dark", "box", Vector3(0.98, 0.2, 0.98), Palette.TILE_LIGHT if is_light else Palette.TILE_DARK, false)


static func pillar() -> Node3D:
	return make("pillar", "box", Vector3(0.94, 0.6, 0.94), Palette.PILLAR, false)


static func wall_segment() -> Node3D:
	return make("wall", "box", Vector3(1.0, 1.0, 1.0), Palette.WALL)


static func clock() -> Node3D:
	return make("clock", "box", Vector3(0.6, 2.0, 1.6), Palette.PROP)


static func silhouette(side: String) -> Node3D:
	return make("silhouette_" + side, "capsule", Vector3(2.4, 5.0, 2.4), Palette.PROP.darkened(0.7))


static func chess_piece(piece_name: String) -> Node3D:
	return make("piece_" + piece_name, "cylinder", Vector3(0.5, 0.9, 0.5), Palette.PROP)
