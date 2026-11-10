# 3D model lab — local 0.4

Open **3D Model lab** in the game toolbar. Tabs show Terrain hexes, Population rigs and a Comparison collage. Back to game restores the strategy screen. No simulation commands or save-format changes are involved.

The terrain studies cover Plains, Forest, Hills, Water and proposed Desert/Fungal variants. All share one hex footprint. Faceted surfaces, broad vegetation/rock forms and limited palettes are intended for comparison; they do not replace the playable 2D map yet.

## Reusable assets

- `assets/models/population_rig.tscn`: reusable Node3D scene; set `role` before adding it to the tree.
- `scripts/population_rig.gd`: a real Skeleton3D with 13 bones and rigid BoneAttachment3D pieces. Call `walk()` for the shared in-place gait and `stop()` for the neutral stance; `gait_speed` controls pace. Local +Y is up, +Z faces forward. No navigation, IK, skin weights, fingers or facial animation.
- `scripts/terrain_study.gd`: set `kind` before adding to the tree. Kinds are Plains, Forest, Hills, Water, Desert and Fungal.
- `scripts/model_parts.gd`: small shared primitive helpers; no external modelling package or runtime downloads.

The skeleton is pelvis, spine, head, two upper arms, two forearms, two thighs, two shins and two feet. The same rest hierarchy and gait serve Worker, Farmer, Engineer, Merchant, Scientist, Administrator, Security and general Specialist. Clothes, hats, packs, tablets and tools follow bone attachments. Outfit colours and silhouettes reference the existing transparent sprite atlas displayed beside each model. These are geometric interpretations, not faithful finished sculptures.

Each visible card has its own orthographic SubViewport, neutral stage and consistent lighting. Hidden pages and the closed lab stop rendering/processing their previews. Walk/Stop control all variants, with only visible previews advancing. Movement is in place; the rig does not move gameplay population.

## Review artifacts and checks

`tests/capture_model_lab.gd` renders the actual comparison and walking lineup into ignored `builds/model-lab/`. It needs a graphical display/OpenGL renderer; headless dummy rendering cannot produce these images. The saved collages are actual Godot output, not image-generator mockups. No manual paint-over is applied.

`tests/test_model_lab.gd` checks toolbar entry, 13-bone hierarchy across outfits, walk articulation, Stop/reset, unchanged game state, shortcut isolation, preview activity and reusing the screen. The previous rules/technology/native UI suites remain applicable.

Known limits: primitive geometry, rigid coat panels, simple in-place gait with no foot IK or prop-specific arm poses, no seamless terrain adjacency authoring, no strategy-map integration and no native desktop physical play test. This is a visual/mechanical asset playground.

## References for future decisions

Use these discussion references when changing systems; their proposals remain options, not automatic implementation instructions:

- [Technology Areas and Ideas](https://chatgpt.com/library?file_id=libfile_1d9d1e05901881918a854fe4ee611f41&account_id=personal)
- [Beyond Earth Reference and Professions](https://chatgpt.com/library?file_id=libfile_b581ed0029988191863cd98d78d9c64b&account_id=personal)
- [SMAC Reference](https://chatgpt.com/library?file_id=libfile_ca3babdd20a88191bd90facc93b0aeb0&account_id=personal)

Upload status: local cloud work only. Last uploaded GitHub source remains `f9369a5`.

## Local 0.4.1 — second population pass

Preserved the 13-bone hierarchy, rig-only display and gait. Replaced the outfit box solids with faceted chamfered forms and added 40 readable wardrobe/face/boot pieces per person. Geometric piece counts (MeshInstance3D, not triangle counts): Worker 26→66; Farmer 28→68; Engineer 25→65; Merchant 26→66; Scientist 27→67; Administrator 26→66; Security 25→65; Specialist 28→68. Each is between two and three times its first-pass count. No extra finger/face bones.

This is intentionally a detail pass, not an optimisation pass. More pieces and chamfer faces increase rendering work; game-map crowd performance has not been profiled. Same rigid attachments, in-place gait and coat/prop limitations apply.

### Terrain advice — proposed, not implemented

Start with broad ground-colour patches and a small shared texture atlas, stable per-hex tint/rotation variation, a few grass/rock/lichen clusters and consistent soft lighting. Add one restrained vertex-sway effect for vegetation and a moving texture/highlight effect for water. Use sparse sprite particles for spores, insects or dust at selected sites. Avoid a separate particle emitter, animated light and full skeleton on every tile. Keep all effects decorative so game rules and worked-tile markers remain readable.

Textures and sparse motion complement geometry: textures supply surface character; silhouettes supply readable terrain type; movement supplies life. Cheapest-looking visual noise is not the goal. Relative cost is a design estimate, not a hardware benchmark. Godot references: https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_first_3d_shader.html and https://docs.godotengine.org/en/latest/tutorials/performance/using_multimesh.html .

## Version 0.5 — living terrain evaluation

Terrain studies now use a shared 128×128 native NoiseTexture2D for broad surface patches and fine grain, subtle deterministic tint variation, small shader-based foliage motion and moving water colour/highlight patterns. Sparse radial Sprite3D motes provide dust/insect/spore suggestions (0–7 per tile, no additional animated lights). Static rocks stay still. Motion and surface/sprite switches allow visual comparison; paused motion freezes its current time. Closing the lab or selecting another tab suspends the invisible controllers and viewports.

A fourth **Terrain landscape** tab joins seven hexes, using existing study assets and stable variation indices. This tests appearance in context, not gameplay map replacement. Tiles do not yet blend biome boundaries; flat hex surfaces and simple material ripples remain deliberate test art. No physical water, environmental simulation or performance benchmark is claimed.

New source: `scripts/terrain_atmosphere.gd`, `assets/shaders/terrain_surface.gdshader` and `terrain_foliage.gdshader`. `tests/capture_terrain_atmosphere.gd` produces actual rendered terrain stills and animation frames under a real OpenGL display. Capture output is excluded from desktop exports. The upload request for 0.5 includes all pending 0.4/0.4.1 work.
