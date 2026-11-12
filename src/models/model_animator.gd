class_name ModelAnimator
extends RefCounted
## Plays an animation on a model if the model has an AnimationPlayer with a matching clip.
## Placeholders have none, so this does nothing for them. Clip names: see src/assets/models/README.md.


static func play(model: Node, animation_name: String) -> void:
	if model == null or not is_instance_valid(model):
		return
	var player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null or not player.has_animation(animation_name):
		return
	if player.current_animation != animation_name:
		player.play(animation_name)
