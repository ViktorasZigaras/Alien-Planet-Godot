# Godot port validation

Engine: Godot 4.5.1 stable, Linux x86_64, Compatibility renderer.

- Editor import completed without script errors.
- Main scene starts headlessly and exits cleanly.
- `tests/test_rules.gd`: 239 checks, zero failures.
- All 44 reference command steps generated from the actual HTML engine match the entire Godot simulation state, excluding presentation log strings. This includes rejected commands, economy, training, construction, specialist output, supply changes, travel, joining, persistent identity and movement budgets.
- Each step validates invariants and JSON round trips, including projects in progress.
- Invalid save variants, duplicate jobs, unsupported versions, missing references, orphan project participants and food shortage recovery are checked.
- `tests/test_ui.gd`: 58 checks, zero failures. Instantiates the actual main scene, emits actual button/dropdown signals, plays the turn-10 construction walkthrough, mobilises and relocates the same Specialist, staffs Field Station, saves/loads via the native handlers, rejects a bad save without replacing state, resets, checks hex picking, wheel zoom and Fit Map.
- UI layout rectangles were checked at normal and minimum window sizes, accounting for Godot's canvas scaling. Overflow found during testing was fixed.

The UI tests are headless native integration tests, not a claim of manual mouse play on Windows. Desktop executable export requires matching export templates. No Windows executable is claimed as tested or included.

The original artwork remains unchanged and is loaded from numbered base64 text chunks, avoiding upload-size limits without a user-run asset assembly step.

## Local batch 0.2 — seven requested additions

- Resource icons, yield overlay and worked-tile ownership labels added. Terrain now uses the reference roster's hex artwork. Native scene import/start succeeds.
- Original reference tests: 239 checks pass after save-schema migration; no base-loop regression.
- New mechanics: 142 checks pass, including exact one-third movement, farm timing/output, coexistence, atomic rejection, queues/waypoints/cancellation, automatic continuation, population creation/upkeep/identity and old-save migration.
- Expanded native UI test: 90 checks pass, including resource texture loading, yield toggle, farm/road construction, growth and job assignment, native movement-queue signals, cancellation and expanded-state save/load.
- Total: 471 automated checks. User physical testing is still pending. Rendering is exercised headlessly; visual appearance has not been claimed manually verified in a desktop window.
- New saves use schema/rules version 4. Original version-1 saves are upgraded on import; the original HTML sandbox cannot read new Godot saves.
- Cloud working copy only. Nothing from this batch has been uploaded to GitHub.

## Local batch 0.3 — technology areas and transparent population sprites

- Added Biology, Industry, Military, Exploration / Research and Social, with exactly two technologies per area. Existing four technologies keep their tested operating behaviour; six new ones extend the roster.
- Added a larger Technology window with five labelled native tabs, two cards per area, actual costs/prerequisites/unlocks and completion state. Native sidebar buttons open their specific area.
- Added Farmer/Food, Engineer/Industry, Merchant/Credits, Scientist/Research and Administrator/Influence training paths, plus Security and the existing General Specialist. All roles retain identity and save support.
- Added Agriculture, Research, Civic and Security districts/workplaces alongside Production. Multiple district types can coexist; one of each type per town. Added Mine, Survey Beacon, Trade Post and Watchtower terrain work. Roads and Farms remain known starter improvements.
- Original rules tests: 239 checks pass; previous batch mechanics: 142 pass; previous native UI checks: 90 pass; new technology/content/sprite/native UI test: 507 pass. Total: 978 automated checks, zero failures.
- The new test trains specialists, constructs and staffs each district workplace, places and works each new terrain improvement, verifies missing-tech rejection and atomicity, checks new save roundtrips, checks all eight sprite regions and actual alpha, and drives the new native tabs and training/district selectors.
- Save version 5 migration preserves older Production Districts and projects in progress.
- Population sprite atlas was produced by the built-in image generator with transparent background enabled. The original PNG is copied unchanged into the project; per-role atlas rectangles select sprites without raster editing. It is static artwork, not an animation sheet.
- Physical desktop testing remains pending. No combat, opponent logic or economy balancing was introduced. This batch has not been uploaded to GitHub.

## Local 0.4 — 3D model lab

- Existing suites: 239 rules + 142 mechanics + 90 native UI + 507 technology checks passed.
- New model-lab suite: 131 checks passed. Total: **1,109**, zero failures.
- Real OpenGL compatibility rendering under Mesa software rendering produced both collages. Inspected the actual neutral comparison and walking lineup; corrected terrain face winding and reviewed framing, outfit references and shared pose.
- Reusable 13-bone Skeleton3D, rigid attachments, walk/stop reset, unchanged game state, shortcut isolation and hidden-preview suspension checked.
- No gameplay 3D conversion, foot IK, advanced prop poses or physical Windows testing claimed. No new executable or GitHub upload.

## Local 0.4.1 — chamfered detail pass

- 165 model-lab checks pass, including unchanged 13 bones, the unchanged bare rig, and 2–3× geometric-piece budgets for all eight outfits.
- All 978 prior rules/mechanics/native-UI/technology checks pass again: **1,143 total**, zero failures.
- Actual OpenGL neutral/walking collages regenerated and inspected. First-pass collages preserved separately. No terrain-animation or crowd-performance claim.

## Version 0.5 — terrain atmosphere

- Model/terrain lab: 245 checks pass, including motion/detail switches, bounded sprite counts, unchanged simulation and hidden-preview activity.
- Prior rules/mechanics/UI/technology suites: 978 checks pass again; **1,223 total**, zero failures.
- Actual OpenGL compatibility renders exercise both shaders and native procedural textures. Six-tile and joined-landscape views reviewed; a short animation preview is captured from the same assets.
- No economy/save changes, strategy-map 3D conversion, executable export or hardware performance benchmark.
