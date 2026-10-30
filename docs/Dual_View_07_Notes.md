# Version 0.7 — two views, shared world and readable assets

The view selector flips between the original top-down pixel terrain and a native, orthographic isometric 3D world. Both use the same rules, selections and right-click/Shift queue controls. View changes, camera movement and motion settings have no economic effects. Click/drag separation, wheel zoom and Fit map work in both. Saves add only visual facing, movement trace and monotonic last-use metadata (schema 7), with versions 1–6 migrated.

## Shared assets and placement

`world_assets.gd` defines the world geometry; `asset_catalogue.gd` lists all **113** variants. Native developer baking renders these models to transparent 80×80 sprite cells with nearest-neighbour sampling. `assets/world/pixel_world.png` and `data/world_sprites.json` are already included: opening the project does not generate them or need network access. The pixel view retains the earlier reference-derived terrain art and uses the new overlays/objects. This is a starter art direction built from low-resolution model renders, not a hand-drawn final tileset.

The catalogue includes all eleven professions, each bare/suited/reinforced and unarmed/armed, a Rover, the eleven current workplace types in two visual tiers (including starter service buildings), all nine improvements, five district platforms, six deposits, two settlements and independent hill/forest overlays. A few tier variants in the visual catalogue are studies beyond the currently purchasable upgrades; this adds no gameplay unlock. Roles have distinct palettes and props, including Medic cross/bag, Extractor helmet/drill, Explorer pack/antenna and Artist palette/brush. All people retain the same thirteen bones. Exoskeleton rails are attached around the existing limbs and torso; the human body/head/clothing remain inside them.

District platforms occupy about 57% of the hex radius, with compact individual buildings toward the back. Deposits occupy a separate side position; the visible person stands toward the front. Settlement clusters and improvements leave ground readable. Water/foliage use shared shader motion; there are no per-hex particle emitters or script clocks in the live map. River lines remain edge geometry.

`rover_rig.gd` is a reusable five-bone Skeleton3D: body plus four wheel axles. Wheels rotate only while visually travelling. The cabin contains a small driver silhouette; the Rover is the main object. Rover transport visually takes precedence over suits/arms, while all equipment remains on the same person. This version has no suspension, steering articulation, vehicle physics or passenger manifest.

## Units and animation

All people can occupy their logical tile, including building workers and deployed people. In 3D only the most recently selected/ordered/moved person is rendered per occupied tile. Initial ties resolve in persistent iteration order. Selecting a hidden stack member in the resident/mobile controls reveals that member without changing assignments. The resident and mobile lists retain every person. Pixel mode can show mobile markers and the top resident figure separately.

Movement events retain the actual crossed steps and final direction. The 3D view interpolates those steps, turns toward each segment and plays the common gait or wheel rotation. The final facing survives saving. Partial-step travel remains on the origin until paid, as in 0.6. Animation is cosmetic; it does not delay simulation commands. If orders are issued faster than the display animation finishes, the newest authoritative state takes precedence. Motion off snaps active travel to its authoritative destination and stops limb/wheel processing; terrain returns to a static shader pose.

Only one live-map viewport renders at a time. The hidden world stops rendering/actor processing, including while the model lab covers it. Repeated static terrain/props/structures use shared cached geometry/materials and explicit MultiMesh batches. No large-world streaming, model LOD system, skeletal skinning or performance framework was added.

## Why the earlier showcase could pause

The previous lab synchronously built all four pages, 18 thirteen-bone figures and 19 terrain studies across **31 separate viewports**, including hidden pages. Many small meshes/materials were created individually. Opening it could therefore block the main thread, followed by first-use shader/driver work. Rendering six, nine or fifteen separate views with lights/shadows/MSAA could also cause sustained slow frames. These are explanations from the source and this test environment; the exact reason on the user's PC is not diagnosed remotely.

The new lab spreads card creation over frames and reuses primitive meshes/materials. Study shadows and MSAA are disabled, hidden pages remain inactive, reopening reuses the prepared lab, and the new asset catalogue uses one viewport. It still has the earlier multi-view comparison pages, so those are intentionally more expensive than the single-world view. First preparation still takes time; it no longer has to be one uninterrupted construction call. First-use shader pauses may still occur, especially with the Compatibility renderer used by this project.

## Illustrative measurements and practical animation budget

Godot 4.5.1, OpenGL Compatibility, Mesa **llvmpipe software rendering**, Xvfb, 1440×900; single illustrative runs, 45 frame intervals per sample after a short warmup. These are not Windows play tests or predictions for a physical GPU. Shared-cloud load and driver caches affect timings. Full results and the script are included for repeatability.

| Measurement | Old 0.6 lab | New 0.7 lab |
| --- | ---: | ---: |
| Synchronous opening call | 203 ms | 9 ms |
| Complete preparation | 203 ms, one blocked call | 1,374 ms, spread over frames |
| Terrain page median frame | 95 ms | 37 ms |
| Walking population page median frame | 192 ms | 59 ms |
| Walking collage page median frame | 231 ms | 57 ms |
| Reopen call | 1.2 ms | 0.7 ms |

The new 384-hex world prepared across frames in about 200 ms in that run. Default view: three rendered figures, 192 draw calls, median **20.5 ms/frame**. A stress fixture with 21 visible detailed figures had 1,688 draw calls and **46.6 ms/frame** with everyone walking. Stopping the figures yielded 44.2 ms; switching all motion off yielded 42.6 ms. This suggests that in this fixture most extra cost came from rendering the additional rigid parts, with animation adding further work. It is not proof of the same cost split on another GPU.

There is no universal number of animations Godot tolerates. At 60 FPS the entire frame has 16.7 ms; at 30 FPS, 33.3 ms. Resolution, draw calls, shadows, transparency, animated geometry and CPU scene work all matter. For this shell, start with shader wind/water, walking only during travel, rotating wheels only when moving, no idle crowd gait and one visible unit per stack. Compare Motion on/off and the footer metrics on the actual test PC. If crowds become the bottleneck, first try fewer visible detailed figures, lower viewport resolution or simpler/merged body parts before adding many more animated people; distant-model LOD can follow later if needed. Shader vegetation across many hexes is a different workload from many separately articulated figures.

Official references: [Godot 4.5 3D performance](https://docs.godotengine.org/en/4.5/tutorials/performance/optimizing_3d_performance.html), [pipeline compilation and renderer limitations](https://docs.godotengine.org/en/4.5/tutorials/performance/pipeline_compilations.html), [jitter and stutter](https://docs.godotengine.org/en/4.5/tutorials/rendering/jitter_stutter.html). Automatic instancing and shader-baker advice for Forward+/Mobile must not be assumed to apply to Compatibility; this project uses explicit MultiMesh and includes no shader-baker promise.
