# Alien Planet — Godot 0.9

Open `project.godot` in **Godot 4.5.1 Standard** and press **F5**. Choose **Sprite / illustrated** or **3D / frontier** above the map. This release implements the approved medium frontier direction with quieter painted ground, rounded raised hills, layered foliage, larger physical resources, lighter field outfits and matching pictorial UI icons.

The current guide is [Visual Style 0.9](docs/Visual_Style_09.md). It explains the art, how to extend it, the generated ground texture and shared model/sprite bake. The implementation is a geometric adaptation of the concept paintovers, not a promise of identical hand-painted detail. The actual opening screenshots show its present appearance.

**1,106 current checks pass:** 421 simulation, 22 UI, 247 model lab, 322 world/art, 55 style and 39 frontier checks. New checks cover raised-surface picking, uphill travel, road ribbons, hill sprites and tightly cropped icons. Actual 1440×900 OpenGL captures preserve the unchanged default simulation.

Gameplay and schema 7 saves remain unchanged. No standalone executable or physical Windows play test is claimed; this upload is the ready-to-open Godot source project. Hills have real relief; structures, deposits, trees and travelling figures sample their surface. Motion and hidden-view suspension remain available. Physical performance testing remains pending.

---

Earlier release notes follow.

# Historical version 0.8

Open `project.godot` in Godot 4.5.1 Standard and press F5. Choose **Sprite A / symbolic** or **3D B / balanced** above the map. Version 0.8 applies the selected Hybrid Studies directions to the actual game: rust/olive/violet terrain, teal water, pale industrial buildings, strong sprite contours and softer 3D materials/lighting.

The continuing style contract and future change procedure are in [Visual Style 0.8](docs/Visual_Style_08.md). It explains palette, silhouettes, layer placement, object scale, sprite baking, animation limits and real screenshot capture. The gameplay and save format remain those of 0.7. The default supply overlay is Off; yields remain optional. Opening camera centring now survives initial layout resizing.

**1,058 current checks pass**: 421 simulation, 22 UI, 247 model-lab, 313 world/art and 55 visual-style checks. Run `tests/test_visual_style.gd` alongside the four existing suites. Actual opening scenes in both directions were captured and reviewed with `tests/capture_opening.gd`; capture verifies unchanged default game state. No physical Windows test or standalone executable is claimed.

---

Earlier release notes follow.

# Alien Planet — Godot 0.7

Open `project.godot` in Godot 4.5.1 Standard, press F5, then choose **Pixel / top-down** or **3D / isometric** above the map. Both views control the same simulation. Click inspects; left/middle drag pans; wheel zooms; right-click moves/replaces the route, Shift appends. Use **Motion** to compare animated/static 3D. Its footer shows FPS, draw calls and visible figures.

The 3D view has animated water/foliage, interpolated walking/rolling travel, saved last-movement facing and one rendered person per occupied hex (the most recently selected/used). Rover equipment displays the vehicle; work suits surround the actual 13-bone person. District platforms are smaller than a tile, buildings stand individually on them, deposits remain visible at one side and people stand toward the front.

**3D Model lab → World asset catalogue** inspects all 113 sprite/model variants using a single preview viewport. Eleven distinct professions, work/reinforced suits, arms, a five-joint Rover, all current workplaces, districts, improvements, settlements and deposits have matching low-resolution transparent sprites and reusable models. Sprite baking is a development script, not a user setup step. Pixel terrain retains the original starter-reference art.

This source release also includes the previously local **0.6 economy/biome/equipment/technology batch**. New saves use schema 7; versions 1–6 migrate. No standalone executable is included; physical hardware play testing remains for the user. Read [Dual-view and performance notes](docs/Dual_View_07_Notes.md) and [Economy batch notes](docs/Batch_06_Notes.md) for provisional choices and limitations.

Current checks: `tests/test_batch.gd`, `tests/test_batch_ui.gd`, `tests/test_model_lab.gd`, `tests/test_world.gd` (1,001 checks in total). Run with `godot --headless --path . --script tests/<name>.gd` after editor import. Actual renders and illustrative before/after software-renderer timings were also reviewed.

---

Earlier version notes follow; their upload status and rules describe those earlier stages.

# Alien Planet — Godot 0.6 (local working version)

Open `project.godot` in Godot 4.5.1 Standard and press F5. This batch adds a 24×16 biome test map, click-and-drag panning, six-resource economy, automatic town growth and medical care, eleven professions, combinable equipment, powered workplaces with tier 1–2 slots, twenty technologies and revised movement queues. All values are provisional.

Start at Main Base: select a person, choose a job, equip a Work Suit to become a builder, or use the Expedition Driver to explore. **Technology** shows the five research areas and their requirements. **Fit map** shows the whole world; wheel zooms and left drag pans. **Yields** shows potential/worked output. Resident controls include equipment and Clear specialty. Buildings and tools spend secondary Industry; a Workshop converts Minerals into more Industry. Read [Batch 0.6 notes](docs/Batch_06_Notes.md) for exact prototype choices and limits.

The existing **3D Model lab** is unchanged and remains an isolated asset study. Soldier combat capability values are previews; opponents/combat resolution are still future work. New profession portraits temporarily reuse existing sprites. Saves use schema 6 and migrate versions 1–5.

**Not uploaded.** GitHub still contains the previously authorised version 0.5. No standalone executable is included. The original HTML prototype is unchanged.

Current checks (after editor import):

```sh
godot --headless --path . --script tests/test_batch.gd
godot --headless --path . --script tests/test_batch_ui.gd
godot --headless --path . --script tests/test_model_lab.gd
```

---

The following sections describe earlier versions, with the rules and upload status they had at the time. Version 0.6 replaces their economy, roster, map and movement specifications.

## Version 0.5 — living terrain visual evaluation

Run `project.godot` with Godot 4.5.1 Standard and press F5. Open **3D Model lab** in the toolbar:

- **Terrain hexes**: six textured studies with vegetation sway, moving water highlights and sparse ambient sprites.
- **Terrain landscape**: seven joined hexes with stable colour/prop variation.
- Toggle **Wind / water / ambient motion** to pause; toggle **Surface texture / ambient sprites** for a simpler surface comparison.
- **Population rigs**: the 13-bone reusable walking rig and eight refined outfits from the preceding batches.

This source release includes the previously local 0.4 and 0.4.1 model work. The strategy map stays 2D; these are isolated visual studies with no economy or save changes. Procedural textures use native Godot resources and require no network access.

The sections below record earlier development stages and their status at that time.

## Local 0.4.1 — refined population shapes

Same 13-bone rig; each outfit now has 65–68 chamfered geometric pieces instead of 25–28 boxes. Open **3D Model lab** for the updated models and shared Walk/Stop. Terrain animation ideas remain discussion only.

## Local 0.4 — 3D model lab

Open **3D Model lab** from the toolbar. Compare six terrain studies, a 13-bone skeleton and eight sprite-inspired geometric outfits. Walk/Stop, view-angle and gait-speed controls share the reusable rig. The playable strategy map remains 2D. See [Model Lab Notes](docs/Model_Lab_Notes.md) for asset reuse and limits.

This 0.4 stage was initially local; it is included in the 0.5 source release.

# Alien Planet — Godot

A development branch of the small settlement sandbox in [Alien-Planet](https://github.com/ViktorasZigaras/Alien-Planet), implemented in native GDScript and Godot Controls. It is an experimental game shell, with provisional rules and a more convenient interface. Version 0.5 includes the gameplay, technology and model-study batches described below. No balancing or opponent strategy was added.

## Run

1. Download this repository (Code → Download ZIP) and extract it.
2. Open **Godot 4.5.1 Standard** (GDScript; no .NET required).
3. Choose **Import**, select `project.godot`, then open the project.
4. Press **F5** to play.

There is no Python, Node.js, asset assembly step, plugin or package installation. The starter artwork loads from the included text chunks automatically. No runtime network access is needed. A native executable is not included; the project is ready to open in Godot.

Get the editor from [Godot's official download page](https://godotengine.org/download/). The project was tested using 4.5.1; later 4.x versions may also work.

## Technology batch (local 0.3)

Use the **Technology** toolbar button for a larger view with five area tabs: Biology, Industry, Military, Exploration / Research and Social. Each has two starter technologies. Cards show actual costs, prerequisites, unlocks and completion.

There are five district/workplace pairs: Production/Workshop, Agriculture/Greenhouse, Research/Research Lab, Civic/Exchange and Security/Guard Post. New worked improvements are Mine, Survey Beacon, Trade Post and Watchtower; Roads and Farms remain known starting improvements.

Train a Farmer for Food, Engineer for Industry, Merchant for Credits, Scientist for Research, or Administrator for Influence. Security training demonstrates the military branch without adding combat. General Specialist remains for existing saves. Training requires Technical Education and the role's capability; all training still costs 4 Credits / two turns at Main Base.

All eight population roles now have transparent sprites, used on the map and in the UI. Their generated atlas is `assets/population/population_roles_v1.png`.

See [Technology demo notes](docs/Technology_Demo_Notes.md) for the small content roster and provisional operating rules. Deeper economy and balance are deliberately deferred.

## Previous local batch (0.2)

1. Pictorial resource icons: grain, minerals, coins, flask and influence standard.
2. Toggle **Yields** for potential tile output per assigned cohort. An unworked tile produces nothing.
3. Worked tiles have a cyan/purple outline and their cohort's name; inspection also names the worker and town.
4. Build **Roads** and **Farms** using an idle resident Worker, the shared construction slot, 1 Industry and one End Turn. No development unlock is required for these provisional improvements. Roads can be placed on passable local land, including towns. Farms need clear flat plains outside towns/districts and may improve a tile someone else is already working. A road and farm can coexist. Roads cost exactly one third movement to enter and also lower supply-path cost. A worked farm adds exactly 1 Food; it has no passive output. No demolition is implemented.
5. Movement queues follow paths across turns. Right-click queues and uses the current movement allowance; End Turn refreshes it and continues the route. Shift+right-click or **Append destination** adds a waypoint. **Cancel movement queue** stops it. No teleporting, automatic joining, movement refresh by queueing, or travelling outside supply. A route through terrain too costly for a unit's full turn is rejected; roads make such land traversable.
6. Plains, forest, hills and water use terrain art from the existing generated roster, mapped to the actual hex polygons.
7. **Grow population** is an inhabited-town action: spend 20 pooled Food for one new idle Worker immediately. It receives a unique persistent ID and adds 1 Food upkeep per turn. It can work, train, build and mobilise like the starting cohorts. There is no automatic growth or extra cooldown.

All improvement costs and growth cost are provisional settings in `data/preset.json`.

## Controls and UI changes

- Resource stocks, forecasts and End Turn stay at the top.
- **Orders**, **Development** and **Report** are independent scrolling tabs; the map stays visible.
- Left-click a hex to inspect it. Select a mobile unit in the strip below the map.
- Right-click a destination to queue the selected unit’s route. Shift+right-click appends a destination. **Move here** still makes an immediate move if the allowance is sufficient.
- Mouse wheel zooms around the cursor. Middle-drag pans. **Fit map** resets the view.
- At a settlement, select a cohort. Change its job in the dropdown; its other orders appear below.
- A selected Worker remains selected while you choose a construction hex. Set it to **Idle**, then build.
- Mobilising automatically selects that same cohort on the map.
- Empty facilities show **unstaffed**. Invalid orders have reasons in their tooltips; movement also shows the reason in the panel.
- **Space** ends a turn (outside a text field, dropdown or dialog).
- **Ctrl+S** quick-saves, **Ctrl+L** quick-loads. These use Godot's local `user://` data folder.
- **Export save…** / **Import save…** use native file dialogs. Saves now use schema/rules version 5. Original HTML/Godot version-1 saves and intermediate local saves migrate on import. New version-5 saves cannot be loaded by the unchanged HTML sandbox. A rejected import leaves the current game intact.
- **Reset** asks before clearing the expedition.

The original generated pixel-art roster remains a trial insert for terrain, facilities and vehicles. All population roles use the new transparent atlas.

## Small playable loop

End Turn twice → develop Technical Education → train Cohort C as a Specialist → End Turn twice → assign it to Field Lab → End Turn → develop Standard Tooling and Field Coordination.

Set Cohort B to Idle, select `(3,2)`, build a Production District, and End Turn. Build its Workshop, End Turn twice, then select Main Base and assign Cohort B to the Workshop.

Mobilise Cohort C, End Turn to refresh its movement, and walk along row 3 to Field Station at `(6,3)`. Join the settlement, assign its Field Lab, and End Turn. There are still four population cohorts.

## Base scenario; expanded Godot experiment

- Fixed 63-hex map, two existing sites, four population cohorts and one rover.
- Five pooled resources, qualification-based lab output and mutually exclusive cohort states.
- Five technology areas with two capabilities each; resource specialist training; one of each district/workplace type per settlement.
- Terrain costs, class-specific supply reach, construction timing, save/import and reset.
- No combat, AI opponents, diplomacy, freight simulation or victory condition. Population growth is now an explicit town action.

`tests/html_reference_trace.json` was generated by the actual HTML simulation, not hand-entered expected values. Godot compares its simulation state against all 44 reference steps after migrating their save schemas (presentation log text excluded). The new mechanics have their own checks.

## Source layout

| File | Purpose |
| --- | --- |
| `project.godot`, `main.tscn` | Importable Godot project and entry scene |
| `scripts/game_rules.gd` | Simulation, validation, commands, turn resolution |
| `scripts/main.gd` | Native Controls UI and save dialogs |
| `scripts/hex_map.gd` | Native map drawing, picking, zoom and pan |
| `scripts/starter_art.gd` | Load unchanged starter image and expose icon crops |
| `data/*.json` | Provisional preset, five tech areas, content definitions, sprite regions and starting state |
| `tests/test_rules.gd` | Rules parity and invariants |
| `tests/test_ui.gd` | Native control signals, playable loop, save/load and layout checks |

The UI is built in GDScript to keep the first port compact. It is a native Godot project, with no embedded web page or JavaScript engine. Individual panels can become authored `.tscn` scenes later if useful. Do not build a content framework yet.

## Test

Replace `godot` with the path to your Godot executable if it is not on PATH:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script tests/test_rules.gd
godot --headless --path . --script tests/test_ui.gd
godot --headless --path . --script tests/test_changes.gd
godot --headless --path . --script tests/test_technology.gd
```

See `VALIDATION.md` for actual results and limits.

## Export a desktop executable

Open **Editor → Manage Export Templates**, install matching **4.5.1** templates, then **Project → Export**. Windows Desktop and Linux presets are included. Create the output directory or choose another export path. The presets include the raw JSON and artwork text files.

For a Windows build from a terminal with templates installed:

```sh
mkdir -p builds/windows
godot --headless --path . --export-release "Windows Desktop" builds/windows/AlienPlanet.exe
```

Building an executable needs Godot and its matching templates. Playing that exported executable needs neither the editor nor a local web server.
