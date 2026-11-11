# Alien Planet — feature, testing and review batches

5 November 2026 • Stage-two plan revised after static source audit • Reviews occur during implementation

## Purpose and status

This is a reviewable development sequence from an almost empty fixed map to the complete start-of-game ensemble, followed by a coarser roadmap for early, middle and late development. **No batch has been implemented or tested by writing this plan.** Stage three has now inspected the reconstructed source against repository commit `8a9f3d6a9f9787bc11e8489f5426f9d3a650395c`. The source-aware adjustments below refine reuse and replacement. Runtime profiling and newly reproduced behavior remain unverified; this is not a tested implementation schedule.

The grouped design was reconciled first. Its latest main sections incorporate reference-interest answers and clarification decisions, rather than relying on appended conversation history. Sources: [grouped design](https://chatgpt.com/library?file_id=libfile_934933783cb0819186e21f52790dd61e&account_id=personal), [decision ledger](https://chatgpt.com/library?file_id=libfile_4bb48d3203e881919b9014182cedbcc8&account_id=personal), and [reference-interest record](https://chatgpt.com/library?file_id=libfile_cf48e5e3d360819199908d9f6ea316fb&account_id=personal).

**Nine detailed batches build the starting ensemble. Fourteen later batches describe the wider roadmap.** These are capability/review packages, not release numbers, estimates or permission to implement every listed idea. Later packages must be divided into small implementations as their contracts become concrete. Conditional content remains conditional.

## Rules applying to every batch and implementation

Every batch has three distinct test responsibilities:

- **Functionality:** legal behavior, resource/person accounting, human interaction, deterministic AI use, failure/recovery, saves and relevant regression checks. AI evidence must include recognition, prerequisite acquisition, execution, reconsideration and sensible rejection; ordinary-game use must supplement isolated demonstrations.
- **Performance:** compare the preceding reviewed build under the same workload and record frame-time distribution/spikes, turn/planning time, relevant memory and save/log size. Test the changed subsystem and its interaction with a representative busy scene. Numerical target selection follows baseline measurement; 30/40/60 FPS remain candidates, not adopted requirements.
- **Balance:** examine whether the new choice is useful, affordable, counterable and neither compulsory nor dominated. A small fixture supports only local conclusions. Broader balance claims require varied approved conditions and repeated seeded runs.

**Every implementation receives a review**, even if a batch has several implementations. Review intended versus actual behavior, affected accounting/AI/UI, relevant tests, performance difference, balance observations and unresolved limits. For low-impact edits, reuse suitable evidence and inspect the changed behavior; do not invent redundant tests. A whole-batch review then checks interactions. User-facing review remains part of the agreed staged process; later planning is not approval of unreviewed mechanics or new scenarios.

Record one of: **accepted for current scope**, **revise**, **blocked**, or **deferred explicitly**. A required check left undone prevents calling a batch fully accepted. A provisional balance result can be accepted only with its narrow scope stated; it does not prove the full game balanced. Fixes that change a rule require review of the changed behavior before the batch is closed.

Test scenarios are proposed here, not executed or automatically approved. Reuse the initial map and already approved reviews first. Before running a newly authored scenario, get the user's suggestion/approval as previously agreed. Keep five detailed runs by default, up to ten for active comparisons, bounded also by size; retain compact build-qualified aggregate lessons. No log deletion is authorized by this document.

Each implementation review record should contain: build/commit and rule revision; intended choice; changed behavior; test workload/seed and baseline; observed outcome and causal evidence; functionality/performance/balance result; limitations; review disposition; next action. Historical passes become obsolete or partial when their assumptions change.

## Dependency and scope map

| Window | Batches | Result |
|---|---|---|
| Minimal foundation | B01–B03 | Readable fixed-map shell, accountable economy and shared actionable planning |
| Build the opening | B04–B08 | Projects, growth/training/research, exploration, ecological pressure and defense |
| Starting ensemble acceptance | B09 | Four-cohort opening works coherently through human and AI play |
| Early network | B10–B13 | Deliberate expansion, generated maps, factions/diplomacy, neutral services |
| Early→middle and middle | B14–B19 | Soundscape, military progression, strategic capacity/automation, marine specialization, advanced ecology and espionage |
| Middle→late and late | B20–B23 | Projects/wonders, society/ideology, orbital services, complete setup flow |

The first nine have a strict dependency spine. Later batches can be reordered or partially developed once their actual prerequisites pass; numbering is a review order, not a claim that unrelated systems need each other. For example, espionage need not wait for aquatic settlements, and initial soundscape experiments need not wait for every early diplomatic feature. Play stages are not shared global eras. Factions/leaders/ideologies and options/setup also describe development milestones, not mid-match menu unlocks.

## B01 — minimal fixed-map shell and observable state

**Entry / functionality:** one tiny fixed-map development fixture, one settlement and one ordinary cohort; explicit omissions from the final opening. Establish consistent hex coordinates, movement legality, fixed-scale actual 3D view, selection, panning, End Turn, save/load and a concise state/decision record. Keep ordinary commands independent of animation completion. Start the machinery/instrument UI language with readable provisional surfaces, not finished decorative assets. Groups G01/G07/G12–G14.

| Test family | Required evidence |
|---|---|
| Functionality | Selection/movement/save/load agree on location and ownership; repeated seed/input replay agrees; illegal orders explain failure; one command applies once. |
| Performance | Establish first-map frame/turn/memory/save/log baseline and measurement method; compare visual and no-presentation execution for outcome parity. |
| Balance | Check map distances, movement and provisional starting assets permit a meaningful choice rather than a forced deadlock; no strategic balance claim yet. |

**Review gate:** readable, reproducible shell. No claim of AI competence merely because a cohort can move.

## B02 — production, storage and turn accounting

**Entry / functionality:** B01. Add the six-resource ledger, actual versus potential yield, ordinary Food/raw-material/Industry routes and turn commitments. For testing, locate Food/Minerals/Industry in settlement records; Energy/Science/Culture global. Automatic eligible-source access, no freight. Immediate actions charge immediately; ordinary production/consumption once at the boundary. UI exposes stocks, inputs and net. Groups G01–G02.

| Test family | Required evidence |
|---|---|
| Functionality | Food 2/1 role accounting; Minerals→Industry conservation; reassignment cannot erase incurred cost or duplicate output; ordinary versus immediate spending reconciles; save/load preserves obligations. |
| Performance | Cost of accounting per cohort/workplace/storage record and growth with larger synthetic state; instrumentation overhead measured separately. |
| Balance | Basic workers can sustain the colony and obtain one useful next step; reserves bridge short deficits without funding an entire mature economy. |

**Review gate:** adopt a precise turn contract before coding it. See the proposed contract below. Warehouse caps remain unselected.

## B03 — shared proposals, legal actions and commitments

**Entry / functionality:** B02. Add the smallest complete direct/derivative proposal chain, authorized goal, required people/resources, legal command, outcome observation and revision. Make useful temporary work, blocking causes and released/shared reservations explicit. Groups G11/G14.

| Test family | Required evidence |
|---|---|
| Functionality | An AI obtains missing inputs for a useful goal; rejects a bad alternative; shares one prerequisite where appropriate; does not reserve the same cohort or supplies twice; replans after purpose disappears. |
| Performance | Candidate counts, pruning and planning time under contention; no full-map repeated scans merely because several goals share a dependency. |
| Balance | Compare purposeful saving against continuing ordinary production; avoid a universal savings hoard, arbitrary goal expiry or constant priority churn. |

**Review gate:** trace purpose→prerequisite→allocation→action→useful outcome. A hard-coded success sequence or log explanation is insufficient.

## B04 — multi-turn work and ordered project queues

**Entry / functionality:** B02–B03. Reusable build kit; separate paid resources and work; settlement effort split between manufacturing and construction; on-site builders; ordered queue; hold/resume, partial affordable work, improvements/districts/buildings and one representative upgrade. Natural yield stops when a new district starts. Groups G01/G04.

| Test family | Required evidence |
|---|---|
| Functionality | Settlement-only, builder-only and assisted modes; no double labor; queued order/holds; underfunded work retains valid progress; upgrade versus new-district output rules agree with the contract. |
| Performance | Queue updates and allocation scale with active work; held/blocked jobs do not produce repeated expensive replans or state spam. |
| Balance | Compare concentrating effort versus allocating it, manufactured inputs versus work, and improving versus replacing a useful tile. Builder advantage is useful without invalidating settlement labor. |

**Review gate:** settle queue blocking, overflow and Engineer-rate interfaces before implementation. Local Industry→Culture conversion remains a possible later recipe, not a required B04 feature.

## B05 — growth, support, training and usable research

**Entry / functionality:** B04. Local growth/global reserve distinction, no-growth/export behavior, one grown cohort per settlement per turn, working-population support, training and supported specialty yields. Instant research with previous-turn operational evidence and a useful unlocked capability. Groups G01/G03/G05.

| Test family | Required evidence |
|---|---|
| Functionality | Combined growth methods obey cap; exports preserve Food; training changes qualification without duplicating people; idle trained people do not satisfy operational gates; chained purchases recheck costs and requirements. |
| Performance | Dependency checks and assignment evaluation stay bounded as workplaces/techs increase; no repeated whole-tree search for unchanged requirements. |
| Balance | Growth versus support versus training versus equipment is a real choice; no circular bootstrap; +2 specialty bonus and costs remain tunable rather than a universally mandatory specialist rush. |

**Review gate:** support-source values and growth charging need explicit trial rules. Record support-loss/essential-Food cases; do not silently introduce RC06's deferred exception.

## B06 — knowledge, anomalies and safe exploration

**Entry / functionality:** B03–B05. Global basic coastline/terrain/relief, local observation and remembered changes; identifiable special sites; Explorer external work versus settlement work; one-time and ongoing rewards. Add relevant map overlays, tooltips and unit actions. Groups G06/G12–G13.

| Test family | Required evidence |
|---|---|
| Functionality | Identification changes access; special rewards are not duplicated by reassignment; external/settlement work is exclusive; AI and human UI cannot see current hidden units/development/natural changes. |
| Performance | Visibility, remembered state and representative-figure updates under repeated pan/selection; compare unseen-area processing and save growth. |
| Balance | Exploration return competes with work, travel and risk; unknown special opportunities matter without making ordinary terrain unusable. |

**Review gate:** both a useful investigation and a sensible decision not to investigate are demonstrated under permitted knowledge.

## B07 — foundational ecology, obstructions and settlement pressure

**Entry / functionality:** B04–B06. Pollution generation from working population plus actual industrial activity, containment/mitigation/spill/physical cleanup, health/Medics, meaningful terrain obstructions, flora and resource-driven fauna/nests. Fauna uses xenomass from its introduction/game start; no human-tech gate for that. Introduce a bounded wildlife-repellent mechanism relatively soon, once species behavior exists. Groups G04/G10.

| Test family | Required evidence |
|---|---|
| Functionality | Idle industry adds no industrial term; contained and spilled waste handled differently; clearing and cleanup obey tools/time; nests follow resources rather than human power; repelling differs from pacifying/control. |
| Performance | Active species decisions, pollution spread/overlays and environmental updates; no need to recompute the entire map for one local change. |
| Balance | Prevention is useful; cleanup is recoverable rather than endless drudgery; repellent expense and limitations preserve guards/retreat as useful choices; no free immunity. |

**Review gate:** environmental causes and responses are legible. Split into reviewed sub-implementations for pressure, world ecology and repellent behavior; do not treat this as one giant change. First resolve exact species benefits and the chosen pollution-throughput measure. No supernatural/ancient-site layer required.

Early-game follow-up idea from Viktoras: researchable, buildable wildlife-repellent towers. Decide the tech, cost, range and upkeep when designing the tower. The B07 temporary field repellent is available as a baseline.

## B08 — civilian survival and first credible military operations

**Entry / functionality:** B06–B07. Food/Energy emergency responses, multiplicative health/shortage power, legal shelter/retreat, rifle/flamer distinction, garrison versus expedition priorities, General/lieutenant planning, force assembly and withdrawal/rebuilding. Combat preview reserved in bottom unit panel. Groups G02/G09/G11–G13.

| Test family | Required evidence |
|---|---|
| Functionality | Civilians use actual reach/protection; threatened towns divert plans; forces stage/depart coherently; shortage recovery does not heal wounds; preview and resolution agree; losing/uncertain operations trigger reassessment. |
| Performance | Threat/reach/target computation with multiple task forces; simultaneous combat/movement visuals and end-turn spikes; skipped presentation preserves results. |
| Balance | Trial +25% force margin, weapon niches, terrain and home defense; judge success/cost/survival rather than dispatch count. An unwinnable grind must not be preferred to rebuilding. |

**Review gate:** ranged resolution/stacking need an explicit provisional tactical contract; ZOC/interception remain unselected. Extend the approved first-map tactical work rather than silently add a new scenario. Elaborate XP/modules wait for B15.

## B09 — complete starting ensemble and presentation review

**Entry / functionality:** B01–B08 accepted within stated scope. Restore the intended opening: one minimal complete settlement, two untrained civilians, Soldier, Explorer, reusable build kit and modest reserves. No mandatory rover or specialist workplace. Integrate working 1080p settlement view, tech cards, map controls, key actions, readable animated 3D figures/occupancy and relevant environment. This is the **start-ensemble acceptance point**, not completion of early-game ambitions.

| Test family | Required evidence |
|---|---|
| Functionality | Ordinary human and AI play links Food→materials→work→growth/training/research→safety; recover from affordable interruptions. Perform the approved five UI tasks and relevant art reviews in clear/cluttered contexts. |
| Performance | Busy-scene and pan/motion stress review, frame-time spikes, AI turn cost, memory/log/save size; compare decorative motion on/reduced and no-presentation outcomes. |
| Balance | Several useful opening choices; modest reserves; no default starvation/deadlock or obligatory first action. Evidence beyond a single successful fixture, with causal explanation of failures. |

**Review gate:** inspect readable furnished assets and convenience, not only mechanics. FPS/loading remedies follow profiling; no fixed frame cap or zoom is introduced by this gate. Optional asset previews do not add those assets to starting inventory.

End-of-B09 idea from Viktoras: add an Alienopedia to the integrated interface for looking up terrain, resources, units, buildings and rules. Decide discovery handling for hidden wildlife and anomalies during the UI pass.

## B10 — deliberate expansion, roads and faction presence

**Entry / functionality:** B09. Real founding materials separate from tools; second-settlement purpose/support/safety, work-area overlap/transfer, purposeful roads, threatened settlement priorities and recovery after hostile destruction. Establish identifiable faction ownership for early development; differentiated diplomacy comes in B12. Groups G03/G07/G09/G15.

| Test family | Required evidence |
|---|---|
| Functionality | Founder reaches a legal site, consumes correct materials, retains person identity; roads change actual travel; one tile is not double-worked; last-town voluntary abandonment prevented while survivor recovery remains possible. |
| Performance | Multiple-settlement proposals, storage-source access, road reach and border updates scale sensibly. |
| Balance | Expansion versus improving existing towns; frontier defense and opportunity justify cost. Do not add rising empire-size costs by default: RF11 reserves them for mid-plus balance evidence. |

**Review gate:** useful new settlement operation, not merely a successful founding command. Better preset starting packages remain later.

## B11 — early map generation and robustness

**Entry / functionality:** fixed-map B09 and legal expansion/knowledge contracts. Generate varied geography, start sites, resources/obstructions/flora/fauna opportunities with seeded reproducibility and legal reach. Reuse the same player rules. East–west wrap stays later. Groups G06–G07/G10/G14.

| Test family | Required evidence |
|---|---|
| Functionality | Deterministic seed/save behavior, legal placements/connectivity and known-versus-observed information; no omniscient compensation or per-seed scripted AI route. |
| Performance | Generation time, peak memory, scene construction/loading and ongoing map costs across sizes. Diagnose stutter before choosing streaming/caching remedies. |
| Balance | Distribution of viable starts and reachable opportunities, recoverability and isolation; no guaranteed claim of fairness from a few hand-picked seeds. |

**Review gate:** user-approved generated-map trials demonstrate use of mechanics outside the first map. Proposed seed ranges/workloads require review; no run launched now.

## B12 — substantive early diplomacy

**Entry / functionality:** B09–B10; generation is useful but not mandatory. Define factions and an expansive, manageable Civ IV-inspired agreement set in small reviewed increments. Start with a concrete bilateral agreement, then add selected passage/information/service/resource terms. Groups G08/G11/G15.

| Test family | Required evidence |
|---|---|
| Functionality | Two parties evaluate/accept/reject and honor terms; payments/reservations/access/expiry or breach are consistent; AI considers treaty utility and constraints; shared maps do not leak unspecified live information. |
| Performance | Negotiation candidate growth, relationship checks and re-evaluation triggers as faction count increases. |
| Balance | Reciprocity and credible tradeoffs; no infinite exchange loops, permanently dominant treaty or free military access disguised as trade. |

**Review gate:** Civ IV reference inventory and selected terms must be defined before coding the broader set. Do not wait for leaders, ideologies, council or espionage to make early diplomacy useful.

## B13 — neutral sites and useful exchange networks

**Entry / functionality:** B06/B10; reuse B12's relevant relation/access rules as available. Visitors physically use authored flat-yield or exchange services; one pop/player/site/service. Trained/untrained access, Merchant scale tests and Science entering ordinary stock/research. Groups G08/G11.

| Test family | Required evidence |
|---|---|
| Functionality | Real visitor/input/output/service limits; multiple players may choose different services without one player stacking them; no research gate bypass. |
| Performance | Site/visitor/service candidate evaluation, path choice and shared capacity changes across a network. |
| Balance | Visit versus local production after travel/risk; test doubling versus +2 at relevant exchange scales, not both stacked. |

**Review gate:** beneficial use and sensible refusal. Multi-service upgrades benefiting all visitors can follow separately; no full neutral-city economy required initially.

## B14 — soundscape exploration, early→middle

**Entry / functionality:** a readable early ensemble. Explore an original soundscape tied to map, actions and environmental/operational state. First scope/style choices are review items, not an assumed music/ambience catalogue. Groups G12–G14.

| Test family | Required evidence |
|---|---|
| Functionality | Relevant cues match visible/known state; hidden activity does not leak through sound; controls and quiet/reduced presentation work as specified. |
| Performance | Concurrent audio sources, decoding/loading, memory and frame/turn spikes in busy scenes. |
| Balance | Informational fairness: audible warnings neither expose hidden threats nor make silent/fast tests strategically different. Assess distraction and repetition through human review. |

**Review gate:** useful atmosphere and readable cues at acceptable cost. Reports/character voices and voice acting remain much later.

## B15 — middle military progression and faction leaders

**Entry / functionality:** B08/B12. Introduce Civ IV-like XP/veterancy with SMAC-inspired abilities; define a small meaningful progression first. Add built vehicle chassis/version compatibility and researched modules incrementally; manufactured or building-granted upgrades only where selected. Add faction leaders by middle development with defined behavior/presentation. Groups G01/G09/G15.

| Test family | Required evidence |
|---|---|
| Functionality | XP/person/equipment identity survives valid changes; incompatible fits rejected; a chosen adapter rule works; AI values veterans and chooses feasible loadouts without inventing research/refits. |
| Performance | Design/promotion candidate pruning, equipment swaps, shared rigs/modules and larger forces. |
| Balance | Veteran preservation without unstoppable snowball; old chassis/refit versus new manufacture; weapon/transport/support niches; leader differences do not grant hidden resources. |

**Review gate:** review XP, a vehicle family and leaders separately, then interactions. Exact compatibility budgets and building-granted veterancies remain contract decisions, not requirements copied wholesale.

Open mid-game design question from Viktoras: how many districts of the same type may one settlement have? Review limits alongside capacity and specialization. No cap has been selected.

## B16 — strategic capacity and automated extraction

**Entry / functionality:** B05/B10, selected advanced assets. Introduce deposit-supported asset capacity separately from ordinary material stocks. Then one automated extractor that substitutes machinery/operation for an assigned pop. Desired tentative midgame scope; development can begin earlier once dependencies pass. Groups G02/G05/G11.

| Test family | Required evidence |
|---|---|
| Functionality | Capacity reservation/allocation/loss is explicit; no double allocation; automation pays selected inputs and actually releases labor; AI obtains access before committing assets. |
| Performance | Capacity/deposit updates and automation evaluation across many sites; avoid multiplied design combinations or constant worker reshuffling. |
| Balance | Strategic scarcity creates choices; automation does not erase labor scarcity or become obligatory everywhere; define loss-of-access consequences before balancing. |

**Review gate:** accept capacity and automation as separately reviewed implementations. This does not introduce routine freight or turn every resource into a support counter.

## B17 — specialized aquatic settlements

**Entry / functionality:** define a genuinely useful marine role and constraints, then required water travel/access/resources/ecology. Build a bounded midgame aquatic-settlement form using shared population/economy rules where appropriate. Groups G07/G10.

| Test family | Required evidence |
|---|---|
| Functionality | Legal access/founding/support and staffing; land/sea travel boundaries; AI recognizes a real marine opportunity and supports it. |
| Performance | Shore/water rendering, travel graph and marine ecology costs on representative maps. |
| Balance | Settlement has a meaningful specialized purpose and constraints; neither mandatory in every geography nor a superior unrestricted land-town clone. |

**Review gate:** essential role must be demonstrated, not manufactured by an arbitrary victory gate. Mobile marine settlements remain optional late work.

## B18 — advanced ecology and local transformation

**Entry / functionality:** B07 and selected technology/equipment. Human reuse of native terrain; one link/controller animal control; then pacification→nest control→nest improvement in separately reviewed steps. Explore a bounded local custom biome alteration when its mechanism is selected. Groups G05/G10/G11.

| Test family | Required evidence |
|---|---|
| Functionality | Link qualification/sustain/release; pacification distinct from control; nests/species keep resource-driven behavior; local transformation changes actual yields/access consistently. |
| Performance | Controlled-fauna planning, link updates and local biome/overlay changes scale without duplicated simulations. |
| Balance | Control versus protection/extermination, maintenance burden and payoff; adaptation offers positive utility without deleting danger/cost or requiring preservation. |

**Review gate:** settle link-loss rules and one specific transformation before implementation. Altitude manipulation, ancient aliens and supernatural layers are not prerequisites.

## B19 — espionage by midgame trials

**Entry / functionality:** B12 and explicit observation/target/effect rules. Begin useful information gathering and countermeasures; add selected sabotage only after costs/detection/consequences are defined. Accidents/outbreaks are candidate effects, not mandatory first actions. Groups G06/G10/G15.

| Test family | Required evidence |
|---|---|
| Functionality | Both sides obey information/detection rules; target legality and countermeasures work; AI values a mission versus direct alternatives and reacts to discovered harm. |
| Performance | Hidden-knowledge updates, mission/target candidate search and countermeasure triggers across factions. |
| Balance | No cheap universally decisive sabotage, free omniscience or unavoidable punishment; repeated effects have explicit limits/remedies where selected. |

**Review gate:** espionage is available during midgame trials; the broad random-event system can remain deferred. May precede B17/B18 if ready sooner.

## B20 — major, minor and local projects/wonders

**Entry / functionality:** mature construction/research and a selected project purpose. Add one bounded local restoration/upgrade and one larger project if selected; define uniqueness per category, time investment, effects and host significance. Explore Civ III–VI/SMAC/BE references before choosing original entries. Groups G04/G16.

| Test family | Required evidence |
|---|---|
| Functionality | Races/uniqueness where chosen, held work and funding, meaningful completed effect; capture/destruction and invested-work treatment explicitly defined. |
| Performance | Global effect propagation, project competition evaluation and representative furnished project assets. |
| Balance | Worthwhile investment versus ordinary growth/defense; effects respect economic logic, do not become blanket dramatic free multipliers. |

**Review gate:** middle-to-late scope, with each project reviewed independently before broadening the catalogue. A unique building name is not enough.

## B21 — policy cards, ideologies and selected social consequences

**Entry / functionality:** factions/leaders and meaningful middle economy. Define a small Civ VI-inspired policy-card model, then faction ideologies by late development. Conquest integration can be a separately selected implementation when human warfare needs it. Unrest/prosperity stay conditional; implement only a specifically selected mechanism, not the whole speculative list. Groups G15–G16.

| Test family | Required evidence |
|---|---|
| Functionality | Policy eligibility/effects/switching; AI evaluates actual tradeoffs and commitments. If integration or social strain enters, trace causes and remedies and preserve population/assets correctly. |
| Performance | Policy-effect invalidation and re-evaluation; avoid rechecking every unit/tile needlessly each selection. |
| Balance | Distinct viable policies/ideologies; switching cannot erase incurred costs; no automatic +50% prosperity output or stacked punitive unrest effects. |

**Review gate:** accepted policy/ideology scope is distinct from deferred discontent examples. Rioting, −10% combat and bandit departures remain possibilities until individually chosen.

## B22 — late orbital service

**Entry / functionality:** advanced economy and one agreed orbital purpose. Start with a single useful observation/support service, explicit launch/operation/coverage rules and knowledge-safe presentation. Groups G06/G16 and RF22.

| Test family | Required evidence |
|---|---|
| Functionality | Coverage, costs, lifetime/loss if specified, legal information access and AI deployment with actual utility. |
| Performance | Coverage/effect updates, rendering and planning overhead across orbital assets. |
| Balance | Service competes with ground investment; no unpriced universal map knowledge or global permanent bonus. |

**Review gate:** useful bounded service, not a full orbital combat layer by default.

## B23 — game options, setup and mature integration

**Entry / functionality:** selected configurable rules and generator. Implement reviewed gameplay options by middle development as small earlier increments; complete the Civ-like new-game setup flow by late. Presets, validation and reproducible settings; maintain separate internal test controls. Larger starting piles/founding packages only where selected. Groups G12/G14/G16.

| Test family | Required evidence |
|---|---|
| Functionality | Chosen settings reach actual rules/generation/save/replay; invalid combinations explained; normal start and loading work without hidden defaults changing tests. |
| Performance | Setup/generation/load delays and memory; gameplay costs compared under equivalent settings. |
| Balance | Supported presets produce their stated experience; options expose variation honestly without claiming every combination equally balanced. |

**Review gate:** overall ecological ambition and civilization viability assessed with the matured selected systems. This is not a prerequisite for initial testing. Encyclopedia, reports/voices, portable artifacts, planetary cycles, broad events and movable sea settlements remain later/conditional scope rather than automatic completion requirements.

## Contracts to review before their affected implementations

These proposals make the plan concrete without treating open interfaces as answered.

| Interface | Proposed starting contract | Decision/review point |
|---|---|---|
| Turn resolution | Immediate paid actions update available stocks immediately. At the boundary, account for one turn of committed work; resolve operating eligibility, production and ongoing obligations consistently; apply shortage remedies once, then record affordable construction/growth and next-turn research evidence. | B02 must publish an exact phase/data table first. The wording here is not enough to code an ambiguous economy. |
| Same-turn resources | Food/Energy production may meet that turn's ongoing demand in a single reconciled budget. Manufacturing/construction inputs should initially be bounded by available/reserved stock, avoiding self-funding cycles; newly produced capital inputs become available next turn. | Proposed, not adopted. Review bootstrap viability and compare with the intended "total pile use" rule before choosing; never silently impose a reservation that forbids agreed pool access. |
| Queue service | Settlement construction effort serves the first eligible non-held entry. If the head is blocked, expose the blocker; proposed default allows a later eligible entry rather than wasting effort. Same-turn overflow may move forward only after completion, within one effort/input budget. | B04 review: user accepted ordered queue but did not select skip/overflow policy. Keep explicit holds and separate builders. |
| Labor | One effort budget per worker per turn split between manufacturing and construction. On-site builder contributes separately. Define Engineer effect and corresponding inputs, not a free duplicated +2. | B04/B05. No exact rate adopted. |
| Growth/founding | One grown cohort maximum/settlement/turn; no-growth exports; reusable tools separate from consumed founding package. | B05/B10 specify affordable growth payment and minimal founding recipe. |
| Support loss | Observe frequency and Food consequences under existing support/reassignment rules. No automatic over-cap exception. | B05/B07 evidence then targeted review if important. |
| Industrial pollution | Measure actual processing/output; expose worker and industry terms separately. | B07 selects rate units/baseline, not a built-factory count. |
| Combat/control | Explicit provisional stack/ranged/shelter rules; one animal link/controller, sustain/release rules before control code. | B08/B18 respectively. ZOC is not silently adopted. |
| Diplomacy/capacity/marine role | Define real agreement obligations; strategic loss-of-access treatment; marine specialization/constraints. | B12/B16/B17. These are scoped design contracts, not another broad questionnaire. |

The turn-phase choice deserves a short focused review at implementation time because Food emergency reassignment, incurred obligations and current-turn outputs interact. Do not disguise accounting changes as balance tuning.

## Stage-three audit and adaptation

The user will review batches when implementation begins. The static stage-three audit is now complete for the available source and version provenance; apply its source-aware changes below. During development, verify runtime behavior and any newer source revision before relying on old results. Map each batch to **verified functioning**, **present but disconnected**, **must replace**, **reusable content**, **missing**, **deferred** or **unverified**. Inspect action/state ownership, accounting, turn loop, proposal/commitment paths, fog, serialization, UI and render assets. Cite paths and observed behavior when available.

Revise dependencies and implementation sizes when these runtime checks or newer source change the evidence. Do not rebuild a functioning system because its filename sounds old; do not retain a broken system because an architecture document names the desired role. Source reuse must survive the same relevant checks as new work. Preserve working versions and reviewable changes; no development work, upload to a repository or test run is implied by this design proposal.


## Source-aware revision after stage three

The audit is recorded in **Alien_Planet_Stage_3_Source_Audit_2026-11-05.md**, with a per-path hash comparison in **Alien_Planet_Stage_3_Source_Evidence_2026-11-05.json**. The current project provides reusable commands, people/equipment, content, resource-driven fauna, model recipes and static batching. Its accounting, construction, observation and AI allocation require substantive replacement/adaptation. Performance causes remain hypotheses pending profiling.

### Adopt this implementation approach for planning

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

