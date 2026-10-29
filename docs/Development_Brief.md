# Planetary strategy game development brief for Codex

Prepared for Viktoras on 29 October 2026. This is a self-contained implementation handoff, based on the ten proposals in `SMAC_Proposed_Changes_01`, version 2. It creates a new brief and does not replace that proposal notebook.

## 1 What to build first

Build a very small, functioning turn-based planetary settlement sandbox. The player must be able to inspect a hex map, assign people to tiles and buildings, develop a technical and a social capability, train a population cohort, construct a district and a workshop, move a rover, and physically relocate a trained cohort to a field station.

The result is an architectural foundation with a short playable loop. It should demonstrate connections between the systems without implementing a complete 4X game. A clear placeholder map and working commands matter more than art, lore, content quantity or numerical balance.

The user has requested this development document and a rudimentary demo concept. This brief describes the implementation to perform when subsequently instructed to build it; it is not a claim that a playable demo has already been created.

### Instruction priority and design status

1. Preserve the user's ten ideas as the long-term direction.
2. Use the concrete demo defaults below to make a first implementation testable.
3. Treat numbers, names, map layout, job rules and prototype shortcuts as **provisional defaults proposed by the assistant**, not additional decisions already approved by the user.
4. Keep defaults together so later discussions can change them easily.
5. If an existing repository has relevant instructions or an established architecture, adapt this handoff to it rather than replacing the project gratuitously.

Do not turn the first build into a framework, a content editor or an elaborate simulation. Do not expand the roster while the basic interactions are incomplete.

## 2 The integrated design

The underlying loop is: geography provides opportunities; population supplies labour; buildings provide workplaces; districts organise them spatially; resources fund different activities; technical and social development expand the available capabilities; supply determines where mobile units can operate.

Population is the link between the settlement screen and the world map. A researcher is a persistent cohort that can leave a laboratory, travel and resume work somewhere else. Constructing a laboratory creates capacity, while its qualified staff produces the useful output. Neither a building nor a technology automatically supplies all its own requirements.

The game should encourage choosing between plausible alternatives. A shortage of researchers may be solved by training someone or moving an existing specialist. A productive hex may be preserved or replaced by a district. A distant site may be visible before the faction can support ordinary colonists there.

### Traceability from all ten proposals

| No | User's idea | Development interpretation | Smallest demonstration |
|---|---|---|---|
| 1 | Hexagonal map | Six-neighbour geography used consistently by movement, range and local work. | One fixed map; click-to-select tiles; visible paths. |
| 2 | Five or six core resources | Distinct Food, Industry, Credits, Research and Influence. Physical Power remains an optional later sixth system. | Five independently changing totals with different uses. |
| 3 | Movable population like Colonization | A cohort retains its identity and qualification when moving between settlements. | Mobilise a worker or specialist, walk to the field station, join it. |
| 4 | Pops work buildings as well as tiles | Tile jobs and building jobs compete for the same available people. | Move a worker from a quarry to a workshop or laboratory. |
| 5 | Every pop has a type | Qualification is persistent; assignment is its current activity. | Worker, Specialist and Administrator; train a Worker into a Specialist. |
| 6 | Terrain more like Civ VI | Distinguish base terrain, relief and surface feature; each can affect rules. | Plains, hills, water and a few forest-covered tiles. |
| 7 | Some buildings grouped in districts | A district occupies a map site and contains appropriate facilities. | One buildable Production District containing one Workshop. |
| 8 | Unit-specific global supply range | The faction computes supply access; unit class determines allowable route cost. | Cohorts and the rover have different reach from the main base. |
| 9 | Connected technical and social trees tied to resources | Research and Influence purchase distinct capabilities with explicit prerequisites. | Two technical nodes and two social nodes, including cross-tree links. |
| 10 | More grounded technological progression | Progress concerns usable methods, training and industrial capability. Exotic branches remain possible later. | Standard Tooling, Precision Assembly, Technical Education and Field Coordination. |

All ten ideas influence the slice. Their full content is not required: supply needs no freight simulation yet, districts need no adjacency puzzle, and progression needs no hundred-node tree.

## 3 Delivery format and scale

For a fresh project, use one self-contained `index.html` with inline CSS and JavaScript. Prefer SVG for the small hex map and ordinary HTML for panels. Use system fonts and simple coloured shapes or text symbols. It must open directly as a downloaded local file without an account, server, installation, build process, remote font, CDN or network request.

Organise the JavaScript into clearly labelled sections and small functions. Logical separation matters even inside one file. Do not introduce a package manager, an entity-component framework, a database or a generic plugin system for this slice. Splitting into files later should be straightforward because rules and presentation are already separated.

If development is already happening in a suitable project, preserve its working conventions while keeping a downloadable self-contained build available. Do not change the runtime or deployment model merely to match this default.

### Hard content budget

- One fixed 9-by-7 axial hex map: 63 tiles, no wrapping.
- One faction and no opponents.
- Two pre-existing settlement sites: Main Base and Field Station.
- Four population cohorts, three qualification types and one non-population rover.
- Five core resource totals.
- Two technical nodes and two social nodes.
- One buildable district type and one buildable building type.
- One construction project at a time for the faction; one training project at a time.
- Turn-based commands, Reset, Export Save and Import Save.

No combat, automatic population growth, diplomacy, random events, weather, complex manufacturing chains or victory system. Do not add decorative controls for these deferred features.

## 4 Fixed scenario

Use pointy-top hexes with axial coordinates `q = 0..8`, `r = 0..6`. The resulting board is a bounded axial parallelogram; screen position must not determine simulation distance.

The six neighbour offsets are `(1,0), (1,-1), (0,-1), (-1,0), (-1,1), (0,1)`. Ignore neighbours outside the board. A plain unobstructed hex distance can help UI inspection; actual movement and supply use their explicitly defined terrain costs.

| Entity or site | Coordinate | Starting condition |
|---|---|---|
| Main Base | `(2,3)` | Active settlement and the only supply source. |
| Field Station | `(6,3)` | Existing empty settlement with one unstaffed Field Lab; no passive yield and no supply-source effect. |
| Food work tile | `(1,3)` | Plains, flat, no feature; Food 3 per assigned cohort. |
| Quarry work tile | `(2,2)` | Plains with hills; Industry 3 per assigned cohort. |
| Intended district site | `(3,2)` | Clear flat plains; eligible for the Production District. |
| Rover | `(2,3)` | Non-population mobile unit, move budget 2, supply reach 5. |

All other tiles start as flat plains. Set `(4,1)` and `(4,2)` to forest feature; set `(5,1)` to hills. Set `(0,0)`, `(1,0)` and `(8,0)` to water. Keep the entire corridor `(2,3)` through `(6,3)` clear flat plains. All coordinates above are valid and distinct except for entities intentionally sharing Main Base.

For this slice, every ordinary unoccupied passable tile has Food 2 as its work yield, except the two named work tiles and forest/hill tiles. Other hills provide Industry 2; other forests provide Industry 2; water provides no usable job. A forest or hill uses the explicit override, not both the ordinary Food yield and the override.

### Starting cohorts and assignments

| ID | Qualification | Location | Assignment |
|---|---|---|---|
| `pop_a` | Worker | Main Base | Work Food tile `(1,3)`. |
| `pop_b` | Worker | Main Base | Work Quarry tile `(2,2)`. |
| `pop_c` | Worker | Main Base | Main Base Field Lab. |
| `pop_d` | Administrator | Main Base | Main Base Civic Office. |

Start all resource stocks at `Food 12, Industry 0, Credits 12, Research 0, Influence 0`. Start at turn 1. Do not silently apply an initial production tick.

Main Base contains a Field Lab, Civic Office and Training Module from the beginning. These are inherited starter facilities, not additional buildable types. Field Station contains only its starter Field Lab. The Production District and Workshop do not yet exist.

## 5 Explicit economy for the first slice

### Resource accounting

Use five faction-wide integer stocks in v0. This is a deliberate prototype shortcut, especially for Food and Industry: there are no local warehouses, shipments, local construction queues or transportable material inventories yet. It keeps relocation and staffing testable without implementing freight. Do not present this as the final economic design.

Industry here means banked construction points. They are spent on an order when it starts. They are not a second name for a mined commodity requiring a hidden ore-processing chain. Research and Influence are also banked points spent once on development nodes. Nothing converts freely into another resource.

| Source or sink | Exact v0 effect |
|---|---|
| Main Base landing systems | Food +2 and Credits +2 per End Turn; no other automatic output. |
| Field Station | No automatic output. |
| Resident tile worker | Produces only the chosen tile's listed yield. |
| Field Lab, one job per lab | Worker: Research +1; Specialist: Research +3; Administrator: Research +1. |
| Main Base Civic Office, one job | Administrator only: Influence +2. |
| Workshop, one job | Any resident cohort: Industry +3; +4 after Precision Assembly. |
| Population upkeep | Food −1 per cohort per End Turn, including residents, trainees, builders and mobile cohorts. |
| Completed Workshop upkeep | Credits −1 per End Turn, including when empty. |
| Rover upkeep | None in v0. It never counts as population or consumes cohort food. |

Tile work is legal only within hex distance 2 of the cohort's settlement centre; the tile must be passable and not occupied by a settlement centre or district. One cohort per work tile globally. Work access does not claim territory in this prototype. Districts replace the underlying work opportunity; a district hex cannot also be harvested as ordinary terrain.

The baseline first End Turn therefore gives Food +1 net, Industry +3, Credits +2, Research +1 and Influence +2. Those deltas are a useful first verification target.

### Shortages without a survival simulator

Apply production before the upkeep check. Stocks never become negative. If Food is insufficient, consume the available stock, display a persistent food-shortage warning and block starting new training or construction until Food is positive again. Do not kill cohorts or add further hidden penalties in v0. Current projects continue to avoid a recovery deadlock.

If Workshop upkeep cannot be paid, clamp Credits to zero, log the unpaid upkeep and block starting projects requiring Credits until enough are available. Do not delete buildings. This is transparent accounting for a sandbox, not the final scarcity model. Main Base's inherited income makes recovery possible.

## 6 Population movement employment and training

### One cohort one state

A cohort has one stable ID, one qualification and one location/activity state. Use a tagged union or equally explicit mutually exclusive fields:

```text
resident(settlementId, assignment = idle | tileJob | buildingJob)
mobile(tileId, movementRemaining)
training(settlementId, targetQualification, turnsRemaining)
building(settlementId, projectId)
```

Do not represent a mobile cohort as a new object while retaining its resident copy. Cohort count is conserved because growth, death and recruitment are out of scope.

Resident population need not appear as four map units on the base hex. Show it in the settlement panel. Mobilising converts that same cohort into a visible mobile token; joining converts the same token back into a resident. Qualification survives both transitions.

### Commands

- **Assign job:** a resident can take one vacant local tile or building job. Release the previous assignment atomically. Production occurs only on End Turn, so rearranging jobs never harvests extra output.
- **Mobilise:** release a resident job and place that same cohort at its settlement centre with **zero movement remaining for the current turn**. Training and construction participants cannot mobilise.
- **Move:** spend movement along the displayed legal path. Cohort movement budget is 1; rover budget is 2. Stacking is allowed, including rover/cohort sharing.
- **Join settlement:** a mobile cohort on either centre becomes an idle resident there. The command is legal even if that settlement has no residents. No founding or transport vehicle is required on this land-only map.
- **Train:** at Main Base, a resident Worker can become a Specialist or Administrator after Technical Education. Training costs Credits 4, takes two End Turns and uses the single Training Module. The trainee performs no productive job during training but still eats.

Main Base qualification is a service access rule, not a requirement to appoint a separate teacher in v0. The Training Module is inherited equipment. Completion produces an **idle** resident with the same ID and new qualification. Assign its new job explicitly; do not automatically steal another cohort's slot.

When a mobile cohort joins a settlement, its newly chosen job can produce on the next End Turn; that is the only production tick of the turn. Prevent re-mobilisation in the same turn after joining, or give it zero movement until the next turn. Either implementation must not refresh travel budget through repeated join/mobilise cycles.

## 7 Terrain movement and supply

### Movement

Entering clear flat plains costs 1 movement point; entering hills or forest costs 2; water is impassable. Do not add the hills and forest costs together: their combined cost, if later used on one tile, is the maximum, 2. No roads, embarkation, fog of war, elevation engineering or zones of control yet.

A move can traverse several adjacent tiles only if their total cost fits the remaining movement budget. With movement budget 1 a cohort cannot enter cost-2 terrain in v0. This is a stated simplification, not an accidental stuck-path bug. The plain corridor remains usable. A later minimum-one-tile rule could change it.

Use a shortest-path algorithm with non-negative terrain costs. Do not use straight-line screen distance or plain breadth-first search while claiming the result accounts for forests and hills.

### The smallest supply rule that actually changes play

Compute minimum supply-path cost from Main Base using the same terrain costs and passability as above. Main Base is the **only** source. Field Station neither resets range nor creates a free relay.

| Class | Movement per turn | Initial supply reach | After Field Coordination |
|---|---:|---:|---:|
| Mobile population cohort | 1 | 3 | 5 |
| Rover | 2 | 5 | 5 |

Every step of a commanded path must lie within the selected unit class's supply reach. A target can be reachable in the long-term supply sense but beyond this turn's movement allowance; show both conditions separately.

The Main Base–Field Station corridor has supply cost 4. Initially a rover may reach the station, while a cohort cannot complete the trip. After Field Coordination the same population token can travel there and join it.

This v0 uses a hard operation boundary, **not** reserves, gradual attrition or freight capacity. Those were options in the notebook, not commitments. No command in v0 disables Main Base, alters terrain or removes Field Coordination, so the prototype does not need to resolve units stranded by a shrinking network. Add a safe return/penalty rule before introducing such changes later.

All cohorts still consume the pooled faction Food regardless of location. Supply range limits mobile operation; it does not simulate actual food shipments. Resident jobs use the settlement's local work-access rule rather than projecting a new mobile supply field. The UI must not imply that a freight model already exists.

## 8 Technical and social development

Implement two visibly separate two-node progressions, represented by data definitions. A node is purchased once when its prerequisites and banked points are sufficient. Completion is immediate on purchase; the time investment is accumulating its points through staffed production. No separate research queue or countdown is needed for four nodes.

| ID | Tree and cost | Prerequisites | Exact benefit |
|---|---|---|---|
| `standard_tooling` | Technical; Research 4 | None | Permits Production District construction and the Workshop it contains. |
| `precision_assembly` | Technical; Research 8 | Standard Tooling **and** Technical Education | Staffed Workshops produce Industry 4 instead of 3. No extra output while vacant. |
| `technical_education` | Social; Influence 4 | None | Allows the Training Module to change a Worker's qualification. No automatic conversion of people. |
| `field_coordination` | Social; Influence 6 | Technical Education **and** Standard Tooling | Changes mobile cohort supply reach from 3 to 5. Rover is unchanged. |

Expose missing prerequisites and exact cost before purchase. Points are deducted once only. Locked, affordable and completed states must look different.

These nodes are local capability development. The expedition already knows basic science; it is establishing usable tooling, training and field coordination with its limited people and equipment. The cross-tree requirements above are small illustrative dependencies, not claims about a universal historical sequence.

Research does not spend Influence, and social development does not silently spend Research. Food sustains the cohort producing either. Industry builds the unlocked equipment; Credits pay selected implementation costs. This is the intended connection to the five-output economy.

Leave psi, unusual alien biology and radical cybernetics out of the first content set. Their eventual entries should use explicit prerequisites, costs, effects and operating limits through the same definition model. Do not add an empty “Psi” button merely to acknowledge the future branch.

## 9 District and construction rules

Implement one Production District and one contained Workshop. Each settlement may have at most one Production District in v0, with one Workshop. The field station's inherited lab does not require a research district; only some activities are grouped into map districts.

| Order | Upfront cost | Duration | Other conditions |
|---|---|---:|---|
| Production District | Industry 2 | 1 End Turn | Standard Tooling; an idle resident Worker; eligible site. |
| Workshop | Industry 6 and Credits 2 | 2 End Turns | Standard Tooling; completed Production District; an idle resident Worker. |

An eligible district site is clear flat plains within hex distance 2 of its owning settlement, not a settlement centre, not already a district, and not currently assigned to a tile worker. The tile must be within the cohort supply field. Reject unsuitable placement and state the reason. `(3,2)` is the intended first site.

Construction uses an idle resident Worker of the owning settlement. The worker is reserved as the builder and produces nothing else during the project. Its location remains the settlement for this slice: the project abstracts local construction work rather than moving the builder onto the site. It still consumes Food.

At project start, validate all conditions before spending or reserving anything. Deduct the cost once, reserve the target site and reserve the builder. At completion, create the district/building and return the builder to **idle**. A completed Workshop creates one vacant job; it does not employ its builder automatically or produce a passive Industry bonus.

Maintain one faction construction slot to avoid queue management. No cancellation, demolition, sale, relocation or refunds in v0. Thus there is no partially defined refund exploit. Save/import must preserve projects in progress and reserved sites.

Districts have no adjacency bonus in this slice. Their role is already real: they occupy land, contain a building, require a location and expose future grouping. Do not add a large placement puzzle before staffing works.

## 10 Deterministic End Turn order

Resolve End Turn exactly once per click and disable the button during resolution. Keep this sequence in one simulation function:

1. Read a snapshot of current assignments and ongoing projects. Only cohorts already resident and productively assigned at this point generate output.
2. Add landing-system income, tile output and staffed-building output to their resource stocks. Apply completed development effects only.
3. Pay Food upkeep for the four cohorts in all states; pay upkeep for Workshops that were already completed at the start of this tick. Clamp deficits and issue the specified warnings.
4. Decrement existing training/construction timers by one. Complete projects reaching zero, release reservations and return their cohorts to idle. A building completed now starts maintenance on the next End Turn.
5. Increment the turn number. Refresh all currently mobile movement budgets to their class maximum.
6. Recompute derived job availability, class supply fields and UI forecasts; append an itemised turn report.

Do not apply output retroactively for a newly trained cohort or a newly completed Workshop. They can be assigned after resolution and produce on a subsequent End Turn.

Training and construction started before End Turn count that forthcoming tick as their first elapsed turn. A duration-2 project started on turn 5 becomes duration 1 when the display advances to turn 6 and completes when it advances to turn 7.

Commands between turns change orders, location, stock purchases or development state. Only End Turn produces resources. Repainting the UI, selecting a tile or exporting a save must never advance time.

## 11 State and code organisation

Use one authoritative serialisable game state. Put immutable definitions in a separate section, referenced by IDs. Derive totals and selected previews rather than maintaining several contradictory copies.

```text
GameState
  schemaVersion, rulesVersion, turn
  resources {food, industry, credits, research, influence}
  map {width, height, tilesById}
  settlementsById
  cohortsById
  mobileUnitsById             # rover only; mobile cohorts remain cohorts
  districtsById, buildingsById
  completedTechnicalIds, completedSocialIds
  trainingProject | null
  constructionProject | null
  warnings, log

Tile
  id, q, r, baseTerrain, relief, feature

Cohort
  id, name, qualification, state # state is one mutually exclusive variant

Settlement
  id, name, centreTileId, starterBuildingIds

Building
  id, definitionId, settlementId, districtId | null

ConstructionProject
  id, orderType, settlementId, targetTileId | null,
  targetDistrictId | null, builderCohortId, turnsRemaining
```

Calculate building occupancy from cohort assignments; do not save a second list that can disagree with them. Stable IDs should survive movement, training and save/load.

### Small reusable functions

```text
createInitialState()
getHexNeighbours(tileId)
getMovementCost(tileId, classId)
findPath(state, startId, targetId, classId)
computeSupplyField(state, classId)
listJobs(state, settlementId)
getJobOutput(state, cohortId, assignment)
canApplyCommand(state, command) -> {ok, reasons}
applyCommand(state, command) -> nextState or validated result
resolveEndTurn(state) -> nextState
validateState(state) -> invariant violations
renderMap(state, uiState)
renderPanels(state, uiState)
```

Separate transient UI selection, hovered paths and open panels from saved simulation state. Command validation belongs to the rules layer, not only to whether a button appears enabled. Use the same rules to calculate previews and to apply commands.

### Examples of adding content later

- Add a different building by defining its job capacity, eligible qualifications, inputs, output and cost; use the existing job assignment and construction flow.
- Add a qualification by defining its training option and job-specific effects; do not duplicate the cohort class or replace a cohort's ID.
- Add a terrain feature by defining its movement and work-yield effects; use the shared terrain lookup in movement and supply.
- Add a technical or institutional node through prerequisites, funding resource and an explicit effect handler. Avoid embedding display names in simulation conditionals.
- Add an alien unit class through movement, passability and support rules when the relevant mechanics are actually built. Do not pretend future biological support is identical to the current land supply field.

Prefer a few explicit handlers to a general scripting language. Do not create an elaborate abstraction layer for hypothetical systems.

## 12 Minimal interface

Use a map, a five-resource/turn bar, and one side panel. Provide a readable event log. The map must distinguish plain land, hills, forest, water, settlement centres, a district site, mobile cohorts and the rover.

Selecting a settlement shows its residents, qualifications, assignments, vacant building jobs, build options and eligible training. Selecting a mobile token shows movement remaining, supply reach and destination status. Selecting a district shows its contained building and staffing. Cohorts sharing a tile must remain individually selectable.

Development shows both two-node trees and their cross links. A list with prerequisites is acceptable; a complex tree visualisation is not required. The supply overlay follows the currently selected class so it demonstrates the difference between a rover and a population cohort.

For a blocked command say, for example, “Field Station is at supply cost 4; cohort reach is 3” or “Workshop needs one idle resident Worker”. Do not answer every failure with “Cannot do that”.

Require only a small, clear control set: select, assign/unassign, mobilise, move, join, train, develop, build, End Turn, Reset and save import/export. Use ordinary buttons and lists. No menus for systems that do not yet exist.

Show an initial short objective list: develop Tooling; build and staff a Workshop; train a Specialist; extend cohort reach; relocate that Specialist to the Field Station. The list is a testing aid, not a full tutorial or victory system.

## 13 Reset to success walkthrough

This scripted path uses the exact defaults above. It checks that the player is not trapped behind circular requirements or insufficient starting resources. Other legal choices should work too.

1. Reset. Inspect the four starting assignments. End Turn twice. At displayed turn 3 expect `Food 14, Industry 6, Credits 16, Research 2, Influence 4`.
2. Purchase Technical Education for Influence 4. Start training `pop_c` as a Specialist for Credits 4. It leaves the Field Lab and spends two ticks in training.
3. End Turn twice. At displayed turn 5 expect `Food 16, Industry 12, Credits 16, Research 2, Influence 4`. `pop_c` is now an idle Specialist, with its original ID.
4. Assign `pop_c` to Main Base Field Lab. End Turn once. At displayed turn 6 expect `Food 17, Industry 15, Credits 18, Research 5, Influence 6`.
5. Purchase Standard Tooling for Research 4 and Field Coordination for Influence 6. Expect Research 1 and Influence 0. Cohort reach is now 5. The rover's reach remains 5.
6. Unassign `pop_b` from the Quarry. Order a Production District at `(3,2)` with `pop_b` as builder, spending Industry 2. End Turn once; the district completes and `pop_b` becomes idle. At displayed turn 7: `Food 18, Industry 13, Credits 20, Research 4, Influence 2`.
7. Order its Workshop, spending Industry 6 and Credits 2 and reserving `pop_b` for two ticks. End Turn twice. At displayed turn 9: `Food 20, Industry 7, Credits 22, Research 10, Influence 6`. Workshop completed, empty; builder idle. No Workshop upkeep has been paid yet because it completed at the end of the most recent tick.
8. Assign `pop_b` to the Workshop. End Turn once. At displayed turn 10 expect `Food 21, Industry 10, Credits 23, Research 13, Influence 8`. Workshop output is staffed Industry 3; its upkeep is Credits 1.
9. Optionally purchase Precision Assembly for Research 8. The next staffed Workshop tick gives Industry 4. It remains zero if `pop_b` is unassigned instead.
10. Mobilise `pop_c`. It appears at `(2,3)` with zero movement remaining and no laboratory assignment. End Turn to refresh movement. Walk it along row `r=3` toward `(6,3)`, at most one tile per turn. Its reach is sufficient after Field Coordination.
11. Join Field Station as an idle resident, then assign `pop_c` to that station's Field Lab. End Turn. It produces Research 3 there. Main Base Field Lab is empty. Total cohorts remain four; no remote copy was created.
12. Select the rover and move it independently. Compare its two movement points with a cohort's one, and its initial supply access with the cohort's pre-upgrade restriction using a fresh Reset if needed.

Reset before checking the exact earlier figures; extra End Turns, changed jobs or purchases legitimately change totals. All temporary numbers belong to this demo preset.

## 14 Verification Codex should perform

Write small meaningful checks for the simulation rules, not a giant UI test suite. These changes create interacting persistent state, so invariants and a deterministic walkthrough are useful here.

| Check | Expected result |
|---|---|
| Starting tick | Resource deltas match the five values in section 5. |
| Unique cohort | Mobilising, joining and training preserve ID and total cohort count. |
| No double employment | A cohort cannot hold two jobs or work while training/building/mobile. |
| No duplicate tile work | Two settlements cannot assign separate cohorts to the same tile. |
| Empty facility | An unstaffed Field Lab or Workshop yields zero. |
| Atomic failure | Invalid construction or training spends nothing, changes no job and reserves nothing. |
| Construction timing | One-tick district and two-tick workshop complete at the specified boundaries. |
| Completion output | Newly completed facilities do not produce or charge maintenance retroactively. |
| Supply class | Before Field Coordination the rover can reach `(6,3)` but a cohort cannot. |
| Social effect | Field Coordination changes only cohort reach; the existing rover remains unchanged. |
| Path cost | Hills/forests cost 2 and water blocks both land classes; no diagonal square shortcut exists. |
| Research accounting | A completed node cannot be bought twice or bypass its cross-tree prerequisites. |
| Qualification effect | A trained Specialist produces 3 Research in a lab; an ordinary Worker produces 1. |
| Save round trip | Export/import preserves cohorts, locations, assignments, projects, resources and completed nodes. |
| Bad save | Malformed or unsupported save data is rejected with an explanation; current state survives. |
| Reset | Returns precisely to the fixed initial preset, not a partly cleared previous game. |

Use a single `schemaVersion` and `rulesVersion`. Validate imported references and state invariants before replacing the current game; treat imported strings as text, never executable HTML or code. Provide an export file rather than relying solely on local browser storage under `file://`.

For manual verification, open the actual exported self-contained build, play the walkthrough, and exercise at least one failed command. Report what was tested and any unavailable browser check honestly. Console or simulation tests do not prove that map selection and job buttons work.

## 15 Implementation order and stopping point

1. **Map and movement:** fixed board, selection, path calculation, rover/cohort budgets, End Turn refresh and Reset.
2. **People and economy:** stable cohorts, jobs, starter facilities, five stocks and itemised turn output.
3. **Capabilities and projects:** the four development nodes, training, district construction and Workshop staffing.
4. **Supply and relocation:** class overlay, blocking reasons, Field Coordination and station arrival.
5. **Persistence and review:** save import/export, invariants, walkthrough and a directly runnable downloadable build.

These are implementation steps within one small slice, not a reason to deliver a static map and stop. Completion means the end-to-end walkthrough can actually be played.

Stop adding systems when the acceptance checks pass. Capture newly noticed design questions separately. Do not fill unused space with extra factions, monsters, research nodes or economic inputs merely because the code permits them.

### What should remain easy to change

Keep map data, yields, qualification bonuses, node costs, build durations, upkeep, movement and supply ranges in a named demo preset. Later features can replace the pooled economy, hard supply boundary or inherited starter equipment without rewriting cohort identity and job assignment.

Do not implement those larger replacements now. The desired foundation is understandable working code with explicit state transitions, not speculative infrastructure for every eventual game feature.

## 16 Compact prompt to start the later Codex build

> Build the small playable sandbox specified in this brief. Follow the demo preset, resource accounting, turn order and acceptance walkthrough exactly before expanding anything. Use one downloadable self-contained HTML file if starting fresh, with no runtime network dependencies. Include the fixed hex map, four persistent population cohorts, one rover, three qualifications, five resource stocks, two technical nodes, two social nodes, training, one Production District and one Workshop, class-specific supply and population relocation. Keep simulation rules separate from DOM rendering and constants in a demo preset. Test meaningful state invariants and play the walkthrough in the runnable build. Report implemented behaviour, checks and any remaining limitation. Do not create a full 4X game, add combat, or silently substitute decorative controls for working systems.

## 17 Relationship to the earlier notes

This brief is a concrete, intentionally small interpretation of the ten proposals together. It does not claim that the broader design has selected five resources permanently, adopted pooled Industry permanently, rejected soft supply penalties, or fixed the eventual population and district models.

The earlier proposal notebook remains the discussion record. This brief is the operational handoff for a first test. It includes everything required to understand that test without retrieving the SMAC wiki or relying on past chat memory. Refer back to the notebook only when deciding how to grow the prototype after its current loop works.

Source discussion notebook: [SMAC Proposed Changes](https://chatgpt.com/library?file_id=libfile_f8bb8352a5f48191937914dd1d41b3a1&account_id=personal), version 2, read 29 October 2026. Example mechanics in this brief are original provisional design choices, not copied rules from SMAC, Colonization, Civilization VI or Endless Legend.
