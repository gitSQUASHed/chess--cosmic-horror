class_name Layers
extends RefCounted
## Physics layer bit values. Layer n has the value 1 << (n - 1).

const FLOOR := 1
const PILLAR := 2
const VOID := 4
const KING := 8
const HAND_DANGER := 16
const WALL := 32
const TRIGGER := 64
