# Alien Planet — start/early-game “should” review

Working agenda • 2 November 2026 • D020 direction

The first review covers the whole start/early-game loop. We will refine one capability at a time across **inventory → mechanics → AI decisions → evidence**, until we agree that the AI handles it well enough. This is an ordered set of discussion targets, not eighteen mandatory new systems or a prescribed opening build order.

The governing question is whether a deterministic AI player can recognize its actual circumstances and use the available tools sensibly. Sometimes the correct choice is to defer, retreat, build a prerequisite, trade or pursue another opportunity. Completing a nest-clearing script is not the universal success criterion.

## Status and use

All items begin **proposed / not yet assessed against current source**. Starting the discussion does not mark an item implemented, tested or accepted as competent. Current item: **S01**. The grouping and proposed checks below are recommendations; existing user decisions retain their original firm, provisional or deferred status.

For each item we will agree its available content and rules, inspect what the current build actually offers, identify the smallest coherent repairs/additions, and define meaningful evidence. Development and approved tests belong in the development thread. Review order can change for dependencies or user preference; an agreed item can reopen when later changes invalidate its evidence.

When comparing, label findings: present and demonstrated; present but disconnected/unused; desired change; new addition; deferred; or unverified. Historical 0.908–0.910 reports are not a current-source audit. No new code, simulations, scenarios or log deletion accompany this document.

## Ordered should-list

| ID | The player/AI should… | Proposed sign of competence |
|---|---|---|
| S01 | Understand the opening and the known world. | Can connect a choice to known circumstances and revise it when new information changes the situation. |
| S02 | Account for resources and keep the colony operating. | A surplus elsewhere does not hide a local deficit; recovery uses legal inputs and preserves essential operation. |
| S03 | Assign persistent people to useful work. | No duplicated workers or chronic assignment churn; changed employment produces the expected output tradeoff. |
| S04 | Grow and support larger settlements. | Growth helps a real plan; larger settlements gain useful scale without ignoring their costs or concentrating blindly. |
| S05 | Choose goals and coordinate commitments. | An important plan progresses through ordinary actions; competing proposals do not repeatedly steal its prerequisites. |
| S06 | Research attainable capabilities. | A capability is researched and put to useful work through ordinary means rather than merely appearing in an unlock list. |
| S07 | Build and improve for a stated purpose. | Construction serves a named need, becomes usable and does not create pointless empty capacity or automatic clear-all behavior. |
| S08 | Explore and identify useful opportunities. | Scouting changes knowledge and decisions; AI neither reads hidden activity nor explores only because it has a unit. |
| S09 | Recognize danger and shelter civilians. | Movement reduces actual exposure when feasible; adjacent troops alone are not treated as guaranteed protection. |
| S10 | Maintain home defense and handle emergencies. | An expedition does not casually empty home defense; emergency action addresses the threat and later releases temporary commitments. |
| S11 | Expand into a useful, supportable network. | A new settlement has a credible purpose and support path; unsafe or low-value expansion can be deferred. |
| S12 | Connect and move people purposefully. | Connections or transport deliver people to actual useful destinations; no blanket road quota or endless transit. |
| S13 | Use real external exchanges. | A partner exchange occurs and the accounting is correct; trained advantage and travel costs are visible rather than magical conversion. |
| S14 | Read wildlife as an ecology. | Threat assessment responds to evidence and resource changes rather than a fixed nest label or an omniscient enemy count. |
| S15 | Prepare an adequate expedition. | A useful force assembles through ordinary growth/training/equipment and departs coherently; deferral has actionable blockers. |
| S16 | Fight, recover and complete operations intelligently. | Actions advance the objective with credible survival; repeated futile attrition or attack counts do not establish competence. |
| S17 | Manage the costs of concentration and land use. | AI can maintain useful development while controlling the pressures represented in that build. Advanced native control is not an opening prerequisite. |
| S18 | Explain decisions and retain qualified evidence. | We can trace cause and outcome, distinguish supplied fixtures from autonomous competence, and retain valid lessons without keeping every raw run. |

## Per-item refinement cards

### S01 — Understand the opening and the known world

- **Inventory to establish:** Starting settlement/workforce, Soldier, Explorer, equipment, technologies, map information and visible hazards.
- **Mechanics to refine:** Separate visible geography, identified details and current observations; define what information a player may use.
- **AI choices to inspect/refine:** Assess usable assets, immediate needs and useful opportunities without hidden knowledge or a fixed universal opening.
- **Proposed competence evidence:** Can connect a choice to known circumstances and revise it when new information changes the situation.
- **Status:** proposed; no current-build verification or agreed test yet.

### S02 — Account for resources and keep the colony operating

- **Inventory to establish:** Food, Minerals, Industry, Energy, Science, Culture; stocks, yields, running costs and outside-population support.
- **Mechanics to refine:** Resolve local Food/global reserve accounting, shortage effects, legal production and real partner exchange.
- **AI choices to inspect/refine:** Detect the actual bottleneck; select an attainable remedy and release lower-priority consumption when needed.
- **Proposed competence evidence:** A surplus elsewhere does not hide a local deficit; recovery uses legal inputs and preserves essential operation.
- **Status:** proposed; no current-build verification or agreed test yet.

### S03 — Assign persistent people to useful work

- **Inventory to establish:** Each cohort, current task, workplace, qualification, travel and availability.
- **Mechanics to refine:** One cohort has one state; define legal tile/building employment, reassignment and productive idle defaults.
- **AI choices to inspect/refine:** Protect useful work, allocate real available people and compare relocation/retraining with local alternatives.
- **Proposed competence evidence:** No duplicated workers or chronic assignment churn; changed employment produces the expected output tradeoff.
- **Status:** proposed; no current-build verification or agreed test yet.

### S04 — Grow and support larger settlements

- **Inventory to establish:** Local growth, global Food spending, external workers, housing/support capacity and population thresholds.
- **Mechanics to refine:** Initially one grown pop per settlement per turn through all growth methods combined; define no-growth routing and costs.
- **AI choices to inspect/refine:** Choose where growth is supportable and useful, including support infrastructure and a job for added capacity.
- **Proposed competence evidence:** Growth helps a real plan; larger settlements gain useful scale without ignoring their costs or concentrating blindly.
- **Status:** proposed; no current-build verification or agreed test yet.

### S05 — Choose goals and coordinate commitments

- **Inventory to establish:** Adviser proposals, leader decisions, local plans, people/resource reservations and active blockers.
- **Mechanics to refine:** Rank compatible goals, retain blocked purposes, create enabling steps, cancel obsolete purposes and permit emergency overrides.
- **AI choices to inspect/refine:** Choose feasible commitments and remedy blockers without every adviser competing for the same means.
- **Proposed competence evidence:** An important plan progresses through ordinary actions; competing proposals do not repeatedly steal its prerequisites.
- **Status:** proposed; no current-build verification or agreed test yet.

### S06 — Research attainable capabilities

- **Inventory to establish:** Known technologies, required professions/facilities, demonstrated prior production, training paths and costs.
- **Mechanics to refine:** Previous-turn actual production qualifies functioning prerequisites; resolve history validity and avoid circular entry gates.
- **AI choices to inspect/refine:** Assess the full missing path and useful payoff; train/staff/build deliberately, with cheap available research as an option.
- **Proposed competence evidence:** A capability is researched and put to useful work through ordinary means rather than merely appearing in an unlock list.
- **Status:** proposed; no current-build verification or agreed test yet.

### S07 — Build and improve for a stated purpose

- **Inventory to establish:** Workplaces, districts, equipment, improvements, terrain features, clearing and settlement work areas.
- **Mechanics to refine:** Define natural-yield replacement, staffing, operation, placement, upgrades and explicit work-area transfer.
- **AI choices to inspect/refine:** Compare improving an existing site with a new site, including people, prerequisites, useful output and land opportunity cost.
- **Proposed competence evidence:** Construction serves a named need, becomes usable and does not create pointless empty capacity or automatic clear-all behavior.
- **Status:** proposed; no current-build verification or agreed test yet.

### S08 — Explore and identify useful opportunities

- **Inventory to establish:** Explorer, unidentified local details, fog, anomalies, deposits and relevant landmarks.
- **Mechanics to refine:** Define what scouting reveals, how investigation works and which opportunity types recur.
- **AI choices to inspect/refine:** Choose useful information or investigation targets, assess travel risk and let discoveries change development choices.
- **Proposed competence evidence:** Scouting changes knowledge and decisions; AI neither reads hidden activity nor explores only because it has a unit.
- **Status:** proposed; no current-build verification or agreed test yet.

### S09 — Recognize danger and shelter civilians

- **Inventory to establish:** Observed/suspected enemies, movement reach, barriers, defensive positions, settlements and exposed workers.
- **Mechanics to refine:** Protection must follow actual combat/access rules; assess reachable shelter and next-turn exposure with incomplete information.
- **AI choices to inspect/refine:** Interrupt threatened work, choose reachable safer positions and keep retreating when pursued.
- **Proposed competence evidence:** Movement reduces actual exposure when feasible; adjacent troops alone are not treated as guaranteed protection.
- **Status:** proposed; no current-build verification or agreed test yet.

### S10 — Maintain home defense and handle emergencies

- **Inventory to establish:** Baseline garrisons, frontier/contested settlements, reinforcements and emergency labor/resource options.
- **Mechanics to refine:** Define higher-risk garrisons, temporary sorties, defensive priorities and last-resort abandonment; retain mobile recovery after town loss.
- **AI choices to inspect/refine:** Defend settlements first, reallocate for survival and recognize when every vulnerable target cannot be saved.
- **Proposed competence evidence:** An expedition does not casually empty home defense; emergency action addresses the threat and later releases temporary commitments.
- **Status:** proposed; no current-build verification or agreed test yet.

### S11 — Expand into a useful, supportable network

- **Inventory to establish:** Founding people/materials, site yields, strategic locations, escorts, initial garrisons and work areas.
- **Mechanics to refine:** Founding is an investment; growth/support gates and later capacity should discourage minimally staffed town-spam income.
- **AI choices to inspect/refine:** Compare expansion with developing existing towns and include access, safety, workforce and support in the proposal.
- **Proposed competence evidence:** A new settlement has a credible purpose and support path; unsafe or low-value expansion can be deferred.
- **Status:** proposed; no current-build verification or agreed test yet.

### S12 — Connect and move people purposefully

- **Inventory to establish:** Roads, useful outposts, transports, passenger capacity and movement rules.
- **Mechanics to refine:** Road construction uses real workers/costs; no current road upkeep or routine resource freight. Define transport entry/exit and protection.
- **AI choices to inspect/refine:** Select useful routes and movement methods, reserve builders and distinguish a requested connection from a completed one.
- **Proposed competence evidence:** Connections or transport deliver people to actual useful destinations; no blanket road quota or endless transit.
- **Status:** proposed; no current-build verification or agreed test yet.

### S13 — Use real external exchanges

- **Inventory to establish:** Neutral sites, visiting populations, partner offers/stocks and trained Merchants.
- **Mechanics to refine:** Basic visitors can trade; trial Merchant doubles neutral-site gains. One visiting pop per player per neutral tile. Refine exact exchange arithmetic.
- **AI choices to inspect/refine:** Find a worthwhile available offer, budget the journey and use trade for a real resource need or opportunity.
- **Proposed competence evidence:** A partner exchange occurs and the accounting is correct; trained advantage and travel costs are visible rather than magical conversion.
- **Status:** proposed; no current-build verification or agreed test yet.

### S14 — Read wildlife as an ecology

- **Inventory to establish:** Species, nests, food/forage, larvae, replacement capacity, biomass and xenomass.
- **Mechanics to refine:** Threat development follows species/resources, not player strength; nest loss does not delete all surviving animals or terrain effects.
- **AI choices to inspect/refine:** Estimate known/suspected danger, identify relevant economic support and choose avoidance, defense or removal for a purpose.
- **Proposed competence evidence:** Threat assessment responds to evidence and resource changes rather than a fixed nest label or an omniscient enemy count.
- **Status:** proposed; no current-build verification or agreed test yet.

### S15 — Prepare an adequate expedition

- **Inventory to establish:** General proposal, leader authorization, target, force roles, home defense, staging point and lieutenant task force.
- **Mechanics to refine:** Trial required power is known plus suspected enemy power with 25% margin; reassess composition and gather initial force before full departure.
- **AI choices to inspect/refine:** Fund achievable preparation, maintain commitments, choose feasible concurrency and update requirements as facts change.
- **Proposed competence evidence:** A useful force assembles through ordinary growth/training/equipment and departs coherently; deferral has actionable blockers.
- **Status:** proposed; no current-build verification or agreed test yet.

### S16 — Fight, recover and complete operations intelligently

- **Inventory to establish:** Rifles, flamers, usable range/terrain, timing, targets, damage, reinforcements and retreat positions.
- **Mechanics to refine:** Rifle range-two blockable support; flamer range-one ranged-only, strong first fire/anti-animal but vulnerable. Stacking/control remain trial questions.
- **AI choices to inspect/refine:** Use support that can act, seek useful kills, defend first, occupy nests when survival is plausible and retreat/rebuild when winning is unlikely.
- **Proposed competence evidence:** Actions advance the objective with credible survival; repeated futile attrition or attack counts do not establish competence.
- **Status:** proposed; no current-build verification or agreed test yet.

### S17 — Manage the costs of concentration and land use

- **Inventory to establish:** Medics, health/growth penalties, Engineers, waste facilities, pollution stock/overlays and productive forests/preserves.
- **Mechanics to refine:** Define population/industry pollution generation, settlement allowance, accumulation and mitigation; support meaningful scale benefits.
- **AI choices to inspect/refine:** Anticipate or diagnose pressures and choose prevention, staffing, cleanup or land-management remedies as available.
- **Proposed competence evidence:** AI can maintain useful development while controlling the pressures represented in that build. Advanced native control is not an opening prerequisite.
- **Status:** proposed; no current-build verification or agreed test yet.

### S18 — Explain decisions and retain qualified evidence

- **Inventory to establish:** Plan/assignment traces, ordinary outcomes, build/context summaries and bounded detailed logs.
- **Mechanics to refine:** Controlled reproducibility; compact cumulative lessons with obsolete markers; five detailed runs by default, up to ten for comparisons.
- **AI choices to inspect/refine:** Expose objective, blocker, chosen means, alternatives declined and reconsideration triggers without pretending explanations prove success.
- **Proposed competence evidence:** We can trace cause and outcome, distinguish supplied fixtures from autonomous competence, and retain valid lessons without keeping every raw run.
- **Status:** proposed; no current-build verification or agreed test yet.

## First discussion — S01

Proposed scope: at the opening, the player can identify their people and equipment, usable work and support capacity, known map opportunities and visible danger. The AI uses that information to select a useful near-term goal and can expose what information supports it and what remains uncertain. It should also be able to reconsider when a new observation changes the choice.

The provisional normal opening is a small established settlement and workforce, one Soldier and one Explorer (D001). Exact workforce composition, starting assets and initially known map layers are still to refine. This does not require modifying the existing test fixture to match the future normal opening immediately.

First decision: should S01 include both the human-facing legibility of that opening information and the AI's assessment of the same legally available information? If agreed, refine the starting inventory next rather than reopening every subsystem at once.

## Later-stage direction retained

Animal control is the first middle-game specialization: control one animal → pacify one nest → control one nest → improve one nest. Ecology is the first late ambition, combining defined project milestones and sustained conditions. These inform the roadmap but do not make all those systems prerequisites for initial competence. Productive forests/preserves and engineered waste management are promoted ecology tools; orbital, gate and digital-society additions remain parked.

## Governing records

- [Authoritative decisions, Q001–Q128 and D001–D020](https://chatgpt.com/library?file_id=libfile_4bb48d3203e881919b9014182cedbcc8&account_id=personal).
- [Four-stage synthesis and completed direction-round consolidation](https://chatgpt.com/library?file_id=libfile_5959be2c4f608191bc9f83915f9cc710&account_id=personal).

Future S-item discussion answers should also be recorded in the authoritative decision ledger, with this working review updated to reflect agreed scope and evidence. No item is currently claimed to have passed.