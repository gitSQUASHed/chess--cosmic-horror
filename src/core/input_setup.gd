class_name InputSetup
extends RefCounted
## Makes sure every input action the game needs exists.


static func ensure() -> void:
	_action(&"move_up", [KEY_W, KEY_UP])
	_action(&"move_down", [KEY_S, KEY_DOWN])
	_action(&"move_left", [KEY_A, KEY_LEFT])
	_action(&"move_right", [KEY_D, KEY_RIGHT])
	_action(&"confirm", [KEY_SPACE, KEY_ENTER])
	_action(&"jump_dash", [KEY_SPACE])


static func _action(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var keycode := int(key) as Key
		var already := false
		for existing in InputMap.action_get_events(action):
			if existing is InputEventKey:
				var existing_key := existing as InputEventKey
				if existing_key.physical_keycode == keycode or existing_key.keycode == keycode:
					already = true
					break
		if already:
			continue
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)
