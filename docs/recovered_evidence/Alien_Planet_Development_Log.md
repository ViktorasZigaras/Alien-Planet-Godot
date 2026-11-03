# Alien Planet — development notes

A short, ongoing record for the HTML and Godot experiments. Keep entries at note level: what Viktoras requested, what changed in response, any additional work, and whether it has been uploaded.

## Working procedure — agreed 29 October 2026

- Keep working files in the cloud development directories.
- Develop, run and check changes there. Upload code or new builds to GitHub only when Viktoras explicitly asks. A request to change the game is not by itself an upload instruction.
- Update this document in `[Generated Games]` after each development batch. These note updates are part of the standing procedure and do not require a separate request.
- Separate requested changes from additional fixes or implementation decisions. Mention checks and unresolved issues briefly.
- Keep the game an experimental shell. Do not add systems, balance strategies or build elaborate infrastructure unless requested.
- Mark finished local work as **not uploaded** until an upload is requested and completed. Record which version was uploaded so later work is distinguishable.
- If the temporary cloud workspace is lost, restore the last uploaded source from GitHub and consult these notes. Notes describe pending work but do not replace a source backup.

## Starting point — 29 October 2026

### HTML sandbox

**Requested:** Make the first small playable architectural shell from the Planetary Strategy Codex brief. Use the generated roster as temporary starter art; leave balancing and brainstorming for later.

**Changed:** Added the hex map, jobs, five resources, training, technical/social development, district and Workshop construction, supply, relocation and save/import.

**Additional work:** Fixed map click targets and selection of occupied destinations. Added a short guide and basic checks. Split the embedded artwork for GitHub transfer; a small assembly script recreates the standalone HTML.

**Checks:** 134 assertions passed; the main construction and relocation loop was also exercised in the browser.

**Upload:** Completed to [Alien-Planet](https://github.com/ViktorasZigaras/Alien-Planet), commit `08b0f9c`. The previously saved standalone HTML remains playable.

### Godot comparison

**Requested:** Recreate the same game in Godot to compare convenience; modest UI improvements allowed.

**Changed:** Added a native Godot project with the same rules and scenario. Added a fixed resource bar, tabbed controls, zoom/pan, right-click movement, clearer person selection, quick saves and file dialogs. HTML/Godot JSON saves share the same format.

**Additional work:** Fixed layout overflow, synchronised the supply selector, added help and desktop export presets, and checked the port against reference steps from the actual HTML engine.

**Checks:** 239 rules checks and 58 native UI checks passed headlessly. All 44 reference steps matched. No standalone Windows executable was produced or claimed tested.

**Upload:** Completed to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `f3d4277`.

### Development procedure

**Requested:** Keep cloud working copies, upload only on instruction, and maintain high-level notes in this folder.

**Done:** Established this log and recorded the working agreement and existing baselines.

**Status when the procedure was established:** No gameplay changes were pending upload. Subsequent local work is recorded below.

## 29 October 2026 — seven-change batch — Godot

**Requested:** Apply seven additions in the listed order; keep the shell suitable for later physical testing and brainstorming.

| Order | Request | Implemented |
| --- | --- | --- |
| 1 | Physical resource icons | Pictorial grain, minerals, coins, flask and influence standard in the resource bar. |
| 2 | Yield map overlay | A toggle shows potential output per assigned tile worker using the same rules as production. |
| 3 | See worked tiles and who works them | Worked-hex outlines, cohort-name markers and explicit worker/town identification in inspection. |
| 4 | Roads at one-third movement; farms adding one Food | Buildable local improvements. Roads cost one-third movement to enter; a worked Farm adds one Food. Both can coexist. |
| 5 | Unit movement queue | Queued paths use current movement, continue on subsequent turns, accept appended waypoints and can be cancelled. Visible queued routes and destinations. |
| 6 | Terrain similar to the reference | Plains, forest, hills and water artwork from the original roster mapped onto actual hexes. |
| 7 | Population proliferation for 20 Food as a town action | An inhabited town can immediately spend 20 Food to create one idle Worker cohort with a unique persistent ID. Normal employment, training, movement and upkeep apply. |

**Provisional choices:** Roads and Farms each use an idle resident Worker, the shared construction slot, 1 Industry and one turn; neither needs a development unlock. They must be within two hexes of their town and inside cohort supply. Farms need clear flat plains outside towns/districts; another cohort may keep working the tile during construction. Roads also lower supply-path cost because supply and movement share terrain costs. Growth has no automatic trigger or extra cooldown; a new cohort adds one Food upkeep per turn. No balancing or strategy optimisation was attempted.

**Additional work:** Preserved original cohort identities; added safe fractional movement, queue cancellation and saved queues; extended save validation for improvements and larger populations. Older saves migrate automatically. New saves use version 4 and cannot be loaded by the unchanged HTML sandbox. Updated controls/help and project notes. Kept mobile units drawn above map annotations.

**Checks / open points:** 239 original rules checks, 142 new-mechanics checks and 90 native UI checks passed (471 total). The original 44-step gameplay reference still matches after migration. Checks cover improvement timing/yields, three road steps per movement point, queues/waypoints, population costs/upkeep/identity, control behaviour and save round trips. Physical desktop testing and visual judgement remain pending.

**Upload status:** **Not uploaded.** Godot cloud working copy is now local version 0.2. GitHub's last uploaded Godot baseline remains `f3d4277`; the HTML working copy and repository were not changed by this batch.

## 29 October 2026 — technology areas and population sprites — Godot

**Requested:** Starting trees for Biology, Industry, Military, Exploration / Research and Social; a tab for each area; two demo technologies per area; related districts, buildings and improvements where applicable; a trainable specialist for each resource; sprites without backgrounds for all population roles. Deeper economy analysis deferred.

**Changed:** Added a larger Technology view with five area tabs, two cards per area, real costs/prerequisites, unlock descriptions and completion state. Retained the four existing capabilities and added six.

| Area | Technologies | Demo content |
| --- | --- | --- |
| Biology | Cultivation; Closed Ecology | Farmer; Agriculture District and Greenhouse. Existing Farms remain available. |
| Industry | Standard Tooling; Precision Assembly | Engineer; Production District and Workshop; Mine. Existing Roads remain available. |
| Military | Field Security; Perimeter Defence | Security qualification; Security District, Guard Post and Watchtower. No combat added. |
| Exploration / Research | Field Methods; Field Coordination | Scientist; Research District, Research Lab and Survey Beacon; existing supply-range extension. |
| Social | Technical Education; Civic Exchange | Administrator and Merchant; Civic District, Exchange and Trade Post. |

**Resource specialists:** Farmer → Food; Engineer → Industry; Merchant → Credits; Scientist → Research; Administrator → Influence. Security and the existing general Specialist are also trainable. Training requires Technical Education plus the role's capability and keeps the previous 4-Credit/two-turn service. Qualified staff have simple workplace bonuses; the five resource specialists add one unit at matching resource-producing tile jobs.

**Population art:** Generated a transparent, static eight-role atlas with the built-in image generator: Worker, Farmer, Engineer, Merchant, Scientist, Administrator, Security and general Specialist. Preserved the PNG's alpha and original pixels; map and UI select per-role atlas rectangles. Project asset: `assets/population/population_roles_v1.png`. Final generation prompt is retained in the project documentation.

**Provisional choices / additional work:** Every town can have one of each district type, with one corresponding staffed workplace; different types occupy separate hexes. Common costs remain simple: district 2 Industry/one turn, workplace 6 Industry + 2 Credits/two turns, new improvement 1 Industry/one turn. Empty buildings do not produce. New site improvements require their technology; one site improvement may coexist with a Road. Engineers can construct alongside Workers. Existing tech costs/cross-prerequisites remain intact to preserve the earlier demo loop. Military buildings currently demonstrate Influence and staffing only. Updated mixed-resource yields, actual specialist output in the map overlay, save validation and old-save migration to version 5. No deeper economy or balancing analysis was performed.

**Checks / open points:** 239 original rule checks + 142 previous-batch mechanics checks + 90 native UI checks + 507 new technology/content/sprite/UI checks passed (978 total). Checks cover all five district/workplace pairs, every new improvement and resource specialist, missing-tech rejection, saved references, transparency, tab labels and native selectors. Physical desktop testing remains pending.

**Upload status:** **Not uploaded.** Godot cloud working copy is local version 0.3, including the previous unuploaded 0.2 batch. GitHub's last uploaded Godot baseline is still `f3d4277`. HTML is unchanged.

## 29 October 2026 — upload and economy discussion — Godot

**Requested:** Save and upload current work; suggest possible secondary resources and special tiles for basic yields.

**Upload:** Completed to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `f9369a559348a2ec8e0a75cae1a77478e35caaf6`. Includes the entire 0.2 gameplay batch and 0.3 technology/population-art batch. All 67 tracked source files matched uploaded Git blob hashes; main branch verified at this commit. Existing validation remains 978 passing checks. Source project uploaded; no standalone executable produced. HTML unchanged.

**Discussion only:** Suggested short staffed conversion recipes, explicit input/output/shortage reporting and food-upkeep priority. Example secondary goods: Rations, Components, Medical Supplies; later Equipment or Cultural Goods. Suggested special tiles: fertile fungal beds, ore seams, conductive crystals, aromatic flora, ancient ruins and landmark groves. Ordinary terrain should remain useful; improved and worked bonuses can encourage settlement choices without making every special deposit mandatory. No economy changes implemented or balanced.

## 29 October 2026 — Beyond Earth reference and professions — design document

**Requested:** Reference Beyond Earth map, tiles, resources and buildings; compare relevant SMAC functions; derive possible professions and simplify them into a manageable thematic roster.

**Created:** `Alien_Planet_Beyond_Earth_Reference_and_Professions.md`: qualitative terrain/features/improvement reference, all 24 resource names, functional index of 60 base buildings plus 12 Rising Tide additions, an SMAC comparison, occupation families and a proposed seven/eight-role starting target with a possible ten-role later ceiling. Separates documented content from original proposals and records source/edition conflicts.

**Choices / checks:** Included Rising Tide with marked additions; avoided unreliable exact balance tables. Reviewed the existing SMAC reference, original demo brief and current log; researched published guide, official expansion material and community indexes. Proposed role/job separation, resource accounting choices and a small special-tile roster. No game changes or GitHub upload in this batch; last uploaded source remains `f9369a5`.

## 29 October 2026 — technology areas and ideas — design document

**Requested:** Based on SMAC and Beyond Earth technologies, suggest minor and major technology subareas, including unrealistic possibilities, and explain the key ideas they represent.

**Created:** `Alien_Planet_Technology_Areas_and_Ideas.md`: 45 focused subfields grouped into 15 major fields under the existing five umbrellas; eight advanced cross-field directions from planetary engineering and living industry to digital society, exotic physics, psi and transcendence. Explains central questions, possible applications, illustrative development lines and connections to current demo technologies.

**Choices / checks:** Separates subjects, individual unlocks, interdisciplinary fields and civilisational choices. Marks grounded beginnings, speculative premises and explicit exotic/metaphysical fiction without treating them as feasibility claims. Includes source trail and scope guidance; preserves current research tabs and prerequisites. No game changes or GitHub upload; last uploaded source remains `f9369a5`.

## 29 October 2026 — 3D model lab and collages — Godot

**Requested:** Use the design references for future decisions; add a model-study screen/tab with moderately detailed geometric terrain hexes, a simple reusable articulated person skeleton with Walk/Stop, and sprite-inspired population variants beside it. Show collage images for comparison.

**Changed:** Added a 3D Model lab toolbar entry with Terrain hexes, Population rigs and Comparison collage tabs. Six studies: Plains, Forest, Hills, Water, plus proposed Desert and Fungal. One reusable 13-bone Skeleton3D scene and shared procedural in-place gait drive the bare joint/limb rig and eight rigid geometric outfits. Clothing, tools and equipment reflect the existing Worker, Farmer, Engineer, Merchant, Scientist, Administrator, Security and Specialist sprites, displayed beside the 3D versions. Added angle and gait-speed controls, Stop/reset and Back to game.

**Additional choices / fixes:** Model lab is isolated from game state; hidden previews stop rendering/processing. Corrected terrain face winding during actual rendered review. Added asset reuse notes and recorded the design documents as future discussion references. No conversion of the playable strategy map to 3D, detailed skinning, IK or final-art claim.

**Checks / results:** Previous 978 checks and 131 new model-lab checks pass (1,109 total). Actual Godot OpenGL renders produced and visually reviewed two requested images: `Alien_Planet_3D_Comparison.png` and `Alien_Planet_Walking_Lineup.png`. The images show the actual assets, with no generated concept-art substitution. Physical desktop play testing remains pending.

**Upload status:** **Not uploaded.** Cloud working copy is local 0.4; GitHub source remains `f9369a5`. Collages saved for review separately. Earlier design documents remain proposals.

## 29 October 2026 — population detail pass and terrain advice — Godot

**Requested:** Preserve joint count; double or triple the shapes in every person and make them slightly less blocky. Suggest inexpensive pleasant ways to enliven terrain.

**Changed:** Kept the same 13 bones, shared gait and bare rig. Each of the eight outfits gained 40 face/clothing/boot pieces and uses chamfered, faceted solids instead of sharp boxes. Counts now 65–68 geometric pieces versus 25–28 previously (roughly 2.4–2.6×). Added piece counts to the study cards and rendered updated neutral and walking collages while preserving first-pass images.

**Discussion:** Recommended subtle shared ground textures and stable colour variation, a few silhouette props, consistent lighting, restrained vegetation sway and water highlights, and sparse local sprite particles. These terrain effects are suggestions only; no terrain animation was implemented. Extra model shapes increase rendering work; crowd performance is not benchmarked.

**Checks / upload:** All 978 prior checks plus 165 model-lab checks pass (1,143 total), covering the 2–3× shape budget and unchanged skeleton. Actual Godot renders visually reviewed. Cloud version 0.4.1; not uploaded to GitHub. Source baseline there remains `f9369a5`.

## 29 October 2026 — living terrain and authorised visual-evaluation upload — Godot

**Requested:** Show the proposed terrain treatment, add it to the game and upload for visual evaluation.

**Changed:** Terrain studies now use shared native procedural texture grain/patches, stable tint/prop variation, restrained shader vegetation sway, moving water colour/highlight patterns and bounded ambient Sprite3D motes (dust/spore/insect suggestions). Added independent motion-pause and surface/sprite comparison switches. Added Terrain landscape tab with seven joined hexes. Closing the lab or hiding a page suspends its preview controllers. All effects remain in the model lab; main strategy map and simulation unchanged.

**Checks / additional fixes:** 245 model/terrain-lab checks plus 978 prior checks passed (1,223 total). Actual OpenGL six-tile and joined-landscape renders inspected; corrected surface normals and toned down texture contrast. A 32-frame motion preview was encoded from actual renders, with changed pixels confirmed in the terrain region. Excluded capture output from desktop export. No physical Windows evaluation or hardware benchmark claimed.

**Upload:** Completed on explicit request to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `e5e9d064e5637b2eb3fa0fdc95d756994d837afb`. All 88 tracked source files matched uploaded blob hashes; main branch verified. Version 0.5 includes both previously local 0.4/0.4.1 model batches and the terrain atmosphere work. No executable produced. Open project in Godot, F5, then 3D Model lab → Terrain hexes / Terrain landscape. HTML unchanged.

## 30 October 2026 — next batch intake: economy resources — pending execution

**Instruction:** Viktoras is listing the next batch first. Record requirements now; do not implement until he explicitly says to execute. This list may be extended by subsequent messages.

**Requested resource/yield changes:**

- **Food:** retained. Each settlement gains a growth mechanic. User's expression: “food - consumption - settlement size + growth penalty reduction supplied by medics working a building.” Preserve the distinction between food consumption, the settlement-size growth penalty and the Medic-provided reduction; exact accounting, coefficients and growth threshold remain to be specified, not silently chosen during intake.
- **Minerals → Industry:** Minerals replace the raw production yield. Minerals are converted into a separate Industry resource used for construction and making things.
- **Energy:** replaces Credits and powers buildings and districts. Stock/capacity model, operating costs and shortage effects are not fixed by this intake message.
- **Science:** retained (currently labelled Research in the prototype).
- **Culture:** replaces Influence and pays for social developments.

**Status:** Recorded only. No code, simulation, resource labels, save schema or GitHub changes. Current uploaded game remains version 0.5, commit `e5e9d0`.

### Pending batch continuation — terrain, map bonuses and presentation

- **Bonus resources:** Map occurrences depend on climate and terrain context. Food and Mineral bonuses are more plentiful; Energy, Science and Culture bonuses are rarer but present. The starting map must contain examples of all five bonus-yield categories. Individual resource names, magnitudes and distribution rules remain open.
- **Base terrain:** Expand terrain types, including Plains, Desert and Tundra. A tile can yield more than one resource type.
- **Forest layer:** Forest is an overlay on underlying terrain, with a Food reduction and Mineral increase; no longer a mutually exclusive base terrain type.
- **Hill modifier:** Hills can occur on any land terrain. They apply the same Food-reduction/Mineral-increase effect as Forest. Forest and Hills may coexist and their effects combine. Exact modifier amounts and any yield floors have not been specified.
- **Rivers:** Represented between tiles, along tile edges, granting extra Food to adjacent tiles. Bonus magnitude and stacking details remain open.
- **Compact map:** Tiles are packed almost without gaps, retaining only enough separation/grid treatment for boundaries, overlays and other information.

**Status:** Added to the same pending batch. Still intake only; no implementation or upload authorised by this continuation.

### Pending batch continuation — revised movement and queue specification

**Requested:** Review hard-terrain and river-crossing movement; retain leftover movement somehow while a queue is unfinished; distinguish entering, following and leaving roads. Shift + right-click amends the queue; ordinary right-click moves and replaces it. Remove movement confirmations.

**Proposed wording / provisional costs (assistant interpretation, not yet confirmed):**

- Ordinary land step costs 1 movement; Forest adds 1 and Hills adds 1, so a forested hill costs 3. Water remains blocked for ordinary land units. Costs can be tuned later.
- Crossing a river edge adds 1 movement. A Road does not automatically erase the crossing surcharge; a bridge exception could be discussed later, without adding a bridge-building system now.
- Following a connected Road from a Road tile costs 1/3 movement, plus any river surcharge.
- Entering a Road from off-road pays the destination's normal terrain cost (plus any river surcharge); a Road at the destination alone does not grant the connected-road rate.
- Leaving a Road pays the destination's normal terrain cost (plus any river surcharge). Terrain costs concern the entered tile; river costs concern the crossed edge.
- For an unfinished queue, preserve insufficient movement as partial progress toward the next queued edge. Add later turns' movement until that edge is paid, then move and spend any remainder on subsequent steps. The unit remains visibly on its origin tile until the step completes. This allows a slow cohort to traverse expensive land rather than treating that land as permanently inaccessible. This partial-step interpretation of “overflow” is proposed, not a settled user formula.
- Shift + right-click appends/amends waypoints and preserves the current unfinished step. Plain right-click issues a new destination, replaces the old queue and immediately uses available movement; remaining travel continues on later turns. With no current queue, Shift + right-click can start one.
- Proposed partial-progress accounting: cancellation/replacement discards credit tied to the abandoned step; ordinary unspent current-turn movement is not refreshed. No general unlimited bank of movement is created by waiting idle. Exact replacement/refund behaviour remains a design choice for execution.
- No confirmation dialog for a valid movement order. Invalid destinations show a brief reason; rejected orders should preserve the existing valid state/queue.

**Status:** Specification intake and suggested redraft only. No movement code, interface or GitHub changes; execution remains deferred with the rest of the batch.

### Pending batch continuation — profession roster and neutral inhabited sites

**User-specified roster (11 roles):**

| Profession | Requested purpose |
| --- | --- |
| Worker | Base untrained population role. |
| Biologist | Bonus across biological extraction tasks, not only one food crop or workplace. |
| Extractor | Bonus to hard/material extraction tasks. |
| Engineer | Bonus to industrial-grade conversion tasks; a power-production bonus is tentative (“maybe”), not settled. |
| Scientist | Research/Science bonus. |
| Medic | Bonus to settlement growth-penalty reduction while working the relevant building. Medical reduction may exceed the penalty: surplus then adds positively to growth rather than being capped at zero penalty. |
| Merchant | Can visit neutral inhabited map sites and provide that site's bonus to the settlement/global supply. Other professions can do so too; Merchant receives a bonus. Include 1–2 starting examples, specifically a Culture site and a Research site. |
| Administrator | Include the role; detailed development deferred. |
| Soldier | Include the role; detailed development deferred. |
| Explorer | Include the role; detailed development deferred. |
| Artist | Generates Culture with a profession bonus. |

**Suggested neutral-site examples (names proposed, numeric rewards not set):** Storykeepers' Enclave → Culture; Independent Observatory → Science. Both are inhabited neutral sites and accept visits by non-Merchants too; the Merchant improves the benefit. This does not yet specify whether visits grant one-time rewards or recurring access, repeat/cooldown limits, settlement routing versus global pooling, or an automatic versus explicit visit action.

**Clarifications / boundaries:** This user roster supersedes earlier assistant suggestions for the target roster. Old Farmer, general Specialist and Security save-role migration/replacement remains an implementation decision, not a deletion performed during intake. Medic contribution to the growth expression is `- size penalty + medical reduction`, with positive surplus explicitly allowed. Professions, jobs and persistent cohort identity remain distinct. No exact numerical role bonuses or training costs have been selected here.

**Status:** Recorded with the rest of the pending batch; no code, sprites, training, map sites or GitHub changes. Execute only when Viktoras says the batch is ready.

### Pending batch continuation — equipment, unit functions, retraining and grouped UI

**Requested:** Units are population/people using equipment stockpiled in settlements. Equipment, buildings and improvements are manufactured/constructed using the secondary Industry resource. Equipment can be combined; examples are Small Arms, Rover and Work Suit / exoskeleton. Rovers provide transport usable by everyone; arms and suits support specific functions. Construction is restricted to builders; Soldiers fight/retaliate efficiently. Further important Soldier and Explorer advantages are to be developed later. Add a “Clear specialty” decision for later retraining. Group repeated same-kind items and tiles with a `(number)` count for readability.

**Design interpretation to carry into execution:**

- Keep person/cohort identity, profession, assigned task and equipped items separate. Equipping a Rover does not create a second independent population identity or erase the user's profession. “Workers” here is the general population concept, not a demand to strip every trained person to the untrained Worker role.
- Equipment comes from settlement stocks and can form a combined loadout: e.g. a person with Rover + Work Suit, or a Soldier with Rover + Small Arms + Work Suit. Exact slots, quantities, equip/return rules, transport capacity and consumption/durability are not yet specified.
- Rovers should not be restricted to Soldiers or Explorers. Useful profession bonuses remain distinct from the capabilities supplied by gear.
- Preserve the user's builder-only construction requirement. “Builder” eligibility (task/equipment/training) needs definition alongside the eleven-role roster; do not silently add a twelfth profession during intake. Likewise, “efficiently” qualifies the Soldier combat/retaliation statement; do not silently interpret this as a confirmed rule that all other people have absolutely no self-defence.
- “Clear specialty” removes the current qualification toward retraining into another profession; the same person persists. Exact cost/timing and any assignment or equipment consequences remain open.
- Repeated item/tile types use readable grouped counts, e.g. `Rover (3)`, `Small Arms (5)`, `Plains (4)`. Retain individual locations, ownership, jobs and identities for actual selection; counts are a presentation rule rather than merging distinct state objects. UI examples are illustrative, not fixed item quantities.

**Status:** Added to the pending batch only. No production, equipment, construction restrictions, retraining, UI code or GitHub changes yet.

### Pending batch continuation — technology prerequisites, workplaces and research investment

**Requested:** Expand the existing five technology groups modestly for testing variety and flavour: Biology, Industry, Military, Exploration/Research and Social. Add technologies for specific profession training, more tools/equipment, more terrain improvements and tier 1–2 buildings. More elaborate technologies require more than increased research cost: prerequisites may include other technologies, preceding buildings, specialists and sometimes resources.

- **Technology conditions:** Support explicit prerequisites across technologies, buildings, trained specialists and resources where appropriate. The precise distinction between conditions to research, unlock or operate something, whether prerequisites are local or global, and whether resources are possessed or consumed remains to be defined during execution. Do not silently turn all prerequisite resources into research costs.
- **Profession-associated workplaces:** Consume Energy, have passive output and specific additional yields when worked. Start with one worker slot and provide two slots later. Tier 1–2 progression should demonstrate this simply; exact outputs, power costs and whether the second slot comes through an upgrade or a replacement building remain open.
- **Settlement baseline:** The settlement itself produces only enough to begin very basic internal infrastructure. Preserve a workable bootstrap path into research, power and Minerals-to-Industry conversion; exact starting stocks and baseline yields are not set by this message.
- **Research:** Rudimentary Science is available passively and from terrain. Greater research output requires investment, such as powered facilities and assigned workers, with trained Scientists providing their previously requested bonus.
- **Scope:** A small, playable selection within the five current groups, not the full catalogue in the reference documents. No exact technology count, new branch or large expansion has been requested.

**Status:** Recorded only. The batch is still being listed; no technology tree, building, power, research, save or GitHub changes have been made.

## 30 October 2026 — accumulated batch execution, biome geography and navigation — Godot

**Requested:** Add broad geographic biomes inspired by Minecraft's thematic map regions, use them in generation, enlarge the map to represent test variety, add click-and-drag scrolling, and “note and begin” the accumulated batch. This authorises local execution of the previously pending economy, terrain, movement, profession, equipment and technology requests; it does not authorise a GitHub upload.

**Changed:** Local version 0.6 adds a reproducible 24×16 map with Temperate, Lush, Dry, Cold, Fungal and Coastal regions; context-sensitive deposits with all five basic bonus-yield examples; layered Forest/Hills, edge rivers, compact hexes and left-drag panning. Six stocks now distinguish Minerals and secondary Industry, with Energy operation, Science research and Culture development. Settlement growth accumulates from food output, consumption, size and medical reduction, including positive medical surplus.

Eleven professions now train and keep persistent identity. Equipment comes from local settlement stocks and combines; Rover transport is available to every role. Work Suits define builder eligibility without adding a profession. Added Clear specialty, grouped counts, two inhabited visit sites with Merchant rewards, powered passive/worked facilities with tier 1–2 slots, and twenty technologies across the five groups with technology/building/specialist/retained-resource conditions. Movement distinguishes entering/following/leaving Roads and river crossings; unfinished steps retain paid progress, Shift appends and ordinary right-click replaces orders without confirmation.

**Provisional choices / additional work:** Growth is automatic at 20 accumulated growth, without charging Food twice. Energy is a shared stock; workshops and generators consume Minerals; generators receive operating priority. Equipment manufacture and tier upgrades are immediate prototype actions. Visits grant shared rewards once per person/site. Supply reach is deliberately generous for exploring the larger test map. Older saves migrate into schema 6 while retaining people and old geography. Existing portraits serve as temporary proxies for new roles; combat capability values are previews only, with no opponents/combat resolution added. Original HTML and the 3D model lab remain unchanged. Detailed choices are in the project's `docs/Batch_06_Notes.md`.

**Checks:** 421 simulation/content/migration checks, 21 native UI/navigation/save checks and 245 model-lab checks pass (687 current checks). Headless import/startup and actual OpenGL landing/map/technology renders checked. Older simulation tests are preserved as historical v0.5 specifications, not counted in this total. Physical play testing and executable export remain pending.

**Upload status:** Not uploaded. GitHub remains version 0.5, commit `e5e9d064e5637b2eb3fa0fdc95d756994d837afb`; version 0.6 source is in the cloud working directory only.

## 30 October 2026 — dual map views, complete prototype assets and testing upload — Godot

**Requested:** Flip between pixel/sprite top-down and animated isometric 3D world views; show the last-used unit in a 3D stack; complete missing people, equipment, vehicles and world objects in both directions; keep small districts, distinct buildings, deposits and figures readable together. Add rotating vehicle wheels, human occupants in exoskeletons, movement facing, investigate showcase pauses, comment on animation cost and upload for testing.

**Changed:** Version 0.7 adds the shared-state 3D world alongside the pixel view, with the same navigation and orders, shader wind/water, walking/rolling travel, saved facing and last-use stack selection. One 3D figure appears per occupied hex; all people remain selectable. Added a reusable five-bone Rover and thirteen-bone suit/role variants, compact district platforms, separate buildings/resources and matching transparent pixel sprites. The native bake includes 113 model/sprite variants across all eleven professions, gear combinations and current structures/improvements/deposits. Added a single-viewport World asset catalogue in the model lab.

**Performance / additional fixes:** Static world geometry uses shared meshes/materials and MultiMesh batches; hidden world rendering/actors stop, including underneath the showcase. Showcase construction is distributed across frames; study shadows/MSAA are disabled. In illustrative 1440×900 software-renderer runs, the old synchronous opening call took about 203 ms versus 9 ms now; complete new preparation took about 1.4 seconds spread across frames. Default world median was 20.5 ms/frame with three figures; a 21-figure walking fixture was 46.6 ms, versus 42.6 ms with all motion off. These suggest rendering the additional parts dominated that fixture, not animation alone. They do not diagnose or predict the user's physical GPU. First-use shader/driver pauses may remain. Detailed measurements, official references and practical animation guidance are included in project notes.

**Checks / limits:** 1,001 current automated checks pass: 421 simulation, 21 native UI, 247 model lab and 312 world/art checks. Actual native OpenGL captures reviewed both views and layered district/building/resource/figure examples; repaired first-bake hex-face culling. New saves use schema 7 and migrate 1–6. Art remains deliberately simple; no suspension physics, large-world streaming, opponent/combat system, physical Windows testing or executable export was added.

**Upload:** Completed on explicit request to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `b643704a11ff2cd1e2ae1003ad42750e8f03f418`. Includes the previously unuploaded 0.6 batch. All 130 tracked files matched remote Git blob hashes before publishing; main branch verified. Source project only; open in Godot and press F5. HTML remains unchanged.

## 30 October 2026 — SMAC / Beyond Earth visual crossovers — concept experiment

**Requested:** Find a few populated-map screenshots from each game, “BE-ify” SMAC and “SMAC-ify” Beyond Earth, and suggest a hybrid appearance in an image.

**Created:** Reviewed three screenshots per game: SMAC upland colonies, a densely developed coast and an offshore mining base; Beyond Earth’s coastal academy network, Mandira bay and Cidadela/Manoel colonies. Generated three concept boards: **SMAC → BE** (three softer, materially richer map repaints), **BE → SMAC** (three sharper sprite-like, red-earth map repaints), and **Alien Planet — Hybrid Studies**, showing Symbolic / Balanced / Atmospheric treatments of a common proposed hex landscape. Source geography is interpreted approximately, not claimed as an exact tile-preserving edit or an actual playable screenshot.

**Discussion:** Preferred the Balanced hybrid: distinctive SMAC-like silhouettes, alien colour separation and readable infrastructure, combined with BE-like terrain relief, water and lighting. Suggested small distinct district/building/resource layers and optional labels/yield overlays rather than persistent large resource pins. These are visual suggestions, not an approved replacement of the current art direction.

**Reference trail:** SMAC sources: Steam’s [Planetary Pack gallery](https://store.steampowered.com/app/2204130/Sid_Meiers_Alpha_Centauri_Planetary_Pack/), [GameOver review](https://www.game-over.net/review/feb99/alpha/index.html), and the [IGDB-hosted ocean-base image](https://images.igdb.com/igdb/image/upload/t_1080p/scxp7p.png). BE sources: [CivFanatics academy guide](https://forums.civfanatics.com/threads/for-science-5-city-academy-spam-guide.542124/), [MobyGames Mandira screenshot](https://www.mobygames.com/game/69130/sid-meiers-civilization-beyond-earth/screenshots/windows/966568/), and [Square Faction gallery](https://squarefaction.ru/game/sid-meier-s-civilization-beyond-earth). Used the retrieved image files as visual inputs; no game mechanics or strategy recommendations were derived from the guide.

**Status:** Brainstorming images only. No source-code, gameplay, shipped art or GitHub changes. Uploaded Godot project remains version 0.7, commit `b643704a11ff2cd1e2ae1003ad42750e8f03f418`.

## 30 October 2026 — selected visual directions A / B applied — Godot 0.8

**Requested:** Apply roughly similar stylistic choices from the Hybrid Studies board: A / Symbolic for sprites, B / Balanced for 3D. Explain the choices and future extension rules in the change documentation, save and upload, and provide an actual opening-scene screenshot for later testing.

**Changed:** Shared rust/ochre/olive/violet ground, deep teal water, dark forests and pale industrial structures now connect both views. Sprite A replaces reference terrain crops with original pre-baked limited-palette ground, stepped-colour/contoured object sprites and cleaner default information overlays. 3D B adds softer world-space ground patches/grain, angular hills, layered canopies, warm/cool lighting and restrained water highlights. Buildings gain dark plinths/accent strips; settlements gain a focal habitation spine. Small platforms, distinct buildings, exposed deposits and figures remain separate.

**Continuing guide:** Project `docs/Visual_Style_08.md` explains palette, silhouettes, scale, placement, A/B differences, baking, runtime cost boundaries and the procedure for future visual additions. The project AGENTS.md points later work to that guide. Gameplay, save schema and the original HTML project are unchanged.

**Checks / additional fix:** 1,058 current checks pass (421 rules, 22 UI, 247 model lab, 313 world/art, 55 style). Headless import and actual OpenGL opening scenes checked. Toned down the first noisy terrain pass and corrected opening camera drift during layout resizing. Both 1440×900 screenshots capture the actual unchanged starting simulation, without added infrastructure or units; the capture script asserts state preservation. Physical desktop testing remains pending. This is a practical first adaptation of the concepts, not a pixel-for-pixel recreation of generated art.

**Upload:** Published to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `33f09f60ea271b2eb52bcb2ef4a72ef789bf9b7c`. All 143 tracked source files matched remote blob hashes, and main was verified. Source project only; open in Godot and press F5. Opening previews: `Alien_Planet_Opening_Sprite_A.png` and `Alien_Planet_Opening_3D_B.png`.

## 30 October 2026 — medium illustrated frontier implemented — Godot 0.9

**Requested:** After comparing Colonization-inspired low/medium/high studies and their screenshot paintovers, implement the medium treatment in both game views and upload for testing.

**Changed:** Quieter rust/olive/plum terrain with an original painted ground texture, fuller layered forests, broad rounded hills, larger fruit/mineral/vent/specimen/monolith landmarks, lighter field outfits with rounder limb/head shapes, helmets and retained profession tools. Resource UI icons now come from tightly cropped matching physical models. Added restrained shoreline edges/water highlights and stronger light/fill separation. Both views share 118 catalogue/baked sprite entries, including five terrain-coloured hills. Current labels are Sprite / illustrated and 3D / frontier.

**Additional fixes:** Real hill surfaces now determine tree, deposit, structure and figure elevation. Queued walking/rolling samples slopes; roads follow segmented surface ribbons; clicks intersect terrain triangles. Removed dark cutout contours from sprite hill overlays, corrected icon padding and kept flat tile geometry simple. Existing skeleton joint counts, animation switches, hidden-view suspension and save schema 7 remain. Economy, map seed, rules and HTML were not changed.

**Continuing guide:** Project `docs/Visual_Style_09.md` supersedes 0.8, describes palette, silhouettes, placement, asset provenance/baking and future extension steps. This is a geometric implementation inspired by the medium concepts, not a pixel-identical recreation of generated paintings. Per-hex hummocks meet at level borders; foundations remain simple level platforms.

**Checks / limits:** 1,106 current checks pass: 421 simulation, 22 UI, 247 model lab, 322 world/art, 55 style and 39 frontier checks. Native 1440×900 OpenGL opening captures in both views preserve the default simulation; they are actual game renders, not paintovers. New checks cover hills, UI icon bounds, crest/shoulder picking, uphill travel, Motion-off placement and sloped roads. Physical play testing, representative hardware performance and standalone executable export remain pending.

**Upload:** Completed to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `9f6bd02c89d70ad38522b2d7d599baa42e7837ff`. All 148 tracked files matched uploaded Git blob hashes before publication; main was verified. Source project ready to open in Godot 4.5.1 Standard and run with F5. Actual previews: `Alien_Planet_Opening_Sprite_Medium.png` and `Alien_Planet_Opening_3D_Medium.png`.

## 30 October 2026 — visual follow-up and next batch intake — Godot 0.9xx

**User feedback / correction:** Viktoras confirms the sparse actual opening screenshots reproduce the visual problem being reported. Do not require another screenshot to acknowledge it. The earlier SVG presence audit did not establish correct on-screen presentation. A source-only copy reproduced the sparse sprite view, resolved all 118 catalogue lookups and loaded all six SVGs without missing-asset errors; a number of resource drawings occupy only 15–26 pixels across an 80px atlas cell. Visibility, scale, layering and the shortfall against the medium art reference remain unresolved work. No runtime missing-resource error has yet been reproduced; this does not mean the visual result is satisfactory.

**Requested next changes — record before execution:**

- Align sprite and 3D maps to the same cardinal orientation. Then make moving left/right behave relative to that shared viewpoint, and invert up/down as requested. The exact affected input gestures/controls were not further specified; do not change hex adjacency or simulation movement rules merely to alter view orientation.
- Future version updates use **0.9xx**, rather than advancing to 0.10. An exact next suffix has not been selected.
- Simplify the model library around base people rather than listing every tool/weapon combination as another person model. User wording: “a non trained soldier soldier is one model, a worker with exoskeleton is one worker.” Preserve this wording because the repeated “soldier” leaves the precise base-model grouping open. The clear requirement is that equipment configurations are separate from person identity/model selection; an exoskeleton-equipped worker remains one worker.
- Tools and weapons are separate configurations on those people, not independent duplicated population identities or an expanded matrix of person entries in the visible library.
- Rovers become **Transports**, each able to carry **two cargoes**. Cargo contents, whether people/goods use the same slots, load/unload actions, capacity accounting and behaviour of the driver are not specified yet. Record the two-slot requirement without inventing those mechanics during intake.

**Status:** Specification intake only, ahead of implementation. No new game-source changes or GitHub upload. Published project remains 0.9, commit `9f6bd02c89d70ad38522b2d7d599baa42e7837ff`; art/visibility corrections and this batch are pending.

## 30 October 2026 — debugging, shared views and two-person cargo — Godot 0.901

**Requested:** Cargo currently means people/units of any type; halve the fast Rover animation, debug the reproduced visibility problem and upload once working. This authorises execution of the preceding orientation/control, 0.9xx versioning and model-library batch.

**Debugged / fixed:** Asset source files were present. The sprite renderer interleaved ground and objects, so later neighbouring ground could paint over earlier objects. Switched to ground-first/object-second drawing, tightly cropped visible-content bounds, category-based sprite sizes, fully visible worker portraits and better separation of resources/figures/vehicles from settlements. Unknown sprite keys now warn and show a visible fallback. Checked actual native opening and developed-layer renders. These are visibility fixes within the current geometric art, not a claim that the generated medium paintings have been reproduced exactly.

**Views / library:** Both maps face east-right/south-down with the same initial 4,3 framing; horizontal drag follows input and vertical drag is inverted consistently. Hex movement rules remain unchanged. The visible World asset catalogue is reduced from 118 variants to 63 base entries, including eleven base people, with separate profession-tool, weapon and exoskeleton controls. The internal 118-variant bake remains complete for gameplay loadouts; joint counts and people identities are unchanged. Version label is 0.901 under the new 0.9xx convention.

**Transports:** Rover is now displayed as Transport. The existing equipped person remains its driver, with two additional passenger slots accepting any profession. Co-located idle residents or mobile people can board; each keeps identity, equipment, qualification, home and Food/population upkeep. Passengers follow the carrier, have no independent map figure/route, and unload onto its current tile with movement returning next turn. Loaded carriers must unload before joining a town or boarding another vehicle. Self-carrying, invalid carriers, third passengers and malformed cargo saves are rejected. This driver-plus-two-passengers interpretation and the provisional same-tile load/unload rules are explained in project `docs/Batch_0901_Notes.md`.

**Animation / saves:** Transport travel is 0.40 seconds per crossed hex instead of 0.20, and wheel spin 3 radians/second instead of 6. Other walkers retain their speed. Turn movement points/costs are unchanged. New cargo states use save schema 8; earlier supported saves migrate with existing people/equipment retained. Older game versions cannot load new cargo saves.

**Checks:** 1,291 current checks pass: 421 rules, 22 UI, 247 model lab, 322 world/art, 55 style, 39 frontier and 185 new 0.901 checks. Tests include every profession as cargo, capacity/atomic rejection, upkeep, saved cargo, movement and unloading, orientation/pan projection, independent model configurations and halved transport timing/wheels. A fresh source-only copy imports and passes the new suite. Native opening capture preserves the default simulation. Physical desktop testing and standalone executable export remain pending.

**Upload:** Published on request to [Alien-Planet-Godot](https://github.com/ViktorasZigaras/Alien-Planet-Godot), commit `797d0560c9fe6e7ab36ef5f242c8269160d2b107`. All 151 tracked files matched uploaded blob hashes; main was verified. Actual opening previews: `Alien_Planet_Opening_Sprite_0901.png` and `Alien_Planet_Opening_3D_0901.png`. HTML unchanged.

## 30 October 2026 — claims, independent red civilization and simulation-recording preparation — local Godot 0.902

**Requested:** Radius-two claims around both blue starting settlements, with small stones at hex corners and only the continuous combined outer ring; a separate red civilization down in green terrain using the same mechanics/tech tree without sharing blue's progress or supplies; a function-driven interest in population, tile development and research; prepare action/outcome recording for future simulated games. Defence follows combat rules later. **Do not upload yet.**

**Changed:** Blue's two town claims merge into one boundary, with no internal same-player border. Both views draw corner stones and a thin connecting blue/red line; towns have owner flags/coloured names. Red Haven is at 10,8 in a clear lush/grassland landing patch, with its own radius-two ring, five people, ordinary resource/equipment stocks and basic services. Each civilization has separate people, stocks, equipment, research, visits, buildings, improvements and projects. Shared geography is combined only for map presentation; blue's overlays/economy retain its own context. Foreign economic orders are rejected; red inspection is read-only.

**Function-driven controller:** Added a deterministic state-to-command policy which uses ordinary GameRules commands: food/workplace assignment, a suited builder, training, technologies, districts/workplaces and farms. It runs up to eight actions and one economy/project turn per blue End Turn. Reserved district plots prevent the policy from filling all building sites with work/farms. Explicit people/tile/job ordering preserves choices through JSON save/load. No stock/research grants or GPT decision calls are used. The profile records future defence as deferred, with no combat/retaliation invented yet. This is a basic testing policy, not a balanced or strategically optimised opponent.

**Testing preparation:** Added a Testing tab with side-by-side civilization summaries, focus controls, recording start/manual finish and JSON export. Recording is off by default. Events record player, logical sequence/turn, exact accepted/rejected command, short policy-rule label, engine result and before/after outcomes. Export includes complete starting states, seed, final summaries and an explicit outcome object; no winner is inferred before victory rules exist. Both players can use the same command_for interface. Traces cap at 10,000 events and report dropped events; no claim of complete replay after truncation. Full saves preserve both civilizations and recordings. Schema 9 migrates prior supported saves and prevents older games silently ignoring civilization state. Project notes: `docs/Batch_0902_Notes.md`.

**Checks / observations:** 1,579 checks pass: 421 rules, 22 UI, 247 model lab, 323 world/art, 55 style, 39 frontier, 185 0.901 and 287 new 0.902 checks. New checks cover radius/closed outer rings, independent stocks/equipment/technologies, rejected foreign orders, both map owners, save migration, malformed nested states, accepted/rejected recording and exported-command replay. Two 65-turn function runs match even when one is repeatedly saved/reloaded. Red grows beyond five people, develops all five districts and improvements, and reaches all twenty current technologies through ordinary commands; blue receives none of that development. Energy/input shortages remain observable policy weaknesses for later balancing. Native OpenGL starting-claim and labelled 65-turn fixture captures reviewed; starting capture preserves simulation. Physical performance/play tests and executable export are pending.

**Upload status:** **Not uploaded.** Local working version is 0.902; GitHub remains 0.901 at `797d0560c9fe6e7ab36ef5f242c8269160d2b107`. The cloud working source is not backed up by these notes or preview images. Original HTML remains unchanged.

## 2026-10-30 — Local 0.903: xeno nest ecology — Godot

**Requested:** Add a non-player nest in purple terrain, mandibled worker larvae, ordinary and armored predators, biomass feeding and births, mineral-dependent heavy predators, worker-spread dark-green xenomass and wandering threats. Do not upload.

**Changed:** A rooted brood mound at 18,12 begins with two larvae and two Hookrunners. Each nest supports three workers and six predators combined. Workers forage for biomass and minerals and spend biomass spreading the mat within three hexes. Every body eats; shortages cause damage. Births pay costs, with minerals required for Carapace predators. Predators roam, detect nearby people and pursue either civilization. The mat improves xeno harvesting; its future combat bonus is reserved but inactive. Ecology uses saved deterministic random state and advances once per complete blue/red round. It has local stocks and no civilization identity, claims or tech tree.

**Additional work:** Added original matching geometric models and sprites, terrain-following xenomass, movement animation, inspection and Testing summaries. A small provisional xeno-only encounter rule lets predators attack adjacent people and permits explicit human attacks and limited retaliation; deaths clean up assignments and release transported passengers. No human-versus-human combat or military policy was added. Environmental events now enter recorder v3; save schema 10 migrates older games. World sprites now include 124 variants. Project detail is in docs/Batch_0903_Notes.md.

**Checks / open points:** All 1,757 checks pass, including 163 new ecology checks for paid births, caps, harvesting, hunger, mineral costs, encounters, death/cargo cleanup, migration and deterministic save/load/replay. Native OpenGL opening captures and a twelve-ordinary-turn progression were reviewed. Nest foliage is suppressed visually for readability only. Power values, food rates and population limits are arbitrary test values. No physical play/performance benchmark or executable export is claimed.

**Upload status:** **Not uploaded.** Both local 0.902 and 0.903 remain unuploaded; GitHub stays at 0.901, commit 797d0560c9fe6e7ab36ef5f242c8269160d2b107. Notes and preview images are not a backup of the unuploaded working source. HTML is unchanged.

## 2026-10-30 — Pending terrain overlays and cleansing — Godot (notes only)

**Status:** Recorded for later implementation, as explicitly clarified by Viktoras. No game code, art, save schema or version changed; working game remains local 0.903. No source uploaded.

**Requested rules:**

- Xenos are animals. Xenomass boosts animal yields but penalises everyone else's yields. Human workers must cleanse a tile to remove xenomass. Exact penalty and cleansing duration/cost remain unspecified.
- Scatter dots and blobs of biomass around the map. Keep this requested map presence distinct in the notes from nest-generated xenomass; its precise collection/removal behaviour is not yet specified.
- Add scattered waste/toxic-sludge pollution as a tile overlay with three severity levels. Maximum pollution gives no yields; middle severity penalises every yield type by 2; lowest severity penalises every yield type by 1. Cleaning reduces severity one level at a time, ultimately clearing the tile.
- Brambles and stone formations are removable overlays with production penalties of 1 and 2 respectively. Exact scope of “production” is pending: minerals is a possible interpretation because it replaced the old production yield, but this was not confirmed and must not be silently fixed in implementation.
- Deserts have no trees.
- Add biome-dependent light vegetation. It changes no yields, but must be removed before building things on a tile.
- Forests likewise must be removed before building, and have biome-specific visual versions. Retain existing forest mechanics unless a later instruction changes them.

**Open implementation details:** Xenomass penalty magnitude, cleansing labour/equipment/cost, biomass collection rules, overlay coexistence and penalty stacking, production-penalty scope, and the scope of construction requiring clearance (buildings/districts/improvements/roads) are not yet fixed. No additional choices are approved by this note.

**Changes made / checks:** Updated this high-level log only. No mechanics implemented, no new tests run, and no source upload.

## 2026-10-30 — 0.904: combat, cleansing and single-seed army test — Godot

**Requested:** Implement and upload all pending work: environmental overlays/cleansing plus Civ-style strength/HP combat, rifle/flamer/spit ranged attacks, healing, defensive terrain, military infrastructure limits, equipment maintenance, no supply ranges, simple attack effects, a red hunting army and one maximum-200-turn test with deaths counted.

**Changed:** Added 100 HP and repeated-round melee duels. Equal healthy modified strengths have exactly 50% survival odds; stronger units gain compounding round advantages. Rifle Soldier strength 1, larva 0.25, predator 1, heavy predator 1.5. Terrain helps defenders, wounds reduce power, and quiet rounds heal 5 HP outside / 20 on a friendly settlement. Rifle ranged attacks use half strength at range two; heavy predators spit at range two. Trained-Soldier Flamer Exoskeletons use adjacent ranged fire and double offensive power against animals, with no added toughness. A cleared nest stops operating when a Soldier steps onto its tile, setting a burned flag; existing brood/mat remain. Human-versus-human warfare is not part of this test.

**Equipment / upkeep choices:** Security Districts and Guard Posts limit total Flamer and Transport stock/loadouts. Mobilised or carried Soldiers pay one extra Food each round beyond ordinary population consumption; deployed Flamers and Transports each pay one Industry maintenance. Stocked equipment has no field maintenance. Shortages impose one 25% readiness penalty. Flamer manufacture costs eight Industry. Supply-distance limits/UI are removed; terrain/river/road costs and movement queues remain. Animals block entry; queues pause for combat/rerouting.

**Environmental batch:** Implemented the previously noted requirements. Xenomass boosts animal extraction and subtracts one from human tile yields. Biomass patches give consumable extra animal forage. Three pollution levels give zero output / minus two / minus one to all tile extraction, for humans and animals. Brambles/stones reduce Minerals by one/two: a provisional interpretation of the requested production penalty, since Industry is converted in settlements. Suited workers cleanse one overlay per round; pollution decreases one level per action. Biome-specific light vegetation has neutral yields; it, forests and obstacles must be cleared before districts/improvements/roads. Forest visuals vary by biome and deserts have no trees. Penalties stack and floor at zero.

**Additional work:** Both map styles now contain 144 baked sprite variants / 89 base catalogue entries, including all new layers, flamer and ruined nest. Added view-only muzzle flashes/tracers, flame bursts, spit, sparks and a short 3D lunge. Avoided rebuilding ground geometry when wildlife counters change. Save schema 11 / world extension 3 migrate supported saves and scale old wounds; death counters begin at zero for migrated games. Recorder v4 preserves combat/environment outcomes, RNG and explicit final status. Red uses ordinary programmatic recruitment/equipment/hunting/retreat commands; no resource grants or GPT play calls.

**Final experiment:** One final-build attempt with seed 731, capped at 200 complete rounds. Blue only ends turns. Result: **turn limit; nest survives; blue deaths 0, red deaths 2, animal deaths 1.** Red finishes with 18 people, 15 technologies, all five district types, one deployed flamer and two unequipped replacement Soldiers. Energy and Industry are both zero; maintenance and absent advanced economic buildings stall the expedition. No balancing/reroll-to-win was performed. A preliminary diagnostic caught missing pollution penalties in animal extraction; it was corrected before the final experiment. Regression fixtures are engineering checks, not extra balance samples.

**Checks / evidence:** **1,880 checks pass** across ten suites, including 80 new combat/overlay checks. The final experiment contains 2,041 recorded commands, no dropped events, and exact action replay reproduces its final summary and deaths. Native OpenGL default-opening captures preserve state; combat/overlay/flame previews are explicitly staged fixtures. Full report, final save (gzip JSON), compact outcome and replay instructions ship under reports/0904/. Detailed rules and assumptions are in docs/Batch_0904_Notes.md. No physical desktop benchmark or executable export is claimed.

**Upload status:** **Uploaded on explicit request**, including previously local 0.902 and 0.903. GitHub main is now **0.904**, commit **3ab147645f2ad9450e5b0f685d52db170e543d75**. Uploaded tree exactly matches tested local tree 4e3bd787056e7e0f8dfe9fb0fb4e2020d7e7f61f, including the atlas and compressed reports. Local working commit is b5988dd; connector commit history has different IDs but identical file contents. Original HTML remains unchanged. Historical pending/local-only entries above describe their state at the time and are superseded by this upload.

## 2026-10-30 — Local 0.905: surveys, settlement expansion and territory atlas — Godot

**Requested:** Build locally without uploading: a human tile survey summarising a two-hex radius and reused by AI settling decisions; worker-founded normal settlement sites with initial one-ring claims, minimum population zero/inactive grey claims; assignable mobile allegiance markers; Culture access purchases up to three hexes; a maximum-200-round blue/red expansion/defence test and a flat schematic of the resulting territory. Clarification: at least **two intervening tiles between town centres**, hence minimum centre distance three, across both civilizations.

**Changed:** Added a Survey tab that updates on map clicks, using the same pure data function as AI site scoring. It includes nineteen tiles away from edges, terrain/biomes/relief/bonuses/yields, ownership, layers, river edges, roads/improvements, towns/districts/buildings, people/equipment/HP, neutral sites, animals and nests. Its output is potential unstaffed extraction, not promised staffed production. The AI uses this summary plus travel cost and explicit threat/spacing exclusions.

**Settlements / access:** Mobile suited builders found clear flat land for eight Industry and one movement. New sites start with one-ring land access, no free people or resource stocks, their own equipment store and the shell's starter services. Joining a person explicitly activates the town. Empty sites keep all territory but produce no landing/workplace yields or growth, consume no building/district power, provide no military capacity and cannot manufacture equipment. Markers become neutral grey; political registration is preserved. Existing settlements retain their old two-ring access. Connected land purchases cost four Culture in ring two or eight in ring three, with no range beyond three and no foreign-claim/water purchases. Local access now controls work/construction/cleansing; friendly towns may separately access an overlapping tile without duplicating its worker job.

**Interface / additional work:** Both live views show permanent mobile pennants from a validated, serialized programmatically assignable civilization colour. Added Territory Atlas with Export PNG, reusing an exact flat renderer for the final map: white settlement dots, B/R registration labels, gold district dots, green improvement dots, brown roads/local road marks, grey empty regions, green xenomass hatching and nest marker. No detailed unit art or game interface is in the exported map. Testing can simulate one round with both AIs. Pioneer plans are ordinary recorded commands and are cleaned up on death. Stable town/tile ordering fixes save/load decision drift. Copying immutable past trace events avoids repeatedly deep-copying the entire accumulated log; command/input-trace immutability is checked. Schema 12 / world 4 / recorder v5 preserve access, plans and colours and migrate prior supported saves.

**Final test:** One completed final-build seed-731 run, capped at 200 rounds, both civilizations using programmatic expansion/defence commands. Blue finishes with **20 survivors, five sites (two inactive), 95 registered claimed hexes / 94 land hexes**. Red finishes with **zero people, two inactive sites and 50 preserved land claims**. Cumulative deaths: **blue 3, red 98, animals 2**; red's count includes replacement population born during the run. The nest survives with three larvae and six armored predators. Registered claims cover 144 of 366 land hexes, about 39%; active blue claims cover 60 hexes. Both sides stall or lose people rather than cover the map. Grey central regions are preserved empty registrations, not a new faction. No tuning/reroll-to-win was done. Earlier diagnostics exposed ordering/reproducibility and initial Transport-upkeep bottlenecks; those engineering issues were corrected before the retained final test.

**Checks / evidence:** **1,911 checks pass** across eleven suites, including 31 new survey/settlement checks. All **3,121 recorded commands** replay to the same final summary; no events were dropped. Final save validates after every round. Native Survey/Atlas windows and final UI-free PNG reviewed; the PNG comes directly from the final save without staging. Full report/final save and compact summary are local in reports/0905/; details are in docs/Batch_0905_Notes.md. Physical desktop play/performance checks and executable export remain pending.

**Upload status:** **Not uploaded**, as requested. Local version 0.905 is committed as **c936972**. Last uploaded source remains 0.904, commit 3ab147645f2ad9450e5b0f685d52db170e543d75. Notes and preview images do not back up the unuploaded source. Original HTML is unchanged.

### 2026-10-30–31 — Persistent civilization planning — Godot 0.906

**Requested:** Add coordinated survive, expand and chosen-resource income activities, explaining why and when; include defence, offence, settling, terrain manipulation, research and training priorities.

**Changed:** Civilizations now keep persistent plans with stages, allocated people, requested budgets, priorities, blockers and cooldowns. Actual economy and five-turn economic forecasts inform goals. Research/training follow the prerequisites of useful plans. Settling evaluates a destination, departure costs, clearance, founding/population and optional escort; defence retains home troops, while offence assembles a surplus force and checks known opposition. Terrain work cleans and improves useful accessible land. The **AI plans** tab shows these decisions, history and forecasts and allows an income focus/target. Both players still use ordinary rule commands; no language-model calls or free resources.

**Additional work:** Fixed save/load decision ordering, cooldown expiry, founding over a worked plot and existing jobs becoming invalid when environmental penalties reduce yield to zero. Reduced repeated economic-copy/validation work. Saves migrate to schema 13/world 4; recorder v6 includes plan reviews. A workspace disconnect interrupted the first release check at turn 160; the same-seed rerun adds ten-round checkpoints and matches all 32 earlier periodic snapshots.

**Checks / outcome:** **1,992 checks pass** across twelve suites. Completed 200-round seed-731 test: blue **81 people / 10 sites**, red **88 people / 11 sites**, one inactive site each; registered claims 91 / 95 hexes. Both finish with positive income in all six resources. Deaths: **7 blue, 10 red, 2 animals**. The nest remains active. All **3,776 recorded commands** replay with matching acceptance, final physical summary and both private AI plans/history; no events dropped. Native AI panel preview reviewed. Full test records and details are local in reports/0906/ and docs/Batch_0906_Notes.md.

**Open points:** This is an inspectable heuristic first version. Its two-person offensive expedition does not yet resize itself to overcome stronger opposition; conservative holding is not a nest victory. Late-game job/route evaluation can be slow. No physical hardware benchmark or executable export is claimed. Earlier test outcomes remain preserved.

**Upload status:** **Not uploaded.** Local version 0.906 is committed as **a903b8b**. Last uploaded source remains 0.904 (3ab147645f2ad9450e5b0f685d52db170e543d75); 0.905 and 0.906 remain local. Notes and preview do not back up unuploaded source. Original HTML is unchanged.

### 2026-10-31 — One-off inventory and AI action review — Godot 0.906

**Requested:** Two one-off references: the entire implemented game inventory and a clear definition of what programmatic players can assess/plan; then a meaningful-action review, area by area, covering what players do/do not attempt and how future decisions could make neglected content worth attempting. Use the original brief, user prompts, implementation and development/test history.

**Produced:** **Alien_Planet_Inventory_and_Player_Capabilities_0906_2026-10-31.md** inventories resources, geography/layers/deposits, settlements/claims, all eleven professions, six equipment types, five districts, eleven building types, nine improvements, all twenty technologies, wildlife/combat, art/rigs, interface, persistence/testing and the exact bounded AI decision process. **Alien_Planet_Action_and_AI_Coverage_Review_0906_2026-10-31.md** distinguishes legal, AI-connected, observed and useful actions; reviews every content area and command family, with observed counts, missing triggers, candidate completion tests and a small future experiment programme. Both are dated frozen snapshots, not continuously maintained specifications or approved gameplay changes.

**Review findings:** Recomputed the 959 ordinary orders, separate from record bookkeeping. Final population has 161 Workers among 169 people, with 57 idle. Documented weak growth/employment demand, absent transport/medicine/visit policies, ignored improvement alternatives and fixed offensive sizing. A concrete coordination issue is visible: 20 of red's 24 Generator staffing orders were next undone by terrain unassignment. Flamer selection can manufacture an item, fill capacity and then select a rifle instead of equipping that stock. These findings are recorded for discussion; neither policy nor balance was changed.

**Additional correction / checks:** The old report prose double-counted predator subtypes. Actual final wildlife is three larvae plus six predators, all armored; the report's armored value is a subset. Corrected only reports/0906/README.md in local commit **d679230**. Cross-checked all content IDs/technology entries, ordinary-command counts, final role/wildlife counts and Markdown table structure. No new simulation or full regression run was needed for this documentation-only task; the existing 1,992 checks/replay remain the prior batch's evidence.

**Upload status:** Documents and this note saved; **no GitHub upload**. Gameplay remains local 0.906 (`a903b8b`), with the local prose correction above; remote source remains 0.904. The snapshots are references, not a backup of unuploaded source. Original HTML is unchanged.

### 2026-10-31 — Ruler, adviser choir and persistent governors — Godot 0.907

**Requested:** A player that knows its identity, higher goal and current resources; blue favours technology/specialisation while surviving/expanding, red strongly opposes the animal nest. General, scientist, city planner and settlement governors propose competing work; a ruler commits without constantly reshuffling everything. Implement and observe a game.

**Changed:** Added private saved ruler doctrines and an adviser council. Reviews use actual stocks/flows/workforce/equipment/threats; scored proposals compete for a bounded authorised portfolio. Settlement roles persist and governors pursue trained local production/workplaces. The scientist has a capability programme, the planner proposes surveyed expansion/road corridors, the general requests an adaptive force, military capacity, viable construction hub, equipment and refitting. Desired resource budgets and actor allocations remain ordinary-command commitments. Six-turn operating-job terms apply even within one adviser; emergencies can override. Ruler project commitments have a six-turn preference rather than an absolute lock. Temporary construction loans retain the previous job and attempt restoration after the project. UI shows missions, governor roles, opinions, authorisations and deferrals.

**Additional engineering work:** Fixed stocked flamers being ignored at manufacturing capacity, over-retained civilian actor reservations, premature loan restoration, equivalent building-slot bouncing and within-governor Food/Science assignment oscillation. Mineral support is considered for Energy as well as Industry. Canonical map traversal on JSON import keeps adviser explanations/private replay deterministic. Schema 14/world 4/recorder v7 preserve the council; prior saves migrate. Intermediate runs exposed implementation faults before the retained experiment; no combat values, starting stocks, passive yields or animal rules were tuned to obtain a victory.

**Checks / final experiment:** **2,043 checks pass across thirteen suites**, including 55 new council checks. Completed 200-round seed-731 game: blue **45 people / 7 sites (one inactive) / 16 technologies**, red **43 / 6 active sites / 13 technologies**. Blue has nine surviving professions including Worker; red five. Staffed workplace jobs are 10 / 8. Deaths: **0 blue, 25 red, 2 animals**. Nest remains active with three larvae and six predators, all armored. All **4,186 commands** replay to matching acceptance, physical summary and both entire private councils/plans/history; no dropped events. Native blue/red council previews after 25 ordinary rounds were reviewed. Full records/observations are local in reports/0907/ and docs/Batch_0907_Notes.md.

**Observations:** The architecture produces clear doctrines and materially more specialisation/infrastructure. Red starts 31 Soldier training orders and manufactures/equips 18 flamers, but initiates only two rifle attacks; no flamer shot is recorded. Its general spends heavily on preparation while tactical firing/retreat needs better service. No same-turn A→B→A employment reversal cycles occur in the final run. Soft funding commitments still change early at times, and builders/power/input dependencies can block advisers. Twenty-four road orders occur in shared terrain helpers, but none belongs to the dedicated road proposal: opinions do not guarantee mission execution. Blue ends with Energy net −2 backed by a stock buffer. Hierarchy makes sense, but is not itself a winning strategy or a complete dependency/tactical planner.

**Upload status:** **Not uploaded.** Local 0.907 committed as **6e388ea**; last uploaded source remains 0.904. The two one-off 0.906 reviews remain frozen historical documents. Notes/previews do not back up unuploaded source. Original HTML is unchanged. No physical hardware benchmark or new executable export is claimed.

### 2026-10-31 — 0.908 tactical lieutenants and cleansing experiments — Godot

**Requested:** Give generals tactical lieutenants with objectives/task forces; both rulers target the nest, prepare forward settlements/roads, prefer at most three combat units per tile, and generate occurrences for evolving provisional tactics.

**Changed:** Added a saved lieutenant per civilization with a field-order fast path before further recruitment/construction preparation. Soldiers use stable target ordering, ranged fire, favourable finishing/supported-flamer charges, wounded retreats and short advances favouring cover/comrades. The three-armed-mobile-Soldier tile limit is a soft AI preference, with explicit retreat exceptions; engine/human stacking is unchanged. Both rulers request the nest campaign; forward-site progress and actual road proposals have stronger priority. The AI panel displays force, phase, results and rules. Saved occurrences distinguish orders, real attack outcomes, interval casualties and rule revisions. Small authored adaptations raise retreat/support/charge thresholds after relevant losses; this is per-match counter-based adjustment, not general or cross-game learning.

**Additional work:** First diagnostic exposed the general recalling the lieutenant's advances over supplies. New offensive movement now respects the general's forecast; immediate fire/retreat remain available. Mobilisation/equipment precede more preparation, and normal deployment/movement also check formation space. Preserved partial-edge movement, ordinary costs and separate civilizations; no freight/ammunition or new supply radius. Optional validated tactical data extends schema 14; recorder v8/game 0.908. Added a tactical notebook and an exact saved-state map timeline; frozen 0.906 reviews are unchanged.

**Experiments / observations:** Two complete default-seed 200-round development runs retained, neither disables the nest. Diagnostic A: blue 0 shots/charges; red 13 shots, 3 flamer charges and 3 direct kills; deaths blue/red/animals 1/4/3, red movement cancellations 214. Final B: blue never departs; red 9 shots, 0 charges/direct kills; deaths 0/9/2, red cancellations 3. Red constructs a genuine forward outpost and four road tiles, with seven ordinary orders from its dedicated road plan, but the outpost ends empty. Final population blue/red 7/8, technologies 15/13, sites 2/2 including one inactive per player. Red's observed Soldier losses raise retreat threshold 55→70 at its decision turn 192; other final thresholds do not change. The two runs change multiple planning details and do not prove causal tactical improvement. The remaining strategic bottleneck is assembling and economically sustaining the operation; nearby support and cover alone do not guarantee survival. Suggestions for matched encounter tests are documented, not silently implemented.

**Checks:** 2,685 checks pass across fourteen suites. Both experiments validate every round; final trace replays all 3,758 commands to identical physical outcome and both full private AI states, zero dropped events. Reviewed a schematic four-stage map and native game capture from the actual final save. The red-only deterministic expansion regression now runs to the campaign's 200-turn horizon, retaining real founding/access/growth assertions. Complete raw evidence and implementation notes are local in reports/0908/ and docs/Batch_0908_Notes.md.

**Upload status:** **Not uploaded.** Local 0.908 commit **b6f51657d543aa74d90508e8045031aa70079c75**; remote remains 0.904. Notes and map do not back up unuploaded source. Original HTML unchanged; no executable export or hardware performance claim.

### 2026-10-31 — 0.909 Green and supplied terrain-learning forces — Godot

**Requested:** Add Green in the eastern brown area, give Red/Green starting troops, have their generals identify the nest hex and let their forces approach while developing terrain-use rules.

**Changed:** Fresh games add independent Green Reach at 16,2 in existing dry/desert geography near the lush edge. Both Red/Green retain five civilian starters and normal stocks, and receive four extra trained field Soldiers (three rifles/one flamer) across two hexes. Both generals persist target hex18,12 and allocate offensive troops while retaining a home guard. Extended scheduling, validation, claims/colours, foreign inspection, ecology/death counters and recorder snapshots to three players. Blue keeps its previous policy; old saves keep their original roster/troops. Starting equipped gear is scenario-provided, with ordinary replacement technology/capacity/costs unchanged.

**Terrain learning / additional work:** Enemy attack events now include the victim's actual location, role and cover. Saved private terrain classes track observations, movement orders/quoted costs and actual incoming hits/damage/deaths. At three hits and60HP damage, caution1; with a death caution2. Each band subtracts2.5 from the next-step score, without changing terrain/weapon rules. Existing casualty-based retreat/support/charge thresholds remain. Red/Green field departure uses two-turn Food/Industry readiness, consistently in general/lieutenant orders; unrelated Energy shortages no longer veto those supplied forces. Canonical player order and normalized death summaries preserve JSON determinism. Added a new rulebook and six-stage actual-state map. The coarse movement-plus-one threat heuristic still underestimates the heavy predator's move-plus-two-tile spit envelope; documented for follow-up, with actual attack legality/damage correct.

**Final retained experiment:** Seed731,200 rounds. Nest survives; deaths Blue0/Red3/Green3/animals4. Red3/Green5 ranged attacks, no charges; one direct larva kill each. Green's two armored-target shots do6HP apiece. Actual closest nest approach Red4/Green2 hexes;26/30 advance orders and4/8 retreat orders. Each side loses its original three offensive troops, then ends with a home guard and one replacement flamer, below the two-offensive-member threshold. Final populations Red17/Green6, technologies7/10, one town each. Red records an Industry reservation blocker; Green remains at assembly/preparation. Red learns caution2 for fungal hills; Green caution2 for desert hills and1 for fungal hills. Both raise retreat threshold55→70; support/charge thresholds remain unchanged. These are encounter-risk associations confounded by opponents/locations/HP/equipment, not proof that hills are intrinsically worse. Initial troops bypass recruitment but not replacement planning.

**Checks:**3,133 checks pass across fifteen suites,445 new. Final5,421-command trace exactly replays the physical result and all three complete private AI/terrain states, zero dropped events; every round validates. Reviewed native Green rendering/panel and map frames0/5/10/20/30/200. Preserved the earlier full validation before scoping the field-readiness refinement, and the20-turn diagnostic; they are engineering checks, not independent efficacy trials. Full final/pre-scope records and notes are in reports/0909/ and docs/Batch_0909_Notes.md. Earlier failed experiments and frozen one-off reviews remain unchanged. Game0.909/recorder v9, optional schema14/world4 additions.

**Upload status:** **Not uploaded.** Local commit **9821111951c7253be4d57fcc3df85bef39fc1617**; GitHub remains0.904. Original HTML unchanged. Notes/map do not back up unuploaded source; no executable export or hardware benchmark claimed.

## 31 October 2026 — binding operations and controlled preparation/execution tests — Godot

**Requested:** Try the proposed binding-decision foundation, test it, observe and analyse; do not upload source.

**Changed:** Added persistent Red/Green nest-operation charters: explicit target, fixed four-rifle/two-flamer expedition plus home guard, civilian support, protected personnel, prerequisite authority across advisers, staging, whole-force provisioning, guarded release and recovery. Existing ordinary game commands execute preparation; no wildlife/combat balance changes. Blue retains its previous policy. Added binding-operation inspection and reproducible diagnostics. Game0.910/recorder v10; optional validated schema14/world4 state.

**Additional fixes:** Removed conflicting completed-guard escrow and prerequisite reserve vetoes, reconciled troop ceiling with support population, prioritised domestic docking, prevented deployed soldiers remaining domestic workers, bounded repeated failure reasons, and made approved supply horizon decrease after launch rather than demanding a fresh24-turn budget every turn. This is a mission-specific supervisor, not a general dependency solver or computed force-strength estimate.

**Observed:** Normal-economy preparation-only test reaches first full readiness Red104/Green141. Final ordinary200-round campaign releases at104/141; Green remusters and releases again at200. Nest survives; deathsBlue0/Red4/Green4/animals4. Explicit early supplied fixture disables nest at world21 with no human deaths/9animal deaths. Mature-world supplied fixture from142 to201 still fails: additionalRed8/Green4/animals3 deaths. Fixtures grant complete forces/gear and2000Food/300Industry/300Energy/300Minerals; do not call them economically earned. Main fresh run resumed its own turn30 checkpoint after cloud interruption under unchanged final policy, without reroll/grants.

**Analysis / open points:** Binding chain can muster and dispatch the requested force, but preparation churn remains (main Red57mobilisations/56docks, Green19/13). Fixed six-unit template does not adapt to mature opposition. Ordinary and mature supplied cases produce no flamer ranged attacks. Joint approach/range/retreat handling, force estimation and stable civilian staffing are next gaps; observations do not isolate causal tactical advantages. Progress high-water marks can misclassify plateaus/rebuilding; preparation certificates are first milestones, not permanent200-turn readiness. Coarse heavy-spit threat envelope remains underestimated. Earlier failed experiments preserved.

**Checks / deliverables:**3,424 checks pass across16 suites (369new). Full canonical5,215-command trace exactly replays physical outcome and all3privateAI states, zero dropped events. Prep5027, early supplied2990, mature supplied1390 and earned continuation2053 also replay under final policy. Native rendering inspected. Saved report, four-panel actual-state atlas and native assembled-army screenshot. Raw compressed traces/states and version-bound pre-budget draft retained in reports/0910; docs/Batch_0910_Notes.md explains setup/limits. No hardware benchmark or executable export claimed.

**Upload status:** **Not uploaded.** Local final commit **838460b3d376c40d3d013103956be640422670cc** (earlier draft checkpoint48c4721). GitHub remains0.904. HTML unchanged. Notes/images are not a backup of unuploaded source.

## 1 November 2026 — inventory, experiment ledger and design clarification queue

**Requested:** Update the full game inventory and known-test behaviour summary; create a broad numbered list about system intentions and player capabilities, reporting the count before asking questions one by one.

**Recorded:** Updated the existing inventory and action/AI review identities with a current-through-0.910 opening section and retained their full 0.906 tables/review as historical baseline. The explicit request supersedes the earlier freeze instruction. Added a consolidated known-case ledger distinguishing final campaigns, development diagnostics, interrupted/repeated trajectories, supplied fixtures and replay/regression evidence. Created `Alien_Planet_Design_Questions_0910_2026-11-01.md`: **128 stable IDs Q001–Q128 across sixteen areas**, initial status unasked, waiting for the user's instruction to begin. Established decisions are contextualized; questions authorize no implementation.

**Evidence limit / correction:** The old unuploaded source directory is absent from this session; updates synthesize the saved log/reports and earlier content audit, not a fresh code inventory. Clarified that new founding gives one-ring access as documented in the 0.905 entry; the architecture guide's phrase “one-hex claim” must not be read as a verified single-tile rule. No new full content/asset counts are asserted beyond the last detailed audit and documented additions.

**Validation / status:** Preserved original detailed document bodies; verified question IDs are contiguous and unique at128. Documentation only; no new simulation, gameplay changes or GitHub upload. Latest reported gameplay remains local0.910, commit838460b3d376c40d3d013103956be640422670cc; remote remains0.904. Historical checks are not presented as rerun today.

## Format for subsequent entries

### Date — short topic — HTML / Godot / both

- **Requested:** …
- **Changed:** …
- **Additional work:** …
- **Checks / open points:** …
- **Upload status:** Not uploaded / uploaded on request, with version or commit.