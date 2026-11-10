# Alien Planet — source audit, reuse decisions and revised implementation approach

5 November 2026 • Stage three • Static source inspection and retained execution evidence

## Recommendation

**Evolve the existing Godot project through a small, coherent replacement of its core decision and accounting paths. Do not restart the whole game, and do not continue stacking advisers and campaign exceptions on the current dispatcher.**

There is substantial reusable work: ordinary legal commands, persistent people and equipment, hex geometry, resource-driven fauna, deterministic random state, recording/replay, a native UI shell, reusable model components and static geometry batching. Several central mechanics nevertheless implement older rules, while parts of the advertised AI architecture are records and labels rather than enforced constraints.

The strongest explanation supported by inspection is **fragmented authority and repeated work around a narrow policy**, rather than an intrinsically excessive number of game systems. The current code can perform many local actions but does not consistently connect them to successful civilization development. Rendering/turn-time concerns have identifiable candidate causes; their relative impact is not yet measured.

The recommendation is to retain the working project as a baseline, introduce one authoritative world state, one rule/effect path and one coherent allocation model, and migrate one capability at a time. Keep a narrow working slice while each replacement is reviewed. These are proposed implementation changes, not edits made by this audit.

## 1. What was actually audited

| Evidence | Result / boundary |
|---|---|
| Current repository | `ViktorasZigaras/Alien-Planet-Godot`, main at `8a9f3d6a9f9787bc11e8489f5426f9d3a650395c` when inspected |
| Source package | `Alien_Planet_Godot_0910_Reconstructed_2026-11-03.zip`, version `0.910-reconstructed` |
| Package SHA-256 | `61d512d90935a03dcb82e047c465d514bc7928a521979edca12e752224a7a288` |
| Repository comparison | All 273 repository file paths present. Git blob hashes match for 267; six differences are documentation/manifest files. **Executable source and assets match the inspected repository commit.** |
| Six differing paths | `CONTINUE_HERE.md`, `SOURCE_SHA256.json`, `docs/Development_Brief.md`, `docs/Model_Lab_Notes.md`, current-design early review and recovered AI reference |
| Source size | 5,997 lines across 31 main `scripts/*.gd` files; other scripts include tests. This is a scope measure, not a complexity score. |
| Code inspected | Session/turn/command ownership; rule legality/economy/projects/research/movement; active coordinator/planner/operation/lieutenant; survey/claims; ecology/combat; UI refresh; world rendering/batching/model assembly; relevant tests and retained checkpoints |
| Retained execution evidence | Reconstruction validation report, test source, 12-round replay record and 200-round campaign summary/checkpoint |
| Fresh execution | **No new game simulation, test suite or GPU benchmark run.** A Godot executable was not available on PATH. Source and existing-record analysis were sufficient for this architectural audit, but cannot establish current runtime speed or a newly reproduced failure. |

The lost original 0.910 commit is not the audited build. Its historical architecture reports cannot establish parity. No files were deleted or changed in the game source, and no repository writes occurred.

Evidence labels below matter: **source fact** means directly inspectable code; **retained result** means a result recorded in the supplied reconstruction reports; **inference** is a supported diagnosis still needing a targeted runtime check. “Keep” is a reuse recommendation, not a declaration that the component already satisfies the latest design.

## 2. What the present execution evidence does—and does not—show

The reconstruction report records 12 passing groups, 2,187 numbered assertions and a separate UI smoke check. Those cover useful consistency properties, including command acceptance, save/replay continuation and explicitly supplied force-readiness cases. They are historical results for this reconstruction, not rerun results from this audit.

The retained seed-731 campaign ran 200 rounds with five civilians and four supplied field Soldiers for each of Red and Green. It is not the intended new four-cohort opening.

| Outcome after 200 rounds | Blue | Red | Green |
|---|---:|---:|---:|
| Population | 11 | 27 | 13 |
| Technologies | 15 | 10 | 12 |
| Settlements in checkpoint | 2 | 1 | 1 |
| Recorded operation releases | — | 26 | 2 |
| Human deaths | 0 | 0 | 4 |

**One animal death; one active nest survives.** Red ends in recovery with 0 Minerals, 7 Industry, 2,706 Food, 1,099 Science and 863 Culture. That suggests a resource/decision bottleneck, not a general absence of accumulated resources. It does not by itself prove which change would fix the campaign.

The retained last 128 Red history entries include 21 docking orders, 18 return-to-hub orders, 15 commissioning orders and 13 staging orders. Blue's retained window contains 13 repeated `release_founder` actions while still holding its original two settlements. These are evidence of repeated preparation/reassignment behavior; the bounded history is not the entire campaign and cannot support full-run action-frequency statistics.

Milestones repeatedly show provisioning Industry and commissioning/staging blockers. This agrees with the preparation/recovery loop seen in source. A new causal trace should establish the exact triggering sequence before changing thresholds.

**The useful retained lesson:** legality, serialization and dispatchability can pass while strategic effectiveness fails. Keep the consistency tests, but change the definition of “AI got it” to the already agreed useful-outcome standards.

## 3. Architectural ideas worth retaining

| Existing idea / location | Disposition | What should remain |
|---|---|---|
| Serializable cohort identity, qualification, equipment and location — `game_rules.gd` | Keep and adapt | A person persists through work, training, mobility and equipment changes. This is the game's central connection. |
| Legal command interface — `GameRules.reason/command`, `Session.reason_for/command_for` | Keep interface; consolidate enforcement | Human/AI ordinary commands and explicit rejection reasons. World-dependent legality must not be bypassed by a planner checking only local rules. |
| Six-resource content and output ledger — `economy`, `content.json` | Keep definitions; replace affected accounting | Gross/net/input distinctions and workable Minerals→Industry bootstrap. New Food/storage/labor rules need one consistent implementation. |
| Seeded gameplay RNG and ecology — `xeno_ecology.gd` | Keep core, narrow interfaces | Actual resource acquisition/upkeep/spawning, persistent fauna/mass, distinct species and reproducible outcomes. |
| Hex coordinates, neighbor/edge geometry and movement queues | Keep semantics; simplify/cost-bound queries | Reuse coordinate/road/river conventions. Optimize searches only after correctness and workload are explicit. |
| Proposal → ordinary action helper direction | Keep purpose, rewrite enforcement | Domain routines propose feasible work; one allocator reconciles resources/people; actual outcomes feed reconsideration. |
| General/lieutenant responsibility distinction | Keep responsibilities | General plans and requests; lieutenant executes a specific task force. Do not require independent agents/processes or extra role objects. |
| Recording, validation and save/replay | Keep selectively | Deterministic logical checks, bounded causal evidence and ordinary-command replay. Old schema-specific expected outcomes need review. |
| Static mesh/material caches, `world_batch.gd` | Keep | Repeated static geometry already uses MultiMesh grouping. Do not rebuild an equivalent batching framework. |
| Shared rigs, tool attachments, modular model helpers and model lab | Keep as production tools | Existing 13-bone rigid-part human rig, vehicle parts and isolated model previews provide a starting assembly pipeline. They are not finished art. |
| Hidden-view suspension and reduced motion | Keep | Current 3D view can stop processing/rendering when hidden and toggle motion. Preserve during UI replacement. |

## 4. AI: what should change before adding more systems

### 4.1 “Authorization” is currently presentation metadata

**Source fact:** `AICoordinator.review()` records the first three proposal IDs as authorized and the remainder as deferred. `choose()` nevertheless loops over **all** proposals. Therefore a supposedly deferred proposal can execute. The UI label is not the intended authority boundary.

**Change:** define real execution eligibility and explicit fallback: a blocked high-priority goal can retain its purpose while another permissible task proceeds, but not by ignoring authorization metadata. Prefer a small concrete rule over a new council hierarchy.

### 4.2 “Budget” and governor records do not implement the promised allocation

**Source fact:** plans are initialized with empty `budget` and `actors`; after execution, `budget` becomes a record of `lastCommand`. Governors get a `research`/`production` label, but the inspected dispatcher does not implement a complete governor specialization/allocation model from it. Current staffing stability relies on job terms and construction loans.

**Change:** replace decorative fields with a minimal real commitment record: purpose, next legal step, reserved effort/actor/resources, dependencies, reason for blocking and release/reconsideration conditions. Do not reconstruct a sophisticated escrow framework merely because the lost implementation used that name.

### 4.3 General planning is a fixed mission supervisor

**Source fact:** Red/Green automatically choose the first unburned nest; operation validation requires exactly four rifles, two flamers, a separate guard and six civilians. It is not an enemy-power estimate or the leader's general choice among threats. While that operation is active, routine research/specialist/expansion/road proposals are suppressed; only some prerequisites still trigger research. Blue has a different non-charter path.

**Change:** keep the phase/state-machine concept—prepare, assemble, deploy, recover—but replace the hard-coded charter with a bounded selected objective, a force request grounded in known/suspected power and a real comparison with defense/development. Keep the old charter only as a labeled historical diagnostic if useful.

### 4.4 Tactical actions bypass civilian priorities and use weak support facts

**Source facts:** `choose()` asks the lieutenant before processing scored economic proposals. Legal ranged fire is chosen before checking that same Soldier's retreat threshold. Support counts armed mobile Soldiers within geometric radius two, including the unit itself; it does not check whether an ally can act in time. A minimum-support value of one can therefore be satisfied by the lone unit. The 12-command-per-turn loop can be spent on early tactical/preparation actions before other goals.

**Change:** emergency protection should have explicit priority, and tactical ownership must not consume or reassign a civilian commitment accidentally. Calculate useful support from feasible actions/arrival, excluding self where “ally” is intended. Review fire-versus-retreat as a tactical rule with observed outcomes.

### 4.5 Legality and planning context are split

**Source fact:** `AIPlanActions.legal()` checks `GameRules.reason(p, cmd)`, while `Session.reason_for()` adds world-level nest/foreign-claim/founding constraints. A locally legal proposal may be rejected by the actual session. `ai_turn()` breaks after a rejected command instead of excluding that candidate and trying a bounded alternative.

**Change:** use the same world-aware legality/query path for intent generation and execution. On failure, record the cause and reconsider another eligible action without an endless retry loop. A full new planning framework is unnecessary to fix this mismatch.

### 4.6 Old policy paths remain in the source

**Source fact:** `civilization_agent.gd` and `Session.military_intent()` contain older quota/hunting routines, but the inspected `ai_turn()` dispatches to the coordinator. The five-turn assessment forecast exists, yet no active runtime caller of `AIAssessment.read/forecast` was found in the inspected dispatcher; tests exercise the forecast directly. Normal income ranking is based primarily on current net targets and stock heuristics.

**Change:** remove unused policies from the active production surface after reference/test dependencies are handled; preserve historical evidence separately. Keep forecasting only where a caller uses it to improve a decision, with an explicit horizon and cost. Do not maintain parallel planners “just in case.”

### 4.7 Adaptation memory is not yet a reliable causal model

**Source fact:** incoming damage accumulates by terrain class and can increase caution after thresholds. Death counts change retreat/support rules. That records experience but does not isolate terrain from enemy strength, positioning or bad force composition.

**Change:** retain useful observations and build-qualified aggregate lessons; avoid treating “damage happened on this terrain” as proof that the terrain itself is bad. Authored rule improvement through reviewed trials remains the selected baseline, not unrestricted in-match learning.

## 5. Rules that no longer match the agreed game

| Current source behavior | New baseline | Disposition |
|---|---|---|
| One global six-resource stock per faction | Testing: location records for Food/Minerals/Industry; other pools global | Replace storage/accounting representation, preserve pooled access |
| Population-based 1 Food plus extra mobile Soldier cost; pressure counts everyone with a home | Productive settlement work 2; other cohorts 1; working civilians drive relevant support/pressure | Replace cost/support calculation and UI/AI consumers together |
| Negative stocks clamped to zero; warnings survive but deficit does not | Actual unmet need matters and drives reassignment/power | Replace shortage treatment, retaining explicit warnings |
| Flat 0.75 power penalty on zero Food/selected Industry; health strength uses `0.5 + 0.5×HP fraction` | Agreed shortage fraction multiplied with remaining health before modifiers | Replace effective-power calculation; reuse duel/odds structure only after updating shared inputs |
| Quiet-round healing can occur without a starvation exception | No automatic healing in catastrophic shortage | Add the agreed eligibility rule |
| Growth uses all-pop penalty and a `while growth >= 20` loop | New support/health logic, local/global Food distinction; maximum one grown cohort/settlement/turn | Replace growth resolution and its tests |
| Building/qualification presence satisfies research prerequisites | Relevant capability actually operated in the preceding turn | Add operational evidence; update legal query/UI/AI consistently |
| One construction project per faction, up-front full charge, countdown | Ordered settlement queues, allocated labor, partial affordable progress, hold/resume | Replace project model; reuse content/assets and basic legal constraints |
| Building upgrades are an immediate action | Intended timed work/labor where applicable | Route selected upgrades through project model |
| World and faction maps contain full current details; projection merges everyone | Known macro geography plus observed/remembered details | Add a real player-observation layer; do not use current projection as knowledge filtering |
| Neutral visits grant one-time bonus per person/site | Actual ongoing visitor services/exchanges with one service/pop/player/site | Replace service rules; retain site concepts/models |
| Ranged range only; no inspected line-of-sight terrain blocking; flamer melee allowed | Terrain-blockable rifle support; flamer ranged-only niche | Define tactical contract then update legality/resolution/preview together |
| Default opening: Blue two towns/five cohorts including Administrator/rover; rivals supplied field troops | One minimal town, two ordinary civilians, Soldier, Explorer and build kit | Preserve old setup as a disclosed fixture; replace default opening |
| UI starts at 1440×900 with sprite mode and many dynamically rebuilt panels | Fixed 1080p 3D-centered map and dedicated settlement/unit views | Rebuild player-facing layout while retaining commands and useful diagnostics |

Current ecology already gives xenomass harvesting benefits to native workers. A reserved future mass-combat constant is not an implemented combat bonus. Keep that distinction: fauna use is present in one concrete form, not every possible movement/healing/combat benefit.

## 6. Performance: evidence-backed suspects, not invented benchmark results

No representative current GPU measurement is available here. The existing `bench_views.gd` is a reusable diagnostic seed, not a pass/fail benchmark for the new design: it uses 1440×900, 45-frame samples and a supplied extra-pop workload. The reconstruction validation explicitly disclaims a physical GPU benchmark.

| Source fact | Likely cost / hypothesis | First measurement and narrow remedy |
|---|---|---|
| Session commands deep-copy the whole root; `GameRules.command` copies again. Blue's root contains rivals, ecology and optional recording history. | Repeated copying grows with world and history size, including for selection commands. | Measure copy/command time with recording off/on and increasing entities. Separate UI selection from gameplay state; avoid copying a historical recorder inside each gameplay snapshot. |
| `own_state()` deep-copies the entire world before removing rivals/testing/xenos; projection then merges rival objects. | Unnecessary copy work for a UI refresh. | Measure projection cost independently; construct a view of needed permitted data, with one observer filter. |
| Every `main.render()` rebuilds orders/development/report/testing/survey/mobile content, even after ordinary selection; hidden tab content is rebuilt too. | Allocation/layout and repeated query work may dominate click latency. | Time each panel and selection path; persistent controls plus dirty/visible-panel updates. Preserve useful feedback rather than hide it. |
| Both map views ask for a supply field on updates; 3D does so even though supply ranges are disabled and overlay often reset. | Full route computation can occur for an unused display. | Skip unused queries; cache by movement/world revision when actually needed. |
| `routes()` scans the open list for minimum cost and visits the reachable map; path requests don't terminate at target. | Path cost scales poorly and repeats in legality and execution. | Count searches/visited nodes, reuse one path result; use bounded/targeted search and a suitable priority structure if needed. |
| Income evaluation deep-copies cohort maps and recomputes the full economy for each legal person/job candidate. | Expensive candidate scoring as people/workplaces grow. | Measure candidate count and ledger calls; reuse unchanged facts and compute local differences where safe. |
| Terrain/structure signatures scan whole collections; one relevant structure/overlay change clears and rebuilds the full structure root. | Local changes may cause global CPU construction and resource churn. | Time signature/build work; use dirty regional/object groups and retain unaffected batches. |
| Static batching groups whole layers; model recipes create temporary node hierarchies before collection. | Already reduces retained draw objects, but repeated construction still costs; larger maps may need spatial chunks. | Measure build time and visible draw cost separately. Keep MultiMesh reuse, add chunking only where measurements justify it. |
| Map picking loops tiles and candidate mesh triangles on hover. | Cost grows with map density; current broad-phase avoids some triangle work but still scans tiles. | Time hover/pick on large maps; map projected location to a small candidate neighborhood before precise relief tests. |
| Human models use many rigid mesh attachments; per-bone poses find bones by name. | Animation/draw overhead may increase with visible figures. | Profile representative moving figures; cache bone indices and combine stable parts where appropriate. Retain moving attachments and silhouette detail. |

The checkpoint stores **three 384-tile maps**, one per faction/root, for 1,152 tile records. Their JSON sections total about 272 KB under this audit's Python serialization. This is a duplication observation, not a Godot heap measurement. Shared terrain and derived tile flags are synchronized through `X.sync_tiles`; any future pollution/fog work risks more synchronization branches if this ownership model remains.

Proposed ordering: remove obviously unnecessary queries and copying, measure again, then decide whether more advanced caching/chunking/loading work is needed. Do not prescribe multithreading, ECS, an event bus, GPU particles or a streaming architecture without a demonstrated workload. A slow turn and a slow animated frame are separate problems.

## 7. Content and visual work that can survive

The source catalogue contains 20 technologies in five trees; 11 qualifications; 11 building definitions; five district types; nine improvement types; six equipment types; six bonus-resource types. **Existing definitions are candidates, not an approved opening roster.**

| Content | Retain / adapt | Reconsider / exclude from initial opening |
|---|---|---|
| Workers and professions | Worker, Engineer, Medic, Soldier, Explorer and other defined specialties as identity/workplace vocabulary | Automatic “train one of every profession” policy; prebuilt advanced specialist economy |
| Equipment | Small arms, flamer, work suit, survey kit, reinforced suit, rover concepts and attachments | A work suit is not automatically the new build kit recipe; rover isn't mandatory starting gear |
| Economy assets | Workshop, greenhouse, clinic, lab, generator, civic/training/other facilities as reusable models/data | Split/bundle rudimentary center functions according to new baseline; don't preserve 11 separate buildings just because they exist |
| Districts | Production/agriculture/research/civic/security definitions and visual motifs | Current one-per-type keys and faction-wide single construction slot do not define the final capacity/queue design |
| Improvements | Road/farm/mine/energy tap and field/research/trade/defense/ecology concepts | Boolean improvements need versioned data for genuine upgrades; don't add all nine before usefulness is shown |
| Special geography | Edible flora/oasis/ore/geothermal/specimens/resonant-stone concepts | Existing full visibility and unrestricted bonus access must change; alien identity remains TBD |
| Wildlife | Larva/Hookrunner/armored predator, nest, mass/biomass distinction and reusable models | Fixed single-nest coordinates/caps and present tactics are trial rules, not universal ecology |
| Terrain | Shared meshes/materials, continuous-edge ground work, hills, vegetation, rocks, shaders and edge rivers | Hard-coded world bands/shoreline and landing examples are a fixture generator, not a general planet generator |
| Art tooling | Model lab, shared palettes/parts, reusable 13-bone human rig, rover rig and native map actors | Final realistic sci-fi styling, owner recoloring, complete action clips and scalable body variation are still work |
| Sprite path | Archive reference images and any useful shared icon resources | Retire duplicate playable sprite renderer/bake maintenance after 3D acceptance; don't delete shared icons/materials by filename alone |

The assembly principle is **already partially present**: recipes, mesh/material caches, static grouping and attached moving components. Continue it with authored reusable detail and manageable runtime objects. Neither bare primitives nor unlimited tiny mesh nodes is required by “granular assembly.” Art complexity and runtime object complexity can be different.

No new visual mockup or actual GPU capture was produced for this audit. Code presence does not establish visual coherence.

## 8. A simpler target architecture

Use a few clearly owned responsibilities, not an architecture diagram that requires a class for every noun:

1. **World state:** one authoritative terrain/ecology/map, faction-owned people/assets/stocks, and separate observations. Derived query indexes are not saved competing truths.
2. **Rules and commands:** one world-aware legal/effect path used by human, AI and previews. Economy/project progress share one explicit turn contract.
3. **Queries:** read-only economy, movement/reach, opportunities and known threats, reused by UI and AI. Cache only against relevant state changes.
4. **Planning and allocation:** domains propose purposes/enabling work; one allocator owns actual commitments. Governors/general/lieutenants are bounded responsibilities on that path.
5. **Presentation:** UI selection, animation and audio consume permitted snapshots/deltas; they don't mutate game economy or copy recorder history for a click.
6. **Evidence:** validator, bounded recorder/replay and small outcome reports sit alongside the game, with profiling on actual bottlenecks.

These responsibilities can initially live in a modest number of modules. Do not split `game_rules.gd` into dozens of adapters before correcting its accounting. Extract along real ownership boundaries while a testable slice remains working.

Keep the old snapshot available for comparison. Prefer one explicit migration at the chosen data boundary over perpetually supporting every obsolete private AI schema. Scope of save compatibility needs review before deleting migrations; retain recorder/replay evidence with its original rule version.

## 9. Revised implementation approach and batch mapping

Start with a short **source-baseline/preparation checkpoint R00**, not a new game feature. Pin this commit/package; record its present behavior and the intended changed rules; identify source ownership and test dependencies. Preserve current source and old evidence. Do not code new behavior or rerun a long campaign merely to complete R00.

Then reuse the existing project to build the minimal correct slice inside it. Retain useful implementations until their replacements pass; avoid running two active authorities for the same stock, project or task force.

| Batch | Source-aware adjustment |
|---|---|
| B01 shell | Reuse project/3D map/commands/save harness. Isolate UI selection, shared world ownership and a labeled minimal setup. Do not rebuild a generic shell from scratch. |
| B02 economy | High-priority replacement: Food roles, persistent deficits, storage scope, incurred obligations and one coherent ledger. Retain raw→Industry vocabulary and rule validation. |
| B03 AI | Replace authorization/budget metadata and fixed net-target dispatch with enforceable minimal allocations. Keep legal-command helpers, but make them world-aware; remove active ambiguity with old policies. |
| B04 projects | Replace the faction-wide countdown slot with ordered settlement work queues, real labor and partial affordable progress. Reuse legal sites/content/models. |
| B05 growth/research | Replace growth/support calculations and presence-only tech gates; retain instant purchases/training identity. Review Engineer inputs before tuning. |
| B06 knowledge | New observation/identification layer required. Existing survey/projection is raw world information, not fog support. |
| B07 environment | Reuse fauna resource loops, xenomass harvesting, obstructions and overlay rendering. Add actual pollution generation/containment/spill and repellents; don't rewrite species from scratch. |
| B08 tactics | Retain attack/effect plumbing and odds mathematics after power-rule reconciliation. Replace force charter/support/priority/retreat logic; define the unresolved combat contract explicitly. |
| B09 integration/UI | Rebuild player-facing layout around the four-cohort 1080p 3D opening. Reuse actor/batching/diagnostic tools; profile full refresh and copying before increasing art mass. |
| B10 expansion | Existing founding/claims/roads are a start, but default costs/site policy are historical. Add actual safety/purpose/work-area transfer and agreed founding materials. |
| B11 generator | Existing seed noise/terrain helpers survive; fixed shoreline/landing/river/nest coordinates must be removed from the general generator. Test arbitrary legal sizes and starts. |
| B12 diplomacy | Mostly new rules/AI/UI; ownership colors and isolated resource pools are not diplomacy. Use the corrected shared-world and allocation interfaces. |
| B13 neutral services | Site data/models survive; one-time `visit` reward does not implement ongoing services/exchanges. |
| B14 sound | New soundscape work; shared observation rules prevent hidden sound leaks. |
| B15 military/leaders | Equipment identities/rigs survive. No complete XP/promotion, modular chassis designer or leader behavior is established by current code. |
| B16 capacity/automation | Mostly new; current flamer capacity is a narrow facility limit, not strategic-deposit support. Reuse asset accounting interfaces. |
| B17 marine | New specialization/transport/founding rules. Water rendering alone is not an aquatic economy. |
| B18 advanced ecology | Native resource behavior survives. Control/pacification/improvement links and human adaptation need new rules; don't confuse a burned nest with pacification. |
| B19 espionage | New missions/information/countermeasures; use real knowledge and diplomacy contracts. |
| B20 projects | New project categories/effects on the corrected queue, with existing models as optional recipe components. |
| B21 society | New policy/ideology and selected integration systems. Existing doctrine strings are not implemented ideologies. |
| B22 orbit | New bounded service, after purpose/coverage contract. |
| B23 options/setup | Existing preset JSON can supply configuration data, but no complete Civ-like setup is established. Middle options and late setup retain their different milestones. |

The first useful milestone is **one settlement, real production, one queued useful improvement, one legal AI plan and one correctly updated human view**. Add complexity only after that chain works. This does not remove the four-cohort opening, wider early diplomacy or middle ambitions; it makes them build on common rules.

Every implementation receives functionality/performance/balance review. Batch reviews can occur when implementation starts, as the user requested; no further approval of this audit's prose is required to finish documenting the plan. New mechanics and user-approved scenario boundaries still apply at development time.

## 10. Focused verification to carry into development

| Priority | Verification purpose | Why it matters |
|---|---|---|
| First | Capture timing for selection/render/projection/supply query and an ordinary AI turn, recording off/on | Distinguish frame/UI cost, planning cost and trace-copy overhead before optimization |
| First | Verify unauthorized/deferred proposal execution and world-legal rejection behavior | Test the identified authority mismatch with a small approved case |
| First | Trace one complete resource→work→project→benefit chain | Prove the corrected core rather than counting commands |
| Before tactics pass | Trace deployment→provision check→recovery for one existing operation | Explain remustering without guessing or weakening the force gate blindly |
| Before tactics pass | Check one isolated Soldier's support count and fire-versus-retreat choice | Replace radius/self-count proxies with useful protection evidence |
| Before broader balance | Apply new opening and accounting to a known map, then approved varied conditions | Old supplied-army campaign is not a balance baseline for the redesigned colony |
| Before visual expansion | Measure busy-scene animation/build/pick costs at 1080p | Preserve recognizability and richness within actual budgets |

These are proposed future checks, not new tests already run. Preserve failures; do not manufacture successful campaigns by adding supplies or reducing enemies silently.

## Source anchors and companion documents

All code references below point to the inspected commit; function names identify the relevant source regions. They are direct primary evidence, not claims copied from an old architecture report.

- [Session: state ownership, command/replay path, AI loop and projection](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/civilization_session.gd)
- [Rules: economy, legality, project/growth resolution, technology and routes](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/game_rules.gd)
- [Coordinator: proposal labels, dispatcher, plan metadata](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/ai_coordinator.gd)
- [Operation: fixed charter, supply/readiness and recovery](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/ai_operation.gd)
- [Lieutenant: support, action order and adaptation](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/ai_lieutenant.gd)
- [Plan helpers: local legality and assignment search](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/ai_plan_actions.gd)
- [Main UI: refresh and selection](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/main.gd)
- [3D view: update signatures, rebuilds, picking and suspension](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/world_map.gd)
- [Static batching](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/world_batch.gd)
- [Wildlife resource behavior, healing and combat](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/scripts/xeno_ecology.gd)
- [Retained reconstruction evidence and limitations](https://github.com/ViktorasZigaras/Alien-Planet-Godot/blob/8a9f3d6a9f9787bc11e8489f5426f9d3a650395c/reports/reconstruction/VALIDATION_SUMMARY.md)
- [Grouped design](https://chatgpt.com/library?file_id=libfile_934933783cb0819186e21f52790dd61e&account_id=personal)
- [Batch plan](https://chatgpt.com/library?file_id=libfile_628b6a0c251c8191b37ae3ea4982702b&account_id=personal)

This audit changes documentation and recommendations only. Runtime verification, code changes and implementation reviews belong to the subsequent development work.
