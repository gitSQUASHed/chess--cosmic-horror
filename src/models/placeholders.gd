class_name Placeholders
extends RefCounted
## Single factory for every model. Today it builds coloured primitives (no name labels). Real models replace them here (see try_real_model) without touching gameplay code.
## Hands are red, the king is green, tiles and pillars are white/gray.

const MODEL_DIR := "res://src/assets/models/"
const PILLAR_SHADER := preload("res://src/models/pillar.gdshader")
## Outline thickness in metres, about one screen pixel cell at each phase's zoom.
const OUTLINE_WIDTH_BOARD := 0.05
const OUTLINE_WIDTH_FIELD := 0.12

## Real-model lookups by placeholder name (PackedScene, or null when there is none), so the
## disk is checked once per name instead of once per model built.
static var _real_models: Dictionary = {}
## Primitive meshes by shape and size, shared by every model of that shape.
static var _meshes: Dictionary = {}
## The one material all pillars share; brightness is a per-instance shader parameter.
static var _pillar_material: ShaderMaterial


## Builds a placeholder (or the real model, if present) for `placeholder_name`.
static func make(placeholder_name: String, shape: String, size: Vector3, colour: Color) -> Node3D:
	var real := try_real_model(placeholder_name)
	if real != null:
		return real
	var root := Node3D.new()
	root.name = placeholder_name.replace("/", "_")
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = _mesh(shape, size)
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.9
	body.material_override = material
	body.position.y = size.y * 0.5
	root.add_child(body)
	return root


## Hook for T-20: returns an instance of res://src/assets/models/<name>.tscn or .glb if it exists.
static func try_real_model(placeholder_name: String) -> Node3D:
	if not _real_models.has(placeholder_name):
		_real_models[placeholder_name] = _find_real_model(placeholder_name)
	var scene := _real_models[placeholder_name] as PackedScene
	return scene.instantiate() as Node3D if scene != null else null


static func _find_real_model(placeholder_name: String) -> PackedScene:
	var base := MODEL_DIR + placeholder_name.replace("/", "_")
	for extension in [".tscn", ".glb"]:
		if ResourceLoader.exists(base + extension):
			var scene := load(base + extension) as PackedScene
			if scene != null:
				return scene
	return null


static func _mesh(shape: String, size: Vector3) -> Mesh:
	var key := "%s:%s" % [shape, size]
	if _meshes.has(key):
		return _meshes[key] as Mesh
	var mesh: Mesh
	match shape:
		"capsule":
			var capsule := CapsuleMesh.new()
			capsule.radius = minf(size.x, size.z) * 0.5
			capsule.height = size.y
			mesh = capsule
		"cylinder":
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = size.x * 0.5
			cylinder.bottom_radius = size.x * 0.5
			cylinder.height = size.y
			mesh = cylinder
		_:
			var box := BoxMesh.new()
			box.size = size
			mesh = box
	_meshes[key] = mesh
	return mesh


static func set_brightness(model: Node3D, brightness: float) -> void:
	var body := model.get_node_or_null("Body") as MeshInstance3D
	if body != null and body.material_override is ShaderMaterial:
		body.set_instance_shader_parameter("brightness", brightness)
		return
	if body != null and body.material_override is StandardMaterial3D:
		var material := body.material_override as StandardMaterial3D
		if not model.has_meta("base_colour"):
			model.set_meta("base_colour", material.albedo_color)
		var base: Color = model.get_meta("base_colour")
		material.albedo_color = Color(base.r * brightness, base.g * brightness, base.b * brightness, base.a)
		if model.has_meta("glow"):
			# Hands are celestial: always emissive with a near-white light, so they stay the
			# brightest thing on screen after the palette mapping (a pure red would map dark).
			material.emission_enabled = true
			material.emission = base.lerp(Color.WHITE, 0.6)
			material.emission_energy_multiplier = brightness * 1.2
		else:
			material.emission_enabled = brightness > 1.0
			material.emission = base


## Adds a solid white outline to every mesh of `model` (placeholder or real model): an unshaded,
## front-culled hull slightly larger than the mesh, so lights and shadows never affect it.
static func add_outline(model: Node3D, width: float = OUTLINE_WIDTH_FIELD) -> void:
	if model.has_meta("outlined"):
		return
	model.set_meta("outlined", true)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	material.cull_mode = BaseMaterial3D.CULL_FRONT
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(model, meshes)
	for source in meshes:
		if source.mesh == null:
			continue
		var bounds := source.mesh.get_aabb()
		var hull := MeshInstance3D.new()
		hull.name = "Outline"
		hull.mesh = source.mesh
		hull.material_override = material
		hull.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var grow := Vector3.ONE
		for axis in range(3):
			if bounds.size[axis] > 0.001:
				grow[axis] = (bounds.size[axis] + 2.0 * width) / bounds.size[axis]
		var centre := bounds.get_center()
		hull.transform = Transform3D(Basis.from_scale(grow), centre - centre * grow)
		source.add_child(hull)


static func remove_outline(model: Node3D) -> void:
	if not model.has_meta("outlined"):
		return
	model.remove_meta("outlined")
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(model, meshes)
	for source in meshes:
		for child in source.get_children():
			if child is MeshInstance3D and child.name == "Outline":
				child.queue_free()


static func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D and node.name != "Outline":
		result.append(node as MeshInstance3D)
	for child in node.get_children():
		_collect_meshes(child, result)


## Flat dark patch on the ground where a top-down hand will land, framed by a solid white
## outline of `outline_width`. `size` is (x, z) in metres.
static func shadow(size: Vector2, outline_width: float = OUTLINE_WIDTH_BOARD) -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = size
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.0, 0.0, 0.0, 0.5)
	var patch := MeshInstance3D.new()
	patch.name = "Shadow"
	patch.mesh = plane
	patch.material_override = material
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	patch.position.y = 0.02
	var frame_material := StandardMaterial3D.new()
	frame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	frame_material.albedo_color = Color.WHITE
	var half := size * 0.5
	var w := outline_width
	# Four strips around the patch: (centre x, centre z, length x, length z).
	var strips := [
		[0.0, -half.y - w * 0.5, size.x + 2.0 * w, w],
		[0.0, half.y + w * 0.5, size.x + 2.0 * w, w],
		[-half.x - w * 0.5, 0.0, w, size.y],
		[half.x + w * 0.5, 0.0, w, size.y],
	]
	for strip in strips:
		var box := BoxMesh.new()
		box.size = Vector3(strip[2], 0.01, strip[3])
		var piece := MeshInstance3D.new()
		piece.name = "Outline"
		piece.mesh = box
		piece.material_override = frame_material
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		piece.position = Vector3(strip[0], 0.0, strip[1])
		patch.add_child(piece)
	return patch


static func set_shadow_strength(patch: MeshInstance3D, alpha: float) -> void:
	var material := patch.material_override as StandardMaterial3D
	if material != null:
		material.albedo_color.a = clampf(alpha, 0.0, 1.0)


static func king(is_white: bool) -> Node3D:
	var colour := Palette.KING_WHITE_SIDE if is_white else Palette.KING_BLACK_SIDE
	var model := make("king_white" if is_white else "king_black", "capsule", Vector3(0.5, 0.9, 0.5), colour)
	# A faint self-light lifts the king above the surfaces around it after the palette mapping.
	var body := model.get_node_or_null("Body") as MeshInstance3D
	if body != null and body.material_override is StandardMaterial3D:
		var material := body.material_override as StandardMaterial3D
		material.emission_enabled = true
		material.emission = colour
		material.emission_energy_multiplier = 0.35
	return model


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
	return make("tile_light" if is_light else "tile_dark", "box", Vector3(0.98, 0.2, 0.98), Palette.TILE_LIGHT if is_light else Palette.TILE_DARK)


## A cube-like pillar: `width` is the tile size in metres (a small gap leaves visible seams),
## `height` its full height so its top lines up with the collision box.
## Its sides fade into the void colour below `surface_y` (pillar.gdshader).
## The 8x8 chessboard, tiles spanning x and z from 0 to 8 with their top at y 0. Used by Phase 1
## and the opening cutscene.
static func board() -> Node3D:
	var root := Node3D.new()
	root.name = "Board"
	for x in range(Constants.BOARD_TILES):
		for z in range(Constants.BOARD_TILES):
			var piece := tile((x + z) % 2 == 0)
			piece.position = Vector3(x + 0.5, -0.1, z + 0.5)
			root.add_child(piece)
	return root


static func pillar(width: float = 1.0, height: float = 1.0, surface_y: float = 0.0) -> Node3D:
	var model := make("pillar", "box", Vector3(width * 0.94, height, width * 0.94), Palette.PILLAR)
	var body := model.get_node_or_null("Body") as MeshInstance3D
	if body != null:
		if _pillar_material == null:
			_pillar_material = ShaderMaterial.new()
			_pillar_material.shader = PILLAR_SHADER
			_pillar_material.set_shader_parameter("albedo", Palette.PILLAR)
			_pillar_material.set_shader_parameter("mist_color", Palette.VOID_BLACK)
		_pillar_material.set_shader_parameter("surface_y", surface_y)
		body.material_override = _pillar_material
	return model


static func clock() -> Node3D:
	var model := make("clock", "box", Vector3(1.6, 2.0, 0.6), Palette.PROP)
	# The clock's time readout: large digits so they survive the pixelation.
	var face := Label3D.new()
	face.name = "Time"
	face.font_size = 72
	face.pixel_size = 0.008
	face.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	face.outline_size = 12
	face.position = Vector3(0.0, 1.2, 0.35)
	model.add_child(face)
	return model


static func set_clock_time(model: Node3D, text: String) -> void:
	var face := model.get_node_or_null("Time") as Label3D
	if face != null:
		face.text = text


static func silhouette(side: String) -> Node3D:
	return make("silhouette_" + side, "capsule", Vector3(2.4, 5.0, 2.4), Palette.PROP.darkened(0.7))


static func chess_piece(piece_name: String) -> Node3D:
	return make("piece_" + piece_name, "cylinder", Vector3(0.5, 0.9, 0.5), Palette.PROP)
