# Alien Planet 0.911 — B01 review copy

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
