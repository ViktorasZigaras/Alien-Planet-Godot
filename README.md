# Alien Planet — Godot

A development branch of the small settlement sandbox in [Alien-Planet](https://github.com/ViktorasZigaras/Alien-Planet), implemented in native GDScript and Godot Controls. It is an experimental game shell, with provisional rules and a more convenient interface. The current cloud working copy includes the seven changes and the technology batch described below; these changes have not been uploaded to GitHub yet. No balancing or opponent strategy was added.

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
