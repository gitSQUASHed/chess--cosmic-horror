# T-23 Attack warnings and grounded hands

## Scope
- Fixed telegraph of at least 1 s (`Constants.MIN_TELEGRAPH`) for every action except guiding hands. Directors raise `Hands.speed_scale` over time instead of shortening the telegraph.
- Hands stand on the field. Ground hands wait where they act; grab and punch stay hidden and show a shadow (`Placeholders.shadow`), then fall from above the screen (`Hand.State.DROPPING`) and strike on landing.
- Void removal has no hand; its pillars go dark with an outline (`PillarField.mark_area`) for 1 s, then sink without the outline.
- Both phases: white unshaded outline (`Placeholders.add_outline`) on the king and every hand, thinner on the board than on the pillar field.
- Phase 2 pillars are cubes.
- Phase 2 hands run at twice the speed (`Constants.PHASE2_HAND_SPEED_MULTIPLIER`), the king at 1.2 times (`PHASE2_KING_SPEED_MULTIPLIER`). The dash is replaced by a plain jump (`jump` action).
- Phase 1 attacks start at 0.6 times speed (including the fall of top-down hands) and reach 1.4 times.
- Top-down shadows carry a white outline until the hand lands.
- Phase 2 depth mist darkens pillar sides toward the void.
- Removed: travel from the silhouettes, brightness ramps and state labels on hands.

## Acceptance criteria
- Run in Godot without console errors.
- Every attack waits at least 1 s after its warning appears, at the start and the end of each phase.
- Sweeps, swipes and strikes are visibly faster late in each phase; the telegraph is not.
- No hand floats above the field; grab and punch are invisible until they fall in from above the top of the screen.
- Outlines read as one pixel cell or more in both phases and keep their colour under the guiding-hand bloom.
- Pillar sides visibly darken toward their base, and the mist does not tint the king, hands or pillar tops.
- The jump clears a one-tile hole, and the camera keeps up with the faster king.
- Rising and sinking cube pillars look right, and the king lands on top of them at the start of Phase 2.
