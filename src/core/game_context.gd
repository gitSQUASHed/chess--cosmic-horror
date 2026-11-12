class_name GameContext
extends RefCounted
## What every game state needs: the run data and the shared camera, pixelation and flow.

var run_config: RunConfig
var camera: CameraRig
var pixelation: PixelationLayer
var effects: ScreenEffects
var flow: GameFlow
## Hand upgrade levels carried from Phase 1 into Phase 2.
var upgrades := {"sweep": 1, "grab": 1, "wall": 1}
