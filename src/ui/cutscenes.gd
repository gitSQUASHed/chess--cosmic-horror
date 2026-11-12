class_name Cutscenes
extends RefCounted
## Placeholder cutscene scripts: the lines come from docs/plan/narrative/cutscenes.md and
## docs/plan/gameplay/endings.md. `props` lists placeholder models staged on screen.


static func get_cutscene(cutscene_name: String) -> Dictionary:
	match cutscene_name:
		"opening":
			return {
				"props": [["king", Vector3(3.5, 0.0, 4.5)], ["piece_a", Vector3(5.5, 0.0, 3.5)], ["piece_b", Vector3(1.5, 0.0, 3.5)], ["silhouette_left", Vector3(1.5, 0.0, -5.0)], ["silhouette_right", Vector3(6.5, 0.0, -5.0)]],
				"lines": [
					"King: Finally. The game is over.",
					"Piece: That was a long one.",
					"Far above: Dinner is ready! Clear the board!",
					"A hand removes the other pieces. It reaches for the king.",
				],
			}
		"arrival":
			return {
				"props": [],
				"lines": [
					"King: ...No more squares. No more rules.",
					"The board is gone. Something vast remains.",
				],
			}
		"ending_captured":
			return {"props": [], "lines": ["Far above: Finally! Now we can go downstairs."]}
		"ending_void":
			return {"props": [], "lines": ["Far above: Where did the king go? Anyway, let's go downstairs."]}
		"ending_escaped":
			return {"props": [["clock", Vector3(4.0, 0.0, 4.0)], ["king", Vector3(4.0, 3.0, 4.0)]], "lines": ["King: Now it's my turn."]}
		"ending_endurance":
			return {"props": [], "lines": ["Far above: Yeah, let's just clean up later."]}
		_:
			return {"props": [], "lines": ["(" + cutscene_name + ")"]}
