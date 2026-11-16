class_name GameContext
extends RefCounted
## What every game state needs: the run data and the shared camera, pixelation and flow.

var run_config: RunConfig
var camera: CameraRig
var pixelation: PixelationLayer
var effects: ScreenEffects
## The shared 3D environment (background, ambient light, Phase 2 depth mist).
var environment: Environment
var flow: GameFlow
## Hand upgrade levels carried from Phase 1 into Phase 2.
var upgrades := {"sweep": 1, "grab": 1, "wall": 1}
