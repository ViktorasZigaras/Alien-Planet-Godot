# Alien Planet 0.910 — source reconstruction

3 November 2026. **This is newly reconstructed code on the recovered 0.904 baseline, not the original lost 0.910 checkout.** Project version: `0.910-reconstructed`.

The user requested rebuilding the unuploaded work so a fresh development thread can continue. This package contains an actual runnable Godot project, not only specifications. No GitHub upload is performed by this reconstruction task. Preserve this ZIP or push an approved source snapshot before relying on temporary workspace files.

## What was recovered and what was remade

Baseline: `ViktorasZigaras/Alien-Planet-Godot`, remote commit `3ab147645f2ad9450e5b0f685d52db170e543d75` (0.904). All 194 baseline paths are present. The original terrain, models, current sprite atlas, content definitions, economy, people, equipment, movement, combat and wildlife are retained, with integration changes described below. `BASELINE_FILES.json` records the remote tree; `RECOVERY_PROVENANCE.json` identifies the modified paths.

One legacy fallback portrait atlas (`assets/population/population_roles_v1.png`) could not be retrieved through the connector's large-file route. It was rebuilt from the recovered current game sprite atlas into the expected portrait regions. This is a replacement, not the lost original picture. The normal world sprite atlas and native models are recovered baseline assets. Seven initially incomplete text-transfer chunks were re-fetched and verified against their remote Git blob hashes.

Historical unuploaded commit `838460b3d376c40d3d013103956be640422670cc` was **not** recovered. No claim of byte identity, original line count, identical campaign outcomes or reproduction of its 3,424 checks is made.

| Lost layer | Reconstruction in this package | Practical boundary |
|---|---|---|
| 0.905 geography/expansion | `tile_survey.gd`; founding and tile-access commands; claim projection; Survey/Atlas UI | Founding costs 4 Industry, retains the founder as resident and grants one-ring access. Purchases cost 4 Culture, connected within radius three. These are reconstruction choices. Grey inactive styling and exact original survey layout are not recovered. |
| 0.906 persistent development | Saved goals, five-turn own-economy forecast, shortages, deterministic assignments and prerequisite helpers | Forecast excludes future policy/enemies. Generic plan `budget` fields are inspection metadata, **not** the original complete escrow/reservation engine. |
| 0.907 ruler/advisers | Private doctrines, ranked proposals, authorizations/deferred display, town roles, job terms and construction loans | Advisers are responsibilities in one coordinator, not independent agents. Town role labels are retained; a complete recovered specialization optimizer is not claimed. Ordinary proposals can still be serviced when higher priorities are blocked. |
| 0.908 tactics | Separate lieutenant attention; ranged fire, supported charges, retreat, scored single-edge movement, soft three-combatant preference | Sequential local rules, not synchronized volleys or complete evacuation planning. Older hunting policy remains as historical source and is not the active dispatcher. |
| 0.909 scenario/adaptation | Green at 16,2; Red/Green five civilians plus four explicitly supplied field Soldiers each; private casualty and terrain memory | New games only get the new scenario. Loading an older two-player world does not inject Green or grant replacement troops. |
| 0.910 binding operation | Persistent target/hub; fixed four rifles/two flamers plus separate home guard; prerequisite-driven preparation; commissioning, staging, supply gate, deployment and recovery | Mission-specific supervisor, not a general dependency solver or enemy-specific army sizing. The 24-turn provision horizon decreases after release to a floor of four. Readiness is computed from actual people/loadouts/health, not a saved label. |
| inspection/evidence | Council/operation/lieutenant inspection; explicit all-AI stepping; generalized recorder and replay initialization; current regression tools | No old 0.905–0.910 raw traces were recovered. Fresh results are separate from retained historical reports. |

## Active code path

`civilization_session.gd` runs the human commands or the AI round. An AI turn records a replayable `aiReview`, then permits up to 12 ordinary commands before its economic turn. Faction IDs are normalized to strings and sorted to avoid save/load changing the turn order.

`ai_coordinator.gd` reviews goals and proposals. `ai_plan_actions.gd` returns legal next steps for resources, technology, workplaces, training, expansion and roads. `ai_operation.gd` owns the binding campaign contract. `ai_lieutenant.gd` supplies immediate tactical orders and bounded saved memory. `ai_assessment.gd` and `tile_survey.gd` expose economic/geographic facts. `game_rules.gd` and `xeno_ecology.gd` remain the authorities for costs and actual effects.

The full active plan chain is **goal → prerequisite command → ordinary engine validation/cost → project/staffing/equipment change → recomputed readiness → release → tactical execution → observed outcome/recovery**. No stock, research or people are granted by that preparation path. Explicit supplied test fixtures are labelled as fixtures.

Schema/rules 14 and world 4 are reconstructed formats. The migration path supports the recovered older schemas/worlds and retains factions. Similar numbering does **not** mean arbitrary saves from the lost original 0.910 implementation are compatible with this different AI schema.

## Integration fixes made while rebuilding

- Generalized ecology, casualty ownership, projection and recording to Green.
- Kept actual incoming combat location and nearby support in ecology events for private terrain/casualty memory.
- Clear exhausted zero-yield tile jobs so environmental changes do not leave invalid saves.
- Sort job/faction selection consistently, normalize generated population names, and validate JSON numeric representations.
- Keep construction loans reserved until a project has actually run, or return a long-blocked loan after a bounded wait. Ordinary income suggestions avoid immediately taking back the reserved builder. This is a reconstruction fix; it does not resolve all staffing churn.
- Require an armed, healthy, commissioned home guard as part of readiness. The engine, rather than display text, establishes movement/combat legality.

## Parity gaps to audit first

The recovered reports describe more fine-grained behaviour than can be reconstructed exactly from their prose. In this build, the five-turn forecaster is available as an assessment helper, while ordinary income ranking primarily uses current stocks/net flows. Full original funding escrow, per-governor economic specialization, adaptive general force requests, and a non-charter Blue expedition policy are not reproduced as complete equivalents. Governor labels/proposal displays must not be mistaken for evidence of all their historical decision branches. Audit these against the reports before declaring parity. The Red/Green mission-specific preparation/release path is implemented and demonstrated separately.

## Current evidence and limits

Read `../reports/reconstruction/VALIDATION_SUMMARY.md` and its JSON/log sources for final checks and campaign results. They are generated for this reconstruction. The old report counts and Red 104/Green 141 release dates describe the lost implementation, not this build.

The campaign is diagnostic, not a balance claim. Preserve failures: do not silently supply stocks, change combat strengths, reroll seeds or force victory to make a recovery appear successful. Preparation and tactical quality remain development work. No physical Windows play test or representative GPU performance benchmark is claimed. Headless UI checks establish construction of both views and panels, not visual polish.

The native capture attempt encountered unavailable X11 sockets in this environment; no native screenshot from that attempt is claimed as verified. Baseline rendering regressions and headless UI checks are retained separately.

## Design work is newer than the historical implementation

`current_design/` contains the complete decision ledger (Library version 147), the four-stage synthesis and S01–S18 early-game review. These are design references, **not implemented wholesale here**. Examples still deferred include fog of war, altered opening composition, localized/global Food pools, previous-turn production gates, trade exchanges, new sites, defensive structures, terraforming and ideological content.

The design interview progressed beyond Q080 in another thread and completed its direction round. The current review begins with S01. Do not use the older Q080 handoff cursor as the current agenda.
