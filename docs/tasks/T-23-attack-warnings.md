# T-23 Attack warnings and grounded hands

## Scope
- Fixed telegraph of at least 1 s (`Constants.MIN_TELEGRAPH`) for every action except guiding hands. Directors raise `Hands.speed_scale` over time instead of shortening the telegraph.
- Hands stand on the field. Ground hands wait where they act; grab and punch stay hidden and show a shadow (`Placeholders.shadow`) until they drop in.
- Void removal has no hand; its pillars go dark with an outline (`PillarField.mark_area`) for 1 s, then sink.
- Phase 2: white unshaded outline (`Placeholders.add_outline`) on the king, attack hands and guiding hands.
- Removed: travel from the silhouettes, brightness ramps and state labels on hands.

## Acceptance criteria
- Run in Godot without console errors.
- Every attack waits at least 1 s after its warning appears, at the start and the end of each phase.
- Sweeps, swipes and strikes are visibly faster late in each phase; the telegraph is not.
- No hand floats above the field; grab and punch are invisible until they strike.
- Outlines read as one pixel cell or more at the Phase 2 zoom and keep their colour under the guiding-hand bloom.
