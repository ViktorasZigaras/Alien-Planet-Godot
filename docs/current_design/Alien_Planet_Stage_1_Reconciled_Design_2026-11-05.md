# Alien Planet — reconciled design and priorities

Reconciled after RF01–RF24 and RC01–RC08 • 5 November 2026 • Priorities and staged targets

## 1. Purpose and review boundary

Alien Planet is a turn-based planetary civilization game in which persistent people connect the economy, exploration, construction, research and military. Geography offers opportunities and threats; infrastructure and training make them usable; the player chooses which purposes deserve scarce people, resources and time. The intended computer player assesses these same circumstances through deterministic programmed rules and ordinary legal actions.

Its influences have compatible jobs: Colonization contributes people and occupations; Civilization contributes spatial development and management; SMAC contributes an alien world, native relationships and ambitious transformations; Beyond Earth contributes useful resource/site and capability ideas. Civ IV informs readable map composition and interface organization, while Civ VI informs district opportunity costs and the reserved combat-comparison area. These are selected principles, not imported rule packages.

This document reconciles the collected design into actionable groups, now incorporating the completed reference-interest and clarification rounds. It is the **stage-one baseline** for the separately prepared stage-two batch plan:

1. Reconcile and prioritize the design; review it and identify additional questions.
2. After review, propose feature-and-test batches progressing from a nearly empty map to a coherent start-of-game ensemble.
3. Then inspect actual implementation, identify useful surviving architecture/content, and revise that plan against evidence.

No current code, repository, dispatcher or executable behavior has been audited for this stage. No game implementation, simulation, new scenario run, benchmark or log cleanup has occurred. Historical implementation reports remain historical evidence. The rankings below are recommendations for review; firm user decisions and explicit deferrals remain binding within their scope.

## 2. How priority and timing work

| Rank | Meaning in this reconciliation |
|---|---|
| **Must** | Protects the central design or prevents an incoherent/incorrect rule chain. Required when its associated capability is introduced; not necessarily in the first batch. |
| **Should** | A strongly supported, useful capability or presentation goal. Include in the relevant ensemble unless review finds a better way to serve its purpose. |
| **Could** | A coherent extension or explicitly later feature. Preserve compatibility, but it need not delay the opening. |
| **Maybe** | A hypothesis, uncertain mechanic or conditional option. Needs a decision or evidence before becoming a requirement. |

**Timing is a separate dimension:** Foundation → Start ensemble → Early network → Middle specialization → End ambition → Later/conditional. These are overlapping emphases in each civilization's development, not global eras, fixed turn ranges or mandatory build orders. A mature civilization can still face survival emergencies.

**Certainty is also separate:** agreed behavior, trial value, provisional preference, assistant recommendation and future possibility are not interchangeable. A Must rule can contain a provisional numerical value. Conversely, an agreed future direction need not become an opening feature.


The action register is a capability inventory, not one coding task per row. Implement overlapping statements through shared rules and test their combined behavior. Later additions below retain their explicit certainty and timing.

## 3. Important reconciliations and supersessions

Use the interpretation in the right column when older source documents differ.

| Older wording or apparent conflict | Reconciled direction |
|---|---|
| Five-resource proposals; Credits, Research, Influence or Dust vocabulary | Six current resources: **Food, Minerals, Industry, Energy, Science, Culture**. No additional universal money resource is selected. |
| Pooled supplies versus warehouses | Track relevant resources by storage location, show aggregate totals, and initially withdraw automatically from eligible sources without physical delivery delay. Testing split: Food/Minerals/Industry have settlement location records; Energy/Science/Culture remain global. Capacity limits remain open. |
| Industry output also determines construction speed | Stored resources pay costs; allocated labor supplies work progress. Do not count the same output or person's effort twice. |
| Stockpiles allow instant building | Abundant funds do not replace multi-turn labor. Research remains instant purchase unless deliberately changed later. |
| Construction shortages go to the shortest remaining project | Settlement projects now have an **ordered queue served in turn**. Preserve holds, separate builders and allocatable effort; queue blocking/overflow and any parallel allocations need an explicit rule. |
| Two civilians replacing the Soldier/Explorer | The detailed opening record retains **two untrained civilians + one Soldier + one Explorer**, four cohorts overall. No starting rover is required. |
| A basic town needs many starter buildings | Bundle essential center/housing/storage/administration functions. Physical building count and precise bootstrap recipe are not settled. No prebuilt specialist economy. |
| Everyone standing in town counts as its development population | Settlement support/pressure tracks **working civilians**. Idlers and garrisons still eat, but do not count merely through presence. |
| Mobilizing Soldiers increases Food upkeep | Current agreed rates supersede historical costs: 2 Food per productive settlement worker, 1 per other cohort, including Soldiers, builders, Merchants and external Explorers. |
| Idle people should immediately return to tiles | Useful tile work is the normal unassigned default; capacity, food affordability, safety and commitments can make idling the correct choice. |
| A reassigned worker must return to the old job | Protect useful ongoing work, but no general career-return obligation. Temporary plan work must not compromise its retained commitment. |
| Every specialist creates its preferred output anywhere | Initial +2 matching bonus needs a tile/workplace supporting that output. Explorer external +1 Science/+1 Culture is separate. |
| Merchant bonus is always doubling | Small exchange scale may use doubling; larger deals may use +2 received output. Alternatives for testing, not cumulative bonuses or a final piecewise formula. |
| A district loses natural yields only when completed | Natural yields stop at actual construction start and remain suppressed while held. District benefits start on completion. |
| All development layers must have upgrade trees | Improvements and buildings are upgradeable. Upgrading districts themselves remains a possible later layer. |
| Building ownership or idle qualification satisfies operational research gates | Required capabilities must actually function. Initial operational check uses the immediately preceding productive turn where applicable. |
| Research must run over several turns | Keep immediate purchases; multiple purchases per turn can occur if each separately meets costs and requirements. Duration-based research is an open future idea. |
| A nearby friendly Soldier guarantees civilian safety | Only actual movement, barriers, reach and applicable protection rules justify safety. Interception/ZOC remain unresolved candidates. |
| The first expedition always uses a fixed historical troop template | Size for known/suspected enemy power; start testing at +25%, with +25–50% as a later discussed trial range. Reassess composition, terrain and losses. No ratio guarantees victory. |
| Destroying a nest removes its ecology | Surviving animals and xenomass can persist. Loss of gathering/replacement capacity follows resource consequences. |
| Losing the last town immediately eliminates the player | Mobile survivors with real founding capacity can rebuild. Voluntary abandonment of the last town is disallowed; hostile destruction remains possible. |
| Ecology is the compulsory objective | It is the first advanced direction to develop and test. Extermination remains a valid player choice. |
| Zoom was part of the initial controls | **Latest decision defers zoom.** Choose one initial camera scale; retain panning. Rotation, tilt and zoom-triggered markers/detail transitions are later. |
| Initial art-review roster equals starting inventory | Review civilians/builders/Explorer/rifle/flamer/rover/nest/animals as needed; this does not grant all of them at game start. |
| The curse images define mandatory technology tiers | They explore a possible visual vocabulary. Their exact tiers, effects and asset details are not adopted game rules. |

## 4. Actionable design groups

Each group gives its intended behavior, priority, appropriate development window and evidence of coherence. Evidence here describes a later review standard, not a claim that any build passes it. Source anchors refer to the decision ledger and the linked supporting documents in section 10.

### G01 — Persistent people, jobs, training and equipment

| ID / priority / window | Actionable design |
|---|---|
| P01 · Must · Foundation | Give every cohort one persistent identity and one current task/location. Work, travel, training, construction and combat cannot duplicate its labor or benefits. |
| P02 · Must · Foundation | Keep qualification distinct from assignment and equipment. Changing jobs does not erase training. Basic jobs accept untrained workers; selected advanced activities may explicitly require training. |
| P03 · Must · Start ensemble | Apply initial +2 to supported matching specialist yields and external Explorer +1 Science/+1 Culture in the agreed mode. Keep these trial values configurable. |
| P04 · Should · Start ensemble | Seek safe affordable useful work for uncommitted people. Preserve useful established assignments unless an important authorized change justifies disruption. Idle is a valid state. |
| P05 · Should · Start/early | Train to real workplaces or retained plans, comparing cost, lost production, travel and local alternatives. Clearing a specialty and retraining are distinct actions. |
| P06 · Should · Start/early | Use Colonization-style equipping: ordinary hex workers put role tools away; builders, Soldiers and Explorers equip relevant items. Define real access and storage rules rather than conjuring equipment. |
| P07 · Could · Middle/later | Develop a SMAC workshop × HOI4 designer direction: built chassis, researched upgrades, version-specific compatibility and possible enabling modules for older vehicles. Multi-skilling and retained interrupted-training progress remain conditional. |
| P08 · Should · Early/middle | Develop cohort XP/veterancy, likely Civ IV-style promotions blended with SMAC special abilities. Manufactured upgrades and building-provided veterancy are possibilities, not universal requirements; exact benefits and timing need design. |

**Coherence check:** changing a person's role changes the expected output, upkeep and availability once; equipment and training remain traceable. No aimless repeated relocation or artificial profession quotas. Sources: Q025–Q040, S01–S05, C04–C07.

### G02 — Resource accounting, production and shortages

| ID / priority / window | Actionable design |
|---|---|
| E01 · Must · Foundation | Separate stock, gross production, input use, upkeep, spending and net change for all six resources. Distinguish potential tile yields from actual staffed output. |
| E02 · Must · Foundation | Preserve Minerals as raw material and Industry as manufactured/construction resource. Give the minimal colony an attainable conversion route without circular specialist or building prerequisites. |
| E03 · Must · Foundation/start | Apply 2 Food to productive settlement work and 1 to other roles. Resolve ordinary production/ongoing consumption once at the turn boundary; explicit immediate actions charge when performed. Switching cannot erase incurred costs or duplicate output. Exact phase order remains a stage-two proposal. |
| E04 · Must · Start ensemble | Use real Food production/reassignments first when reserves cannot cover upkeep. Then idle suitable non-food workers to reduce demand by 1 each. Already-1-Food cohorts offer no further saving by idling. |
| E05 · Must · Start ensemble | If shortage persists, retain the actual deficit; combat power receives the unmet-demand fraction multiplicatively with remaining combat health. No automatic healing in that catastrophic state. Resupply clears the shortage modifier, not combat wounds. |
| E06 · Should · Start ensemble | Shut down highest-consuming nonessential installations during Energy shortage, protect immediate Food/defense where possible, use relevant plans for ties and controlled random ties otherwise. Reassign displaced workers usefully; avoid unstable restart cycles. |
| E07 · Should · Start/early | For testing, record Food/Minerals/Industry at settlement storage locations and show their aggregates; Energy/Science/Culture remain global. Access eligible sources automatically without freight delay. Capacity limits are not yet adopted. |
| E08 · Maybe · Later | Capacity limits, warehouse upgrades and eventual transport constraints need explicit resource-specific rules. Do not add a new currency or magic shortage conversion. |
| E09 · Should · Middle | Introduce limited strategic-deposit capacity supporting selected advanced assets. Track allocation and define loss-of-access consequences; do not replace ordinary stockpiles. Development desired soonish, gameplay timing tentatively middle. |
| E10 · Should · Middle | Allow selected automated extraction to substitute machinery/Energy/maintenance for permanently assigned people. Same tentative timing as strategic capacity; no freight implied. |
| E11 · Maybe · Early/later | Consider local conversion tasks, such as local Industry → global Culture. Recipes, staffing and rates require individual decisions, not unrestricted universal conversion. |

**Coherence check:** all resource changes reconcile; finite reserves bridge deficits but cannot hide them forever; recovery does not duplicate income or create supplies. Sources: Q017–Q024/Q077, S02, C08–C11.

### G03 — Growth, settlement support and concentration

| ID / priority / window | Actionable design |
|---|---|
| GH01 · Must · Start ensemble | Distinguish local growth progress from global Food reserve support. Preserve Food once across upkeep, growth and exports. |
| GH02 · Must · Start ensemble | Start with at most one newly grown cohort per settlement per turn across all growth methods combined. Existing-person relocation is not population creation. |
| GH03 · Should · Start ensemble | Support no-growth policy and export surplus after upkeep when growth is disabled or infrastructure-gated. Local-growth-first/overflow routing remains a provisional accounting default. |
| GH04 · Must · Start/early | Track working civilian population for development support and associated pressure. Reevaluate support when infrastructure stops functioning; normally idle excess workers, with Food-emergency behavior tested rather than silently fixed. |
| GH05 · Should · Early/middle | Larger supported settlements offer worthwhile capabilities/economies of scale alongside health and pollution costs. Tiny town spam must not replace real productive development. |
| GH06 · Could · Early/middle | Deliberate global-reserve spending to accelerate chosen growth remains an intended option needing an exact rule. It cannot bypass the growth cap or infrastructure gates. |
| GH07 · Maybe · Later | Additional shelter caps for idle/garrison reserves are deferred; initially their Food cost is the constraint. Exact support gates, scale effects and advanced urban capacities need testing. |

**Coherence check:** growth is useful capacity with a support path; an infrastructure loss causes intelligible restructuring without deleting people or blindly worsening starvation. Sources: Q025–Q032, D003–D004, S04, C05/C14.

### G04 — Land work, projects, districts and upgrades

| ID / priority / window | Actionable design |
|---|---|
| B01 · Must · Foundation | Represent funding and labor progress separately. Retain completed work and use proportional payments for actual affordable progress; preserve unspent resources. |
| B02 · Must · Start ensemble | Make relevant tile actions/building programs multi-turn. Allow settlement labor, on-site builder, and combined contributions without assigning the same capacity twice. |
| B03 · Must · Start ensemble | Serve an ordered settlement project queue; preserve labor allocation and explicit hold/resume. Define blocked-entry and overflow behavior before coding. A held new district retains progress and suppresses natural yields without unfinished benefits. |
| B04 · Should · Start/early | Separate improvement, district and building purposes. Improvements and buildings have upgradeable versions; compare useful marginal benefit with the full missing path and opportunity cost. |
| B05 · Should · Start/early | Construction, land buying and clearing serve real goals. Preserve useful natural yields, cover or ecology when clearing is not worth its costs. |
| B06 · Should · Start/early | Provisionally restrict settlement construction labor to its work area; use a physical builder for remote work. Resource pooling does not teleport labor. |
| B07 · Maybe · Early/later | Initially retain existing output during upgrades, pending economic tests. District upgrades, advanced-improvement upkeep, cancellation salvage/refunds and exact payment/allocation rates remain unselected. |
| B08 · Could · Later | Consider adjacency networks using Civ VI bonuses as an analogy, with specific useful spatial relationships. Mixed-function improvements remain conditional and context dependent. No exact multiplier or mandatory upkeep model selected. |

**Coherence check:** a project can be funded yet labor-limited, or staffed yet resource-limited, and UI/AI report the correct blocker. Completed assets must become genuinely operable. Sources: Q053–Q071, S07, C08–C13.

### G05 — Research and capability progression

| ID / priority / window | Actionable design |
|---|---|
| R01 · Must · Start ensemble | Keep instant research purchases with explicit costs, associations and requirements. Recheck after every purchase, including when several occur in one turn. |
| R02 · Must · Start ensemble | Where research requires an operational workplace/specialist, mere ownership or idle qualification is insufficient. Use actual immediately previous-turn production as the initial evidence rule. |
| R03 · Must · Foundation/start | Avoid circular bootstrap gates. Every required opening capability needs a legal route from starting assets; dependencies must identify actual missing steps. |
| R04 · Should · Start/early | Research buys usable capability, not just a filled icon. Rank full prerequisite burden and payoff; cheap unrelated research may legitimately beat an expensive enabling step. |
| R05 · Should · Start–end | Explain early advances mainly as adapting inherited knowledge to local production; alien ecology and later breakthroughs can involve discovery. Keep cross-field requirements meaningful. |
| R06 · Could · Later | Could add institutional choices, alternative external research-service prerequisites or advanced convergences. Duration-based research remains an open option, not a required timer system. |

**Coherence check:** ordinary people/resources can obtain a capability and use it. A blocked goal can remain relevant without every prerequisite inheriting unlimited urgency. Sources: Q033/Q039/Q041–Q048, D005, S06, C03.

### G06 — Knowledge, exploration and opportunity use

| ID / priority / window | Actionable design |
|---|---|
| K01 · Must · Foundation/start | Separate macro geography, exploration, current visibility, recognition, investigation, usability and remembered state. RC05 is interpreted inclusively: coastline, basic terrain and relief known globally; special details/current activity require discovery/observation. Human and AI use permitted knowledge. |
| K02 · Must · Start ensemble | Ordinary terrain/basic yields are usable; bonuses can require Explorer identification. Tooltips state what is known/usable and why access is blocked. |
| K03 · Must · Start ensemble | A tile's ongoing settlement work and external Explorer work are alternatives, not additive simultaneous incomes. Settlement work gets applicable ordinary/special yields; external work gets only special yields plus its specified bonus. |
| K04 · Should · Start/early | Permit one-time investigation reward and recurring work at the same site without regenerating discovery rewards on reassignment. Per-player first rewards remain provisional. |
| K05 · Should · Early/middle | Add varied anomaly levels, broad plausible identification and selected research-gated investigation/use. Distinguish a repeat workplace, access-enabling deposit and one-time discovery where those rules exist. |
| K06 · Must · Wherever fog applies | Remember last-observed development/nests/natural changes; do not display live unseen upgrades or activity. Historical sightings are not proof of present units. |

**Coherence check:** scouting changes a decision; unexplored details do not leak through yields, tooltips, models or AI assessment. Sources: D011, S01/S08/S09, U18/U21, V14, X03.

### G07 — Territory, expansion, movement and recovery

| ID / priority / window | Actionable design |
|---|---|
| T01 · Must · Foundation | Keep one consistent hex topology for movement, range and reach. Actual costs and legal access determine guaranteed movement. |
| T02 · Must · Early | Assign each workable tile to one settlement work area until explicitly transferred; preserve one-worker-per-tile semantics and explicit overlap handling. |
| T03 · Should · Early | Expansion compares safety/support, development cost elsewhere and unique or otherwise slow-to-obtain opportunity. Include real founder, equipment/materials, road plan and escort/garrison needs. |
| T04 · Should · Early | Build purposeful roads between useful settlements/outposts. No current ongoing road upkeep; no whole-map road coverage quota. |
| T05 · Should · Early/middle | Use transport when it improves actual group travel/safety. Vehicle access/capacity/passenger protection need concrete rules before claims of capability. No routine material freight. |
| T06 · Must · Where destruction exists | Loss/abandonment releases ownership without automatically erasing surviving contents. Do not voluntarily abandon the last town. Real mobile founding capacity can permit recovery after all towns are destroyed. |
| T07 · Should · Early | Add map generation after initial fixed-map competence tests, by the early-game ensemble. East–west wrapping remains later. Water/air travel need their own explicit rules; people do not implicitly swim with equipment. |
| T08 · Maybe · Later | Settlement radius 3/minimum spacing 3, possible tech gates, regional services and bunker networks require separate relevance tests. They are not adopted current numbers. |
| T09 · Should · Middle | Aquatic settlements must have specialized capabilities, constraints and a meaningful essential role; define these before building them. They are not generic land towns in water. Mobility is only a late, low-priority possibility. |
| T10 · Could · Later | Better preset founding packages may establish more developed settlements at greater founding investment. Exact packages/prerequisites remain open; reusable tools are separate from consumed founding materials. |

**Coherence check:** people and connections reach useful supported destinations; a requested route is not counted as completed. Empty strategic footholds are not free mature economies. Sources: Q049–Q056/Q064/Q072–Q078, D018, S11–S12, C10, X01.

### G08 — Neutral sites, visitors and exchange

| ID / priority / window | Actionable design |
|---|---|
| N01 · Must · When sites enter play | Basic trained/untrained visitors can use authored services. Flat visitor yield and paid input→output exchange are distinct legitimate site models. |
| N02 · Must · Early | Allow one visiting pop per player per site, using one service at a time. Different players may choose different services. Do not import this exception into general combat stacking. |
| N03 · Must · Early | Apply real costs and available service/supply limits. Science-producing exchanges add Science to normal stock/research, rather than bypassing research requirements. |
| N04 · Should · Early | Make trained Merchant benefit meaningful; select doubling versus +2 according to actual exchange scale and test it. Compare travel/risk/foregone employment with return. |
| N05 · Could · Later | Could add multi-service sites and investment upgrades benefiting all visitors. Outpost prerequisite substitution, city-state economies and bandit towns remain conditional. Inter-faction diplomacy has a separate early target in G15. |

**Coherence check:** an actual visitor and service explain every resource change; no fabricated conversion, visitor duplication or hidden multi-service bundle. Sources: D010, S13, C15–C16.

### G09 — Civilian safety, defense and tactical operations

| ID / priority / window | Actionable design |
|---|---|
| M01 · Must · Start ensemble | Civilians interrupt exposed work and seek reachable shelter unless actual protection makes staying safe. Retreat aims beyond enemy attack reach and continues under pursuit. |
| M02 · Should · Start/early | Maintain a small garrison baseline, stronger for frontier/contested settlements, plus threat-driven reinforcement. Numerical policy remains a tactical trial. Town defense generally takes priority. |
| M03 · Must · Early | General proposes threats; leader ranks/authorizes campaigns. Survival may disrupt growth and established plans. External expeditions do not override immediate defense. |
| M04 · Should · Early | Estimate known/suspected force with a margin, maintain home defense, stage the initial force at a suitable nearby settlement/outpost and depart coherently. Reassess after losses/new information. |
| M05 · Must · When these weapons enter play | Preserve weapon distinctions: rifle range-two terrain-blockable support; flamer range-one ranged-only, effective first fire/anti-animal and vulnerable. Count allies able to act in time, not merely nearby bodies. |
| M06 · Should · Early | Lieutenant/task-force execution coordinates feasible support, movement and attacks. Prefer useful kills unless urgent protection demands another target. Occupy a nest when expected enemy-turn survival makes it worthwhile. |
| M07 · Must · Early | Avoid grinding an unlikely victory. Retreat, recover and assemble a more adequate force; purposeful losses may be justified by a worthwhile likely success. A task force may shrink to one unit or be eliminated. |
| M08 · Maybe · Tactical trials | Stacking limits, zone of control, interception, garrison sallies, ranged resolution and exact retreat discretion need tests. Do not import SMAC collateral or one-unit-per-tile as settled policy. |
| M09 · Could · Middle/later | Expand vehicles, loadouts, protective/support roles and domains. Military sophistication is part of the ambition; it need not arrive as a full opening roster. |

**Coherence check:** safety follows executable rules, and a prepared expedition has credible means to accomplish its purpose. Force dispatch/action counts alone prove neither adequate sizing nor tactics. Sources: Q080–Q104, D006–D009, S09/S10/S15/S16, C01.

### G10 — Wildlife, pollution, health and ecological ambition

| ID / priority / window | Actionable design |
|---|---|
| W01 · Must · When wildlife enters play | Nests develop from species, starting conditions and acquired resources; no automatic scaling to human strength or elapsed turns alone. Gathering/replacement disruption follows actual economic effects. |
| W02 · Should · Early/middle | Different species can behave differently. Nest destruction leaves surviving animals and xenomass for separate handling. Distinguish xenomass from consumable biomass. |
| W03 · Should · Early/middle | Health causes growth penalties mitigated by staffed Medics; pollution accumulates, spills and worsens tile overlays. Its industrial term follows actual processing/output, with no industrial-activity contribution from idle facilities; rates remain trial values. Engineer waste services address contained pollution; existing spills need substantial physical worker cleanup. |
| W04 · Should · Early/middle | Couple large-settlement benefits with manageable pressure. Forest/preserve progression begins with no-tech generation reduction, then selected tech-enabled treatment/spread benefits. Exact rates and biome forms remain open. |
| W05 · Should · Middle | First advanced native relationship progresses: control one animal → pacify one nest → control one nest → improve one nest. Pacified and controlled remain different. Initial animal tier: one active link per qualified trained/equipped controller. Sustaining/release conditions and later nest-link limits remain open. |
| W06 · Should · End ambition | First ecology arc combines concrete projects/milestones with sustained viable civilization/pollution/native-management conditions. Suggested route, not compulsory preservation or a finalized victory formula. |
| W07 · Could · Middle/later | Develop water ecology/resources and sea/flying species as relevant to the marine direction. Local custom biome alterations are a desired future terraforming direction; exact sci-fi mechanisms pending. Altitude manipulation stays low priority. New human-controlled nests and nest seeding remain candidates. |
| W08 · Should · Early | Prioritize pollution, terrain obstructions, fauna and flora before speculative alien identity/supernatural layers. Fauna uses its xenomass from game start; eventual human reuse is desired, with exact benefits open. |
| W09 · Should · Early/middle | Develop wildlife repellents relatively soon: define species response, coverage, operation and limitations. Repelling differs from pacifying/control; no universal safety assumed. |
| W10 · Could · Later | Ancient practical-service sites are accepted eventually; alien origins and any supernatural nature remain TBD. Portable specimens/artifacts are only a tentative late idea. |
| W11 · Maybe · Later | Preparedness-sensitive events and predictable planetary cycles remain tentative future exploration. Spy-caused accidents/outbreaks are possible event links, not adopted event rules. |

**Coherence check:** world changes have causes the player can learn and respond to; prevention limits cleanup drudgery. One supplied ecological mini-quest would demonstrate a chain, not universal AI understanding. Sources: Q057–Q061/Q105–Q112, D012–D017, S14/S17, C02/C17/C18.

### G11 — Shared AI decisions, authority and commitments

| ID / priority / window | Actionable design |
|---|---|
| A01 · Must · Foundation | Use ordinary legal actions and permitted observations. The AI is deterministic programmed assessment/planning with controlled randomness, not a runtime language-model player. |
| A02 · Must · Foundation | Put direct opportunities and derivative enabling actions into the shared proposal process. Separate legality, affordability, executability, priority and purpose. Domain routines propose; leader resolves civilization-wide competition. |
| A03 · Must · Foundation/start | Reserve real people/resources without double commitment. Share genuinely reusable prerequisites; canceling one goal does not remove work still needed by another. |
| A04 · Must · Start ensemble | Retain relevant blocked goals and seek feasible remedies. Release/revise commitments when purpose disappears or authorized emergencies intervene. Do not use arbitrary age expiry or endless unproductive waiting. |
| A05 · Should · Start/early | Let governors handle bounded routine development; general plans military needs and lieutenants execute task-force tactics. Useful temporary work may coexist with a retained plan reservation if it cannot delay readiness. |
| A06 · Should · Throughout | Cover every supported action family in reasoning, with practical candidate grouping/pruning. Prefer simple sufficient heuristics over elaborate systems that confuse other functions. |
| A07 · Could · Later | Human automation/override and plan overview may grow gradually. Autonomous in-match policy learning or experimentation is not the default; authored tactical rules improve through repeated tests. |

**Coherence check:** trace a chosen purpose through prerequisites, allocation, ordinary command and actual useful outcome. Do not declare architectural components reusable from their names alone; stage three must inspect them. Sources: Q001–Q021/Q037–Q044/Q113–Q127, S05/S18, historical AI architecture reference.

### G12 — Human interface and controls

| ID / priority / window | Actionable design |
|---|---|
| U01 · Must · Start ensemble | Target a fixed 1920×1080 PC interface, map-centered with top menus and six-resource stock/net summaries. Distinguish local growth and reserve Food. |
| U02 · Should · Start ensemble | Dedicated settlement management: central map/tile assignments, choices along bottom, progress on right, contributors on left. Show actual workers, idle/reserved/away people and costs without double counting. |
| U03 · Must · Start ensemble | Prefer direct clicks/drags and contextual actions with clear unavailable reasons. Preview reassignment effects inline. Intentional idle/held projects need no forced busywork; serious End Turn warnings permit proceeding. |
| U04 · Must · When combat enters play | Reserve a combat-comparison area in the bottom unit-information panel for selected unit/hovered target. Right-hold previews move/attack; release executes ordinary order; Esc cancels. Confirm major additional consequences where applicable. |
| U05 · Should · Start ensemble | Provide idle-unit cycling, settlement/selection navigation, center view, End Turn button/key and action keybinds. Pan by middle-drag/arrows; minimap shows known terrain/ownership/settlements/camera footprint with click/drag navigation. |
| U06 · Should · Start/early | Use tier-emphasized tech rectangles: boons above, costs below, icons where clear, connection lines hidden but prerequisites inspectable. Start map overlays with yields, resources/anomalies and pollution. |
| U07 · Must · Whenever relevant | Important states are readable beyond color alone. Tooltips identify things, actual/potential output, contents, knowledge and blockers. Keep health, contained pollution and spilled pollution distinct. |
| U08 · Could · Later | Add encyclopedia, fuller plan/AI inspection UI, advanced overlays, group selection, pinned comparisons and player-facing animation-speed options. Zoom/rotation/tilt remain future scope. |

**Coherence check:** approved five-task UI review: diagnose Food shortage, reassign pop, hold/resume project, inspect anomaly and preview/order safe movement. Judge visual coherence and convenience, not just information completeness. Sources: U01–U24, X01–X06 and later zoom deferral.

### G13 — Map, models, assembly and animation

| ID / priority / window | Actionable design |
|---|---|
| V01 · Must · Start ensemble | Retain actual animated 3D view; abandon separate sprite-map direction. One pop has one figure, with one visible representative on a shared hex and a more-occupants indication/roster. This does not choose combat stacking. |
| V02 · Should · Start ensemble | Grounded realistic sci-fi survival/work clothing, mostly uncovered faces, recolorable costume panels and equipment/task silhouettes. Initial assets are recognizable and furnished, not barren primitives. |
| V03 · Should · Start ensemble | Aim for continuous-looking ground, connected relief/water and coherent vegetation clusters. Use subtle/contextual hex boundaries. Judge at the chosen fixed map scale; 50–75% hex-size guidance remains approximate. |
| V04 · Should · Start/early | Use granular recipes/modular parts for vehicles/improvements and reusable human bodies/rigs/equipment where appropriate. This adapts Medieval Town's construction principle without importing its sprite presentation. |
| V05 · Should · Start ensemble | Cover idle, travel, work, attack, hit/defend, retreat and elimination with simple readable animation, reusing clips appropriately. Use restrained vegetation/water motion and purposeful machinery/smoke; operational animation agrees with actual state. |
| V06 · Must · Whenever applicable | Visuals respect fog knowledge and ownership. Distinguish hostile/pacified/controlled animals while retaining species identity; nests and related forms share motifs but retain distinct silhouettes. |
| V07 · Should · Start/early | Provide reduced decorative motion. Occasional varied idles/turret turns add life where affordable; local occluder fading or outline/icon fallback is provisionally preferred, subject to visual usability tests. |
| V08 · Could · Later | Zoom-dependent detail/markers, manual icon mode, advanced body variants and elaborate curse styling can evolve later. No exact curse progression, fixed skeleton count, mesh budget or frame cap is adopted. |
| V09 · Should · Early→middle | Explore a soundscape between early and middle development: scope/style to review. Original scientific/civic reports and faction/leader voices are deferred until much later; soundscape does not require voice acting. |

**Coherence check:** approved first art review set: civilian, builder, Explorer, rifle, flamer, rover and nest/animals, including clear/cluttered contexts and motion. Because zoom is now deferred, close views may be separate asset previews; initial gameplay need not implement zoom to satisfy review. Include a representative improvement such as the generator as a recommendation, not a required extra starting asset. Sources: V01–V18, X03–X04, granular assembly brief and screenshot discussion.

### G14 — Evidence, stress testing and maintenance

| ID / priority / window | Actionable design |
|---|---|
| F01 · Must · Foundation | Record meaningful decisions/rejections/blockers and actual commands/outcomes. Reproducibility, save/replay integrity and economic conservation support diagnosis; none alone proves competent play. |
| F02 · Must · Every capability | Before declaring AI support, demonstrate useful recognition, prerequisite acquisition, execution, interruption/reconsideration and sensible rejection, plus ordinary-game use beyond a supplied fixture. |
| F03 · Must · Throughout | Keep five detailed runs by default, up to ten for active comparisons; also bound size. Preserve compact aggregate lessons with build/rule context and obsolete/partial/retest status. Do not apply pruning to design docs, source or player saves. |
| F04 · Should · Start/early | Begin competence work on the first map. Use user-suggested/approved scenarios to isolate problems; broaden conditions when relevant before balance/generalization claims. No new scenario is run merely because this plan mentions it. |
| F05 · Should · Stress testing | Evaluate busy scenes, scrolling, simultaneous motion, frame-time spikes and turn work. Retain 30/40/60 FPS discussion for measurement; no universal fixed target selected. Investigate smooth asset loading if stuttering appears, after identifying causes. |
| F06 · Should · Testing first | Internal playback acceleration/skipping and no-presentation test execution must preserve outcomes. Player-facing options later. Keep cosmetic randomness separate from gameplay randomness. |
| F07 · Must · Every implementation | Review each implementation against the intended behavior and evidence before calling it complete. Every batch must have functionality, performance and balance tests; record limits, failures and any justified deferrals explicitly. No test result is presumed by this plan. |

**Coherence check:** a later conclusion identifies the build, circumstances, actual outcome and limits of inference. Repeated useful progress, not explanations or raw command volume, establishes adequacy. Sources: Q113–Q127, D019–D020, S01–S18, V11 and performance follow-ups.

### G15 — Factions, diplomacy and espionage

| ID / priority / window | Actionable design |
|---|---|
| DP01 · Should · Early | Establish factions with identifiable ownership and distinct authored behavior as developed. Faction leaders are a middle target; faction ideologies a late target, not timed global-era unlocks. |
| DP02 · Should · Early | Develop an expansive diplomacy system with Civ IV as the key reference and a manageable option set. Practical agreements can cover passage, information, repair access and resource exchanges; exact rules remain to select. |
| DP03 · Must · When agreements exist | Make terms, eligibility, obligations, expiry/breach and effects explicit, obey limited knowledge and prevent duplicate resource commitments. The AI must assess agreements using the same legal rules and explain acceptance/rejection. This is an implementation-coherence requirement, not an adopted reputation formula. |
| DP04 · Should · Middle | Espionage must exist by and during midgame trials: information gathering, sabotage and countermeasures are directions to define. Possible industrial accidents/outbreaks remain examples pending rules. |
| DP05 · Could · Later | Broader councils, collective institutions and mature diplomatic layers can follow the practical system. No EU IV-scale option/suboption catalogue required. |

**Coherence check:** relationships change real permissible actions and commitments, with observable outcomes. Diplomacy cannot be a menu disconnected from AI planning, fog or the economy. Sources: RF20–RF22 and added faction milestones.

### G16 — Policies, projects and later identity

| ID / priority / window | Actionable design |
|---|---|
| SP01 · Could · Later | Use a Civ VI-style policy-card model as the future civilization-policy direction. Slot/category/switching and effect rules remain open; not every card must have a penalty. |
| SP02 · Should · Middle→late | Develop meaningful major, minor and local wonders/projects, including restored/upgraded tiles and time-consuming civilization investments. Some may be globally unique; not every project must be unique or global. Explore Civ III–VI, SMAC and BE examples before selecting original content. |
| SP03 · Could · Later human warfare | Captured settlements may retain people/assets but require integration, repairs or restored services; specifics may borrow from several games. Do not invent a settled assimilation timer. |
| SP04 · Maybe · Later | Unrest remains deferred. Taxing policy cards could cause resistance, temporary cohort rioting, combat penalties or departures/bandit founders; all are speculative alternatives with no adopted numerical values. |
| SP05 · Maybe · Later | Prosperity bonuses are conditional and must respect social/economic/technological causes. Avoid dramatic blanket yield boosts such as +50% without corresponding economic logic. |
| SP06 · Could · Middle→late | Add game options by middle development and a Civ-like new-game setup flow by late. These are product milestones, not features unlocked halfway through an existing match. |

**Coherence check:** projects and policies alter useful choices without bypassing resource, labor or knowledge constraints. No mandatory happiness/rebellion stack. Prototype surcharges and regional/distance administration are deferred; escalating expansion costs are a mid-plus balance question. Sources: RF10–RF16, RF22 and subsequent clarifications.

## 5. Four-stage view retained without prescribing batches

| Play stage | Main purpose | Relevant groups and priority emphasis |
|---|---|---|
| **Game start** | A small complete foothold understands its assets and can make a useful choice without an economic deadlock. | Foundation accounting/people/actions; opening Food/production/construction/research path; safe initial work; basic world knowledge, UI and map readability. G01–G06/G09/G11–G14. |
| **Early game** | Develop a protected network and make local opportunities deliver useful operation. | Supported growth, land allocation, deliberate expansion/roads, neutral services, functioning research, garrisons, factions, substantive diplomacy, map generation after fixed-map tests and adequately prepared local operations. G03–G10 with the shared AI/UI foundation. |
| **Middle game** | Specialization changes what the civilization can do. | Useful equipment/platform roles, advanced workplaces, concentration management, productive ecology, strategic capacity, automated extraction, specialized aquatic settlements, faction leaders, espionage and the selected animal→nest relationship progression. Soundscape exploration begins between early and middle. No required global era transition. |
| **End game** | Mature capacity pursues a chosen ambition while remaining viable. | First selected focus is ecological projects plus sustained conditions. Broader ideological, industrial, biological and planetary goals remain a catalogue of possibilities. Faction ideologies, orbital direction and later project families enter here as defined; formal victory thresholds are not yet chosen. |

The **start-of-game ensemble** for stage two is an integration target, not a requirement to introduce all groups at full depth. The almost-empty-map development starting point may temporarily omit the final starting cast or advanced dangers to isolate a behavior. Every such omission must be labeled a development fixture, not silently redefine the intended opening.

## 6. Proposed minimal content envelope, without final recipes

The current material supports the following scope for planning, while exact costs and names await explicit rules and the later source audit:

- **Opening inventory:** one bare-bones settlement, two untrained civilians, one basic-rifle Soldier, one Explorer, an equippable build kit and modest Food/Energy/construction reserves. No mandatory starting rover, advanced suit or specialist workplace.
- **Bootstrap capabilities:** attainable Food, raw-material acquisition, basic Industry conversion, construction, entry training and research. Most developed economy belongs outside the settlement-center hex; the center can provide rudimentary functions.
- **Early geographical choices:** ordinary workable land, a few identifiable opportunities, construction sites and useful routes. Fog/knowledge should be introduced as a meaningful capability, not a cosmetic dark overlay over omniscient AI.
- **Representative threats and services:** enough actual wildlife and later neutral services to test relevant choices, without requiring a complete fauna/trade roster before basic accounting works.
- **Working presentation:** readable fixed-scale 3D map and direct management/action controls. This is more than a console harness, but does not require finished art or every future menu.

These are design envelopes rather than a new scenario or a list of assets verified in code. Stage two will decide the bounded order and reviews; stage three will test what can be retained.

## 7. What the collected reference material adds—and what stays parked

| Contribution | Current treatment |
|---|---|
| SMAC ecology, useful forests, native relationships and planetary ambition | **Should**, selected in adapted form: productive ecology and progressive animal/nest management. No imported psi ratios or full social-rating stack. |
| Colonization persistent people, workplace staffing and role equipment | **Must/Should**, central organizing connection, using our Food/support/resource rules. No compulsory Europe market, immigration or ocean commodity freight. |
| BE distinctions among terrain, deposit, access, discovery and yield | **Should**, clarifies existing opportunities. It does not require adding all reference resources, strategic counters or artifacts. |
| Technical capability versus practical local manufacture | **Should**, early-research framing and meaningful prerequisites; no mandatory four-step bureaucracy for every technology. |
| Civ IV readable landscape, visible objects and procedural arrangement | **Should**, adopted principles with exact original renderer internals only claimed where documented. Fixed-scale initial presentation remains compatible. |
| Civ VI district placement, policy cards, adjacency analogy and bottom combat comparison | District opportunity costs and combat UI retain their agreed scopes. Policy cards are a future direction; adjacency networks a promising future idea. No entire roster, formula or government system imported. |
| Reusable recipes and shared components from Medieval Town | **Should** as a production recommendation. No requirement to convert Alien Planet to sprites or generate every human vertex from primitives. |
| Historical AI authority/commitment/ordinary-action chains | **Must** as intended behavior. Candidate architectural value only; actual surviving source must be inspected at stage three. |
| Huge technology taxonomy, every SMAC facility and BE profession | **Could/Maybe** catalogue, not implementation obligations. Strategic deposit capacity and automated extraction now have desired tentative midgame scope; no empty node per proposed subfield. |
| Orbit and civilization identity | Orbit is a good late-game direction; factions by early, leaders by middle, ideologies by late. Gate/digital-society/transcendence possibilities remain parked. |
| World expansion | Map generation is early after fixed-map tests; specialized aquatic settlements are midgame. Full weather/hydrology and planetary cycles remain tentative eventual exploration. Movable marine settlements remain late and low priority. |
| ZOC/interception, stack punishment, advanced module slots and human-controlled nest founding | **Maybe**, distinct tactical/content hypotheses needing rules and evidence. |
| Runtime language-model AI, omniscience and fabricated resource grants | Outside the selected baseline. Test instrumentation must not masquerade as ordinary capabilities. |

## 8. Clarifications resolved and intentionally open

Both prepared rounds are complete: **RF01–RF24** and **RC01–RC08**, including deferrals. Their individual records remain in the ledger and the historical clarification appendix below.

| Interface | Current decision | Still open |
|---|---|---|
| RC01 storage | Testing: Food/Minerals/Industry local records; Energy/Science/Culture global; pooled automatic access | Capacities and restrictive warehouse rules |
| RC02 accounting | Once per turn-boundary ordinary production/consumption; immediate explicit actions; preserve incurred costs | Exact phase order to review in stage two |
| RC03 labor | Divide manufacturing and project work without double counting; ordered settlement queue; separate builders | Queue blocker/overflow allocation; Engineer rates; conversion recipes |
| RC04 tools/founding | Reusable kit for improvements/clearing/districts; separate consumed founding materials | Founding recipe and duration |
| RC05 map | Inclusive answer interpreted as global coast/basic terrain/relief; details/activity discovered | Precise macro display and resource identification rules per type |
| RC06 support loss | Observe frequency; do not adopt an automatic Food-work exception | Support-source mapping and emergency treatment when relevant |
| RC07 pollution | Industrial contribution follows actual activity/processing, idle facilities excluded | Rates and chosen throughput measure |
| RC08 control | One active animal link per qualified controller | Sustain/release conditions and later nest limits |

No new broad questionnaire is required before stage-two review. Feature contracts must settle their blocking interfaces before implementation; explicit testing deferrals remain deferrals. Numerical tuning does not require a fresh interview unless it changes the design direction.

## 9. Review conclusion and handoff to the next stage

The design is coherent when the same constraints govern every domain: real people, real resources, real access, meaningful time, limited information and chosen priorities. Its main risk is inconsistent accounting or duplicated authority across otherwise sensible subsystems—not a lack of content ideas.

This grouped baseline incorporates the completed clarification and reference-interest rounds. The next review is of the separate **stage-two batches**, including functionality, performance and balance checks and a review of every implementation. Stage two should turn the accepted groups into small integrated feature/test batches with stated entry state, newly available choices, evidence and deferrals. It should progress toward the full opening ensemble without inventing a compulsory player opening script.

Stage three must then inspect the actual available source and label each item: verified present, present but disconnected, behavior needing replacement, reusable content, missing, deferred or unverified. It must revise stage two around actual reuse and dependencies. No historical architecture report or generated concept image is sufficient proof of implementation.

## 10. Source register and authority

Latest explicit user decisions supersede older proposals. This reconciliation is the new review summary, not a deletion or rewrite of the underlying historical record.

| Source | Role / version used |
|---|---|
| [Decision ledger](https://chatgpt.com/library?file_id=libfile_4bb48d3203e881919b9014182cedbcc8&account_id=personal) | Primary authority: Q001–Q128, D001–D020, S01–S18 refinements, C/U/V questions, X01–X06 and later zoom deferral; through version 303 before this stage. |
| [Four-stage synthesis](https://chatgpt.com/library?file_id=libfile_5959be2c4f608191bc9f83915f9cc710&account_id=personal) | Version 1; progression bins and filtered reference additions. Older unresolved text is superseded by later answers. |
| [Start/early should-review](https://chatgpt.com/library?file_id=libfile_06b76f8c5320819197c968c4e5ad530f&account_id=personal) | Version 80; S01–S18 behavior/evidence standards. Not current competence proof. |
| [Identity/consistency review](https://chatgpt.com/library?file_id=libfile_096aff088e148191a719d2453bd70a05&account_id=personal) | Version 21; identity, interfaces and C answers. Historical cursors not current queue. |
| [UI reference and decisions](https://chatgpt.com/library?file_id=libfile_f1ba5655d9808191b11287c194a73612&account_id=personal) | Version 30; U answers, controls, bottom combat panel and zoom supersession. |
| [Map/unit art reference and decisions](https://chatgpt.com/library?file_id=libfile_8186e845af6c81918615bed7eff06627&account_id=personal) | Version 29; V answers, extra map topics, assembly/terrain explanations and screenshot observations. |
| [SMAC-inspired proposals](https://chatgpt.com/library?file_id=libfile_f8bb8352a5f48191937914dd1d41b3a1&account_id=personal) | Version 2; useful conceptual connections, not current currency/logistics authority. |
| [BE reference/professions](https://chatgpt.com/library?file_id=libfile_b581ed0029988191863cd98d78d9c64b&account_id=personal) | Version 0; geography/resources/services vocabulary. No wholesale roster adoption. |
| [Technology ideas](https://chatgpt.com/library?file_id=libfile_1d9d1e05901881918a854fe4ee611f41&account_id=personal) | Version 0; 45/15/eight-area possibility taxonomy, not mandatory technology count. |
| [Historical AI architecture](https://chatgpt.com/library?file_id=libfile_34969fd37e648191b7f9b54c31023a61&account_id=personal) | Version 0; reported 0.910 architecture and explicit source-access limitations. Used for design lessons, not a fresh audit. |
| [Historical tactical notebook](https://chatgpt.com/library?file_id=libfile_3dcf8d6003e08191929a986204033539&account_id=personal) | Version 0; causal/evidence lessons and tactical hypotheses. Historical observations do not establish current results. |
| [Medieval Town assembly brief](https://chatgpt.com/library?file_id=libfile_700fd34e7dec8191809015698ac60f9b&account_id=personal) | Construction/presentation separation, bounded variation and useful detail. Read during preceding cross-project discussion; presentation/styling not transplanted. |

The older source collections remain available through their registers. This stage reorganizes the selected project material and recorded decisions; it does not claim an exhaustive new factual audit of every SMAC/BE entry or a live inspection of either commercial game.

## Review supplement — reference-interest pass requested 5 November 2026

After delivery, the user requests another comparison against older SMAC/BE collections to identify future ideas they can rank by interest and utility. A separate Alien_Planet_Reference_Ideas_Interest_Queue_2026-11-05.md records RF01–RF24, distinguishing unranked mechanisms, deeper specifics and already parked revisits. This supplements stage-one review; it does not silently promote candidates, change the opening scope or replace RC01–RC08. RF01 now asked; later feature/testing batches and implementation audit remain pending. No candidate is accepted merely by appearing in the reference list.


## Historical clarification record — 5 November 2026

The current decisions are integrated above. Questions reproduced here document the sequence; they are not pending questions.

### RC01 answer — 5 November 2026

User accepts **for game-world testing purposes**: Food, Minerals and Industry have physical settlement storage records; Energy, Science and Culture remain civilization-wide pools. Provisional testing model, not an irrevocable final economy. Preserve pooled automatic access without freight or delivery delays. Storage capacities and capacity enforcement were not selected by this answer; do not silently adopt numeric caps or a restrictive warehouse model.

### RC02 — within-turn accounting contract

For initial testing, should ordinary production and ongoing consumption resolve once at the turn boundary, using assignments and recorded activity, while immediate actions charge their explicit costs when performed? Already-incurred obligations must survive reassignment, and one cohort must not receive several full turns of production or upkeep merely by changing jobs. Detailed ordering of shortages, growth and construction should be proposed in stage two rather than treated as decided by this question.


### RC02 answer — 5 November 2026

User accepts: ordinary production and ongoing consumption resolve **once at the turn boundary**, while immediate actions such as technology purchases charge explicitly when performed. Reassignment neither erases incurred obligations nor grants multiple turns of output. Use assignments and recorded activity consistently without charging several full upkeeps for one cohort. Detailed ordering among operating inputs, shortages, growth and construction remains for stage-two proposal; this answer does not approve an unstated exact schedule.

### RC03 — manufacturing versus construction labor

For initial testing, should a settlement worker allocate its turn's effort either to manufacturing stockpiled Industry or to construction progress, with effort split possible but no double use? Builders on-site could contribute separately, preserving settlement-only, builder-only and assisted construction. Engineer specialization details, input rates and exact construction bonuses remain open.


### RC03 answer — 5 November 2026

User accepts division of settlement-worker effort between manufacturing stockpiled Industry and advancing construction, without double-counting effort; on-site builders contribute separately. **Settlement has an ordered project queue served in turn.** Record this as the settlement's default project service order, refining earlier multi-project allocation discussion; do not assume every earlier option to pause work, allocate capacity or have separate builders is removed. Exact handling of blocked entries, holds, overflow and parallel on-site work remains to specify. Engineer input/output and specialization-rate details remain open.

Additional consideration: **local conversion tasks**, for example local Industry converted into global Culture. Retain as a possible task/project type, not an accepted recipe or unrestricted conversion between every resource pair. Exact inputs, rates, labor, prerequisites and global/local accounting remain undecided.

### RC04 — build-kit permissions and reuse

For initial testing, should the equippable build kit be reusable for basic improvements, clearing and district work, while founding a new settlement consumes a separate package of materials? Exact permitted actions and founding recipe remain open. This proposal separates a worker's tools from the resources needed to establish a settlement.


### RC04 answer — 5 November 2026

User accepts the equippable build kit as **reusable tools for improvements, clearing and district construction**, while **founding a settlement consumes a separate package of materials**. Routine construction still has its own resource/labor costs; reusable tools do not make actions free. Exact material recipe, action-specific requirements and any founding duration remain open. Existing cohort identity/training persists; no population consumption rule newly adopted.

### RC05 — initial macro-map knowledge

Should initial broad map knowledge show **continent/coast shapes only**, with ordinary terrain and relief revealed through exploration, or also show **basic terrain and relief globally**, while anomalies, resources requiring identification and current activity remain unknown until discovered/observed? Local ordinary known terrain remains usable as already agreed; fog-of-war rules still apply.


### RC05 answer and future founding packages — 5 November 2026

User answers “Yes to all”. Interpret the inclusive answer as initial broad knowledge of **continent/coast shapes plus basic terrain and relief globally**, while anomalies, special resources requiring identification and current activity still require exploration/observation. State this interpretation to the user; preserve fog and last-seen information rules, not globally live world state.

Additional late idea: **better preset versions of newly founded settlements**, with more substantial founding investment/cost. Record as improved settlement-start packages; exact bundled infrastructure, technology prerequisites, options and costs remain open. User wrote “more expansive to build”, interpreted in context as larger/more costly packages; no exact recipe or free upgrades adopted.

### RC06 — settlement support and emergency Food work

For testing, should the settlement center provide basic working-population support, with amenities extending it; and if support infrastructure is lost, should essential Food jobs be allowed to exceed the reduced support limit temporarily to avert starvation? Exact support amounts, growth gates and over-cap consequences remain open. Preserve the existing rule that displaced workers otherwise become idle and shortages trigger reassignment.


### RC06 answer — 5 November 2026

User: “Remains to be tested how often that happens”. **Do not adopt the proposed emergency over-cap Food-work exception yet**; observe how frequently support loss creates this situation and decide from evidence. This answer does not independently confirm every proposed support source or numerical cap. Preserve prior accepted support/infrastructure-reassignment rules and Food-shortage response; exact support-source mapping and the emergency interface remain unresolved for targeted testing/design when relevant. No new scenario run authorized by this answer.

### RC07 — industrial pollution cause

In pollution generation, should the industrial contribution follow **actual industrial activity/throughput**, rather than merely counting built facilities? For example, an idle factory adds no industrial pollution, while an operating one contributes according to how much it processes. Exact rates, baseline and whether worker count is a useful first approximation remain open.


### RC07 answer — 5 November 2026

User accepts **actual industrial activity/throughput** as the basis for the industrial contribution to pollution. Idle facilities contribute no industrial-activity pollution; operating facilities contribute according to output or processing. Preserve the separately discussed working-population contribution and mitigation mechanisms. Exact throughput measure, rates, baseline allowance and technology/process differences remain open for testing; do not count an installation merely because it exists.

### RC08 — initial advanced-control limit

For the first animal-control tier, should each trained/equipped controller maintain **one active animal link at a time**, with later technology extending the relationship to nest pacification/control? This proposes a per-controller limit rather than one animal for the whole civilization. Requirements to sustain a link, release/loss conditions and exact nest-control limits remain open.


### RC08 answer and clarification-round completion — 5 November 2026

User accepts **one active animal-control link per trained/equipped controller**, rather than one animal for the whole civilization. Later technology extends capabilities toward nest pacification/control, preserving the agreed progression. Exact qualifications, sustained-link requirements, range, release/loss conditions and later nest-control limits remain open; no automatic unlimited aggregate army or free control implied.

**RC01–RC08 clarification round complete**, including RC06's explicit deferral to testing. RF01–RF24 reference-interest round is also complete. No additional prepared questions remain in either round. Retain unresolved exact values and scoped interfaces for the relevant feature batches rather than reopening a broad interview. Outstanding testing deferral: frequency and treatment of essential Food work after support loss. Preserve conditional/provisional answers.

Next review stage is **stage two: feature and testing batches progressing from a minimal fixed-map foundation to the full start-of-game ensemble**, with dependencies and observable AI competence criteria. Reflect subsequent reference priorities, including early diplomacy/map generation/factions, midgame strategic capacity/automation/aquatic settlements and espionage by midgame trials; distinguish these wider stage targets from the initial opening ensemble. Stage three's actual implementation assessment and revised plan follows separately. No implementation, scenario run, audit or log deletion performed by closing this round.


## Reconciliation update after the reference and clarification rounds

All RF decisions have now been integrated into the relevant action groups and stage targets. G15–G16 make diplomacy/factions/espionage and policies/projects visible instead of leaving them buried in appendices. Recent priorities supersede the older broad parked labels. The minimum opening remains four cohorts and a basic settlement; early/middle/late ambitions are not all starting inventory. Each implementation now requires review, and every batch has functionality, performance and balance tests. Stage three has not been performed; this is a design reconciliation, not a claim about existing source.


Stage-two companion prepared: **Alien_Planet_Stage_2_Feature_Test_Batches_2026-11-05.md**. Nine detailed batches lead to the starting ensemble, with fourteen coarser early/middle/late roadmap packages. Every batch contains functionality, performance and balance checks; every implementation and completed batch requires review. Later packages need smaller reviewed implementation steps. No tests or code changes have been performed.


## Source-audit handoff — 5 November 2026

The static stage-three audit is complete for `0.910-reconstructed`, compared against current repository commit `8a9f3d6a9f9787bc11e8489f5426f9d3a650395c`. See **Alien_Planet_Stage_3_Source_Audit_2026-11-05.md** and the revised stage-two batch plan. This does not change the design priorities: it identifies reusable implementation/content, conflicting mechanics, decorative AI records and unmeasured performance suspects. The recommendation is selective replacement of state/accounting/allocation paths within the existing project, preserving useful commands, people/equipment, ecology, art tooling and batching. No game code was changed or freshly executed. Earlier “stage three pending” wording describes the document's original review phase, not the current project status.
