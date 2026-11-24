# Enemy Curve

Earlier mechanics remain active after each timestamp. The timestamps for hand counts, guiding hands and when each attack appears or upgrades are set in `config/schedule.cfg`; this document describes the default values. The Phase 2 attack-hand count excludes guiding missile hands.

## Phase 1 — Board Cleanup

| Timestamp | Added or changed |
|---|---|
| [00:00] | Start with one action hand. Enable tile side sweeps and 1×1 top-down punches. Initial action interval: about four seconds. |
| [00:30] | Add a second action hand. |
| [01:00] | Upgrade side sweeps (3 tiles wide) and top-down punches (2×2). |
| [01:30] | Add a third action hand. |
| [02:00] | End Phase 1 and begin the board-collapse transition. |

## Phase 2 — Beyond the Board

| Timestamp | Added or changed |
|---|---|
| [00:00] | Start with two attack hands. Enable flat swipes and carry forward the completed Phase 1 upgrades: 3×1 swipes and 2×2 punches. Reset the action interval for the new phase. |
| [00:30] | Add a third attack hand. |
| [01:00] | Add the first guiding missile hand. Enable void removal and smash actions. |
| [01:30] | Add a fourth attack hand. |
| [02:00] | Add a fifth attack hand. Upgrade smash and void removal. |
| [02:30] | Add a sixth attack hand. |
| [03:00] | Add a seventh attack hand and the second guiding missile hand. No later upgrade or hand-count increase is planned; action cooldowns may continue to approach their zero-second floor. |
