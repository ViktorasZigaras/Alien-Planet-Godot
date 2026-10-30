> Updated by [0.901 visibility and transport notes](Batch_0901_Notes.md): ground-first rendering, tight sprite bounds, shared map orientation, separate model configurations and schema 8.

# Illustrated frontier — medium treatment, version 0.9

This supersedes the 0.8 Symbolic/Balanced treatment. Viktoras approved the medium-detail Colonization-inspired studies and their game-screen paintovers for implementation in both views. Those images are visual references, not tile-accurate game states or a promise of identical illustration quality.

## What the game now uses

- **Ground:** subdued rust/umber plains, dusty olive vegetation, ochre desert, cool tundra, muted fungal plum and teal water. A generated, neutral painted soil/groundcover texture supplies restrained material detail; colours remain shared code-defined values. Broad colour patches are deliberately low-contrast so figures and deposits carry attention.
- **Elevation:** hills are broad rounded surface meshes, about 0.68 world units at their crest, tapering to level boundaries. The exposed shoulders have pale, irregular stone accents and grassier crests. They are no longer separate brown rock props. Flat tiles retain simple geometry. Five terrain-coloured hill sprites use the same surface, without a dark cutout contour.
- **Forest:** five small, overlapping, layered-crown trees per forest hex; tree bases follow hill elevation. Fungal forests have plum foliage. Forest remains a feature over underlying terrain, mechanically unchanged.
- **Resources:** Food is a leafy fruiting plant; Minerals a slate outcrop with bronze seams; Energy a warm vent with simple moving vapour forms; Science cyan crystal-like specimens; Culture a marked violet monolith. Larger side deposits remain separate from districts, workplaces and figures. UI resource pictograms are tightly cropped from these same models; Industry retains its existing factory icon.
- **People:** lighter cream-mixed work clothing, coloured profession panels, simple field helmets/visors, rounder heads and limb volumes, existing tools/backpacks and equipment. The thirteen-bone skeleton/gait and five-bone rover remain reusable. Figures are slightly larger; suits still surround a person, and rovers remain the main object when equipped.
- **Coast/light:** restrained pale shoreline edges and subtle water highlights, with stronger separation between directional light and ambient fill. No new shadow, particle or postprocessing system.

The sprite view is labelled **Sprite / illustrated**, and the 3D view **3D / frontier**. Both retain their existing cameras, controls and interface structure. The initial scene has no fabricated farms or extra workers to resemble the concepts.

## Surface correctness

`WorldAssets.height_at` is a presentation-only height function. The same function creates mesh vertices and places trees, deposits, structures and people. Roads use short surface-sampled segments rather than running underground. Travelling figures sample the surface between route centres and finish at the authoritative destination placement. 3D picking intersects actual terrain triangles rather than a flat ground plane; selection, yields and labels remain presentation layers. Clicking/hovering continues to select a hex, not an individual tree or building mesh.

The hill surface is intentionally a compact per-hex hummock with flat shared borders, not erosion-generated regional mountain ranges. Large building platforms sit level at their sampled position and are stylised foundations rather than excavated terrain. River edges remain at shared low boundaries. These are deliberate prototype limits.

## How to extend it later

1. Keep ground subdued; reserve strong value/colour contrast for useful landmarks, pale construction and people. Do not restore the old high-contrast camouflage.
2. Model silhouette and primary material regions before small details. Keep exposed ground around a district/building, a side resource and a front figure. Sample relief for any new world placement.
3. Add models to the shared catalogue. It now has **118** entries, including five terrain-specific hill overlays. Terrain and resource identity come from game state; the art must never reseed generation or change yields.
4. Re-bake `tests/bake_pixel_assets.gd` with an actual renderer after model/material changes. It produces the shipped 80px transparent sprite atlas and 24 ground variants; users do not need to bake anything. Sprite contouring is selective: object silhouettes get it, hill decals do not.
5. Crop pictorial UI icons to their painted content; an 80px cell often contains camera padding. Keep nearest sampling for the sprite view. Do not enlarge all UI controls to compensate for padded icons.
6. Capture the actual default scene with `tests/capture_opening.gd`, which asserts unchanged simulation. Label any developed fixtures as staged. Compare at ordinary game zoom, not only enlarged catalogue close-ups.
7. Run the six current suites, including `tests/test_frontier.gd` for relief, projected clicks, uphill movement, sloped roads and icon bounds. Record high-level changes in the continuing development log and upload only on request.

Static meshes/materials remain shared and batched; hidden view/model-lab suspension and Motion controls remain. Extra hill triangles and canopy geometry can cost rendering time; this is not a claim of equal performance on physical hardware. No automatic LOD/streaming framework was added.

## Art provenance / reproduction

`assets/world/frontier_ground.png` is a 384×384 developer-resampled version of an original built-in imagegen texture. Godot resamples it once during asset preparation; runtime loads the imported texture normally. Generated from this prompt:

> Use case: stylized-concept. Production texture asset for a painted sci-fi strategy game terrain material. A single perfectly top-down orthographic square, seamless tileable hand-painted earth-and-low-groundcover texture. No scene, no objects, no perspective, no hexagons, no grid, no words. Neutral greyscale (warm greys allowed), medium-low contrast with dominant middle grey. Broad soft areas of compacted soil alternating with very sparse small moss/grass brush clusters, a few tiny mineral grains, fine deliberate painterly marks. Quiet gameplay background, not a busy camouflage or photoreal photo. No large cracks, no big rocks, no shadows of trees. Continuous evenly lit surface with no directional light or vignette. Designed to be tinted burnt-sienna, olive, tundra-grey or plum by game shader; greyscale detail only. Medium detail illustrated frontier art, classic painted strategy terrain elegance. Texture must have uniform scale and density all across edges and centre.

The rest of this pass's world objects are code-native geometry and renderer-baked matching sprites. No paintover screenshot is used as a live map background. This is an implemented geometric interpretation of medium detail, not hand-painted versions of every model or a pixel-for-pixel reproduction of the generated mockups. Gameplay, map seed, economy, save schema 7 and original HTML prototype remain unchanged.
