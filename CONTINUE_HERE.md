# Current local handoff — 10 November 2026

Open `b02.tscn` and press F6 for the partial B02 economy trial; F5 retains B01.
The user reviewed the trial and requested upload after walking-timing adjustment.
Walking now uses constant horizontal speed across route segments (1.4 world
units/second; rover 2.1), with matching fixed walking cadence. Longer routes
take proportionally longer; no route-duration cap or gameplay delay is added.
Motion Off still snaps to the authoritative destination. This has automated
timing/regression checks; final visual pace remains subject to user preference.

See `docs/Batch_0911_B02_Review.md` for B02's exact limits. Next planned B03 is
shared proposals, legal actions and real people/resource commitments: useful
goals acquire prerequisites, act legally, observe results and replan, without
double reservations. B02 prerequisites must be settled before B03 acceptance;
project queues remain B04. Current local checks use `Run-Local-Tests.ps1`.

## Historical B01 handoff

5 November 2026. Local-first restart from audited 0.910-reconstructed, repository main `8a9f3d6a9f9787bc11e8489f5426f9d3a650395c`. No repository push is authorized until Viktoras gives final signoff after downloading and playing.

Open `project.godot` in Godot **4.5.1 Standard**, then F5. The default scene is `b01.tscn`: the explicitly reduced **B01 fixture**, not the final opening. The retained historical three-faction game is `main.tscn` (open that scene and F6). Historical scene rules are not reconciled with the new design.

B01 has one Landing Station, one mobile ordinary Worker, and a 9×7 crop of the existing seed-731 map. Movement, panning, selection, End Turn, save/load and command recording are active. Economy, growth, projects, research, AI and fauna are inactive here. The full opening remains two civilians + Soldier + Explorer, introduced in later batches.

## Play review

1. Select a clear destination and compare its travel cost with a wooded or hilly hex.
2. Right-click to travel; Shift+right-click appends a waypoint. End Turn advances queued travel. Stop route explicitly cancels it.
3. Export during a partially paid rough-terrain step; advance, then import. Location, paid movement, route and camera should return.
4. Pan by middle/left drag or arrows; C centers the party; Tab selects it. Scale is fixed. Esc deselects. M orders travel to the inspected hex. Space ends one turn. Ctrl+S/L quick-save/load.
5. Toggle command recording to retain a concise reproducible trace in the save. Motion changes presentation only.

B01 saves use their own envelope and quicksave filename. Historical saves open through the historical scene. Invalid imports must preserve the current game. This does not promise arbitrary lost-original-0.910 save compatibility.

Read `docs/Batch_0911_B01_Review.md` for changes, evidence, performance and limits. Current design/batch/audit documents are in `docs/current_design/`. They supersede old S01/Q080 cursors and earlier sprite/zoom directions. Preserve historical reports and their provenance.

## Checks

- `godot --headless --path . --script tests/test_b01.gd`
- `godot --headless --path . --script tests/test_0901.gd`
- `godot --headless --path . --script tests/test_world.gd`
- `ALIEN_TEST_REPORT_DIR=res://reports/b01/reconstruction godot --headless --path . --script tests/test_reconstruction.gd`

The environment-variable prefix is shell syntax for Linux. For Windows set it before running the last command. It keeps fresh evidence separate from retained reconstruction evidence. Do not automatically run the long historical campaign.

## Next step

**Await user play review and final signoff; do not push automatically.** B01 is implemented for review, not user-accepted. B02 next requires settling the exact turn-accounting contract already flagged by the handoff. The proposed same-turn-input rule was not approved. Do not slip B02–B04 mechanics into this shell.
