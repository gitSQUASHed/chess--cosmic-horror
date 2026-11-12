# T-02 Placeholder models

## Goal
Primitive stand-ins for every model, so gameplay and effects can be built before real art exists.

## Scope
- One factory, for example `Placeholders.make(name, kind)`, that returns a Node3D with a mesh, optional collision shape, and a floating name label (`Label3D`).
- Colors: hands red, king green (light and dark variant for white and black side), tiles and pillars white or gray.
- Variants: king (white, black), hand per action and level (names match `hand/<action>-lvl<N>`), guiding hand, board tile (light, dark), pillar, hole marker, wall, chess clock, silhouette (left, right), chess pieces.
- The label always shows the placeholder name.

## Acceptance criteria
- Every placeholder shows its name and uses the agreed color.
- No gameplay script builds meshes by hand; it asks the factory.
- Swapping a placeholder for a real model needs no change in gameplay code (the factory is the single seam, used again in T-20).
