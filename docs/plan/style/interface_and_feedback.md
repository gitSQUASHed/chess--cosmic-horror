# Interface, Text, and Feedback

## Interface policy

The game is intentionally low-UI. Do not add a permanent health bar, score, minimap, objective arrow, Phase 2 timer, or a visible escape-distance meter.

## Diegetic feedback

- The Phase 1 chess clock is the only time reference, embedded in the scene.
- Attack telegraphing follows [attack warnings](../gameplay/enemy_mechanics.md#attack-warnings): hands waiting on the field, shadows of top-down hands, dark outlined pillars for void removal, and white outlines on the king and hands in Phase 2.
- Phase 2 pursuit is communicated through white illumination, static, fisheye, screen shake, and sound—not an enemy marker.
- The state of pillars is communicated by their movement: rising to emerge, falling and darkening when removed.

## Dialogue

Background dialogue is short and mundane. It should feel like overheard human conversation, not tutorial text. It does not pause the game unless it is part of a cutscene.

## Cutscene textbox

Use a bottom-covering pixel-font textbox for important dialogue and scene text. It pauses the action and continues only after Space / confirm input. See [Narrative and Cutscenes](../narrative/cutscenes.md) for its required moments.
