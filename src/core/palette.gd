class_name Palette
extends RefCounted
## Placeholder colours (hands red, king green, tiles and pillars white/gray) and the
## provisional retro-green screen palette, see docs/plan/style/colors.md.

const HAND := Color("d93a3a")
const KING_WHITE_SIDE := Color("7be08a")
const KING_BLACK_SIDE := Color("1f7a36")
## Light squares are kept below white so hands and outlines stay the brightest things on the board.
const TILE_LIGHT := Color("bdbdbd")
const TILE_DARK := Color("8c8c8c")
const PILLAR := Color("c4c4c4")
const WALL := Color("a8a8ff")
const PROP := Color("b8b8b8")
const VOID_BLACK := Color("050a07")

## Screen palette ramps (void, deep, mid, light) for the shader's palette mapping, set per
## phase by ScreenEffects. Phase 1 keeps a wide ramp so the board, clock and silhouettes stay
## distinct. Phase 2 follows docs/plan/style/reference/phase2_target.png: a lifted gray void
## and desaturated greens, brightened for legibility.
const SCREEN_PHASE_ONE: Array[Color] = [Color("171a17"), Color("2b362e"), Color("546b57"), Color("c7e6bd")]
const SCREEN_PHASE_TWO: Array[Color] = [Color("262826"), Color("3d443d"), Color("617061"), Color("d1e3c2")]
