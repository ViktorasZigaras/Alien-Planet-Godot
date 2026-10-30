> Historical 0.8 guide. The current approved medium frontier treatment is in [Visual Style 0.9](Visual_Style_09.md).

# Alien Planet visual direction — version 0.8

Viktoras selected **A / Symbolic for the sprite view** and **B / Balanced for 3D**, from the preceding Hybrid Studies concept board. These are practical adaptations to the existing small Godot shell, not a promise to reproduce a generated painting pixel for pixel. This document is the continuing visual-change guide. The concept experiment and this implementation are recorded in the main development log.

## What changed

The sprite map replaces the old reference-image ground crops with original, baked, limited-palette terrain textures: rust-red plains, olive biological ground, ochre desert, grey cold ground, violet fungal land and deep teal water. Ground patches use coarse deterministic grain and hard colour steps. Object sprites are freshly baked from the current models, with restrained dark silhouettes, stepped colour and genuine transparency. Only selected/hovered tile coordinates remain visible by default; the default supply overlay is Off, and yields remain optional. The opening camera includes both starter settlements more comfortably.

The 3D map uses related, slightly softer terrain colours, world-space ground patches/fine grain, rough industrial materials, angular hills in place of little flat-topped cylinders, layered dark-green tree crowns, warm directional light/cool ambient fill and subtle water highlights. It retains an orthographic camera, compact separate district platforms and the existing thirteen-bone people/five-bone Rover. Buildings have pale neutral bodies, dark plinths/windows, and small functional colour strips. Settlement clusters gain a taller habitation spine, so their silhouette differs from a workplace or district.

Neither view changes terrain yields, bonus distribution, population, economy, technologies, queues, equipment, save schema or tile picking. The initial state has the same two settlements, people and equipment as 0.7; preview screenshots do not add developed infrastructure to make it appear busier. Later development will fill the map through play.

## Shared visual language

- **Alien ground, recognisable infrastructure.** Rust, olive and purple belong to the environment. Pale silver/cream industrial walls and dark blue-grey structure belong to human construction. Avoid making all undeveloped land generic green.
- **Identify by silhouette first.** A settlement has a focal habitat tower and low modules; research has a dome/antenna; industry has stacks/machinery; power has tanks/panels; a Clinic has a clear cross. New objects need a recognisable shape at ordinary opening zoom, not just a different colour.
- **Use colour economically.** Production: ochre; agriculture: leaf green; research: cyan; civic: plum; security: slate. Reserve bright cream/gold for selection and important focal objects. Keep profession clothes/props distinct from background ground.
- **Keep functional layers separate.** Ground → road/site improvement → small district platform → individual building → visible person/vehicle. Resource props remain at one side, exposed. Do not replace a whole hex with an opaque city illustration or hide a deposit behind a district plate.
- **Treat scale as symbolic.** Figures, vehicle silhouettes and distinctive buildings may be enlarged for legibility. Preserve exposed ground between them. Large settlement markers do not justify filling every district with a dense skyline.
- **Keep information optional.** Names of towns/worked tiles and selection feedback remain useful. Yield/supply overlays are player choices. Avoid permanent large resource pins, labels on every empty tile, bloom or haze that washes out job/resource distinctions.

## A — sprite view

| Property | Direction |
| --- | --- |
| Ground | Coarse patches, hard palette steps, obvious biome contrast |
| Objects | Transparent 80×80 source cells, nearest-neighbour display, thin dark contour |
| Lighting | Baked, stable, with a clear light/dark side; no continuous atmosphere overlay |
| Grid | Thin dark warm boundaries; brighter outlines only for selection/work/supply feedback |
| Readability | A small handful of strong shapes per object; workers/vehicles clearly separate |

Source palettes are `SPRITE_TERRAIN` and `GROUND_COVER` in `scripts/visual_style.gd`. Plains use `#ad513d`, water `#155367`, forest foliage a dark green, desert `#c39b57` and fungal terrain `#8f599c`. Exact colours can evolve together after visual testing; do not locally invent another unrelated palette in a new rendering function.

Ground generation produces six terrain families × four deterministic variants into `assets/world/symbolic_ground.png`. The bake happens during development, so normal game startup loads images instead of calculating noise pixel by pixel. The existing per-tile background selection is purely cosmetic; it does not call or reseed game RNG.

## B — 3D view

| Property | Direction |
| --- | --- |
| Ground | Broader, softly blended world-space patches with restrained grain |
| Models | Medium geometric complexity, chamfered industrial forms, faceted rock/trees |
| Lighting | Warm key light, cool soft ambient; no mandatory dynamic shadows/MSAA |
| Water/vegetation | Gentle shader highlights/sway, with the existing Motion comparison switch |
| Readability | Same silhouettes, accent colours, relative placement and exposed deposits as A |

`WORLD_TERRAIN` in `scripts/visual_style.gd` is the companion palette, not a separate art universe. Ground texture is controlled by `world_ground.gdshader`; shallow normal variation gives material relief without moving the actual ground, units or picking plane. The actual height cues come from hill/tree/building geometry. This intentionally remains cheaper and simpler than a fully displaced landscape with collision/shoreline reconstruction.

The new ground materials reuse the same procedural noise resource. Static meshes still use shared geometry/materials and explicit MultiMesh batches. There are no per-tile animated scripts/particle systems in the live world. Keep people/wheels animated during travel rather than starting an idle crowd gait. Hidden views must stop rendering and processing. Do not silently add expensive shadows, transparent layers or a light on every building while extending the style.

## Procedure for future visual changes

1. Read this guide and inspect the actual A/B opening screenshots, alongside the concept board. Treat the concepts as direction and the captured game as the current implementation.
2. Edit shared palette/material/model definitions first: `visual_style.gd`, `world_assets.gd`, `population_rig.gd`, `rover_rig.gd`. Keep game rules independent of appearance.
3. For a new role, equipment combination, building, improvement or deposit, add its model and catalogue entry. Check its silhouette, exposed ground, neighbouring deposits and occupant placement in 3D.
4. Re-bake with `tests/bake_pixel_assets.gd` under a real renderer. It regenerates the matching sprite atlas and ground atlas. Do not replace actual model output with generated concept art or leave a needed sprite blank. Do not make users run the baker.
5. Re-import assets in Godot. Inspect both views at opening zoom, with overlays on/off, and inspect a populated district example. Check the catalogue and all current sprite regions.
6. Run the relevant current checks. Use `tests/capture_opening.gd` for reproducible actual opening screenshots: it verifies that capture leaves the default simulation state unchanged. Name any staged test fixtures explicitly.
7. Update the high-level development log with the request, visual choices, checks and upload status. Keep the guide current if the user changes the approved direction. Upload only when requested.

## Limits

This is a first implementation of the chosen directions, with simple geometric placeholders. It does not contain the full richness, terrain relief or object detail suggested by the generated concept board. A and B deliberately share geometry, meanings and placement; they differ in surface treatment, rendering and edge/lighting language. No change to the original HTML prototype or gameplay balancing is part of this pass.
