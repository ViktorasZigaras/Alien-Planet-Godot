# Alien Planet — design clarification queue

Prepared 1 November 2026. **128 questions in 16 areas.** Q001–Q046, Q048–Q093, Q095–Q125 and Q127–Q128 discussed; Q047, Q094 and Q126 resolved by earlier answers. The original interview is complete; second direction round complete; capability-review cursor S01. Q011 leaves non-military opportunity valuation open for simulations. The one-question-at-a-time interview is underway. This document records possible clarification points; it authorizes no gameplay changes.

## Handoff checkpoint — 2 November 2026

**128 original IDs addressed:** 125 directly discussed (Q001–Q046, Q048–Q093, Q095–Q125 and Q127–Q128), plus Q047, Q094 and Q126 resolved by earlier answers. Addressed includes provisional, conditional and deferred decisions; it does not mean every mechanic is settled. **No original interview questions remain unanswered.** The four-stage synthesis starts a new direction round: D001–D020 discussed. All twenty prepared second-round IDs are addressed; the next phase is the sequential start/early-game capability review, beginning with S01.

Current phase: organize game-start, early-, middle- and endgame ideas; enrich selectively from collected SMAC/BE/AI material; clarify direction; only then compare with the existing build and agree a repair/addition plan. See `Alien_Planet_Four_Stages_Design_Synthesis_2026-11-02.md`. No implementation or test scenario is authorized by the synthesis.

Continue updating this same document and Library identity. Companion documents: `Alien_Planet_Thread_Handoff_2026-11-02.md` (restart instructions and condensed retrieval cues) and `Alien_Planet_Documents_and_Directories_2026-11-02.md` (reference links, identities and source availability). No unsaved answers remain through Q128; Q094 is resolved by Q092–Q093 and Q126 by Q114/Q121/Q122. No new gameplay changes or simulations were performed for this handoff.

## How to use the queue

Use stable IDs Q001–Q128. Ask one numbered question per turn only after the user signals to begin. Supply a short factual context and, where helpful, a concrete example. Accept an answer, deferral, rejection of the premise, or “use your judgment.” Record the answer under that ID; do not silently turn a deferred idea into a requirement. If an answer resolves later questions, mark those resolved by reference rather than asking again. Follow explicit user reordering. Current cursor: **S01, opening inventory and world comprehension; proposed scope awaiting refinement**. Q001–Q128 remain stable original IDs; D001–D020 belong to the new direction round.

These are design questions, not requests for the user to write code. Where implementation judgment suffices, the assistant should propose a concrete interpretation after understanding the intended outcome. Existing choices in each area are context, not decisions being revoked. Numerical details remain provisional unless the user fixes them.

## Source and scope

Grounded in the original brief, updated inventory/action review, current development log and 0.908–0.910 reports. Latest documented state is 0.910; the old source workspace is unavailable, so exact current call paths remain unverified. The separate AI architecture guide contains source-verification questions; this queue focuses on intended game behaviour. Historical experiments are evidence of opportunities and failures, not proof that every underused mechanic needs forced use.

## Area index

| Area | IDs | Count |
|---|---|---:|
| 1. Game purpose and player experience | Q001–Q008 | 8 |
| 2. Ruler identity, authority and commitment | Q009–Q016 | 8 |
| 3. Resources, scarcity and economic value | Q017–Q024 | 8 |
| 4. Population, growth and medicine | Q025–Q032 | 8 |
| 5. Professions, employment and labour ownership | Q033–Q040 | 8 |
| 6. Technology, capabilities and research choice | Q041–Q048 | 8 |
| 7. Settlements, claims and territorial development | Q049–Q056 | 8 |
| 8. Terrain, clearing and environmental choices | Q057–Q064 | 8 |
| 9. Buildings, districts, power and local development | Q065–Q072 | 8 |
| 10. Movement, roads, transports and external sites | Q073–Q080 | 8 |
| 11. Threat assessment and home defence | Q081–Q088 | 8 |
| 12. Campaign approval, force production and sustainment | Q089–Q096 | 8 |
| 13. Tactics, weapon roles and battlefield coordination | Q097–Q104 | 8 |
| 14. Wildlife, ecology and hostility | Q105–Q112 | 8 |
| 15. Adaptation, memory and explanation | Q113–Q120 | 8 |
| 16. Testing, interface and future content integration | Q121–Q128 | 8 |

## 1. Game purpose and player experience

Established: an extensible experimental shell, with more content and balancing expected later.

**Q001.** Which recurring decision should make an ordinary turn satisfying for the human player?

**Q002.** What should count as a successful civilization when no scenario objective is specified?

**Q003.** Which tradeoff should prevent surviving, expanding and specializing from all being automatic choices?

**Q004.** How much routine settlement management should the human delegate to the programmed player or governors?

**Q005.** Should a scenario normally end through a concrete world objective, a score comparison, or open-ended play?

**Q006.** What level of recoverable failure should a normal game permit before the player is effectively defeated?

**Q007.** Which existing provisional systems should remain deliberately simple even as content expands?

**Q008.** What evidence should be enough to promote a prototype rule into the intended core design?


## 2. Ruler identity, authority and commitment

Established: Blue favours technology/specialization; Red/Green have nest campaigns; advisers propose and a ruler authorizes.

**Q009.** How strongly should doctrine restrict choices when a different strategy appears more effective?

**Q010.** What circumstances justify the ruler overriding an adviser’s specialist judgment?

**Q011.** Which emergencies should interrupt an approved long-term operation?

**Q012.** How should the ruler choose between two important operations that need the same people?

**Q013.** When should a blocked operation be revised rather than kept alive through another delay?

**Q014.** What should count as an unacceptable cost that forces the ruler to abandon a chosen objective?

**Q015.** Should settlement roles be chosen mainly by doctrine, local opportunities, or present empire shortages?

**Q016.** How much difference between faction behaviour should remain when all factions face the same urgent threat?


## 3. Resources, scarcity and economic value

Established: six resources, separate stocks/net flows, operating inputs; no new currency decision assumed.

**Q017.** What distinct difficult choice is each of the six resources intended to create?

**Q018.** Should basic settlement startup income eventually stop being sufficient for advanced development?

**Q019.** What should make constructing a staffed workplace preferable to founding another settlement?

**Q020.** How far ahead should a player reserve resources for ordinary development?

**Q021.** What should a player do with large surpluses once immediate targets are satisfied?

**Q022.** Should resource shortages mainly delay progress or threaten already existing capabilities?

**Q023.** Which resource substitutions or emergency conversions, if any, should be legal?

**Q024.** How should a player value reducing future upkeep against increasing current gross production?


## 4. Population, growth and medicine

Established: persistent cohorts, automatic growth, Food upkeep; Medic/Clinic benefits concern growth rather than assumed combat healing.

**Q025.** What useful demand should trigger a player to encourage additional population?

**Q026.** Should a player be able to deliberately suppress growth when there are no useful jobs?

**Q027.** What should make a populous town preferable to several small towns?

**Q028.** Which costs should represent the difficulty of supporting a large population?

**Q029.** When should a growth-focused player invest in medicine rather than more Food production?

**Q030.** What strategic role should a Medic have beyond the currently documented growth effect?

**Q031.** How readily should a civilization replace population lost to dangerous expansion or warfare?

**Q032.** What condition should make evacuating a settlement preferable to defending or repopulating it?


## 5. Professions, employment and labour ownership

Established: eleven professions; construction, training, work and military service compete for persistent people.

**Q033.** What meaningful advantage should specialized labour have over flexible Workers?

**Q034.** How reversible should choosing a profession be?

**Q035.** When should an idle person be retained as a reserve rather than assigned or trained?

**Q036.** What should justify moving an established specialist to another settlement?

**Q037.** Which operating jobs should normally be protected from temporary construction or military demands?

**Q038.** What should an adviser promise before borrowing another plan’s worker?

**Q039.** How should a governor choose between training an existing productive worker and waiting for new population?

**Q040.** What should distinguish an Administrator’s strategic purpose from other Culture-producing professions?


## 6. Technology, capabilities and research choice

Established: five areas, twenty current technologies, explicit prerequisites and provisional tier progression.

**Q041.** What should make research worthwhile when current economic targets are already met?

**Q042.** Should a technology require demonstrated operation of its prerequisite capability rather than mere ownership?

**Q043.** How should a player compare an immediate useful unlock with a prerequisite for a distant programme?

**Q044.** What should prevent a research-focused civilization from simply purchasing every cheap technology?

**Q045.** Which existing technology descriptions should gain real effects rather than remain dormant?

**Q046.** What should make the Exploration/Research branch strategically different from increasing Science income?

**Q047.** How should a player choose research when multiple advisers request incompatible priorities?

**Q048.** Should advanced technology primarily improve efficiency, unlock different decisions, or expand scale?


## 7. Settlements, claims and territorial development

Established: two intervening hexes between centers, Culture access through radius three, grey retained empty claims.

**Q049.** What should a new settlement have to contribute before a planner considers its founding worthwhile?

**Q050.** How should the player choose between a resource-rich site and a strategically placed support site?

**Q051.** What operating benefits should remain in an empty settlement, if any?

**Q052.** Under what conditions should abandoned claims be lost, reassigned, or restored?

**Q053.** What meaningful tradeoff should determine whether Culture buys more land or funds development elsewhere?

**Q054.** Should overlapping friendly work access remain unrestricted apart from one worker per tile?

**Q055.** What should make an intended forward settlement safe enough to populate?

**Q056.** How should the intended role of a town change when its original opportunity or purpose disappears?


## 8. Terrain, clearing and environmental choices

Established: layers have real extraction/construction effects; cleanup removes layers; rivers/relief affect travel.

**Q057.** When should preserving a forest be strategically preferable to clearing it?

**Q058.** What should make a player choose a biome-specific improvement instead of a generic Farm?

**Q059.** Should environmental cleanup create value beyond restoring the underlying tile’s output?

**Q060.** What should determine the priority between clearing pollution, obstacles and xenomass?

**Q061.** Should biomass patches have a meaningful human use or remain an animal resource?

**Q062.** Which terrain transformations should be allowed without introducing large-scale terraforming?

**Q063.** How much should a district’s lost underlying tile yield matter in placement decisions?

**Q064.** What should make two routes through different terrain strategically different besides raw travel cost?


## 9. Buildings, districts, power and local development

Established: capacity needs labour/inputs/power; eleven building types and five districts; some upgrade models exceed legal upgrade content.

**Q065.** What choice should placing a district impose beyond paying its cost?

**Q066.** When should expanding an existing workplace be better than constructing another one?

**Q067.** How much unused capacity should governors deliberately build for future demand?

**Q068.** Should an empty building continue to consume all of its current upkeep?

**Q069.** How should power shortage priorities choose which workplaces keep operating?

**Q070.** What should distinguish different buildings that produce the same resource?

**Q071.** What should a governor verify before calling a newly constructed building a completed development project?

**Q072.** Which local infrastructure benefits should extend to nearby settlements, if any?


## 10. Movement, roads, transports and external sites

Established: roads speed movement; Transports carry a driver plus two people; no freight/ammunition system currently.

**Q073.** Which recurring mission should make passenger Transports worth their cost and coordination?

**Q074.** When should the player build a road before travel rather than simply walk across the map?

**Q075.** Should roads require maintenance or remain permanent once built?

**Q076.** What meaningful benefit should a forward support town provide to an expedition?

**Q077.** Does the intended game need actual material freight rather than pooled-resource upkeep?

**Q078.** What should make visiting an external site preferable to working or developing at home?

**Q079.** What distinct role should an Explorer have on a fully revealed map?

**Q080.** How much travel risk should a civilian mission accept before seeking an escort or another route?


## 11. Threat assessment and home defence

Established: guards do not automatically intercept attacks or shield civilians; current danger estimate understates heavy reach.

**Q081.** What outcome should qualify a settlement as adequately defended?

**Q082.** Should protecting nearby civilians require an explicit screening or interception mechanic?

**Q083.** How much military strength should remain at home during an offensive?

**Q084.** When should a general preemptively attack a latent threat rather than wait for an immediate danger?

**Q085.** Which exposed civilian activities should stop automatically when predators approach?

**Q086.** How should the general value protecting a road, worker group or founder against defending a town?

**Q087.** What should make a defensive retreat successful beyond moving closer to a settlement?

**Q088.** How should a player respond after repeated civilian losses on the same frontier?


## 12. Campaign approval, force production and sustainment

Established: Red/Green binding charter delivers fixed four-rifle/two-flamer forces plus home support; not a general force solver.

**Q089.** What enemy information should determine a proposed expedition’s size and composition?

**Q090.** What preparation delay should make the ruler reconsider an otherwise feasible campaign?

**Q091.** How much of the civilian economy may an approved campaign temporarily sacrifice?

**Q092.** What specific conditions should permit a partially assembled force to depart?

**Q093.** How should replacements be produced and assigned while the first wave is still fighting?

**Q094.** What should trigger reinforcement rather than full withdrawal and remustering?

**Q095.** How should staging locations be chosen relative to safety, travel time and weapon range?

**Q096.** What should prevent preparation workers and military commissioning from repeatedly undoing each other?


## 13. Tactics, weapon roles and battlefield coordination

Established: real ranged/charge/retreat rules; three-combatant tile preference is soft; flamers lack added toughness.

**Q097.** What battlefield role should distinguish rifles from flamers beyond range and damage multipliers?

**Q098.** What should count as usable supporting force when deciding whether to advance or charge?

**Q099.** How should troops choose between finishing a wounded enemy and attacking a more dangerous healthy one?

**Q100.** When should a force accept casualties to close range or complete its objective?

**Q101.** Should the three-unit tile preference ever be relaxed for ordinary offensive concentration?

**Q102.** What should coordinate the timing of shooters, close attackers and arriving reinforcements?

**Q103.** How should a lieutenant choose a retreat route when the safest direction abandons the objective?

**Q104.** What event should tell the lieutenant to occupy the nest immediately rather than continue fighting elsewhere?


## 14. Wildlife, ecology and hostility

Established: nest economy, three-larva/six-predator caps, mineral-dependent heavy births, occupation disables nest activity.

**Q105.** What long-term role should wildlife play after the player understands its mechanics?

**Q106.** Should an ignored nest become steadily harder, reach a stable threat level, or sometimes decline?

**Q107.** What should give players alternatives to exterminating a nest?

**Q108.** How much should attacking larvae or disrupting forage weaken the nest’s military capability?

**Q109.** What should happen to surviving animals and xenomass after nest destruction?

**Q110.** Should animals distinguish easy civilian prey from dangerous armed formations?

**Q111.** How should the difficulty of a nest scale across scenarios with different starting economies?

**Q112.** What would make an animal victory or human defeat interesting rather than merely prolonged replacement deaths?


## 15. Adaptation, memory and explanation

Established: bounded per-match casualty/terrain adjustments; association is not a causal terrain model.

**Q113.** Which kinds of tactical mistake should the player be able to recognize and correct during a match?

**Q114.** What amount of evidence should be required before a learned caution changes behaviour?

**Q115.** How should a player distinguish dangerous terrain from a dangerous enemy occupying that terrain?

**Q116.** When should an old caution be weakened after circumstances change?

**Q117.** Should learned rules persist across new matches or remain part of the current civilization’s history?

**Q118.** How much controlled experimentation should a player risk to learn an uncertain tactic?

**Q119.** What explanation should accompany a decision that rejects an apparently useful legal action?

**Q120.** How should a player detect that its own protective rule has become a permanent obstacle to its objective?


## 16. Testing, interface and future content integration

Established: exact replay and many fixtures; development games are mostly one seed, no representative hardware benchmark.

**Q121.** Which measurable outcomes should decide whether a controller change improved play?

**Q122.** What controlled scenarios should be mandatory before declaring a new mechanic AI-supported?

**Q123.** How much variation across seeds and starting positions should be tested before drawing balance conclusions?

**Q124.** What should the interface show to distinguish intended plans from funded, ready and completed actions?

**Q125.** Which decisions should the human be able to override without permanently disabling delegation?

**Q126.** What evidence should accompany each new content item before it joins ordinary autonomous play?

**Q127.** How should scenario-specific objectives be separated from general civilization competence?

**Q128.** Which decisions from this question series should be settled before the next gameplay implementation batch?

## Decision record

| ID | Status | User decision | Design consequence | Implementation/test consequence |
|---|---|---|---|---|
| Q001 | Answered, 1 November 2026 | Pursue visible opportunities, work through their requirements, remove unwanted threats, and expand from a secure base; interesting choices need not be optimal or have a narrow predefined purpose. | Opportunity-driven development and persistent goal-to-prerequisite reasoning; see detailed answer below. | Recorded only; no gameplay changes. |
| Q002 | Answered, 1 November 2026 | Self-protected, well-teched, fully expanded, fully tile-improved civilization, trained wherever useful; future ideological/story/wonder/planetary goals and terraforming remain pending. | Security and comprehensive useful development are shared success expectations; future doctrines can add distinct ends. | Recorded only; no gameplay changes. |
| Q003 | Answered, 1 November 2026 | Ideally pursue all activities through a balanced approach; timing and urgency set emphasis. Emergencies override balance; catastrophic threats may disrupt normal economic operation. | Concurrent development with proportional emergency escalation rather than permanent mutually exclusive strategies. | Recorded only; no gameplay changes. |
| Q004 | Answered, 1 November 2026 | Human governors remain an optional design idea; user generally prefers direct management. Computer governors should make coherent settlement decisions within civilization-wide reasoning; leader military requirements can override local logic. | Distinguish optional human automation from necessary computer-player hierarchy and cross-settlement authority. | Recorded only; no gameplay changes. |
| Q005 | Answered, 1 November 2026 | After winning, the player may continue the same map until bored. | Recognized victory with optional continued play; exact victory conditions remain pending. | Recorded only; no gameplay changes. |
| Q006 | Answered, 1 November 2026 | Survive until survival is no longer possible; severe losses may leave little chance of winning against undamaged survivors, but do not justify premature elimination. | Separate loss of competitiveness from actual elimination; allow continued survival/recovery while possible. | Recorded only; no gameplay changes. |
| Q007 | Answered, 1 November 2026 | Individual subsystems such as research and town management should be simple in themselves, while their interplay and choice space are expansive, at least combinatorially. | Seek understandable local rules with broad meaningful combinations across systems. | Recorded only; no gameplay changes. |
| Q008 | Answered, 1 November 2026 | An unanticipated solution should stay if it solves an important problem. Numeric values remain provisional for later tests; balance work becomes useful when a player can achieve a set of goals. | Establish functional goal achievement before numerical optimization; retain useful discoveries. | Recorded only; no gameplay changes. |
| Q009 | Answered at phase-policy level, 1 November 2026 | Early game: grow; middle game: specialize; end game: maximize ideological goals. | Stage-dependent emphasis, compatible with balanced development and emergency overrides. Hard ideological prohibitions and phase-transition criteria remain open. | Recorded only; no gameplay changes. |
| Q010 | Answered, 1 November 2026 | Weighted activity areas (expansion, defence, offence, economic improvement, etc.) form an emerging hierarchy that ranks adviser suggestions; proposals may conflict for resources or coexist, and opportunities can be elevated or deferred. | Contextual proposal ranking with explicit resource compatibility; not a fixed adviser pecking order or a single exclusive activity. | Recorded only; no gameplay changes. |
| Q011 | Survival/force principle answered; non-military valuation deferred to simulations, 1 November 2026 | Immediate survival first; destroying danger sources desirable; enlarge a task force if a small force is too risky. Relative value of competing non-military opportunities needs simulation. | Escalate preparation toward adequate force instead of repeatedly attempting an inadequate template; no fixed non-military interruption threshold chosen. | Recorded only; simulation question retained, no run or gameplay change authorized. |
| Q012 | Answered, 1 November 2026 | Waiting or alternative routes can all be considered under the existing competing, ranked stack of ideas. | Resource conflicts generate candidate responses; ranking determines which to pursue rather than a universal wait-or-replace rule. | Recorded only; no gameplay changes. |
| Q013 | Answered, 1 November 2026 | Offer and attempt ways to solve blockers; a goal may remain top priority for a long time without succeeding, while interim steps are pursued. | Separate enduring goal importance from immediate feasibility; pursue useful enabling actions instead of passive repeated waiting. | Recorded only; no gameplay changes. |
| Q014 | Answered, 1 November 2026 | Survival without damaging the whole is top priority; accumulated resources and lack of expansion room favour dealing with regional threats. Inter-civilization wars belong to a much later iteration. | Preserve overall viability while preparing threat removal; contextual escalation rather than exhausting the civilization for one objective. | Recorded only; no gameplay changes or war implementation. |
| Q015 | Answered, 1 November 2026 | Local opportunities, civilization needs and eventual doctrine all enter the leader’s weighted proposal pool. Develop distinctive landscape appropriately; balance growth/production unless emergency or low importance defers it. Ideology is for later balancing tests. | Contextual settlement development rather than rigid single-factor roles; priority can defer a locally useful investment. | Recorded only; no gameplay or ideology changes. |
| Q016 | Answered, 1 November 2026 | Shared survival necessities, with seriousness assessed relative to each player’s exposure and distance; town garrisons desirable and maintained against opportunistic roaming threats. | Common survival reasoning need not produce identical responses to geographically different risks; standing defence has value before an emergency. | Recorded only; no gameplay changes. |
| Q017 | Answered, 1 November 2026 | Food supports general industrial/military development; Minerals represent extracted raw material; Industry is physical manufacture/construction; Energy supports maintenance/training and possible trade/research; Science is thinking effort; Culture supports land/training/thematic advancement, with future policies/ideas economy. Research can have extra resource costs. | Distinct resource meanings and material support for progress; distinguish intended new spending from existing rules. | Recorded design intent only; no costs, trading, policies or research changes implemented. |
| Q018 | Answered, 1 November 2026 | Spamming settlement tiles with one resident each should generate little worthwhile output; founding costs materials and ungarrisoned towns add potential security exposure. | Settlement markers/startup income cannot substitute for developed land, workplaces, useful population and protection. | Recorded only; no yield, cost or defence rule changes. |
| Q019 | Answered, 1 November 2026 | Established infrastructure/trained people can favour further development; expansion offers new land/resources/positions, with context-dependent protection costs. Future defences and economies of scale may strengthen existing towns. | Compare building-plus-specialist returns with the full alternative cost of expansion rather than always favouring either. | Recorded only; no scale bonus or defensive structure implemented. |
| Q020 | Answered at investment-policy level, 1 November 2026 | Mix low/medium/high investment according to wider circumstances: scarce means under survival pressure differ from unused stockpiles with no competing plans. | Adaptive commitment scale; no universal reservation horizon or fixed whole-programme escrow chosen. | Recorded only; no budget or reservation changes. |
| Q021 | Answered, 1 November 2026 | Any/all legal moves should generally be proposed, with proposal categories weighted too. Threats, available land and attainable technologies generate investigation, development and affordable research opportunities. | Broad candidate coverage beyond satisfied income targets, hierarchical weighting and affordability; proposing differs from executing. | Recorded only; no action-enumeration or planner changes. |
| Q022 | Food clarified by Q023; Energy direction specified; military remedy provisional, 2 November 2026 | Negative Food initially mobilizes non-food producers; Q023 adds that they should try to produce Food if able. Negative Energy powers down hungriest installations, ties to test. Proportional military penalty and disarm/employ remedy provisional. | Actual Food recovery replaces passive waiting as the desired response where feasible; trigger/order and balance need tests. | Recorded only; no shortage, combat or population changes. |
| Q023 | Answered, 2 November 2026; clarifies Q022 | Affected population should try to produce Food if able, subject to balance tests. No magical resource conversion without proper trading partners or actual generation methods. Neutral stations/city-states likely later. | Food recovery needs real productive actions; future exchanges require real mechanisms/partners. | Recorded only; no gameplay, trade or city-state changes. |
| Q024 | Answered, 2 November 2026 | Yes: reducing upkeep competes with increasing production; absent other complications choose the largest obvious gain. | Compare useful net benefits and relevant costs/plan effects rather than preferring gross production automatically. | Recorded only; no scoring or gameplay changes. |
| Q025 | Answered, 2 November 2026 | Population supports all proposed work/development uses and creates possibilities, including defensive/offensive force. Excessive concentration should later create pollution, squalor, disease and similar liabilities. | Population is both flexible capacity and a managed liability; growth value is broader than immediate vacancies. | Recorded only; no demographic, pollution, squalor or disease changes. |
| Q026 | Answered, 2 November 2026 | Yes: limit unwanted growth by not producing excess Food where unneeded; explicit no-growth control mentioned as an option used in some Civ games. | Growth can be deliberately restrained; keep explicit growth permission as a possible control, with details open. | Recorded only; no food, growth or UI changes. |
| Q027 | Potential late-game direction; details deferred, 2 November 2026 | Specialist/multi-specialist buildings, sophisticated weapon modules or tertiary resources could reward concentration; suitability depends strongly on testing/balancing. | Keep advanced concentrated capabilities as possible late-game options, not fixed population gates. | Recorded only; no advanced facility, module or resource implemented. |
| Q028 | Design direction answered; exact pressure model open, 2 November 2026 | Ultra-tall development merits design/testing, unique desirable outcomes and long conscious investment, rather than merely inflated revenue. Technology should solve problems players face or are intended to face. | Connect advanced urban capability and research to actual challenges; no complete congestion/mitigation rule chosen. | Recorded only; no city-scale or technology changes. |
| Q029 | Answered at infrastructure-threshold level, 2 November 2026 | Certain population/growth thresholds should require infrastructure, analogous in purpose to SMAC habitation and Civ III aqueduct/hospital examples; Food alone is insufficient. | Infrastructure unlocks further growth; exact thresholds, facilities and relation to health remain unspecified. | Recorded only; no caps or building changes. |
| Q030 | Possible future roles/content direction, 2 November 2026 | Potentially both settlement and field medical roles, with other roles open. Future variety of troop, transport and gun-platform types should use interesting plausible alternatives, avoiding impractical laboratory lasers or uncarryable armour. | Keep medical support flexible and engineering plausibility a military-content criterion. | Recorded only; no medical, combat or vehicle changes. |
| Q031 | Answered, 2 November 2026 | Choose natural growth and ordinary infrastructure for replacement; avoid losing people rather than relying on emergency population creation. | Casualties cost labour, qualification investment and recovery time; no special replacement grant selected. | Recorded only; no growth or recruitment changes. |
| Q032 | Likely option; criteria deferred to testing, 2 November 2026 | Evacuation may be preferable, but exactly when is a serious testing concern and depends on the player AI that emerges. | Preserve evacuation as a candidate without fixing automatic abandonment thresholds or assuming successful escape. | Recorded only; no evacuation policy changes. |
| Q033 | Output/ability direction specified; progression breadth/counts tentative, 2 November 2026 | Specialists produce more preferred goods; some have abilities unavailable to untrained people. Likely all professions connect to tech progression by presence and potentially numbers; Soldiers especially connect to exotic/high-level equipment. | Value specialization through productivity, exclusive capability and progression requirements; detailed gates remain open. | Recorded only; no profession, equipment or tech changes. |
| Q034 | Clearing supported; multi-skilling conditional, 2 November 2026 | Clearing a profession is certainly possible. Multi-skilling/retained qualifications may be worth testing later if they solve a real consistent problem. | Keep clear/retrain path available; do not assume accumulated qualification history or switching rules. | Recorded only; no profession-state changes. |
| Q035 | Answered, 2 November 2026 | People without a specific assignment should work tiles. If all settlements are at full capacity and no troops are needed, keep them as mobilized idles and seek a purpose when available. | Productive default; idle status is allowed without deletion or forced recruitment, with continuing opportunity review. | Recorded only; no staffing or mobilization changes. |
| Q036 | Answered with implementation-scope qualification, 2 November 2026 | Compare and rank specialist relocation if the AI dependency structure supports it relatively simply; otherwise use opportunistic relocation or emergency reshuffling. | Useful relocation without requiring an elaborate global workforce optimizer; emergency override remains possible. | Recorded only; no migration or planner changes. |
| Q037 | Answered, 2 November 2026 | Established useful production should be protected; moving its worker requires a serious top-down decision responding to something important. | Stability applies beyond immediate subsistence jobs; routine lower-level opportunity scoring should not casually undo useful sustained assignments. | Recorded only; no staffing/authority changes. |
| Q038 | Answered: no required return continuity, 2 November 2026 | People may successively work a job, build, serve in garrison, retrain and work elsewhere; no obligation to restore the previous job. | Protect useful ongoing assignments under Q037, but let subsequent roles follow new priorities without a career-continuity requirement. | Recorded only; existing labour-return policy needs later review, not silently changed. |
| Q039 | Answered, 2 November 2026 | Compare training benefit/urgency and temporary lost output, including existing specialized buildings and formulated future specialist plans. An existing workplace creates training demand; train if affordable, otherwise retain the need and act when able if still needed. | Persistent demand tied to actual capacity/plans, with affordability and relevance rechecked. | Recorded only; no training or planning changes. |
| Q040 | Provisional role and later direction, 2 November 2026 | Administrator broadly evokes Colonization’s statesman; population-size maintenance/increase later when consequences exist. Provisionally gain Culture while working the settlement tile/settlement itself. | Settlement-centred Culture role now as design intent; later population-support effects need corresponding mechanics. | Recorded only; no yield, assignment or population-support changes. |
| Q041 | Tentative default research preference, 2 November 2026 | Maybe cheapest technologies first, with cheap meaning least complicated overall to achieve. A pure20-Science technology is preferable to4 Science plus a missing building. | Consider actual prerequisite burden, not nominal Science price alone, when choosing discretionary research. | Recorded only; no research-ranking changes. |
| Q042 | Operational prerequisite direction, 2 November 2026 | A required building should function; a required specialist should work a job producing their matching yield. | Actual operating capability, not mere building/person ownership, should satisfy relevant research prerequisites. | Recorded only; current existence-based checks not changed. |
| Q043 | Answered, 2 November 2026 | Keep a goal while important, but its prerequisites differ in feasibility/desirability; a cheaper unrelated technology may rank above them. | No blanket equal priority inheritance for every prerequisite; preserve goal importance while comparing actionable steps in the ranked pool. | Recorded only; no research/planner changes. |
| Q044 | Answered, 2 November 2026 | Available/doable technologies belong in the proposal pile regardless of present importance; acquiring several low-importance achievable technologies is acceptable because they lead to better future options. | Broad research participation and option value; no special restriction solely to prevent collecting cheap technologies. | Recorded only; no research-cost or scheduling changes. |
| Q045 | Answered: iterative design/testing process, 2 November 2026 | Placeholders are acceptable while testing. Add content, redistribute/add technologies, run tests, adjust a selected goal and tech trees, and discover consistently desired versus barely considered options. | Technology/content structure is provisional and evidence-driven; do not force placeholder effects or final tree design prematurely. | Recorded only; no content, tree or simulation changes. |
| Q046 | Future direction; branch/role allocation tentative, 2 November 2026 | Branch identity emerges later. Fog of war planned; specialized units may see farther/move faster and exploit exotic sites. Explorer possibly map-oriented, Merchant settlement/building-oriented; exploration techs possibly chassis, military/defence techs installations/tools/hardware. | Keep explicit future capability hooks without treating tentative roles or tech boundaries as fixed. | Recorded only; no fog, movement, profession, chassis or tech changes. |
| Q047 | Resolved by Q010/Q021/Q041/Q043 | Competing research requests join the weighted proposal pool; consider actual prerequisite burden and individual step desirability rather than uniform inherited priority. | No need to ask the same ranking principle again. | No new user answer or implementation. |
| Q048 | Answered, 2 November 2026 | Advanced technology can improve efficiency, unlock new actions and enable larger-scale activity; all are context-dependent. | No single universal progression benefit; evaluate technologies against the capabilities and problems they address. | Recorded only; no technology changes. |
| Q049 | Initial planning direction, 2 November 2026 | Propose useful locations from best/interesting yields, with a road plan and minimal escort becoming garrison. Richer reasoning if the emerging dependency structure supports it; unused land may remain unclaimed even midgame. | Start with grounded site/support plans; investigate neglected land rather than force universal coverage. | Recorded only; no settling, road or garrison changes. |
| Q050 | Answered, 2 November 2026 | Strategic position can justify a poor-yield settlement if its proposal rises sufficiently high in the decision pile. | Compare operational/location value with other proposals; low extraction value does not automatically disqualify a site. | Recorded only; no site-scoring changes. |
| Q051 | Provisional empty-service answer plus destruction/reclamation direction, 2 November 2026 | Probably no practical services from empty settlements. Rampaging creatures/hostile players should damage or destroy tiles/things; surviving things without a settlement persist until reclaimed. Player district demolition enables reuse but needs a strong intentional reason. | Separate inactivity, physical destruction, ownerless persistence and deliberate redevelopment; avoid casual AI demolition. | Recorded only; no destruction, reclamation, service or PvP changes. |
| Q052 | Ownership direction specified; population-loss method open, 2 November 2026 | Destruction removes tile ownership while contents remain; simple abandonment leaves neutral land. Population may be purged one at a time or all at once. | Abandonment/destruction no longer preserve former territorial claims; distinguish surviving contents from population-loss mechanics. | Recorded only; no ownership, destruction or population changes. |
| Q053 | Answered, 2 November 2026 | Buy a tile when it belongs to an expansion plan. Culture stockpiles can accumulate in testing; future ideas should provide desirable consumption. | Plan-linked land acquisition rather than spending merely to drain reserves; future Culture sinks remain to design. | Recorded only; no land-purchase or Culture changes. |
| Q054 | Answered: exclusive settlement allocation, 2 November 2026 | Choose one settlement's working-area ownership at a time, with explicit transfer rather than unrestricted overlapping access. User asks whether this is generally preferable in Civ-like design. | Clear settlement responsibility and deliberate transfers; retain one worker per tile. Genre-wide superiority is not established. | Recorded only; no access/transfer changes. |
| Q055 | Assessment direction and command roles specified, 2 November 2026 | Planner supplies settlement options/pros/cons; general scans threats; leader makes the decision, preserving internal command. | Forward-site evaluation combines planning and military assessment without making either adviser the independent final authority. | Recorded only; no assessment/authorization changes. |
| Q056 | Answered, 2 November 2026 | Town purpose/priority should change, but prefer retaining productive people locally and addressing shortages through infrastructure/retraining rather than repeatedly moving population or military across the map. | Adapt roles with a soft locality/stability preference; relocation remains possible for justified needs. | Recorded only; no staffing, movement or role changes. |
| Q057 | Answered with future pollution direction, 2 November 2026 | Preserve forest yield/defence value and future benefits; forests/preserves should help manage pollution alongside prevention/reduction/cleanup tools. Avoid repetitive late-game cleanup and pressure to keep conquered cities small. | Strategic environmental management rather than endless maintenance chores; exact forest/preserve effects pending. | Recorded only; no forest, preserve or pollution-generation changes. |
| Q058 | Both directions supported, 2 November 2026 | Biome-specific improvements may exploit local conditions better with distinct technology/specialist requirements; exact distinctions should emerge through content tests. | Context-sensitive alternatives, not generic improvement superiority; details remain provisional. | Recorded only; no improvement changes. |
| Q059 | Extra rewards undecided; settlement-security use identified, 2 November 2026 | No particular extra cleanup benefits chosen. Fighting off animal-benefiting biomass may be preferable when securing current or planned settlements. | Cleanup can serve settlement security through actual ecological effects, without inventing health/ideology rewards. | Recorded only; no cleanup or ecology changes. |
| Q060 | Answered, 2 November 2026 | Cleanup priority follows land purpose and the problem a layer creates, not a fixed cleanup order. | Rank yield restoration, construction access and animal-support removal by their concrete goals/context. | Recorded only; no cleanup-order changes. |
| Q061 | Tentative future direction, 2 November 2026 | Human biomass uses are for mid-to-late-game testing; perhaps civilization-wide adaptation or mutation makes population accustomed to some form of biomass. | Keep biological adaptation as a possible civilization transformation; exact benefits and mechanics remain open. | Recorded only; no biomass or population changes. |
| Q062 | Answered with future directions, 2 November 2026 | Supports clearing/planting early and later drainage/terrain changes; mid-to-late game should account for localized artificial environments or biome changes. Land–water conversion is a possible late-stage flavour idea. | Plan progressive environmental capabilities; exact technologies, scope and effects remain open. | Recorded only; no terrain changes. |
| Q063 | Answered, 2 November 2026 | District placement sacrifices underlying natural yields; the district itself provides something even unworked, with Civilization VI as inspiration. | Compare lost extraction with district baseline benefit and staffed development potential. | Recorded only; no district-yield changes. |
| Q064 | Conditional direction; complexity may defer, 2 November 2026 | Weigh route safety and terrain advantages alongside time if the AI structure supports it; otherwise retain as later AI tuning. | Prefer a practical extension of existing planning; no elaborate route optimizer required now. | Recorded only; no pathfinding changes. |
| Q065 | Answered, 2 November 2026 | District location should affect benefits; Civilization VI is a good inspiration. | Terrain/resource relationships can make district placement meaningful alongside lost natural yield. | Recorded only; no placement bonuses implemented. |
| Q066 | Answered, 2 November 2026 | Upgrading and building another workplace should both remain useful; compare opportunity costs and complications, especially missing requirements for one option but not the other. | Evaluate attainable development paths and displaced alternatives alongside capacity, land use and worker productivity. | Recorded only; no upgrade or construction changes. |
| Q067 | Answered, 2 November 2026 | Construction and training follow an executing plan and may finish in either order; catastrophe can leave the sequence incomplete. | Allow planned preparation without requiring synchronized completion. | Recorded only; no sequencing changes. |
| Q068 | Answered in principle, 2 November 2026 | An unstaffed building that provides a benefit by itself should cost something. | Autonomous benefits carry upkeep; exact idle and operating costs remain open. | Recorded only; no upkeep changes. |
| Q069 | Tentative automatic priorities; manual control desired, 2 November 2026 | Essential services may receive shutdown protection; manual disabling should also permit self-regulation. | Retain automatic shortage priorities as provisional and provide deliberate operating control. | Recorded only; no power or interface changes. |
| Q070 | Conditional future idea, 2 November 2026 | Alternative buildings producing the same resource with different tradeoffs may be useful if future balance testing shows they solve an interesting problem. | Retain the design option without requiring parallel building alternatives now. | Recorded only; no building additions. |
| Q071 | Objective and cancellation principle clarified, 2 November 2026 | Plans have objectives but may eventually be cancelled if a town is lost or the original problem no longer exists. | Reassess relevance; do not force unfinished plans to persist indefinitely or label cancellation as success. | Recorded only; no plan lifecycle changes. |
| Q072 | Potential future design idea, 2 November 2026 | Infrastructure serving multiple settlements is a possibility, with Civilization VI power plants as inspiration. | Retain regional infrastructure as an option; eligible facilities and delivery rules remain open. | Recorded only; no regional benefits implemented. |
| Q073 | Purpose and testing direction recorded, 2 November 2026 | Mainly fast movement of groups; initially test off-road speed and basic combat protection. Ships are intended later, helicopters possible; distinguish cargo-only, APC-like and primarily gun vehicles. | Develop transport roles progressively; no current freight, naval or aircraft system assumed. | Recorded only; no vehicle changes. |
| Q074 | Answered with future outpost idea, 2 November 2026 | Connect settlements and potential outposts quickly; a ring of bunkers is a future idea. Roads on every tile are neither a boon nor a cost, and are not expected or desired. | Favor purposeful connections rather than blanket road coverage. | Recorded only; no road or outpost changes. |
| Q075 | Deferred ongoing upkeep, 2 November 2026 | Do not introduce road maintenance at this stage of development. | Roads remain usable without recurring road upkeep for now; future reconsideration remains possible. | Recorded only; no maintenance system added. |
| Q076 | Answered with future services, 2 November 2026 | Forward settlements should support gathering, recovery and reinforcements; specialized buildings can eventually enable faster healing, repairs and equipment changes, plus defensive improvements. | Strategic support value can justify forward settlement investment; exact facilities and effects remain open. | Recorded only; no support or defence changes. |
| Q077 | Pooled resources; pool scope open, 2 November 2026 | Resources should be pooled; town-specific and empire-specific pools may develop, especially for Food, requiring further consideration. | No general physical freight requirement; local versus empire accounting remains an open design issue. | Recorded only; no resource or cargo changes. |
| Q078 | Initial test direction and future sites, 2 November 2026 | Supports varied site incentives; first test resource exchanges while a merchant visits, trained or not. Envisages multiple neutral sites/outposts, city-states, bandit towns/camps alongside animal nests. | Begin with actual visiting trade opportunities; distinguish future site types and training benefits from basic access. | Recorded only; no trading or site additions. |
| Q079 | Provisional role; fundamentals first, 2 November 2026 | Get the basics running and AI reasoning well before expanding roles; do not invent Explorer duties just for the revealed-map prototype. | Prioritize general competence; retain Q046's future exploration direction. | Recorded only; no role changes. |
| Q080 | Recorded, 2 November 2026 | Civilian travel through known danger only with guaranteed movement; otherwise nearest shelter. Combat-unit zones of control are a balance-testing possibility. | Define movement/shelter checks before implementation; zone-of-control rules remain open. | Recorded only; no gameplay changes. |
| Q081 | Provisional policy, 2 November 2026 | Fixed baseline garrison plus assembling reinforcements; possibly larger garrisons at outer/contested settlements and bare minimum in the interior. | Exact numbers, classification and reinforcement triggers remain open. | Recorded only; no gameplay changes. |
| Q082 | Recorded, 2 November 2026 | Positioning-based protection certainly; nearby-defender interception situationally. Develop tactical manual through in-game stress testing. | Interception conditions and zone-of-control rules remain to be tested. | Recorded only; no gameplay changes. |
| Q083 | Tentative; testing needed, 2 November 2026 | Units beyond the first may sally in a pinch or cover damaged units; situational testing and play analysis should refine this. | No blanket permission to strip garrisons for offensives; exact rules open. | Recorded only; no gameplay changes. |
| Q084 | Recorded, 2 November 2026 | General proposes threats as problems; leader chooses which to pursue among competing problems. | No automatic preemptive attack or fixed urgency threshold. | Recorded only; no gameplay changes. |
| Q085 | Recorded, 2 November 2026 | Civilians within predator next-turn attack reach interrupt exposed work and seek shelter unless positioning/protection makes staying safe. | Reach and safety must reflect actual rules; nearby guards alone do not establish protection. | Recorded only; no gameplay changes. |
| Q086 | Recorded, 2 November 2026 | Towns have overall priority; likely losses and mission importance inform exceptions. Not every vulnerable target can be saved; civilians seek shelter first. | No universal rescue guarantee or fixed scoring formula. | Recorded only; no gameplay changes. |
| Q087 | Recorded, 2 November 2026 | Primarily escape enemy attack reach; continue retreating if pursued. | No mandatory town arrival or recovery/regrouping completion criterion selected. | Recorded only; no gameplay changes. |
| Q088 | Recorded, 2 November 2026 | Repeated losses raise danger priority and discourage unchanged civilian exposure. Settlement abandonment is a last resort; never voluntarily abandon the last town. | Exact response thresholds remain open; hostile destruction is distinct. | Recorded only; no gameplay changes. |
| Q089 | Starting test rule, 2 November 2026 | Assemble/commit against total known plus suspected enemy power with a 25% margin. Richer force/terrain/weapon-role considerations conditional on clean AI integration. | Tactical trials refine power estimate, composition and margin; no victory guarantee. | Recorded only; no gameplay changes. |
| Q090 | Recorded, 2 November 2026 | Campaign goals persist while execution may wait; inadequate garrisons can block attacks. Select one or several feasible targets without attacking every nearby nest simultaneously. | No elapsed-turn cancellation rule or fixed concurrency limit selected. | Recorded only; no gameplay changes. |
| Q091 | Recorded, 2 November 2026 | Emergencies may sacrifice growth and established setups, e.g. imminent settlement loss. Defence and survival outrank external expeditions. | No fixed sacrifice budget or blanket permission for food/operating shortages. | Recorded only; no gameplay changes. |
| Q092 | Recorded, 2 November 2026 | Defend first; attack when likely to win. Grinding without winning is wasteful. | Exact departure/staging conditions and victory threshold remain open. | Recorded only; no gameplay changes. |
| Q093 | Tentative reinforcement option, 2 November 2026 | May feed replacements to the front; if winning seems unlikely, fall back, rebuild and increase expedition strength. | Timing, production and delivery details open. | Recorded only; no gameplay changes. |
| Q094 | Resolved by Q092–Q093 | Reinforcement may sustain a viable fight; unlikely victory triggers fallback and stronger remustering. | No numerical likelihood threshold fixed. | No new answer or gameplay changes. |
| Q095 | Provisional staging policy, 2 November 2026 | Assemble at the closest settlement/outpost near the threat, then depart in full. | Exact site eligibility and full-force readiness remain open; later replacements distinct. | Recorded only; no gameplay changes. |
| Q096 | Recorded, 2 November 2026 | Reserve people assigned to necessary preparation until task completion, subject to emergency or explicit plan revision. | Prevent conflicting recruitment/reassignment; no permanent personnel lock. | Recorded only; no gameplay changes. |
| Q097 | Recorded, 2 November 2026 | Rifles: weaker range-two terrain-blockable support. Flamers: range-one ranged-attack-only, strong when firing first and against animals, vulnerable to damage. | Exact strength, terrain blocking and firing-first mechanics remain open. | Recorded only; no gameplay changes. |
| Q098 | Provisional; tactics testing needed, 2 November 2026 | Count allies that can actually contribute in time, considering movement, remaining actions, range and terrain blocking. | Timing horizon and contribution assessment need tactical testing. | Recorded only; no gameplay changes. |
| Q099 | Recorded, 2 November 2026 | Generally favour likely kills that remove an enemy action; urgent danger from a more dangerous enemy can override. | Exact kill probability and urgency weighting remain open. | Recorded only; no gameplay changes. |
| Q100 | Recorded, 2 November 2026 | Accept likely losses when they make victory or saving a settlement likely; acceptable cost depends on objective importance. Avoid sacrifices merely prolonging an unsuccessful fight. | No fixed casualty budget or win-probability threshold. | Recorded only; no gameplay changes. |
| Q101 | Deferred to tactical testing, 2 November 2026 | Stacking/concentration policy needs tactical testing; consider interactions with stacked-unit losses and tile bombardment. | No cap, penalty or relaxation rule selected; historical comparisons are user recollections. | Recorded only; no gameplay changes. |
| Q102 | Recorded, 2 November 2026 | Lieutenant coordinates a variable-size task force, even one unit; task force can be eliminated. General is the planner role. | Tactical sequences develop through trials; no physical officer unit required. | Recorded only; no gameplay changes. |
| Q103 | Possible; testing needed, 2 November 2026 | Retreat by safest viable route away from target/staging site is possible, not settled. | Test local retreat discretion and subsequent campaign reorganization. | Recorded only; no gameplay changes. |
| Q104 | Recorded, 2 November 2026 | Prioritize reachable nest occupation over nearby animals if occupying unit is not expected to die on enemy turn. | Exact survival estimate and probability threshold remain open. | Recorded only; no gameplay changes. |
| Q105 | Future direction and tentative additions, 2 November 2026 | Overlapping early obstacle, persistent danger and evolving opportunities. Land/sea/flying species; evolving nests with static defences; possible psi control (one psi user per nest at a time) and seeding new nests. | Progression, control scope and expansion balance remain open. | Recorded only; no gameplay changes. |
| Q106 | Recorded with tentative resource uses, 2 November 2026 | Nest development depends on resources/conditions; no food keeps it small. Other resources may support it, e.g. Culture allowing extra units. | No time-only escalation selected; exact resource sources, costs and caps remain open. | Recorded only; no gameplay changes. |
| Q107 | Potential future options, 2 November 2026 | Potential containment/bypass; advanced biology technologies should open alternatives, perhaps domestication or pacification. | Specific technologies, effects and costs remain open; distinct from tentative psi control. | Recorded only; no gameplay changes. |
| Q108 | Recorded, 2 November 2026 | Larva/forage disruption weakens gathering and replacement capacity through actual shortages, without an additional abstract surviving-animal combat penalty. | Exact economic effects and timing remain open. | Recorded only; no gameplay changes. |
| Q109 | Recorded with tentative future idea, 2 November 2026 | Surviving animals stay active and xenomass persists. A controlled specimen might establish human-controlled nests after all nests are destroyed. | No automatic nest-loss decline; founding/control details remain open. | Recorded only; no gameplay changes. |
| Q110 | Recorded, 2 November 2026 | Attack selectivity and behaviour should vary substantially by species. | No universal civilian-prey/armed-force avoidance policy or species roster fixed. | Recorded only; no gameplay changes. |
| Q111 | Recorded, 2 November 2026 | Nest difficulty follows species, starting conditions and resources; scenario settings determine challenge. | No automatic adjustment to human civilization strength. | Recorded only; no gameplay changes. |
| Q112 | Recorded, 2 November 2026 | Full elimination is possible in animals-versus-humans and humans-versus-humans conflict; AI should change failing strategy instead of endless replacement deaths. | Exact elimination condition and PvP mechanics remain open/future. | Recorded only; no gameplay changes. |
| Q113 | Recorded, 2 November 2026 | Prefer authored tactical rules refined between test runs for the listed mistakes, rather than requiring within-match learning. | Does not remove situational assessment or settle every future memory mechanism. | Recorded only; no gameplay changes. |
| Q114 | Recorded, 2 November 2026 | Adopt cautions after repeated failures with identifiable cause; test benefit and whether useful actions elsewhere are blocked. One unlucky result is insufficient. | No fixed trial count or statistical threshold selected; between-run refinement under Q113. | Recorded only; no gameplay changes. |
| Q115 | Recorded, 2 November 2026 | Assess actual terrain effects separately from enemy capabilities; do not infer generic terrain danger solely from a loss there. | Their real interactions still matter; no automatic learning system implied. | Recorded only; no gameplay changes. |
| Q116 | Recorded, 2 November 2026 | Reassess caution when relevant conditions change, e.g. stronger allies, enemy departure or protected route. | No automatic safety declaration or fixed expiry timer. | Recorded only; no gameplay changes. |
| Q117 | Recorded, 2 November 2026 | Retain a mounting aggregate body of experiences across tests for reference and analysis. | Evidence retention does not itself mandate autonomous cross-match rule learning or importing old world state. | Recorded only; no gameplay changes. |
| Q118 | Recorded with conditional option, 2 November 2026 | Default experimentation in dedicated scenarios; ordinary play uses best available rules. Limited normal-match experimentation may be tested if AI can manage it. | No risk budget or autonomous-learning requirement selected. | Recorded only; no gameplay changes. |
| Q119 | Recorded, 2 November 2026 | Log concrete reason for rejecting apparently useful legal actions and what would make them worth reconsidering. | Explain actual blockers/priorities; exact format and coverage remain open. | Recorded only; no gameplay changes. |
| Q120 | Recorded, 2 November 2026 | Repeated safety blocks with no progress trigger review and remedy proposals while important goal persists. | No automatic safety-rule bypass or fixed stall timer selected. | Recorded only; no gameplay changes. |
| Q121 | Recorded, 2 November 2026 | Compare completion, survival/losses, time/resources, economy and stalled turns together. Faster ruinous victory or passive survival is not automatically better. | No fixed composite score or weights selected. | Recorded only; no gameplay changes. |
| Q122 | Recorded, 2 November 2026 | Demonstrate useful recognition, prerequisite acquisition, execution, interruption handling and suitable rejection; include at least one ordinary-game demonstration beyond supplied fixtures. | Test support claims within demonstrated scope; no universal competence proven by one run. | Recorded only; no gameplay changes. |
| Q123 | Recorded, 2 November 2026 | Initially retain first map to test AI use of supplied mechanics; later expand varied conditions adaptively and keep balance provisional. Full map generation and iterative UI/art are planned. | No fixed large test count or immediate map-generation batch. | Recorded only; no gameplay changes. |
| Q124 | Conditional approval and retention preference, 2 November 2026 | Inspectable plan states/details plus simpler ordinary summary, conditional on low storage burden. Periodically prune old test logs; roughly 5–10 saved runs max. | Preserve compact aggregate experience; exact retention/size policy open. | Recorded only; no gameplay changes or deletions. |
| Q125 | Tentative; low priority, 2 November 2026 | Human overrides with return to delegation are a possible later feature if useful. | Full override scope and assignment persistence not finalized. | Recorded only; no gameplay changes. |
| Q126 | Resolved by Q114/Q121/Q122 | Existing evidence standard covers useful recognition, prerequisites, execution, interruption, rejection and ordinary-game demonstration. | No new admission gate or requirement that every item be used in every run. | No new answer or gameplay changes. |
| Q127 | Recorded, 2 November 2026 | Test scenarios when user suggests or approves them; final aim is general deterministic situation assessment and development suited to circumstances. | Scenario success alone is not general competence; no omniscience or optimality guarantee. | Recorded only; no gameplay changes. |
| Q128 | Recorded; synthesis and direction phase, 2 November 2026 | Four actionable stage bins ranked by usefulness/relevance; enrich from collected SMAC/BE/AI material; clarify direction; then compare with existing build and agree fixes/additions. | Stage assignments and source-derived additions are reviewable recommendations, not automatic implementation. | Documentation only; no gameplay changes or simulations. |

The initial order moves from overall purpose through economy and geography to military execution, learning and testing. It can be changed without renumbering. Answers are not implementations: each accepted change should later be mapped to affected rules, AI paths and an observable completion test.

### Q001 — recorded answer and interpretation

User examples: an unworked bonus Culture tile prompts consideration of the required building/improvement, suitable population and technology unlocks. The resulting choice may be non-optimal but an interesting mental exercise. A visible nest, or a possible future bandit camp, motivates assembling a force and wrestling with the threat. A secure, developed controlled area motivates looking for another interesting/useful location, potentially simply to cover more ground without a specific resource reason.

Intended recurring experience: **notice an opportunity → choose a purpose → investigate requirements → prepare → act → observe the result**. Economic opportunity, threat removal and territorial presence are all valid self-chosen motivations. Optimal resource efficiency is not a requirement for a satisfying choice.

Implication for later AI design (interpretation, not implementation): support explicit goals and prerequisite paths grounded in map opportunities and faction priorities, including discretionary expansion once the base is secure. This answer does not authorize arbitrary waste or imply that every visible opportunity must be pursued. A future bandit camp remains an idea, not current content.

Q002 should clarify what civilization-level success means when no scenario objective is imposed, building on these open-ended motivations rather than assuming a mandatory victory condition.

### Q002 — recorded answer and interpretation

The user's desired successful civilization is self-protected, well teched, fully expanded, fully tile improved and fully trained where useful. This establishes a broad aspiration toward security, technological capability, territorial development, land improvement and useful specialization, rather than merely accumulating stock or reaching modest income thresholds.

Future possibilities explicitly mentioned: wonder-like projects, story choices, manipulation of the planet, and differently minded players pursuing different ideological goals. Tile terraforming should become a later option; specifics are pending. These are future direction, not implemented content or authorization to invent their detailed rules now.

Scope cautions: “fully expanded” does not yet specify a boundary, all-map conquest or unlimited founding; “fully tile improved” does not yet settle whether every controlled tile should be modified irrespective of use or preservation value. “Fully trained where useful” explicitly conditions specialization on usefulness rather than a requirement to eliminate Workers. “Well teched” is not automatically every technology purchased. These details remain for the relevant later questions.

Q003 now concerns what tradeoffs should make survival, expansion and specialization meaningful competing choices while preserving this long-term aspiration.

### Q003 — recorded answer and interpretation

User decision: timing and urgency govern the tradeoffs. Ideally all activities are pursued. An emergency can override a balanced approach; a catastrophic emergency can disrupt the normal economy. Examples: an enemy faction attacking a town, or multiple predators roaming around.

Intended normal policy: keep survival/protection, expansion, development and useful specialization in a balanced portfolio, with different activities receiving attention according to their current need and timing. This does not require an order quota per category on every turn or activity with no useful purpose.

Emergency implication: severity can justify progressively stronger reprioritization, including interruption of productive work and ordinary commitments during a catastrophic threat. Exact severity criteria, mobilization authority and return-to-normal conditions remain open for later defence/ruler questions; no numerical thresholds are specified here. The player's enemy-faction example is future-capability intent, not a claim that PvP currently exists. Predator roaming is an example of danger whose actual urgency depends on context; the answer does not define every sighting as catastrophic.

No gameplay implementation authorized by recording this answer. Next: Q004, how much routine settlement management the human should delegate.

### Q004 — recorded answer and interpretation

The user recalls governors in original SMAC and Civilization III, but personally almost never uses them. Human settlement delegation should be retained as a design idea, not treated as a committed feature or the default human experience.

For computer players, the answer is yes: governors/local reasoning should help the controller make sense of its civilization and develop settlements coherently. A leader may impose requirements over normal settlement logic when military priorities require it. Local development is therefore subordinate to civilization-level commitments; a governor is not an independent optimizer allowed to frustrate an authorized military programme.

This reinforces the ruler/general/governor coordination requirement already under discussion. Exact authority, duration, labour/budget ownership and emergency overrides remain to be specified in later questions. It does not authorize permanent military micromanagement, a new human automation UI, or new gameplay code in this documentation phase.

Next: Q005, ordinary scenario ending versus open-ended play.

### Q005 — recorded answer

User: “I guess after winning one can continue the map until they get bored.” Intended design is a recognizable win followed by optional continued play on the same map. Victory need not forcibly end the simulation. The precise winning conditions and post-victory faction behaviour remain unspecified; this answer does not settle them or implement an ending system.

Next: Q006, recoverable failure versus effective defeat.

### Q006 — recorded answer

User: “Just survive until you cant, a player likely wont ‘win’ if there are other surviving and undamaged players, but theres no reason to be eliminated prematurely.”

Design intent: a civilization may continue surviving and attempting recovery after severe military, territorial or economic setbacks. Being unlikely to win against intact competitors is not itself a defeat/elimination condition. Do not invent an early-elimination rule based on lost army size, lost settlements, low score or projected competitiveness.

Exact terminal conditions for impossible survival remain unspecified (for example, the treatment of surviving mobile population without a settlement must be resolved later). This answer does not assert that every damaged civilization can recover or that other surviving players mechanically forbid victory. It expresses a likely competitive consequence, not a complete victory formula. Recorded only; no implementation changes.

Next: Q007, which systems should deliberately stay simple as content expands.

### Q007 — recorded answer

User: “Simple is a hard to define word, but i guess individual subsystems like research or town management should be ‘simple’ in themselves, but their interplay and possible choise space should be expansive, at least combinatorically.”

Design principle: locally understandable subsystems, broad interacting possibilities. Complexity should arise substantially from combinations of research, town development, people, geography and other systems. Do not interpret simplicity as a globally narrow decision space, nor expansive combinations as a request to complicate every subsystem internally.

This does not settle a specific logistics abstraction or rule-count ceiling, and does not authorize a combinatorial framework or content expansion by itself. Meaningful choice, clear dependencies and inspectable effects are compatible implementation interpretations; exact interfaces and content remain for later questions.

Next: Q008, evidence needed to treat a provisional rule as intended core design.

### Q008 — recorded answer

User decision: if an unanticipated mechanism/solution solves an important problem, it should stay. Numerical values will change and be tweaked in later tests. Once a player can achieve a set of goals, balancing becomes useful.

Development principle: prioritize functional capability and coherent goal completion, then tune numerical tradeoffs using meaningful tests. The design is open to useful discoveries rather than requiring every retained solution to have been anticipated. Numerical defaults are not frozen merely because a fixture passes.

This does not require perfect AI or completion of every conceivable goal before any balancing, nor authorize hidden grants or numerical changes to manufacture apparent capability. A real solution should be distinguished from a workaround that masks a disconnected planning chain. The relevant goal set and evidence can be specified in subsequent tests.

Next: Q009, how strongly doctrine should influence choices when alternatives appear more effective.

### Q009 — recorded answer

User: “Early game: grow; middle game: specialise; end game: maximise ideological goals.”

This supplies the intended broad temporal progression of civilization priorities. Growth establishes a base, specialization becomes more prominent in the middle game, and late development maximizes ideological aims. Read this together with Q003: ordinarily pursue a balanced set of activities, while urgency/emergencies can override that balance. The answer does not specify mutually exclusive phases, prohibit early specialists, or require abandoning growth and security later.

Unresolved details: what determines phase transitions (capability, circumstances, time or another measure), exact ideological objectives, and whether any doctrine creates hard prohibitions rather than preferences. Do not invent fixed turn thresholds or universal progression quotas. Those details can be addressed when relevant later without treating this broad answer as a complete doctrine rule set.

Next: Q010, when the ruler should override an adviser’s specialist judgment.

### Q010 — recorded answer

User describes weighted areas of activity: expand, defend, offend, improve economy and others. Adviser suggestions should be ranked within the emerging hierarchy. Some proposals clash over resources; others do not at a given time. An opportunity identified by an adviser may be promoted as important or placed far down the list.

Intended decision structure: contextual civilization-wide activity weights inform the ranking of concrete proposals. The leader resolves competing requests through this hierarchy rather than automatically favouring a particular adviser. Compatible proposals can proceed together when actual means permit. A suggestion being possible is neither sufficient for immediate authorization nor reason to discard it; it may remain a low-priority option.

Read with Q003/Q009: weights can reflect growth/specialization/ideological emphasis and emergency severity. Exact scoring formula, proposal-cost comparison, resource/person/service-slot accounting, commitment stability and refresh cadence remain unspecified. This answer does not authorize per-turn flip-flopping, strict resource silos or mandatory action quotas. Adviser freedom over execution details was not explicitly settled in this answer.

Next: Q011, which emergencies should interrupt an approved long-term operation; Q003 already establishes proportional emergency override, so ask about concrete interruption criteria rather than repeating whether overrides exist.

### Q011 — recorded answer and open experiment

Immediate survival is the top priority. Destroying the sources of danger is desirable. If three riflemen appear to form a risky task force, assembling a large task force is desirable. What constitutes a more valuable non-military opportunity is explicitly left as a useful question to answer through simulations.

Intended implication: a threat-removal objective should lead to a force appropriate to its risk, rather than a permanently fixed small expedition, an indefinitely repeated unsafe attempt, or simply stopping at “unsafe.” Actual immediate protection still takes precedence over the longer preparation needed to remove the source. The three-rifle example is illustrative, not a universal force threshold; no particular large-force composition is fixed.

Open: how to value non-military opportunities against ongoing commitments and interruption costs. Retain this as a simulation/design uncertainty rather than marking it resolved or choosing weights silently. A future controlled comparison could evaluate continuing a commitment versus redirecting spare or committed means, observing survival, delayed goals, resource output and disruption. That experiment is an assistant suggestion, not a new run requested by this answer.

No precise army-sizing formula, emergency trigger, spending fraction or cancellation policy was settled. No gameplay changes or simulations performed. Next: Q012, allocation between important operations that need the same people, building on Q010's weighted ranking.

### Q012 — recorded answer

User accepts the suggested possibilities under the previously stated governing principle: a competing stack of ideas, acted on according to how they rank. Thus waiting, requesting another worker, growing replacement population, or changing a settlement plan can all be candidates when another priority takes the original actor. These are possibilities to evaluate, not instructions to perform every response.

Design consequence: alternative means to a goal should participate in the same contextual priority process as other proposals. Neither automatic indefinite waiting nor automatic replacement creation is the universal rule. Read with Q010: feasibility, resource conflicts and compatible work matter. No scoring formula, search breadth, actor-claim policy or mandatory retry schedule is fixed here. Recorded only; no gameplay changes.

Next: Q013, revising a blocked operation instead of repeatedly postponing it. Ask how a continuing blocker should influence that ranked set, without assuming a fixed turn limit is desired.

### Q013 — recorded answer

User: “Yes, offer ways to solve the blocker; the goal might be a top priority for a long time and not succeed, but interim steps should be attempted.”

A long-lived blocked goal need not lose priority solely because it has not yet succeeded. Advisers should propose and attempt actionable enabling steps that address the actual blocker, while retaining the overarching objective. Read with Q010–Q012: candidate remedies and competing activities still participate in the ranked proposal process; the answer does not demand every remedy run at once.

Design implication: distinguish goal importance, present executability and dependency progress. A useful move can advance a prerequisite rather than directly complete the goal. Repeating an unchanged waiting status or a known-inadequate final attempt is insufficient when useful intermediate work is possible. No automatic age-decay rule, fixed timeout, forced success guarantee or precise progress metric was specified.

Recorded only; no gameplay changes. Next: Q014, what unacceptable cost should justify abandoning a chosen objective, separate from mere elapsed time or temporary infeasibility.

### Q014 — recorded answer

User agrees with containing/developing rather than sacrificing the civilization for an unaffordable immediate objective: “survival without damaging the whole should be the top priority.” When resources accumulate and there is nowhere to expand, regional threats should be dealt with. Wars common to4X games are intended only for a much later iteration.

Design interpretation: protect overall civilization viability while retaining threat removal as an ambition. Accumulated means and exhausted expansion opportunities can elevate regional clearing within the ranked ideas. No exact sacrifice budget or abandonment threshold is specified. Lack of expansion space is a reason to increase offensive priority, not an exclusive prerequisite that forbids earlier defence or removal of an urgent threat.

Read with Q003/Q011: catastrophic immediate danger can still disrupt the normal economy; preserving the whole does not mean every operation must have zero local cost or casualties. Read with Q013: delay/containment need not permanently discard the underlying objective, and useful preparations should continue when justified. Future inter-civilization warfare is direction, not current mechanics or an instruction to implement it now.

Next: Q015, choosing settlement roles among doctrine, local opportunity and empire needs.

### Q015 — recorded answer

The user includes all suggested influences (local opportunity, civilization-wide needs and ideology) within the general weighted pile of matters the leader arranges. Unique/special landscape features should be developed accordingly. Ordinarily pursue some balance of growth and production, while allowing emergencies or lack of importance to interfere. Ideology should matter, but its treatment belongs later during balancing tests.

Design implication: geographically suitable development creates proposals; these are ranked with other civilization priorities rather than automatically demanding action or making every town match a faction-wide theme. A locally useful opportunity may legitimately be deferred. Baseline growth and production remain considerations, not inflexible per-town quotas. No exact weighting, forced specialization roster, landscape feature effect or ideology mechanic is specified.

Ideology remains intended direction, consistent with Q009’s late-game emphasis, without requiring detailed ideological behaviour in the present architectural pass. No gameplay changes. Next: Q016, how much faction behaviour should converge under the same urgent threat; acknowledge that ideological tuning has already been deferred.

### Q016 — recorded answer

The user agrees that factions should recognize common survival necessities, while noting that a threat to one player’s town can be much more serious than the same threat to a player dozens of tiles away. Garrisons should be desirable and maintained against roaming opportunistic threats.

Design consequence: assess urgency relative to the civilization’s own exposed people, settlements and geography, rather than applying a uniform emergency weight to everyone whenever a threat exists anywhere. Shared survival principles do not imply identical action or urgency in different situations. Standing garrisons are a desired precaution, not only a reaction after damage.

Unspecified: minimum garrison size/composition, affordability, coverage radius and physical protection mechanics. Existing engine rules do not grant automatic interception or civilian shielding; this answer states intended defensive value and maintenance, not that such mechanics already exist or that a guard guarantees safety. No joint faction response or alliance is implied. Recorded only; no gameplay changes.

Next: Q017, the distinct choices each of the six resources should create. The queue now moves from overall aims/authority to resources and economic value.

### Q017 — recorded resource roles and new ideas

| Resource | User-stated purpose | Status / open detail |
|---|---|---|
| Food | Needed for general development of industry and military. | Broad support role; no new exact cost recipe or universal direct Food charge specified. |
| Minerals | A flavour raw resource signifying that excavated rocks are not manufactured goods. | Preserve conceptual separation between extraction and manufacture; no new refining recipe specified. |
| Industry | Hard physical manufacture and construction. | Physical productive effort/output, distinct from raw Minerals; no automatic equivalence to money. |
| Energy | Part settlement maintenance, part training use; potential trading purpose; might also become a research requirement. | Intended roles/potential uses, not evidence all current actions spend it. Trade and precise shares/costs pending. |
| Science | Raw “thinking” effort of progress. | Intellectual effort need not be the sole research input. |
| Culture | Claiming tiles, training and thematic technological advancements. May become currency for a societal tree or marketplace of ideas / policies. | Broad design roles recorded; societal/policy mechanism explicitly future idea, no tree or market invented. |

Spontaneous research idea: various resources can be used as extra costs of research, reflecting that progress may need more than theory. Energy is one suggested input, not the only possible one. No requirement that every technology consume every resource, no numerical costs and no specific technologies/recipes were chosen. Whether these resources are spent, retained as prerequisites, invested over time or represented by operating facilities remains to be clarified where applicable; do not conflate those mechanics.

This answer defines intended resource meanings and directions, not a fresh audit of current costs. Existing resource-specific conditions in the prototype must be distinguished from newly suggested expenditures. No gameplay, research-cost, training-cost, trading or policy changes implemented during this clarification queue.

Next: Q018, whether basic settlement startup income should eventually cease to support advanced development by itself.

### Q018 — recorded answer

User strongly agrees that startup income should not sustain advanced development: “just spamming settlement tiles and running one person per town should not generate anything worthwile,” while settlement creation should cost materially and ungarrisoned towns can become a security threat.

Intended design: broad settlement-marker proliferation with minimal population is not a worthwhile substitute for real development. A new site consumes means and expands defensive exposure; productive value should depend on its developed land, workplaces, people and support. This clarifies an incentive problem seen in earlier tests where starter structures/passive income supplied much of the economy.

No exact starter-yield reduction, minimum population, founding resource recipe, garrison count or new attack/interception rule is specified. A small town can still be a temporary foothold; the answer rejects meaningful economic returns merely from spam, not every strategic outpost. Security exposure describes desired consequences of vulnerable sites, not a claim that an ungarrisoned town spawns enemies or that garrisons automatically screen civilians under current rules.

Recorded only; no game changes. Next: Q019, when investing in a staffed workplace should be preferable to founding another settlement, taking this newly established anti-spam principle as given.

### Q019 — recorded answer

The user confirms that established infrastructure and trained people should make further development attractive, while new settlements offer new land, special resources or strategic positions. Protecting extra land may or may not be problematic depending on circumstances. An established settlement might benefit from future defensive structures and/or an economy of scale if building a workplace and training a specialist offers more than the alternative cost of expansion.

Design consequence: evaluate the relative payoff and full costs of local investment versus expansion, including actual geographic/security exposure. Development should have a meaningful economic case without making expansion automatically wrong. Scale advantages may emerge from useful existing infrastructure, workforce and investment rather than necessarily requiring an arbitrary size multiplier.

No exact return formula, construction/training discount, compounding bonus or defensive building rule is fixed. Future defensive structures remain a possibility; existing military-themed structures must not be assumed to provide unimplemented fortification/interception effects. This qualifies Q018: additional territory is not always difficult to protect, but its security costs cannot be ignored when relevant.

Recorded only; no gameplay changes. Next: Q020, how far ahead resources should be reserved for ordinary development.

### Q020 — recorded answer

User calls for a combination of low, medium and high investment depending on what else the empire/nation is dealing with. Scarcity with survival taking precedence is one case; unused stockpiles and no plans for them is another.

Intent: investment scale is contextual, informed by survival pressure, available stocks and competing commitments. Neither universal minimal spending nor universal full-programme reservation is the rule. Read with the ranked proposal approach: a programme’s funding must account for the wider situation and other planned uses.

The answer addresses investment posture rather than selecting an exact forecast horizon, reservation duration, escrow mechanism, numerical tier boundaries or spending fractions. Those remain implementation/design details to propose and test; do not silently treat low/medium/high as three fixed funded modes already coded. Stockpiles lacking planned uses are a reason to consider investment, not permission to buy arbitrary useless content.

Recorded only; no gameplay changes. Next: Q021, what to pursue with large surpluses once immediate needs are satisfied, extending this answer rather than repeating scarcity versus abundance.

### Q021 — recorded answer

User explicitly wants “any and all legal moves” to be generally proposed, with the categories of proposals also weighted against one another. Examples: a bug chasing a worker should prompt investigation and mounting an expedition; unused nearby land should be evaluated for resources and potential threats; a technology available sometime soon should be pursued when stocks permit and it is the highest-priority affordable one.

Design consequence: broad autonomous consideration of legal possibilities rather than stopping useful activity after modest income thresholds. Opportunity/threat recognition should connect to actionable proposals and, where needed, preparation sequences. Both the category and the concrete candidate participate in prioritization. Research selection should account for actual affordability and relative priority rather than buying merely the first legal technology.

Proposals are not mandatory executions: ranking and resource/actor compatibility still determine what proceeds, consistent with Q010/Q012/Q020. Exact enumeration frequency, candidate pruning/grouping, lookahead and performance limits remain implementation details; do not quietly exclude entire legal action families merely because the current controller has no policy branch. Equally, the statement does not require every equivalent action instance to be exhaustively re-enumerated every turn. The phrase “research sometime soon” indicates considering preparation/near-future possibilities, not bypassing actual unlocks or legal costs.

Immediate worker protection remains highest priority under Q011; investigating a source and mounting an expedition is the broader response, not a reason to delay urgent safety. Specific safety or expedition mechanics are not implemented by this answer. No rule that surplus must always be exhausted was specified.

Recorded only; no game changes. Next: Q022, the consequences of resource shortages for existing capabilities, beyond stopping new expenditure.

### Q022 — recorded answer, 2 November 2026

**Food:** Negative Food should kick out/mobilize population that does not produce Food, leaving those people waiting for instructions. Sentry/fortify/sleep and similar orders are future ideas. This is a requested response direction, not an instruction to delete people, auto-reassign them to food jobs, or implement those future order modes now.

**Energy:** Negative Energy should power down the most energy-hungry installations. Tie-breaking priorities explicitly need testing. Do not silently replace this with an optimization by total net economic value or assume a permanent building loss.

**Military maintenance:** The user calls this tricky and tentatively proposes a global percentage reduction of combat power proportional to the fraction of global maintenance demand not met. Disarming and employing some troops is suggested as a possible way to reduce the problem. Both are provisional, with no coefficient, affected-unit scope, minimum strength, resource combination, rounding rule, or retraining mechanism settled. Do not present these as implemented rules or as an accepted exact formula.

**Open rule interactions to resolve/test:**

- “Negative” has not been distinguished between negative net income while reserves remain, a forecast deficit, and actual unpaid upkeep after stocks are exhausted. Current stocks are clamped, so a negative stock value is not a sufficient implementation definition.
- Under the documented current rules, mobilized people still consume ordinary Food and mobilized Soldiers have additional Food upkeep. Mobilizing non-food producers therefore does not by itself lower global Food demand or create Food output. Record the desired action without inventing a free-upkeep exemption; determine the intended economic effect before implementation.
- A mixed-output job that produces some Food needs explicit treatment before selecting non-food producers. Which people, how many, and whether essential operating-input staff are protected remain unspecified.
- Energy shutdown ordering can interact with generators, Minerals, food facilities and other dependent output. The most-hungry rule and its tie tests need actual operating-demand measurements and a defined restart policy.
- Disarming, demobilizing, joining a town, clearing Soldier specialty and productive employment are distinct existing/possible operations. The user has not yet selected which are required or whether retaining qualification is intended. Any effect on maintenance and Food must use actual rules.
- No prolonged-shortage permanent-loss rule was selected by this answer.

Recorded only; no new simulations or gameplay changes. Next: Q023, legal emergency conversions or substitutions among resources.

### Q023 — recorded answer and Q022 clarification, 2 November 2026

**Food follow-up:** After learning that mobilized people still eat, the user says to make them try to produce some Food if able, with balance testing needed. This qualifies Q022's earlier passive-awaiting-orders response: affected people should seek feasible Food production, not merely be moved out while retaining the same consumption. Exact assignment/movement sequence, available food jobs, whether mobilization remains necessary and behaviour when no feasible source exists are not yet fixed. No free Food or free-upkeep status is implied.

**Conversion/trade:** No magical resource conversions when there are no dedicated proper trading partners and/or actual methods of generating the desired resource. Ordinary production/conversion facilities may have authored generation rules; exchanges require a proper mechanism rather than an arbitrary emergency button that invents supplies. No exchange rates, trade interface, partner stocks or delivery rules are selected here.

**Future content:** Neutral stations and city-states will likely be a later feature. These intended future entities must be distinguished from the existing neutral reward-visit sites, which do not by themselves implement full trading partners/city-state economies. No diplomacy, trade, settlement generation or city-state AI implemented by recording this idea.

Q022's original wording remains as historical answer; the decision table and this clarification provide the updated intent. No gameplay changes or balance tests performed. Next: Q024, reducing future upkeep versus increasing gross production.

### Q024 — recorded answer, 2 November 2026

User agrees that upkeep reduction, added production and other legal remedies should compete according to costs, benefits and effects on plans: “if no other complications, largest obvious gain is chosen.”

Design implication: evaluate improvements in useful net outcome, including saved consumption, rather than treating larger gross output as automatically superior. Existing commitments, useful output lost by shutdown, construction/training costs and operating dependencies are examples of complications that can change the ranking. These are interpretations of the question's accepted comparison, not newly fixed numerical weights.

No exact gain metric, payback horizon or cross-resource conversion of value is specified. This does not authorize imagined efficiency upgrades that lack actual legal effects. Q022's automatic energy-shortfall shutdown direction and unresolved tie rules remain distinct from choosing a proactive economic proposal. Recorded only; no game changes.

Next: Q025, what useful demand should trigger encouraging additional population.

### Q025 — recorded answer, 2 November 2026

User accepts all suggested motivations: staffing buildings, developing land, founding settlements, military recruitment and growth as capacity for future possibilities. Population gives opportunities to do something and is potentially a defensive and/or offensive force. Its value need not be restricted to a currently vacant named job.

Future direction: too much population should generate pollution, squalor, disease and similar problems, especially when concentrated in a huge metropolis. Raw population is therefore both a strength and a managed liability. This specifically introduces concentration/scale as relevant; do not assume the same penalty for an equal population dispersed over many towns.

No exact population ceiling, density formula, shortage effect, pollution emission rate, disease/squalor system, militia capability or recruitment rule is specified. These are future mechanics, distinct from currently implemented pollution overlays and documented Medic/growth effects. Population's military potential does not by itself mean that untrained people gain trained Soldier abilities or that every person should mobilize.

Recorded only; no gameplay changes. Next: Q026, whether deliberate growth suppression should be possible when further growth is unwanted or currently unsupported, building on population's potential value and later liabilities.

### Q026 — recorded answer, 2 November 2026

User agrees that growth can be limited, first through not producing too much Food where it is not needed. The user also notes the existence of explicit “not permit” growth controls in some Civilization games. Record deliberate restraint as desired and explicit growth permission as an available design option; the answer does not specify its precise implementation.

No starvation policy is implied: reducing excess production is distinct from deliberately failing population upkeep. No growth toggle, growth-meter handling, food disposal/storage behaviour, migration mechanism or local-versus-pooled Food allocation rule is settled here. A future implementation must reconcile settlement-specific growth control with the actual resource pooling and growth rules rather than assume a local surplus model already exists.

Read with Q025: population retains opportunity value, but growth need not be maximized in every location or circumstance. Recorded only; no gameplay changes. Next: Q027, what makes a populous town preferable to several smaller towns, acknowledging Q019's existing economies-of-scale principle.

### Q027 — recorded answer, 2 November 2026

Potential late-game options include a specialist or multi-specialist building, a very sophisticated weapon module, or a tertiary resource. The user emphasizes that these depend greatly on testing and balancing, while potentially providing worthwhile late-game capabilities.

This is a conditional direction rather than a commitment to population-gated unlocks or any particular requirement. Do not invent minimum population, worker numbers, module effects, production recipes or named tertiary resources. Several specialists working together could be relevant, but the answer does not demand every advanced building require multiple staff.

Read with Q019/Q025: concentrated development may yield capabilities or scale advantages that must be weighed against future concentration liabilities. Preserve the option for later testing; no current roster or economy change is made. Next: Q028, costs/difficulties of supporting large population; pollution/squalor/disease already identified in Q025 and should not be re-asked as new ideas.

### Q028 — recorded answer, 2 November 2026

User says ultra-tall development should be a design and testing consideration. Its value should include something unique and desirable, requiring long, conscious investment, rather than simply inflated revenues. Technology should be associated with solving problems players face or will be designed to face.

Design consequences: evaluate very large cities as a purposeful development path with meaningful capabilities and commitments. Link technological progression to authored needs and problems instead of relying only on generic output increases. This reinforces Q007's simple interacting systems, Q027's possible advanced capabilities and Q008's capability/testing-first approach.

Unresolved: whether pollution/squalor/disease can be fully mitigated, whether some concentration pressure always remains, and which unique urban outcomes should exist. The answer supplies direction, not a city-size target, infinite scaling promise, mandatory tall strategy or specified technology unlock. Future problems must be explicitly designed and implemented before treating a technology as solving them in current play.

Recorded only; no gameplay changes. Next: Q029, when a growth-focused player should invest in medicine instead of additional Food production.

### Q029 — recorded answer, 2 November 2026

User agrees with infrastructure addressing growth constraints in a way that certain thresholds cannot be crossed without infrastructure, citing SMAC habitation buildings and Civilization III aqueduct/hospital buildings as design analogies.

Intended mechanic: at least some stages of settlement growth require enabling infrastructure; enough Food is not the sole condition. This supplies a concrete role for development investment and supports Q028's long-term deliberate tall path. The analogies concern the design principle; this note does not import exact rules, numeric caps or exemptions from the referenced games.

Unspecified: threshold values, which buildings/capabilities satisfy them, whether staffing/power/technology are required, whether the gate is population-based or has additional health criteria, and how saved growth behaves at a cap. Do not infer that every medical building must raise a cap or that all illness/poor conditions disappear after building one. No gameplay changes.

Next: Q030, possible Medic role beyond the currently documented growth effect.

### Q030 — recorded answer, 2 November 2026

User says potentially both, responding to settlement/growth/health and field/military medical support, and leaves room for something not yet considered. Do not freeze the Medic into one exclusive role or treat any particular healing bonus/support unit as approved.

Broader future military direction: as in the variety offered by SMAC, there should be multiple troop, transport and gun-platform types. Designs should explore interesting plausible alternatives rather than literal physics-laboratory lasers mounted on wheels or slabs of armour that cannot practically be carried. This is a preference for plausible deployable engineering, not an exact unit roster, ban on every laser/armour concept, or requirement for a full physics simulator.

The user refers to an earlier standalone SMAC document as background. That document was not retrieved for this answer record, so no specific technical conclusion or numerical specification from it is asserted here. Consult that source if later military-content work depends on its findings. No new unit types, healing rules, medical equipment, weapon designs or transportation mechanics implemented.

Next: Q031, how readily a civilization should replace population lost to expansion or warfare.

### Q031 — recorded answer, 2 November 2026

User chooses the first option: natural growth, with the joke “if youre gonna lose... try not to lose... ;-)”. Lost people are replaced through ordinary growth and available supporting infrastructure, not a special emergency population-replacement mechanism.

Consequences: preserve population where feasible; losses remove productive/military capacity and training investment, and rebuilding takes ordinary growth/training time. This does not promise immunity to defeat or guarantee rapid recovery. Existing people can still be mobilized, trained or relocated through legal means; the answer concerns creating replacement population, not forbidding recruitment from the surviving population.

No new growth speed, immigration rule, casualty refund, emergency spawn or training rule specified. Recorded only; no gameplay changes. Next: Q032, when to evacuate a settlement rather than defend or repopulate it.

### Q032 — recorded answer, 2 November 2026

User: “Perhaps, likely, but when exactly is a serious testing concern, depends on what kind of player ai emerges.”

Evacuating to preserve people is a likely appropriate option in some situations, but no exact criterion for preferring it over defence/repopulation is chosen. Treat its timing and effectiveness as an important simulation/testing question shaped by the emerging controller, rather than inserting a universal threat-distance, casualty-probability or time-to-reinforcement threshold as user policy.

Testing should distinguish the decision to evacuate from a genuinely reachable escape and successful resettlement; these are review considerations, not a newly requested experiment. Existing survival priorities still apply, but this answer does not settle their full tactical implementation. Recorded only; no gameplay changes.

Next: Q033, the useful advantage of specialized labour over flexible Workers.

### Q033 — recorded answer, 2 November 2026

User states that specialists certainly produce more of their preferred goods, and some have unique abilities that untrained people lack. Likely all professions should connect to technological progression through their existence and potentially through required numbers. Soldiers are especially linked to exotic and high-level equipment.

Design intent: specialist value includes matching productivity bonuses, some exclusive actions/capabilities, and institutional/technical prerequisites. Do not reduce professions to interchangeable yield modifiers alone. Presence-based specialist prerequisites already occur in the documented prototype; extending links to all professions or numerical requirements is intended/potential direction, not a claim that every such gate currently exists.

No universal requirement that every profession have an exclusive ability, exact training return, headcount requirement, specialist-consumption rule, technology list, advanced loadout or equipment eligibility matrix is specified. Soldier qualification should matter particularly for sophisticated military equipment, but this does not itself assign a new item or ability. The user did not explicitly adopt reduced general-worker flexibility as an additional penalty; do not impose one from the question wording.

Recorded only; no gameplay changes. Next: Q034, how reversible profession choice should be.

### Q034 — recorded answer, 2 November 2026

User supports clearing a profession as an option, referring to Colonization as an example from personal experience. Multi-skilling is not selected as a baseline requirement, but would be welcome as a later tested solution if it solves a very real, consistent problem. The user's recollections about other games are context, not independently verified comparative claims in this document.

The documented prototype already has a clear-specialty command; retaining that capability aligns with the answer. No automatic refund, profession-history retention, multiple simultaneous bonuses, free switching, retraining cost/time or number of qualifications is specified. Clearing and normal retraining remain conceptually distinct from multi-skilling. Record the latter as a conditional design option and tie any later proposal to evidence of the problem it solves.

Recorded only; no gameplay changes. Next: Q035, when idle people should remain a reserve versus be assigned or trained.

### Q035 — recorded answer, 2 November 2026

User chooses tile work as the default for people not assigned to anything specific. If all settlements are at full capacity and no troops are needed, those people should persist as mobilized idles, and a purpose should be sought for them when one becomes available.

Intended policy: use available productive tile work rather than keeping generic uncommitted labour unnecessarily idle. Respect specific assignments; do not automatically undo a plan's dedicated actor allocation. When productive settlement capacity is exhausted and no military demand exists, preserve people rather than deleting them, forcing pointless training or pretending they have useful employment. Reconsider useful opportunities as conditions change.

Unspecified: what counts as full capacity (job slots, future population infrastructure thresholds, workable land, etc.), where mobile idle people wait, their safety/movement orders, and search cadence. This answer does not grant free Food upkeep to mobile idles or authorize unsafe tile assignments in conflict with established survival priorities. No automatic clearing of a specialist's profession is implied by fallback tile work.

Recorded only; no gameplay changes. Next: Q036, when moving an established specialist to a different settlement is justified.

### Q036 — recorded answer, 2 November 2026

User accepts comparing destination benefit, lost home output, travel time/risk and local training alternatives, provided the AI dependency tree allows it in a relatively uncomplicated way. If not, or less readily, relocation can be opportunistic or an emergency-required reshuffle.

Design/implementation boundary: support useful specialist movement through existing plan/dependency machinery where straightforward. Do not construct an elaborate global migration/assignment optimizer merely to satisfy this option. A simpler opportunity-driven path and emergency reassignment are acceptable when richer planning is cumbersome. This does not remove actual movement costs, safety rules or the civilization-wide priority ranking.

No exact comparison formula, relocation interval, compulsory specialist redistribution, complexity/performance budget or emergency actor override is fixed. Recorded only; no gameplay changes. Next: Q037, protecting essential operating jobs from borrowing for construction or military needs.

### Q037 — recorded answer, 2 November 2026

The user agrees generally with protecting essential jobs, and states the wider principle: if someone is providing something useful and has been for a while, moving that person requires a serious top-down decision responding to something important.

Intent: sustained useful employment carries stability/commitment value. Protection is not confined to Food, essential power or an immediate chain-break condition; an established useful assignment should not be casually displaced by routine adviser competition or a small transient scoring advantage. Authorized civilization-level priorities can justify the move when the reason is important.

No exact tenure threshold, priority margin, approval data structure or absolute job lock is specified. “Something important” is not restricted solely to catastrophic emergencies. A serious relocation opportunity or required prerequisite may qualify subject to the established leader hierarchy; this is an interpretation to assess, not a pre-approved exception list. Q036's relocation option must respect this additional stability requirement.

The repeated Q037 formulation resulted from a display glitch, not a separate question or answer. Recorded only; no gameplay changes. Next: Q038, what obligations should accompany a temporary worker loan between plans.

### Q038 — recorded answer, 2 November 2026

User rejects the proposed return obligation: someone can work a position for a while, then construction, then garrison, then retrain and work elsewhere. Continuity is not needed.

Important distinction with Q037: stability of an ongoing useful assignment is desirable until an important top-down reassignment is warranted. Once reassigned, there is no required restoration of the former workplace or prescribed career continuity. Subsequent work can follow current priorities. Do not mistake this for permission to repeatedly reshuffle workers without good reason or to leave essential production broken without evaluating the consequences.

The existing documented temporary construction-loan/return-to-job mechanism is an implementation choice, not a requirement endorsed by this answer. Flag it for later review against this intent; do not claim it has already been removed or that returning to the old job is forbidden if it is the best current use. No mandatory replacement-worker obligation or new allocation algorithm is specified.

Recorded only; no gameplay changes. Next: Q039, training an existing productive worker versus waiting for new population.

### Q039 — recorded answer, 2 November 2026

User agrees with comparing the expected benefit/urgency of training against temporary lost work and waiting, while adding two explicit inputs: specialized buildings already present and formulated plans that require future specialists.

For an existing workplace, the desired task is to try to train when resources allow. If unaffordable, wait and retain the need; execute when affordable provided the specialist is still needed. Do not discard a valid staffing need solely because it cannot be funded immediately, nor carry it out after the relevant demand has disappeared.

This grounds specialist production in workplaces and real planned capabilities rather than a generic quota of every profession. It does not imply training an additional person when suitable staff already satisfy the need, disregarding essential current output, or automatically outranking immediate survival. Existing priority and reassignment principles still apply. Exact actor selection, training budget/horizon and prerequisite ordering remain unspecified.

Recorded only; no gameplay changes. Next: Q040, the Administrator's distinct strategic role beyond Culture production.

### Q040 — recorded answer, 2 November 2026

User describes a provisional Administrator role analogous in broad purpose to a Colonization statesman, with population-size maintenance/increase when the consequences of population size are implemented. Provisionally, the Administrator should provide some Culture while working the settlement tile/settlement itself.

No specific mechanics from Colonization are imported. Do not infer liberty bells, independence, rebel percentages or any other referenced-game system. The analogy is user-supplied context for the role. Exact Culture amount, job representation (center tile, settlement job or workplace), passive versus staffed distinctions and later population-support effects remain unspecified. The wording calls for working, not an unconditional bonus merely because an Administrator exists anywhere.

Population-size support must be connected to real future constraints/consequences before being claimed operational; no cap increase, growth percentage, upkeep reduction or policy authority is fixed. Existing prototype Civic Office/Administrator output is a separate implementation fact; recording this answer does not change it or prove that center-tile work already exists.

Recorded only; no gameplay changes. Next: Q041, research motivation after current economic targets are met, building on Q021's broad proposal coverage and Q028's problem-solving technology principle.

### Q041 — recorded answer, 2 November 2026

User tentatively proposes cheapest technologies first when immediate needs are met, defining cheap through the least complicated achievable path. A nominally inexpensive technology may demand sophisticated or missing prerequisites. Example: if one technology needs4 research plus a building, a pure20-research alternative is preferable.

Intended default: discretionary research should consider the entire outstanding prerequisite burden, not just the listed Science payment. A missing building brings additional work/cost/dependencies; an already fulfilled requirement should not be treated as still missing. No exact cross-resource cost formula, delay penalty or complexity metric is fixed.

The word “maybe” makes this a provisional policy for later testing. Do not turn it into an absolute ban on researching a more demanding technology that serves an urgent explicit goal. Existing weighted priorities, real affordability, extra-resource research costs (Q017) and problem-solving intent still apply. The answer does not separately settle long-horizon forecasting of new possibilities.

Recorded only; no gameplay changes. Next: Q042, whether prerequisites should demonstrate active operation or merely ownership/existence.

### Q042 — recorded answer, 2 November 2026

User: “I guess it should function and specialists if required should also work a job that produces their yeald.”

Intended research prerequisites: required buildings must be functioning rather than merely present. Where a specialist is required, that specialist should be working a job that produces the yield associated with their profession. An idle qualified person does not by itself demonstrate the intended productive capability.

Exact operating validation, whether requirement must be co-located, duration of operation, and whether checks occur only on research purchase/start or throughout a future timed project remain unspecified. Do not invent a mandatory dedicated building where an eligible matching-yield tile job would suffice under the eventual authored rule. Professions without an ordinary matching resource yield (particularly Soldiers) need explicit applicable capability criteria rather than an impossible generic yield test.

This is a change in desired semantics from the documented earlier existence-only prerequisite checks, not a claim that those checks already require operation. No gameplay or prerequisite validation changed. Next: Q043, comparing an immediately useful unlock with a prerequisite for a more distant programme.

### Q043 — recorded answer, 2 November 2026

User: “the goal itself should remain, if still important, but not every prerequisite should be equally achievable or desirable, hence a cheaper unrelated tech could be higher up the pile.”

Design principle: retain the overarching goal while it matters, but do not automatically assign identical urgency or dominance to all dependency steps. Each concrete prerequisite differs in attainability, cost and desirability. Unrelated inexpensive research can legitimately outrank a step of a more important long-term programme.

This qualifies the proposed blanket inheritance of expedition priority in the question; it was not accepted. Distinguish goal persistence/authority to fund dependencies from mandatory execution priority. Read with Q013: useful enabling steps should be attempted, but not all outrank every competing proposal. Read with Q041: cheap includes outstanding prerequisite complexity, not nominal Science alone.

No exact priority propagation, discounted downstream benefit, starvation-prevention rule or guarantee of eventual goal completion is specified. No automatic cancellation or endless cheap-research diversion is mandated. Recorded only; no gameplay changes. Next: Q044, whether pursuing many cheap technologies needs a deliberate constraint or can be an acceptable strategy.

### Q044 — recorded answer, 2 November 2026

User says anything available and doable belongs in the pile; its importance is a separate matter. If several currently unimportant but doable technologies are available, taking them is acceptable, because they lead to better options later.

Design consequence: distinguish candidate eligibility from urgency. Do not exclude a technology simply because no immediate demand is identified, or add an artificial anti-cheap-tech rule merely to stop broad progress. Future option value is a valid research motivation even without a fully specified downstream plan.

Execution still respects the broader ranked proposal system, actual affordability/prerequisites and survival/commitment constraints. This does not require spending every available resource on research before other work, or assert that nominal affordability ignores Q041's missing-prerequisite burden. No precise future-option score or number of technologies per turn is fixed. Recorded only; no gameplay changes.

Next: Q045, which dormant technology effects should become real. Distinguish a review question about existing entries from an instruction to invent or implement effects now.

### Q045 — recorded answer, 2 November 2026

User permits placeholders during testing. Intended process: add things to the game; those additions redistribute and add technologies; run tests; tweak a chosen goal and the technology trees themselves. Overall aim is to discover which things are universally good/desirable and which sound nice but are barely considered.

Preserve this as an iterative empirical design process, not a commitment to the current tree or a requirement to invent a replacement effect immediately for every dormant node. Existing goals and content are to be tested and reworked as relationships emerge. The user wants observed desirability, not forced usage quotas to make all definitions appear successful.

Evaluation caveat: barely considered content may reflect missing candidate/executor paths, infeasible prerequisites, controller faults, weak demand or genuinely unattractive benefits. Those must be distinguished before treating usage as evidence of value. Similarly, “universally good” is a question to investigate across relevant conditions, not a property established by one default-seed trajectory. These are evidence interpretations, not additional user-imposed test counts.

No specific new content, technology redistribution, test suite, numerical tweak or implementation batch is authorized merely by recording this process. Next: Q046, whether the Exploration/Research branch has a distinctive purpose beyond more Science; it may remain provisional under this answer.

### Q046 — recorded answer, 2 November 2026

The Exploration/Research branch's identity should emerge later. Future fog of war is intended. Some specialized units will see farther and move faster; units yet to be determined will be better at exploiting more exotic map locations.

Tentative role differentiation: Explorer may be primarily map-oriented, Merchant primarily building/settlement-oriented. Both roles should become better determined as content develops; this is not a finalized job/mission specification or rejection of every overlap.

Tentative technology organization: exploration may connect to new chassis types, while military/defence technologies connect to installations and tools/hardware. No chassis roster, transport rules, weapon system, prerequisite allocation, fixed tree partition, visibility radius or movement bonus is specified.

Distinguish future fog of war and actual exploration abilities from the current fully revealed map and survey tools. Exploiting exotic sites is intended future specialization, not a claim that all existing sites already offer such differentiated actions. Existing Merchant visit rewards are a current mechanic but do not settle the role's final focus.

Recorded only; no gameplay changes. Next: Q047, resolving competing advisers' research requests through the already established weighted proposal framework.


### Q047 — resolved by earlier answers, 2 November 2026

Original question: how to choose research when several advisers request incompatible priorities. Q010/Q021 establish weighted categories and concrete proposals; Q041 defines effective cheapness through prerequisite burden; Q043 rejects equal priority inheritance for all prerequisite steps. These already answer the broad question, so skip re-asking it. No new policy inferred. Next is Q048, the intended contribution of advanced technology.

### Q048 — recorded answer, 2 November 2026

User: “Yes, all of it, context dependent.” Advanced technologies can improve efficiency, enable new actions (including access to previously unusable opportunities) and support larger settlements/expeditions or other scale. No one category is selected as the sole or universal purpose.

Read with Q028/Q045: benefits should address meaningful problems and opportunities, while content/technology trees evolve through testing. The answer does not require every technology to supply all three types of benefit, prescribe numerical bonuses or approve particular new content. Recorded only; no gameplay changes.

Next: Q049, the contribution that makes a new settlement worth founding, building on Q001/Q015/Q018/Q019's existing opportunity, anti-spam and cost principles.

### Q049 — recorded answer, 2 November 2026

Initial settlement consideration should focus on the nature of the best or most interesting map yields, when a location is proposed as useful. Include a road-making plan and a minimal escort that becomes the new settlement's garrison. More advanced reasoning is desirable if supported by the emerging AI dependency tree.

The user raises the possibility of unused midgame land that no player seems to want. Treat that as an outcome to inspect, not a mandate that all land must be settled. Distinguish a reasonable low-value/deferred site from missing candidate generation, blocked prerequisites or an unsupported road/escort sequence. No particular cause is established by this hypothetical.

The proposed site-support package is initial design scope, not a fully specified economic schedule. Escort size/equipment, timing of road work, route safety, population transfer and exact yield scoring remain open. Escort-to-garrison continuity should be represented in a later plan so protection is not assumed to follow automatically from founding. No default free guard, road, population or funds is implied.

Recorded only; no gameplay changes. Next: Q050, choosing between resource-rich and strategically positioned support sites within the weighted proposal framework.

### Q050 — recorded answer, 2 November 2026

User: “Yes, provided its idea reaches up high enough the decision pile.” A forward base, route-support town or other strategically placed settlement can be justified despite weak local yields when its proposal ranks sufficiently highly.

This reinforces the shared weighted proposal framework rather than creating an automatic military-site exception. Actual support value, cost, staffing, roads and defence requirements still matter under previous answers. No fixed strategic-site bonus, guaranteed funding or free founding is specified. Recorded only; no gameplay changes. Next: Q051, which operating benefits remain at an empty settlement, if any.

### Q051 — recorded answer and related design additions, 2 November 2026

**Empty settlement services:** User says “Probably not” to the practical-benefit question. Recorded provisionally as no practical healing/refitting or other operational services while empty. Because the question offered both stopping and retaining services, this is an interpretation of a short answer, not a fully specified service matrix; do not treat exact service exclusions as settled beyond the broad provisional preference.

**Hostile damage/destruction:** Rampaging creatures and/or hostile players should be able to damage or destroy tiles and things. This is intended future interaction, not a claim that current combat supports PvP, building damage or terrain destruction. No damage model, target list, recovery costs, destruction probabilities or terrain consequences are specified. Inter-faction war remains a later iteration under Q014.

**Persistence/reclamation:** Things left without a settlement should exist until reclaimed by a new settlement. Preserve surviving map infrastructure rather than automatically deleting everything with a lost/removed town. Distinguish physical survival from ownership, productive operation and services. Exact ownership rules, range, reclamation cost and what destruction removes remain open.

**District demolition/redevelopment:** The player should be able to destroy districts and reuse the land for another purpose. Wanting to do this should be a well-intentioned, strongly supported decision. In AI terms, treat demolition as a consequential proposal needing a clear compelling reason rather than routine score churn. No numerical priority threshold, mandatory approval UI, refund/salvage recipe, demolition time or building-survival rule was selected.

Existing documented inactivity/grey claims do not automatically implement these additions. No gameplay changes performed. Next: Q052, abandoned claim loss/reassignment/restoration; account for the surviving-infrastructure principle without assuming it settles political ownership.

### Q052 — recorded answer, 2 November 2026

User: “Tile ownership gone if destroyed, tile contents remain, pops might be purged one at the time or all at once, simple abandonment just leaves the area neutral.”

Intended ownership: settlement destruction removes its territorial ownership, without automatically wiping surviving tile contents. Simple abandonment also leaves the area neutral. Former political registration should not continue to exclude reclamation on the abandoned/destroyed settlement's behalf. Surviving physical contents are distinct from territorial ownership and can persist under Q051.

Population loss during hostile destruction may happen individually or all at once; the wording leaves the method open, rather than selecting either as the final rule or requiring both modes. Do not apply population destruction to voluntary abandonment without an explicit rule. No automatic new captor ownership, movement of survivors, salvage, destruction timing, or contested-overlapping-claim resolution is specified.

This supersedes the desired permanent grey territorial retention for abandonment/destruction discussed in the earlier implemented prototype. Exact treatment of a temporarily empty but not abandoned/destroyed settlement remains to be distinguished before implementation; zero residents must not silently be assumed identical to deliberate abandonment. Existing grey-claim rules remain current code until changed. No gameplay changes performed.

Next: Q053, Culture spending on additional land versus other development; apply the established weighted proposal principle and clarify only the distinct choice if needed.

### Q053 — recorded answer, 2 November 2026

User: “Buy a tile when its part of an expansion plan; culture stockpiles might form when testing but later ideas should give some kind of desirable consumption mechanism.”

Intended purchase trigger: a tile belongs to an expansion plan, rather than automatic speculative spending solely because Culture is available. The answer does not define the required plan detail or insist that a worker must use the tile immediately. Do not equate tile-access expansion with founding a new settlement exclusively.

Accumulating Culture during tests is acceptable. Later content should introduce desirable uses; existing future policy/ideas-market suggestions (Q017) remain possibilities, not a finalized sink. No cap, decay, mandatory spending, exchange rate or new consumption system is selected. Recorded only; no gameplay changes.

Next: Q054, overlapping work access for settlements of the same civilization and the one-worker-per-tile rule.

### Q054 — recorded answer and comparison, 2 November 2026

User chooses the second option: a tile belongs exclusively to one settlement's working area until explicitly transferred, rather than either reachable friendly town using it freely. Preserve the one-worker-per-tile constraint. This changes desired semantics relative to the documented overlapping friendly local-access implementation.

User also asks whether this is generally preferred for Civ-like game development. Evidence checked: the official Civilization VI manual's Working the Land section states only one city can work a tile even where multiple city radii cover it. Source: https://downloads.2kgames.com/civilization/vi/manuals/eu/CIV_VI_25TH_ONLINE_MANUAL_ENG.pdf . Search extraction returned the relevant passage; direct PDF retrieval exceeded the web tool size limit. This supports a one-city-use convention, not a universal industry preference or full proof that every Civ-like title uses exclusive ownership with explicit transfers.

Assistant design judgment: exclusive assignment is a good fit for this project's governor roles and stable planning because each tile has an unambiguous responsible settlement and transfers become inspectable decisions. This is a project-specific recommendation, not empirical proof of superiority. Exact transfer cost, range/connectivity checks, occupied-job handling and district/building constraints remain open.

Recorded only; no gameplay changes. Next: Q055, when a forward settlement is safe enough to populate.

### Q055 — recorded answer, 2 November 2026

User agrees with assessing safety beyond the presence of an escort, while emphasizing the internal chain of command: planner provides settlement options with pros and cons; general scans for threats; leader decides.

Intended responsibility split: site suitability/opportunity analysis belongs to the planner, military danger assessment to the general, and authorization to the leader's ranked decision process. The planner must not independently claim final strategic safety authority merely because it can score terrain, and the general's input must feed the ruler's decision rather than bypass it automatically.

Nearby enemy strength, reinforcement access and possible evacuation were the suggested assessment dimensions, but no exact safety threshold, mandatory veto, force ratio or requirement for guaranteed evacuation is fixed. Q049's escort-to-garrison plan remains relevant, without treating it as sufficient proof of safety. A single implementation routine may organize these computations; separate mental responsibilities do not by themselves require independently running agents or additional personalities.

Recorded only; no gameplay changes. Next: Q056, reviewing a town's role after its original purpose disappears.

### Q056 — recorded answer, 2 November 2026

User supports changing settlement purpose and priorities when circumstances change, but wants to avoid sending extra population around the entire map merely to fill a newly chosen role. This is not a hard prohibition: if a person provides useful output, try to keep them there; if the civilization has a resource shortage, propose ways to produce more. Infrastructure and retraining should have priority to avoid “headless running around” in both population and military behaviour.

Intended adjustment policy: change goals without automatically uprooting functioning employment. Prefer developing capacity and appropriate qualifications locally where feasible, comparing such proposals with relocation instead of reflexively routing people to match every new role. Military reassignment likewise needs purpose and stability; the answer does not forbid deployment, retreat or justified reinforcement.

Read with Q037/Q038: useful current work deserves stability, but once a purposeful reassignment is made there is no obligation to return to an old job. Read with Q036: planned or opportunistic relocation is still legal, qualified now by a soft local-development preference. No maximum travel distance, permanent town-role lock, universal ban on migration, or exact cost multiplier is specified.

Recorded only; no gameplay changes. Next: Q057, when forest preservation is preferable to clearing.

### Q057 — recorded answer, 2 November 2026

User agrees to comparing forest yields/defensive value against clearing and to later technology increasing preservation value. When pollution becomes a serious system, there should be tools to lower it and clean it up; forests and preserves should be part of managing it.

Negative experience to avoid: the user's Civilization III endgames involved keeping conquered cities smaller and repeatedly cleaning newly generated polluted tiles. Record this as the user's experience/preference, not an independently verified universal description of another game's optimal strategy. The intended game should offer meaningful preventive/management choices, not rely on repetitive individual tile-cleanup chores or make keeping conquered cities small the forced solution.

Forests/preserves are desired environmental-management options. No preserve object definition, pollution absorption radius/rate, upkeep, cap, automatic cleaning, forest regrowth, or technology requirement is selected. Current removable pollution overlays and cleansing actions are implemented prototype mechanics; ongoing pollution generation, population-linked pollution and preserve mitigation remain future design.

This does not make every forest untouchable or pollution irrelevant: compare preservation, clearance and investment under actual authored effects. Recorded only; no gameplay changes. Next: Q058, choosing biome-specific improvement over generic Farm.

### Q058 — recorded answer, 2 November 2026

User: “Yes and yes.” Supports biome-specific advantages and potentially distinct technology/specialist requirements (fungal garden versus generic Farm was the example), with concrete distinctions refined through later content tests. No exact recipe, yield, eligibility, specialist gate or technology is fixed. Not every bespoke improvement must always outperform a generic one or require all example conditions. Recorded only; no gameplay changes. Next: Q059, additional value of environmental cleanup beyond restoring tile extraction.

### Q059 — recorded answer, 2 November 2026

User has no particular ideas for extra cleanup rewards now. Fighting off biomass may be preferable when securing existing or planned settlements because it advantages animals.

Intended link: evaluate removal/control of animal-supporting material as part of settlement safety/preparation, not only recovered human tile yield. No new health benefit, ideological reward, ecological-danger score or mandatory clearing radius is selected.

Terminology to preserve carefully: user says biomass broadly here; the documented prototype distinguishes consumable biomass patches from spreading xenomass/mat. They have different animal-support/extraction effects. Do not merge their content identities or assume an inactive xenomass combat bonus already functions. Future implementation should map the intended security task to the actual relevant layer and consequences. No new damage, spread, clearing or combat rule fixed.

Recorded only; no gameplay changes. Next: Q060, prioritizing clearing among pollution, obstacles and animal-benefiting layers, building on goal-linked priorities rather than assuming a fixed universal order.

### Q060 — recorded answer, 2 November 2026

User agrees that cleanup priority follows the affected land's purpose and the problem being solved: pollution reducing useful extraction, obstacles blocking planned construction, or xenomass supporting nearby animals. No universal ordering of layer categories is selected. Apply the established weighted-proposal framework to these concrete needs. No scoring formula, cleanup automation or extra effects specified. Recorded only; no gameplay changes. Next: Q061, human use of biomass patches versus animal-only use.

### Q061 — recorded answer, 2 November 2026

User: “Smac had such ideas but thats for a mid-late game testing and flourishing; perhaps a civilization wide transformation makes your pops accustomed and or mutated to like some form of biomass...????”

Human applications of biomass are a possible mid-to-late-game direction to explore through testing and content development. A tentative idea is a civilization-wide transformation through which population becomes accustomed or mutated to like some form of biomass. Preserve the speculative wording: this is neither a finalized transformation system nor a commitment to a particular benefit.

No decision yet about biomass as food, fuel, materials, research input, habitat, terrain bonus or any other specific use. No technology, cost, timing threshold, biological pathway, permanence, population coverage or tradeoff is fixed. The SMAC reference is the user's inspiration, not a verified specification to copy. Keep consumable biomass patches and spreading xenomass/mat distinct until future design explicitly identifies which material is affected (Q059).

Recorded only; no gameplay changes. Next: Q062, terrain transformations before large-scale terraforming, respecting Q002's later terraforming direction with specifics pending.

### Q062 — recorded answer, 2 November 2026

User: “Yes to all, smac allowed water and land tiles to be interchanged but thats a late stage idea to consider for flavour, but mid-late game should account for localised artificial environments or biome changes.”

The answer supports the proposed progression: early clearing of vegetation and planting forests, with drainage and more substantial terrain alterations associated with later technology. Exact unlock timing remains provisional; no technology roster or numerical gates are fixed.

Mid-to-late-game design should account for localized artificial environments and/or biome changes. These are intended future options to develop, without assuming a specific dome, enclosed habitat, biome-conversion recipe, radius, maintenance demand or ecological consequence. Artificial local conditions need not automatically mean physically replacing a tile's natural biome; that distinction remains to be designed.

Interchanging water and land is a possible late-stage flavour direction to consider, inspired by the user's SMAC reference, rather than a committed implementation requirement. Do not infer sea settlements, hydrology simulation or global climate manipulation from this answer. The historical reference is recorded as user inspiration, not independently verified here.

Recorded only; no gameplay changes. Next: Q063, how lost underlying tile yield should influence district placement.

### Q063 — recorded answer, 2 November 2026

User: “Yes, ill use civ 6 as inspiration here, though district itself gives something too, even unworked”.

District placement should sacrifice the tile's underlying natural yields, making the forgone extraction relevant to site choice. The district itself should also provide some benefit even when unworked. Compare the displaced natural output with the district's baseline benefit and potential staffed benefits rather than treating an unworked district as necessarily providing nothing.

Civilization VI is the user's inspiration, not an instruction to copy its full rules or an independently verified claim about its mechanics. No baseline yield type, amount, adjacency system, stacking rule, upkeep exemption or power requirement is selected. An unworked district is not necessarily an abandoned/empty settlement; this does not override Q051's provisional absence of practical services in an empty settlement or Q018's rejection of worthwhile one-person settlement spam. Those interactions require explicit treatment when implementing district benefits.

Recorded only; no gameplay changes. Next: Q064, strategic differences between routes beyond raw travel cost.

### Q064 — recorded answer, 2 November 2026

User: “Yes if ai structure supports having this consideration, if complicated in by itself, leave it as ai tuning idea for later”.

Supports considering route safety and terrain advantages as well as travel time, including the proposed civilian protected-route and military defensible-terrain examples, conditional on practical support in the AI structure. If this introduces substantial standalone complexity, defer it as an AI tuning idea. This is not a requirement to implement a sophisticated route planner before other development.

No route-scoring formula, risk tolerance, detour limit, guaranteed safety, new terrain combat effect or fixed civilian/military routing policy is selected. Existing architecture's suitability has not been freshly verified because source is unavailable; do not claim this consideration is already supported or decide its complexity from documentation alone. Recorded only; no pathfinding changes.

Next: Q065, district placement choices beyond cost, building on Q063's lost natural yield and unworked district benefit.

### Q065 — recorded answer, 2 November 2026

User: “Yes, again, civ 6 is a good inspiration”.

Supports district location affecting its benefits, beyond simply paying the cost and occupying available land. Nearby mineral deposits benefiting industry and unusual terrain benefiting research were illustrative possibilities in the question; exact relationships are not fixed by this general agreement. Read with Q063: placement compares district benefits, including its unworked baseline, with displaced natural extraction.

Civilization VI remains a design inspiration rather than a requirement to copy its full adjacency rules. No bonus values, qualifying features, distance, stacking, district-to-district interactions or implementation schedule is selected. Recorded only; no gameplay changes.

Next: Q066, expanding an existing workplace versus constructing another one.


### Q066 — recorded answer, 2 November 2026

User: “Yes, and opportunity costs and other complications if one option demands something thats missing and another doesnt”.

Upgrading an existing workplace and constructing another should both remain useful alternatives. The proposed distinctions—saving land or improving output per worker through upgrades, versus additional total capacity or development elsewhere through new construction—are supported as possible reasons to choose, not fixed properties of every building.

The comparison must include opportunity costs and complications, particularly requirements missing for one option but already available for the other. Judge the attainable path and what it displaces rather than comparing only final output or nominal construction prices. Missing technology, resources, staffing or infrastructure are examples to inspect where actually required; this answer creates none of those requirements by itself. It does not mandate automatically choosing the immediately available option over a valuable blocked upgrade. Relevant prerequisite remedies can compete under Q013/Q041/Q043.

No universal upgrade preference, cost formula, mandatory multi-step optimizer, building roster or numerical balance is selected. Recorded only; no gameplay changes.

Next: Q067, deliberate unused workplace capacity for future demand.


### Q067 — recorded answer, 2 November 2026

User: “Yes, depends on a plan being executed, sometimes lab is finished first, sometimes a scientist finishes training first, sometimes one does and another doesnt if something catastrophic interrupted the sequence”.

Unused capacity is acceptable as part of a plan being executed. Building construction and specialist training can complete in either order; neither must be held until both can finish simultaneously. A catastrophe can interrupt the sequence, leaving only one component finished. That outcome is possible rather than proof that advance preparation was inherently wrong. No fixed spare-capacity quota, speculative building mandate or automatic abandonment/demolition rule is specified. Relevant plans and demand can be reassessed under earlier principles.

This answer was retained in the conversation while the workspace was unavailable and is now saved with Q068. Recorded only; no gameplay changes.

### Q068 — recorded answer, 2 November 2026

User: “Yes, if it provides something by itself, it should cost something”.

An unstaffed building that provides an autonomous benefit should carry a cost. Read with Q063's unworked district benefit: passive output or services are not assumed free merely because no person is assigned. The question proposed reduced idle upkeep and full costs when active; the user's explicit condition establishes a cost for autonomous benefit without fixing a particular reduction or cost schedule.

Whether an idle building with no current benefit still has maintenance costs remains open. No exact resource, amount, proportionality, power rule or distinction between building and district upkeep is selected. Recorded only; no gameplay changes.

Next: Q069, priorities for keeping workplaces operating during power shortages; Q022 already proposes shutting down the hungriest installations, with ties requiring testing.


### Q069 — recorded answer, 2 November 2026

User: “Potentially; i think manual disabling should be an option to self regulate too”.

Protecting essential services or facilities critical to important plans from energy-shortage shutdown is a possibility, not a finalized priority hierarchy. Q022's provisional hungriest-first shutdown rule remains subject to testing and refinement; no specific exception or tie-breaker is fixed here.

Manual disabling should be available so the player can deliberately regulate operating demand, including before an automatic shortage response. This establishes an operating-control option, not demolition or loss of ownership. Exact disabled-state effects, residual upkeep, staff handling, reactivation timing/cost and whether automatic systems can override manual settings remain open. Q068's benefit-linked upkeep principle still applies; no free continuing output while disabled is specified.

Recorded only; no gameplay or interface changes. Next: Q070, distinguishing buildings that produce the same resource.


### Q070 — recorded answer, 2 November 2026

User: “Be offered such options but smac didnt... hmmm... maybe, if future balance testing suggest that solves an interesting problem”.

Treat alternative buildings producing the same resource through different worker, energy, input or terrain tradeoffs as a possible future design option. The user's conclusion is conditional: explore it if future balance testing suggests it solves an interesting problem. Do not convert the initial openness into a requirement that every resource or building tier needs multiple competing production models.

No particular building alternative, recipe, numerical advantage or problem to solve is selected. The SMAC remark is part of the user's reflection, not independently verified here. This leaves Q065's location-dependent district benefits and Q066's upgrade-versus-new-workplace choice intact, without requiring a new roster of equivalent producers.

Recorded only; no gameplay changes. Next: Q071, when a constructed building counts as a completed development project.


### Q071 — recorded answer, 2 November 2026

User: “No, a plan should have objectives but perhaps a plan can be eventually cancelled if fe a town is lost or the problem that the plan was made for is no more”.

The user rejects the question's categorical formulation and emphasizes objectives plus possible cancellation. Plans should have objectives, and may eventually be cancelled when circumstances invalidate their purpose—for example, loss of the relevant settlement or disappearance of the problem the plan was meant to solve. Do not force an incomplete plan to remain active indefinitely merely because its original benefit has not been delivered.

Distinguish an accomplished construction step, the broader plan's objectives, and cancellation because the objective is no longer relevant. Cancellation is not evidence that the original objective was achieved. This answer does not approve the proposed universal requirement to observe laboratory output before any development plan may be marked complete. Exact success criteria should follow the particular plan's objectives and remain to be specified where necessary.

Read with Q013: a still-important blocked goal can persist and pursue interim remedies; loss of relevance can instead justify cancellation. Q067's interrupted construction/training sequence remains possible without requiring automatic demolition, retraining or immediate cancellation. No fixed expiry timer, cancellation delay, refunds or handling of committed people/resources is specified.

Recorded only; no gameplay changes. Next: Q072, whether infrastructure benefits should extend between settlements.


### Q072 — recorded answer, 2 November 2026

User: “Civ 6 did that with power plants, a potential design idea”.

Infrastructure whose benefits extend to other settlements is a potential future design idea. The user cites Civilization VI power plants as inspiration; this historical comparison is recorded as their reference, not independently verified here. No regional system is committed for immediate development.

Power plants are the cited example. The answer does not specifically approve regional hospitals or research facilities, nor decide benefit range, roads/connections, distribution capacity, upkeep, stacking or which settlement controls allocation. Keep regional service effects distinct from the prototype's pooled resource accounting: shared stocks alone do not establish a regional infrastructure mechanic.

Recorded only; no gameplay changes. Next: Q073, recurring missions that justify passenger transports.


### Q073 — recorded answer, 2 November 2026

User identifies fast movement in mass as the main passenger-transport purpose. For initial testing, consider faster movement in areas without roads and rudimentary protection in combat. These are proposed test directions, not selected movement multipliers, armour values or passenger-survival rules. Fast group movement does not itself fix vehicle capacity or require large formations in every mission.

Ships are intended future content; people should require appropriate transport to cross water rather than swimming individually in full equipment. Helicopter transports are a possible later addition. No naval/air movement, embarkation, flight range, fuel or landing rules are specified or claimed to exist.

Future vehicle roles should differ: some are cargo transports only, some APC-like, and some primarily gun vehicles. Do not assume every vehicle carries passengers or that a combat vehicle is simply a transport with a weapon. Exact meaning and scope of cargo, freight accounting, capacities and equipment remain open; Q077 will address whether actual material freight is wanted. Current passenger transport mechanics do not already supply these future systems.

Read with Q030's plausible troop/transport/platform variety. Recorded only; no gameplay changes. Next: Q074, when road construction is worth undertaking before travel.


### Q074 — recorded answer, 2 November 2026

User: “Settlements and potential outposts, like a ring of bunkers, a future idea, should be connected quickly, road on every tile is neither a boon nor a cost, just not expected or desired”.

Settlements and potential outposts should receive road connections promptly. A ring of bunkers is a future outpost/defensive-infrastructure idea, not an existing object or a finalized ring-placement requirement. Read with Q049's road plan for new settlements.

Road coverage of every tile is neither an intended boon nor a cost in itself, and is not expected or desired. Favor useful links between destinations rather than treating universal road coverage as development completion. This does not introduce a blanket-road penalty, forbid useful additional roads, or remove their actual construction costs and movement effects. Exact road maintenance remains for Q075; do not interpret this answer as settling it.

No fixed construction deadline, universal road-before-departure rule, bunker specification or route-layout algorithm is selected. Recorded only; no gameplay changes. Next: Q075, road maintenance and persistence.


### Q075 — recorded answer, 2 November 2026

User: “Yeah... civ 5 did make the cost money, but previous civs and smac or be didnt, or else wed be also paying for pastures and farms... not at this time in development”.

Do not introduce ongoing road maintenance at the current stage of development. This is a present scope decision, not a permanent prohibition against reconsidering upkeep later. Construction costs and possible hostile damage remain separate questions; absence of recurring upkeep does not mean roads are indestructible or cost nothing to construct.

The comparisons with Civilization V, earlier Civilization titles, SMAC and Beyond Earth are the user's reasoning/reference, not independently verified historical claims here. The pasture/farm analogy does not authorize adding or removing upkeep for all other improvements. Preserve Q074's preference for useful connections rather than blanket road coverage without manufacturing a maintenance penalty to enforce it.

Recorded only; no gameplay changes. Next: Q076, the intended support a forward settlement can provide to an expedition.


### Q076 — recorded answer, 2 November 2026

User: “All of that plus defensive improvements”.

Supports the full proposed range of forward-settlement support: a defended place to gather, recover and receive reinforcements, with specialized buildings eventually enabling services such as faster healing, repairs and equipment changes. Defensive improvements are also desired. These purposes can contribute to the strategic value of a support site under Q050.

This is intended capability, not a claim that repairs, equipment changes, defensive structures or automatic reinforcement delivery already function. Exact services, prerequisites, costs, staffing, recovery rates and defensive effects remain open. Do not assume every newly founded settlement supplies all advanced services automatically. Read with Q051: an empty settlement provisionally offers no practical operating services. Read with Q074: connections and possible bunker outposts complement this role, without fixing a particular defensive layout.

Recorded only; no gameplay changes. Next: Q077, whether actual material freight is wanted rather than pooled resource upkeep alone.


### Q077 — recorded answer, 2 November 2026

User: “Pooled, though some town specific and empire specific pools might develop, food especially - that needs consideration”.

Resources should remain pooled rather than requiring routine physical shipment between settlements or to armies. Pool scope may later distinguish town-specific from empire-specific resources or accounting, with Food particularly needing consideration. This is an unresolved future distinction, not a decision that Food must already become local or that every resource needs both kinds of pool.

A local pool does not by itself imply cargo units, simulated freight routes or manual transfers. Distribution, sharing and shortages between future local pools remain unspecified. Q073's cargo-vehicle roles remain a future content idea with their precise cargo and missions open; do not use that idea to infer general supply logistics against this answer. Nor does this answer commit special-goods transport missions merely because the question offered them as an alternative.

Recorded only; no gameplay changes. Next: Q078, the intended appeal of visiting external sites compared with working or developing at home.


### Q078 — recorded answer, 2 November 2026

User: “Yes, but first tests should be resource exchanges while a merchant is visiting, trained or not; multiple neutral sites and outposts, city states even, bandit towns and camps in addition to existing animal nests”.

Supports the proposed broad possibilities for external-site value, but gives a concrete first test direction: resource exchanges while a merchant is physically visiting. Basic participation should not require being trained. The exact representation of an untrained visitor acting as merchant, and any advantages conferred by the trained Merchant profession, remain to be specified; do not assume the current profession-gated visit implementation already supports this distinction.

An exchange is distinct from arbitrary resource conversion or a free visit reward. Read with Q023: trading should involve a proper partner or actual means of generation. No prices, offered resources, stock limits, refresh intervals, repeat frequency, transaction action costs or automated trade route rules are fixed. The wording does not require continued trading after the visitor leaves.

Future world content should include multiple neutral sites and outposts, potentially city-states, plus bandit towns and camps in addition to existing animal nests. These are distinct site possibilities, not a requirement that every site trades, that bandits behave identically to animals, or that diplomacy/PvP already exists. Exact affiliations, hostility, capture, destruction and site economies remain open.

Recorded as design and testing direction only; no gameplay changes or test runs performed. Next: Q079, Explorer purpose, accounting for Q046's future fog of war and map-oriented specialization.


### Q079 — recorded answer, 2 November 2026

User: “Yes, lets get basics running and ai thinking well first, then handling roles and stuff will be much easier”.

Keep Explorer-specific activities provisional before fog of war and avoid inventing extra duties simply to force usefulness on the currently revealed map. The development priority is working fundamentals and sound AI decision-making; expanding and differentiating roles should be easier on that foundation.

Q046's future fog of war, map-oriented Explorer identity and possible movement/visibility/chassis specialization remain intended directions, not cancelled features or current requirements. This answer does not demand removing existing Explorer actions or postponing fixes needed for basic functionality. No new role roster or implementation batch is authorized by this clarification.

Recorded only; no gameplay changes. Next: Q080, civilian travel risk, escorts and route alternatives.


### Q080 — recorded answer and tentative combat idea, 2 November 2026

User: “Only if movement is guaranteed, like, three tiles via road, next tile theyre standing with, but otherwise take nearest shelter; also note a possibility of combat units having zone of control as in smac but this needs balance testing”.

Civilian travel facing a known threat should proceed only when the necessary movement is guaranteed; otherwise take the nearest shelter. The road example grounds this in concrete movement reach rather than mission value alone authorizing exposure. The precise destination/protection intended by “next tile theyre standing with” is not fully explicit: do not infer a fixed four-tile allowance, guaranteed combat immunity, escort proximity rule or a new movement mechanic from the wording. Operational definitions of shelter, guaranteed reach and threat exposure remain to be specified.

Combat units potentially exerting zones of control, with SMAC as inspiration, is a separate tentative idea requiring balance testing. No radius, movement restriction, interception, exception or implementation schedule is selected. Do not assume zones of control already exist or import the referenced game's full rules.

Recorded only; no gameplay changes or simulations. Next: Q081, what outcome qualifies a settlement as adequately defended.


### Q081 — recorded provisional answer, 2 November 2026

User: “I guess fixed number plus assembling reinforcements; perhaps outer or contested settlements get an increased garnison while deeper inside empire towns get bare minimum”.

Provisional defence policy: use a fixed baseline garrison together with assembling reinforcements. Outer or contested settlements may receive increased garrisons, while settlements deeper inside the empire retain a bare minimum. Preserve the tentative wording; exact numbers, how settlements are classified, reinforcement assembly locations/triggers and arrival requirements remain open.

This does not accept the assistant's proposed replacement of a fixed guard count with a universal withstand-until-reinforcements test. Threat assessment can inform later tuning, but no guarantee of surviving every known threat, mandatory defensive simulation, automatic interception or free reinforcement units is established. Additional troops must still fit the game's population, equipment and planning rules.

Recorded only; no gameplay changes or simulations. Next: Q082, whether protecting nearby civilians needs explicit screening or interception mechanics, with Q080's tentative zone-of-control idea as relevant context.


### Q082 — recorded answer, 2 November 2026

User: “First certainly, second situationally; this is where a ‘tactical’ manual of sorts comes in and it will be developed in in game stress testing”.

The first offered approach is accepted: positioning should matter to protection; civilians shelter behind troops but remain vulnerable if enemies can reach them. The second approach—nearby defenders intercepting attacks on civilians—is supported situationally, not as an unconditional automatic protection rule. Relevant conditions should emerge through in-game stress testing and be developed into a tactical manual of sorts.

Q080's zones of control remain a possibility requiring balance testing; this answer does not finalize their mechanics merely because the positioning option mentioned them. No interception radius, timing, eligibility, reaction budget or guaranteed redirection is fixed. The tactical manual is an intended evolving body of tested rules, not a claim that it already exists or that the controllers learn new rules autonomously at runtime.

Recorded only; no gameplay changes or simulations. Next: Q083, military strength retained at home during an offensive; Q081 already supplies baseline garrisons, leaving whether offensive plans may borrow them to clarify.


### Q083 — recorded tentative answer, 2 November 2026

User: “Maybe, needs situational testing and play analysis, maybe units above the first can sally in a pinch or to cover damaged units”.

Tentative option: garrison units beyond the first may sally out in an urgent situation or to cover damaged units. The suggestion implies retaining the first as an anchor in this candidate rule, but is not a finalized universal one-unit minimum. Situational testing and play analysis should determine suitable behaviour, in keeping with Q082's evolving tactical manual.

This does not grant blanket permission to borrow a settlement's garrison for a distant offensive, nor require replacements to be assembled before every sally. Exact urgency, range, return conditions, damaged-unit coverage and acceptable home exposure remain open. Q081's provisional larger outer/contested garrisons remain relevant.

Recorded only; no gameplay changes or simulations. Next: Q084, when to preempt a latent threat rather than wait for immediate danger.


### Q084 — recorded answer, 2 November 2026

User: “General should certainly propose threats but they will be one of possible problems a leader chooses to pursue”.

The general should identify and propose threats as problems for consideration. These compete with other possible problems in the leader's decision process; identifying a threat does not itself authorize an attack or automatically elevate it above other goals. This reinforces the established adviser-proposal/leader-authorization framework.

No fixed preemption trigger, threat-distance threshold, mandatory link to a specific development plan or requirement to eliminate every latent threat is chosen. The answer settles the authority and proposal principle rather than a numerical policy for when future danger deserves action.

Recorded only; no gameplay changes or simulations. Next: Q085, which exposed civilian activities should stop automatically when predators approach, building on Q080's movement/shelter rule and Q082's positioning protection.


### Q085 — recorded answer, 2 November 2026

User: “Yes” to: “Should any civilian within a predator’s next-turn attack reach automatically interrupt exposed work—road construction, gathering, founding—and seek shelter, unless positioning or protection makes staying safe?”

Accepted rule: civilians exposed to a predator's next-turn attack reach should automatically interrupt such work and seek shelter. Staying is permitted where actual positioning or protection makes it safe. Read with Q080's movement/shelter rule and Q082's positioning-based protection and situational interception; proximity to a friendly combat unit alone is not proof of protection.

Exact reach computation, shelter eligibility, escape choice when no safe shelter is reachable and work resumption conditions remain unspecified. This answer does not finalize zones of control or interception mechanics. Recorded only; no gameplay changes or simulations. Next: Q086, weighing protection of roads, worker groups and founders against town defence.


### Q086 — recorded answer, 2 November 2026

User: “All of that and towns are a priority overal; general should accept that not every vulnerable target will always be possible to save, hence trying to seek shelter first”.

Town defence has overall priority when protection is limited. The user also accepts considering likely losses and civilian-mission importance when assessing exceptions, as proposed in the question. No absolute town-first rule regardless of circumstances or fixed scoring weights are established.

The general must allow for some vulnerable targets being impossible to save. Civilian attempts to seek shelter are the first response, rather than depending on a guaranteed military rescue. Read with Q080/Q085 for movement and shelter, and Q081/Q083 for baseline garrisons and tentative urgent sallies. This does not imply deliberately abandoning a saveable target or sending rescuers into an equally futile loss. Exact feasibility tests, priorities among civilian targets and shelter fallback remain open.

Recorded only; no gameplay changes or simulations. Next: Q087, what makes a defensive retreat successful beyond merely moving closer to a settlement.


### Q087 — recorded answer, 2 November 2026

User: “Mostly first, continuing to retreat if pursued”.

Primary retreat aim: get beyond enemy attack reach, continuing to withdraw if pursuit maintains or renews danger. Merely getting closer to a town is not sufficient evidence of safety; the response must account for pursuit rather than treating one retreat move as completion.

The answer emphasizes the first part of the offered formulation. It does not require reaching a town, finishing healing or regrouping before a retreat can count as successful. Actual protection may still be useful under prior answers, but no mandatory destination, pursuit timeout, distance margin or unreachable-escape fallback is fixed.

Recorded only; no gameplay changes or simulations. Next: Q088, response to repeated civilian losses on the same frontier.


### Q088 — recorded answer and abandonment constraint, 2 November 2026

User: “All if it, abandoning settlements outright should be a last ditch resort and certainly not your last town”.

Accepts the proposed response to repeated frontier civilian losses: increase the priority of addressing the danger and discourage sending more civilians into the same conditions until protection, a safer route or another meaningful change is available. Read with Q084: higher priority feeds the leader's competing-problem decision process, rather than automatically authorizing a specific attack. No exact loss threshold, scoring increment or universal deployment ban is fixed.

Outright settlement abandonment should be a last-ditch resort. The civilization must not voluntarily abandon its last town. This constrains strategic abandonment; it does not make the final town immune to hostile destruction or establish that every threatened settlement must be held at any cost. Shelter-seeking and temporary withdrawals are distinct from outright abandonment. Read alongside Q032's evacuation question and Q051/Q052's persistence/neutral-territory rules.

Recorded only; no gameplay changes or simulations. Next: Q089, enemy information used to determine expedition size and composition.


### Q089 — recorded answer and starting test value, 2 November 2026

User: “All of that if coding for it doesnt confuse other ai player functions but to make deciding easier: a sum total of known and suspected enemy force power plus some margin, 25% as a starting testing value, to assemble and commit but tactical trials will clarify this”.

Supports known enemy numbers/types, terrain, likely enemy reinforcements and suitable weapon roles informing expedition sizing/composition, conditional on implementation not confusing or disrupting other AI player functions. The simplifying starting test rule is to assemble and commit against total known plus suspected enemy force power with a 25% margin: proposed expedition power target = 1.25 × estimated enemy power. This is a power comparison, not a headcount ratio.

The margin is explicitly a starting testing value, to be refined through tactical trials. Exact definition of power, scope of the enemy estimate, handling of suspected forces/reinforcements, terrain and weapon modifiers, rounding and reassessment remain open. Do not double-count the same suspected force as both known enemies and additional uncertainty. No guarantee that this ratio wins a battle is established. Leader authorization and existing home-defence/economic priorities remain applicable; satisfying a force estimate does not independently authorize a campaign.

Recorded only; no gameplay changes or simulations. Next: Q090, preparation delay and reconsideration of an otherwise feasible campaign.


### Q090 — recorded answer, 2 November 2026

User: “Always active goal but maybe not being executed, fe three nests nearby but not enough garrisons to feel safe before attacking any of those, or if attacking then maybe one or more but not all three at the same time”.

Distinguish persistent goal from current execution: a campaign goal remains active even when action is deferred. Insufficient home garrisons can prevent attacks on any nearby nest. Where capacity permits an offensive, select one or more targets without automatically launching against all nearby nests simultaneously. The three-nest example illustrates capacity and safety constraints, not a permanent cap of two concurrent campaigns.

No preparation timeout or cancellation solely for elapsed turns is chosen. Read with Q013/Q071: persistence through delay does not require executing an obsolete objective after its purpose disappears. Home-defence readiness, target selection and concurrent commitments should be assessed together; exact safety thresholds and allocation rules remain open. This answer does not require continuous spending on every active goal or give every goal equal priority.

Recorded only; no gameplay changes or simulations. Next: Q091, how much civilian economic activity an approved campaign may temporarily sacrifice.


### Q091 — recorded answer, 2 November 2026

User: “Emergencies should sacrifice growth and established setups, fe a settlement is soon to fall, but external expeditions should be less important than pure defense and survival”.

Urgent defence/survival needs can justify sacrificing growth and disrupting established arrangements, with imminent settlement loss as the concrete example. Do not treat productive assignments or existing development plans as untouchable when responding to such an emergency. External expeditions have lower priority than pure defence and survival.

This establishes a priority distinction, not a fixed mobilization percentage or a blanket sacrifice rule for every approved expedition. The answer does not separately authorize arbitrary food deprivation, operating shortages or destruction of infrastructure; exact emergency tradeoffs and limits should be assessed in context. Read with Q081/Q086/Q090 for home defence, town priority and deferred offensive execution.

Recorded only; no gameplay changes or simulations. Next: Q092, conditions for departure of a partially assembled force.


### Q092 — recorded answer, 2 November 2026

User: “Defend first, then attack when likely to win, grinding and not winning is wasteful”.

Defence takes precedence; offensive action should follow when it is likely to win. Avoid committing to prolonged fighting that fails to achieve victory or meaningful progress. This reinforces Q091's defence/survival priority and Q089's assessed force preparation, without turning the provisional 25% power margin into proof of victory.

The answer states the decision principle rather than a detailed partial-force departure rule. It does not explicitly settle early movement to safe staging areas, define a numeric win-probability threshold or forbid all costly battles. Distinguish defensive deployment from starting an underprepared offensive; mere availability of some assembled units is insufficient reason for an attack. Exact forecasting, stall detection and reassessment remain to be developed through tactical testing.

Recorded only; no gameplay changes or simulations. Next: Q093, production and assignment of replacements while the initial force is fighting.


### Q093 — recorded answer, 2 November 2026

User: “Maybe feed the front but if winning doesnt seem likely fall back and rebuild, increase expedition force”.

Direct reinforcement of the front is a possible approach, rather than requiring every replacement to wait for a newly assembled group. Preserve “maybe”: no unconditional individual-unit delivery policy is fixed. If winning no longer seems likely, fall back, rebuild and increase the expedition force rather than continuing to feed an unsuccessful fight. Read with Q092's rejection of wasteful grinding.

Exact replacement production triggers, staffing/equipment requests, safe delivery, strength increase and win-likelihood threshold remain open. Increasing the force is the intended response when rebuilding an inadequate expedition, not a specified increment or unlimited claim on defence/survival resources. Q089's 25% margin remains a starting test value, not a guarantee or permanent cap.

Recorded only; no gameplay changes or simulations.

### Q094 — resolved by Q092–Q093, 2 November 2026

Original question: “What should trigger reinforcement rather than full withdrawal and remustering?” Q093 directly addresses this choice: feeding the front is possible, but if winning seems unlikely, fall back and rebuild a larger expedition. Q092 establishes attacking when likely to win and avoiding unsuccessful grinding. Skip repeating the question; no additional user answer counted. Exact thresholds remain for tactical testing. Next: Q095, staging-location choice.


### Q095 — recorded provisional answer, 2 November 2026

User: “I guess at the closest settlement/outpost near the threat and then depart in full”.

Provisional staging policy: gather the expedition at the closest settlement or outpost near the threat, then depart as the full assembled force. The user chooses an existing support-site type rather than specifying an arbitrary field staging tile. Exact qualifying ownership, operational/safety checks, distance measure and fallback when no suitable site exists remain open. Do not infer a requirement to found a new outpost for every expedition.

“Depart in full” concerns assembly/departure of the expedition; Q093's tentative possibility of feeding later replacements to an ongoing front remains distinct. Full readiness should relate to the assessed expedition plan, including Q089's provisional strength target, without equating the target with guaranteed victory. Q091/Q092's defence-first priority remains applicable.

Recorded only; no gameplay changes or simulations. Next: Q096, avoiding conflicting preparation-worker and military-commissioning decisions.


### Q096 — recorded answer, 2 November 2026

User: “Yes” to reserving people assigned to necessary preparation until their task finishes, unless an emergency or explicit plan revision overrides that assignment. The example was recruiting an expedition road builder as a soldier and thereby leaving its necessary road unfinished.

Preparation commitments should prevent contradictory personnel assignments from repeatedly undoing the same plan. Reservations are task-bound, with emergency or deliberate revision overrides; they are not permanent ownership of a person. Read with Q091's emergency disruption of established setups and Q071's cancellation when a plan loses its purpose. Exact reservation representation, override authority and release handling remain implementation choices.

Recorded only; no gameplay changes or simulations. Next: Q097, intended rifle/flamer battlefield roles beyond range and damage modifiers.


### Q097 — recorded answer, 2 November 2026

User: “Rifles would be weaker range two terrain blockable support cohort where flamer is a range one only ranged attack unit, much better at firing first and against animals but otherwise vulnerable to damage”.

Intended roles: rifles are a weaker support cohort with range two, whose ranged fire can be blocked by terrain. Flamers are range-one, ranged-attack-only units, much better at firing first and against animals, but otherwise vulnerable to damage. Do not recast flamers as durable melee assault troops or assume a unique nest-clearing action from the previous question's suggestion.

“Firing first” describes the desired combat advantage; exact initiative, retaliation, preemptive fire or action-order rules remain unspecified. The answer does not grant automatic interception or a named first-strike mechanic. Exact damage/strength, animal bonus, rifle comparison baseline, flamer vulnerability, terrain blockers and range/line-of-sight rules remain to be tested and authored. These are intended roles, not a fresh audit of current implementation.

Recorded only; no gameplay changes or simulations. Next: Q098, which supporting forces can actually contribute when deciding to advance or charge.


### Q098 — recorded provisional answer, 2 November 2026

User: “Good question, assume first but needs tactics testing”.

Provisionally count only allies that can actually contribute in time when deciding whether to advance or attack, considering movement, remaining actions, weapon range and terrain blocking, rather than all nearby friendly units. This accepts the first offered approach as a test assumption, not a finalized support-evaluation algorithm.

The relevant timing horizon, contribution estimates, treatment of next-turn support and coordination must be refined through tactical testing. Read with Q097's terrain-blockable rifle support and short-range vulnerable flamers. No automatic coordinated attack, interception or guaranteed support is introduced by this answer.

Recorded only; no gameplay changes or simulations. Next: Q099, choosing between finishing a wounded enemy and attacking a more dangerous healthy one.


### Q099 — recorded answer, 2 November 2026

User: “Yes” to generally favouring a likely kill that removes an enemy's next action, unless a more dangerous enemy poses an urgent threat; the example was a healthy predator about to reach a vulnerable flamer or civilian.

Targeting should normally value removing an enemy's ability to act, while allowing urgent protection against a more dangerous target to take precedence. This is a conditional preference, not an unconditional lowest-health-first rule. Exact probability thresholds, danger estimates and target scoring remain open. Read with Q098: only feasible attacks and support should contribute to the assessment.

Recorded only; no gameplay changes or simulations. Next: Q100, accepting casualties to close range or complete an objective.


### Q100 — recorded answer, 2 November 2026

User: “Yes” to accepting likely losses when doing so makes victory or saving a settlement likely, while avoiding sacrifices that merely prolong an unsuccessful fight; acceptable cost depends on the objective's importance.

Casualty avoidance is not absolute: purposeful losses can be justified by likely success or settlement rescue. This does not authorize unlimited casualties merely because an objective is important. Exact cost assessment, casualty budgets and victory thresholds remain open, to be refined with tactical testing and the existing defence/survival priorities. Read with Q092/Q093's avoidance of unsuccessful grinding and fallback/rebuilding policy.

Recorded only; no gameplay changes or simulations. Next: Q101, whether the three-unit tile preference should be relaxed for offensive concentration.


### Q101 — deferred to tactical testing, 2 November 2026

User: “Needs tactical testing because smac had no cap but brutal penalties if land unit killed one stacked unit and bombardment damaging anything in a tile and later civs having one unit per tile but pre civ 5 allowing stacks and being more forgiving...”

Do not finalize whether to relax the documented soft three-combatant tile preference. Stacking and concentration need tactical testing. The user contrasts uncapped stacks with severe consequences for stacked units and tile bombardment, one-unit-per-tile approaches, and more forgiving stacks as considerations for that testing.

These comparisons are recorded as the user's recollections and design references, not independently verified specifications of SMAC or Civilization. No particular cap, collateral-loss rule, bombardment system, stacking penalty or adoption of another game's model is selected or authorized for implementation. Q101 is addressed in the interview but its mechanical choice remains deferred.

Recorded only; no gameplay changes or simulations. Next: Q102, coordination of shooters, close attackers and arriving reinforcements.


### Q102 — recorded answer and role clarification, 2 November 2026

User: “Yes, exactly, and lieutenant is a sort of group of units as a task force, that task force might be small or even one unit, or eliminated; general is the planner role”.

Accepts lieutenant-level coordination of support positioning, firing, advancing and incorporation of reinforcements, avoiding individual units rushing ahead independently. Actual tactical sequences should develop through trials rather than being fixed solely by this answer.

The lieutenant is the tactical role associated with a task-force grouping, not necessarily a separate physical officer unit. A task force can be small, including a single unit, and can be eliminated. The general is the planner role, distinct from local task-force execution. This clarifies intended responsibility and grouping, not a claim about exact current code objects. No minimum force size, fixed formation, new personnel cost or autonomous learning system is implied.

Exact handling of an eliminated task force—closing its record, replacing it or retaining a broader objective—remains open under the existing persistent-goal/replanning principles. Recorded only; no gameplay changes or simulations. Next: Q103, retreat routing when safety leads away from the objective.


### Q103 — possibility pending testing, 2 November 2026

User: “Possibly, needs testing” to allowing the lieutenant to choose the safest viable retreat route even away from the target or staging settlement, leaving the general to reorganize the campaign afterward.

Retain this as a candidate tactical policy, not unconditional authorization or a finalized safety-versus-objective hierarchy. Test whether local retreat discretion and later campaign reorganization produce useful behaviour. Q087's accepted aim of escaping attack reach and continuing withdrawal under pursuit remains relevant; this answer leaves the route tradeoff open.

No route score, maximum displacement, regrouping rule or mandatory return path is fixed. Recorded only; no gameplay changes or simulations. Next: Q104, when to occupy the nest rather than continue fighting elsewhere.


### Q104 — recorded answer, 2 November 2026

User: “Yes, if the unit is not expected to die on enemy turn” to prioritizing reachable nest occupation, disabling nest activity, over fighting nearby animals even when some remain alive.

The lieutenant should normally take the occupation opportunity when the occupying unit is not expected to die during the enemy turn. Surviving animals do not by themselves require clearing every other target first. The survival condition explicitly qualifies the priority; do not treat a sacrificial occupation as approved under this rule merely because it would briefly disable the nest.

Exact survival forecasting, probability threshold and support accounting remain open. Read with Q098's feasible-support assessment. This is intended decision policy, not new nest destruction/persistence rules or a fresh code verification. Recorded only; no gameplay changes or simulations. Next: Q105, wildlife's intended long-term role.


### Q105 — recorded answer and future wildlife directions, 2 November 2026

User: “All of it and maybe even become a controllable force, one psi user per nest at the time; there should be land and sea species, even fliers; nests would evolve, build static defenses, maybe seed new ones”.

Supports overlapping wildlife roles: an early obstacle, persistent regional danger that stronger civilizations can contain, and new threats/opportunities as play develops. These need not characterize every species or every region identically.

Desired future content includes land and sea species and fliers. Nests should evolve and build static defences; seeding new nests is a tentative possibility. No species roster, evolution schedule, defence type, construction economy or expansion rate is fixed. Evolving nests do not by themselves settle whether unchecked growth is unlimited, capped or reversible; Q106 remains useful.

Possible future psi control could turn wildlife into a controllable force, with one psi user per nest at a time in that candidate design. Exact control scope (nest, its animals or both), acquisition, presence/range requirements, training, upkeep, loss of control and competing claims remain unspecified. Preserve this as a possibility, not an implemented system or a rule that every nest must already contain a psi user. It supplies a potential alternative to extermination relevant to Q107 without closing all alternative-interaction design.

Recorded only; no gameplay changes or simulations. Next: Q106, progression and limits of an ignored nest.


### Q106 — recorded answer and possible resource uses, 2 November 2026

User: “First option, if theres no food, nest remains small, other non human civilization resources might be used by the nest, like culture for extra units allowed or similar”.

Chooses resource/condition-dependent development: available food, minerals and territory can support growth, plateau or decline rather than nests strengthening simply because turns pass. Explicit example: without food, a nest remains small. This does not specify starvation damage, automatic nest death or exact decline mechanics.

Other resources may also serve nest development. Culture increasing the number of units allowed is a tentative example, not a fixed rule or numerical capacity formula. The phrase about non-human civilization resources does not establish automatic access to human stocks, stealing, trade, a full duplicate human economy or identical meanings for every resource. Resource acquisition, use, capacity and other development costs remain to be authored and tested.

Read with Q105's evolving nests and possible expansion: development needs actual enabling conditions, not a blanket elapsed-turn escalation. Recorded only; no gameplay changes or simulations. Next: Q107, alternatives to exterminating nests, with possible psi control already noted in Q105.


### Q107 — recorded future direction, 2 November 2026

User: “Potentially, with advanced bio techs options should emerge, perhaps domestication or pacificstion”.

Containment, bypassing and leaving a nest alive remain potential choices. Advanced biology technologies should open alternatives to extermination, with domestication or pacification as tentative examples. Q105's possible psi control is another candidate; do not silently merge biological pacification/domestication with psi control or impose its one-user-per-nest condition on all alternatives.

No specific technology, unlock timing, acquisition procedure, upkeep, permanence, hostility reduction, breeding benefit or controllable-unit roster is chosen. This records a future content direction, not a requirement to implement peaceful interactions before basic AI and combat work reliably.

Recorded only; no gameplay changes or simulations. Next: Q108, how disrupting larvae or forage should affect nest military capability.


### Q108 — recorded answer, 2 November 2026

User: “Yes” to killing larvae or disrupting forage reducing nest gathering and replacement capacity through actual resource shortages rather than applying an additional abstract combat penalty to surviving animals.

Intended weakening follows the nest economy and its resource dependencies, consistent with Q106. The answer adds no automatic morale/strength debuff to surviving animals merely because larvae or forage were lost. Exact gathering losses, reserve buffering, replacement costs and timing remain unspecified; disruption need not instantly stop production while adequate resources remain.

Recorded only; no gameplay changes or simulations. Next: Q109, surviving animals and xenomass after nest destruction.


### Q109 — recorded answer and possible human-controlled nest founding, 2 November 2026

User: “First option, though if all nests are destroyed, perhaps a controlled specimen can be used to make new human controlled ones”.

Surviving animals remain active and xenomass persists after nest destruction, requiring separate handling. Nest loss does not by itself trigger their automatic decline or removal. This does not cancel any separately authored ordinary resource or environmental effects. Keep xenomass/mat distinct from consumable biomass patches.

Tentative future idea: if all nests have been destroyed, a controlled specimen could be used to establish new human-controlled nests. This could preserve access to controlled wildlife without requiring a surviving wild nest. It is not yet specified whether total nest destruction is an exclusive prerequisite, merely the motivating example. Exact specimen eligibility, founding costs/location, technology, consumption, ownership and ongoing control remain open. Read with Q105/Q107's possible psi control, domestication and pacification without assuming those alternatives have identical requirements.

Recorded only; no gameplay changes or simulations. Next: Q110, animal discrimination between vulnerable civilians and armed formations.


### Q110 — recorded answer, 2 November 2026

User: “Second option” to the choice between a broadly shared selective-attack policy and behaviour varying substantially by species.

Animal attack behaviour should vary substantially by species. Prey selection, caution around armed formations, nest defence and group attacks can be differentiated through species rules rather than assumed identical for all wildlife. The answer does not accept the entire first option as a universal policy, nor specify which species has which behaviour.

Exact species roster, perception, risk assessment and behavioural parameters remain open. Recorded only; no gameplay changes or simulations. Next: Q111, nest difficulty across scenarios with different starting economies.


### Q111 — recorded answer, 2 November 2026

User: “First option” to nest difficulty following species, starting conditions and available resources, with scenario settings determining challenge, rather than nests automatically adjusting to human civilization strength.

Use authored scenario/world conditions and the nest's own development to produce difficulty. No automatic strength matching to human civilization is selected. Read with Q106's resource-dependent growth and Q110's species variation. Exact scenario presets, starting quantities and balance values remain open.

Recorded only; no gameplay changes or simulations. Next: Q112, making animal victory or human defeat a meaningful outcome rather than prolonged replacement deaths.


### Q112 — recorded answer, 2 November 2026

User: “Yes, full wipe, animals vs humans, humans vs humans”.

Accepts settlement destruction and ultimate civilization defeat, with full elimination possible in both wildlife–human and human–human conflict. Also accepts the question's principle that the AI should recognize a failing strategy and attempt defence, withdrawal or rebuilding rather than endlessly producing units to die. Full defeat remains possible despite these attempts.

Q088's rule against voluntarily abandoning the last town does not protect it from hostile destruction. Exact elimination conditions (settlements, remaining population/units and recovery opportunities), victory reporting and inter-human warfare mechanics remain unspecified. Human–human conflict is intended future scope, not a claim that PvP already functions or an instruction to implement it now.

Recorded only; no gameplay changes or simulations. Next: Q113, tactical mistakes the programmed player should recognize and correct within a match.


### Q113 — recorded answer, 2 November 2026

User: “Second option” to the choice between within-match learned correction of tactical mistakes and keeping some such behaviours as fixed tactical rules refined between test runs.

Prefer authored tactical rules refined through testing between runs for problems such as advancing without usable support, exposing flamers, underestimating enemy reach and repeatedly committing inadequate forces. Do not make autonomous within-match learning a requirement for these corrections. The question said “some”; this answer does not by itself ban all future memory/adaptation or authorize removal of existing bounded adjustment code.

Authored rules can still assess current circumstances, change targets, retreat or request larger forces during play under prior answers. Distinguish situational decisions under stable rules from changing the rules through experience. No implementation changed. Q114 onward should respect this scope rather than presuppose an accepted learning system.

Recorded only; no gameplay changes or simulations. Next: Q114, evidence for adopting a caution, reframed around between-run tactical testing.


### Q114 — recorded answer, 2 November 2026

User: “Exactly” to requiring repeated failures with an identifiable cause before adopting a tactical caution, then checking that the proposed fix helps without blocking useful actions elsewhere. A single unlucky combat result is insufficient.

This is an evidence standard for between-run tactical-rule refinement under Q113, not approval of an autonomous within-match learning system. Inspect the cause and the consequences of the proposed fix, including unwanted restrictions in other relevant situations. Exact trial counts, scenario coverage and statistical thresholds remain unspecified.

Recorded only; no gameplay changes or simulations. Next: Q115, distinguishing terrain effects from the strength of enemies occupying that terrain.


### Q115 — recorded answer, 2 November 2026

User: “Yes” to tactical assessment using actual terrain effects and enemy capabilities separately, recognizing for example that a heavy predator caused a loss rather than treating every forest tile as dangerous because the fight happened in one.

Distinguish causal combat factors from location-only associations in both assessment and between-run analysis. Separate factors can still interact: real terrain defence, movement or fire blocking must be considered where authored, without blaming a terrain category for enemy strength alone. Read with Q113/Q114; this does not itself require autonomous causal learning during matches.

Recorded only; no gameplay changes or simulations. Next: Q116, reassessing caution when relevant circumstances change.


### Q116 — recorded answer, 2 November 2026

User: “Yes” to reassessing caution when relevant conditions change—stronger forces arrive, a dangerous enemy leaves or a route becomes protected—instead of continuing to avoid an opportunity solely because it was previously unsafe.

Evaluate the current applicability of a protective rule rather than preserving a stale unsafe judgment indefinitely. A changed condition triggers reassessment, not guaranteed safety or automatic execution. This fits Q113's situational decisions under authored rules and does not require within-match rule learning. No fixed expiry, decay rate or reassessment interval is specified.

Recorded only; no gameplay changes or simulations. Next: Q117, persistence of rules versus match-specific history, respecting Q113's between-run refinement preference.


### Q117 — recorded answer and correction to proposed reset framing, 2 November 2026

User: “Actually, a mounting body of experiences should be remembered in aggregate for tests to use for reference”.

Preserve an accumulating aggregate body of experience across test runs for tests and analysis to reference. Do not discard all historical evidence at every new match as the question's reset framing might suggest. The answer specifies persistent reference evidence, alongside Q113/Q114's tested refinement of authored tactical rules.

Retaining evidence is distinct from automatically teaching each fresh civilization facts about another match's map, carrying active plans into a new world or autonomously changing shared rules from outcomes. Those mechanisms are not specified here. Exact aggregation fields, case/context separation, source-run provenance, storage format and retrieval methods remain design/implementation choices. Outcomes must remain interpretable in their conditions; Q114/Q115's evidence and causal distinctions still apply.

Recorded only; no gameplay changes, aggregate dataset creation or simulations. Next: Q118, controlled experimentation, framed around test runs rather than assuming autonomous in-match learning.


### Q118 — recorded answer, 2 November 2026

User: “First with second being an option to test if ai can manage it”.

Default: explore uncertain tactics in dedicated test scenarios while ordinary AI play follows the best available rules. Limited experimental risks during normal matches remain an option to test, conditional on the AI managing them competently. Do not turn this conditional option into mandatory live experimentation or unlimited sacrifices for information.

Exact experiment selection, risk bounds, success criteria and learning/update mechanism remain open. Read with Q113/Q114's between-run rule refinement and Q117's persistent aggregate evidence. Recorded only; no gameplay changes or simulations. Next: Q119, explaining rejection of an apparently useful legal action.


### Q119 — recorded answer, 2 November 2026

User: “Yes” to decision logs naming the concrete reason an apparently useful legal action was rejected and what would make it worth reconsidering. Examples offered: reserved workers, inadequate support, endangered home defence or a higher-priority proposal.

Logs should expose the actual applicable reason and relevant reconsideration conditions, distinguishing legality from current strategic choice. A lower-ranked proposal is not necessarily mechanically blocked. Exact format, detail level and logging coverage remain open; do not invent an explanation unsupported by the controller's actual decision path.

Recorded only; no gameplay changes or simulations. Next: Q120, detecting when a protective rule persistently obstructs an objective.


### Q120 — recorded answer, 2 November 2026

User: “Yes” to repeated blocking of an important goal by the same safety rule, without progress, triggering review of the blocker and practical remedies—more troops, another route, different equipment or revised timing—while keeping the goal active instead of simply ignoring the rule.

Protective constraints should lead to inspectable enabling proposals when they prevent progress, rather than silent permanent paralysis or automatic unsafe execution. The examples are possible remedies, not mandatory additions to every plan. No stall duration, scoring threshold or blanket guarantee that a remedy exists is selected. Goal persistence remains subject to Q071's loss-of-purpose cancellation and Q090's distinction between active goal and current execution.

Recorded only; no gameplay changes or simulations. Next: Q121, measured outcomes used to judge controller improvements.


### Q121 — recorded answer, 2 November 2026

User: “Yes” to judging controller changes through objective completion, survival and losses, time and resources spent, economic development and stalled turns together. Winning faster at ruinous cost or surviving by doing nothing does not automatically count as better play.

Evaluate tradeoffs across relevant outcomes rather than treating a single metric as universal proof of improvement. No numeric weights, aggregate score, fixed stall definition or mandatory pass threshold is selected. Interpret deliberate preparation/deferral in context under Q090 rather than counting every non-attacking turn as failure.

Recorded only; no gameplay changes or simulations. Next: Q122, controlled scenarios needed before declaring a mechanic AI-supported.


### Q122 — recorded answer, 2 November 2026

User: “Yes” to testing that the AI recognizes when a mechanic is useful, obtains its prerequisites, executes it, handles interruption and declines it when unsuitable, including at least one ordinary-game demonstration beyond a specially supplied test.

These are evidence requirements before declaring the mechanic AI-supported, not a claim that existing mechanics already meet them. Supplied fixtures remain useful for isolating behaviour but cannot alone demonstrate ordinary prerequisite acquisition and integration. An ordinary-game demonstration establishes observed use within its conditions, not reliable performance across all situations or balance. Exact test counts beyond that minimum and scenario selection remain open.

Recorded only; no gameplay changes or simulations. Next: Q123, variation across seeds and starting positions before drawing balance conclusions.


### Q123 — recorded answer and initial testing scope, 2 November 2026

User: “Yes and before full map generations (which obviously need to become a thing, also ui/art will take many updates) well initially stay in the first map with the intention of whether ai can understand the tools and mechanics its given”.

Accepts an adaptive later test breadth: manageable variation in seeds/starting positions, expanded when outcomes vary or expose edge cases, with balance conclusions provisional until supported across meaningfully different conditions. No fixed large upfront count is selected.

Immediate phase remains on the first map, testing whether the programmed AI can recognize and use its supplied tools and mechanics. Do not make broad map-generation coverage a prerequisite for fixing foundational competence on this map. Conversely, first-map competence alone is not proof of general balance. Q122's ordinary-game evidence and targeted scenarios remain compatible with this initial map scope.

Full map generation is intended future development. UI/art are expected to take many iterations. Neither statement is an instruction to implement those systems in this design interview. Exact generator scope, variation schedule and art/UI work remain open. Recorded only; no gameplay changes or simulations. Next: Q124, interface visibility of plan and action states.


### Q124 — recorded conditional approval and log-retention policy, 2 November 2026

User: “Assuming it doesnt consume my cloud storage (30 gb), sure, but also a periodic cleanup of old test run logs, perhaps 5-10 max saved runs at the time because older tests become useless as builds advance and assumptions change”.

Accepts an inspectable plan view distinguishing proposed, approved, preparing, ready, executing, blocked, completed and cancelled, with targets, assigned people/resources and current blockers, alongside a simpler ordinary-interface summary. Approval is conditional on avoiding a material storage burden; the user's stated 30 GB capacity is context, not verified quota or available-space measurement. Do not promise zero storage use or infer that UI inspection requires indefinitely saving every state.

Periodically clean up older test-run logs, provisionally retaining approximately 5–10 runs at a time. Older runs can lose relevance as builds and assumptions change. Exact count within that range, byte limits, cleanup cadence and relevance/version criteria remain open. A count alone does not bound disk consumption if individual runs become very large.

Read with Q117: maintain a compact aggregate body of useful experience for reference while pruning detailed raw-run logs, preserving enough build/assumption context to avoid treating obsolete findings as current evidence. This is a reconciliation of the two stated aims, not a commitment to retain all obsolete detail. The scope is generated test-run logs, not source, user game saves, design records or unrelated files. No storage inventory, deletion or retention implementation performed in this design interview.

Recorded only; no gameplay changes or simulations. Next: Q125, human overrides compatible with delegation.


### Q125 — recorded tentative, low-priority option, 2 November 2026

User: “Probably, not a priority to implement, but maybe if that becomes useful” to human overrides of delegated decisions, return to AI control and respecting explicit human assignments until release/completion.

Retain the proposed override/delegation interaction as a possible later feature, conditional on usefulness and not an implementation priority. Do not treat the tentative answer as a finalized requirement to support every override immediately or settle all assignment persistence and conflict rules. Existing manual controls are not audited or changed here.

Recorded only; no gameplay changes or simulations.

### Q126 — resolved by earlier answers, 2 November 2026

Original question: “What evidence should accompany each new content item before it joins ordinary autonomous play?” Q122 already establishes the relevant AI-support evidence: useful recognition, prerequisite acquisition, execution, interruption handling, suitable rejection and at least one ordinary-game demonstration beyond supplied fixtures. Q114 supplies the causal/repeated-evidence standard for cautions, and Q121 the multi-outcome evaluation principle. Apply these existing standards to content integration rather than ask the same evidence question again.

No extra user answer counted, fixed test quota or requirement that every content item be used in every game is introduced. Q045 permits placeholders while testing; experimental inclusion must remain distinguishable from demonstrated AI support. Next: Q127, scenario objectives versus general civilization competence.


### Q127 — recorded answer, 2 November 2026

User: “Scenarios for testing if i suggest or approve one, but final goal is an ai player that can deterministically ‘understand’ any situation its in and develop to the best of its circumstances”.

Use test scenarios when the user suggests or approves them. The ultimate aim is a general deterministic AI player that assesses the situation it encounters and develops as effectively as its circumstances allow. Test objectives are instruments for evaluating that competence, not substitutes for it. Do not infer approval of a new scenario merely from discussing the general testing process.

“Understand” is the user's functional goal for programmed assessment/planning, not a request for GPT instances or a claim of literal universal understanding. “Any situation” expresses the generality ambition within the game's supported rules, not proven optimality, omniscient access to hidden information or implemented coverage of future mechanics. Scenario completion alone does not establish broader competence.

Recorded only; no gameplay changes or simulations. Next: Q128, what must be settled before the next gameplay implementation batch.


### Q128 — recorded synthesis and sequencing request, 2 November 2026

User: “Oh, i was waiting to get to this summary phase! First, make sense of my answers in a form of four actionable idea bins: game start, early, middle and end games with ideas within being judged by usefulness and relevance; then use the totality of smac, be and ai material already collected for and in this project to add to the piles if interesting and then make another round of clarification/direction questions; after those clarificstions we can compare the four stages with existing ‘frankestein’ and decide upon a plan of action of fixing and adding things”.

Authorized sequence: (1) synthesize the interview into game-start, early-, middle- and endgame idea bins with usefulness/relevance judgments; (2) use the project's collected SMAC/SMAX, Beyond Earth/Rising Tide and AI reference material to propose interesting additions; (3) conduct another clarification/direction round; (4) after those clarifications, compare the intended stages with the existing implementation and agree a fixing/adding plan. This is not authorization to start gameplay implementation or run new scenarios now.

Preserve firmness/tentativeness and distinguish user decisions from assistant stage placement, rankings and source-derived recommendations. Synthesis document: `Alien_Planet_Four_Stages_Design_Synthesis_2026-11-02.md`. It includes 53 stage entries, 16 selected reference contributions, parked ideas, unresolved interfaces, a source register and D001–D020. This record remains the authoritative answer ledger for both rounds.

Original interview complete: 128 IDs addressed, 125 directly discussed and three resolved by earlier answers (Q047, Q094, Q126). The new round does not renumber or replace the original questions. Recorded and synthesized only; no gameplay changes, simulations, log cleanup or source/build comparison performed.

## Second clarification round — four-stage direction

Based on `Alien_Planet_Four_Stages_Design_Synthesis_2026-11-02.md`. Stage IDs GS/E/M/L and source recommendations A01–A16 are review references, not accepted implementation commitments. Ask one question at a time and record answers below this queue.

| ID / state at creation | Focused question | Why it changes the synthesis |
|---|---|---|
| D001 • Provisional opening recorded, 2 November 2026 | Does an ordinary game open with a mobile landing group choosing its first settlement site, or with a small established settlement and workforce already in place? | Defines the distinct game-start loop, inherited assets and initial AI duties. |
| D002 • Recorded, 2 November 2026 | Should stage changes describe achieved capabilities and circumstances, without formal global era unlocks or fixed turn dates? | Makes these four bins a useful progression model rather than an unchosen rigid era system. |
| D003 • Provisional hybrid and growth cap recorded, 2 November 2026 | For the first coherent play arc, keep Food empire-pooled or introduce a town-level Food account; if local, what can share it and how abstractly? | Resolves the largest accounting dependency without presuming freight. |
| D004 • Recorded, 2 November 2026 | What recurring advantage should developing an existing town offer over another minimally staffed settlement: access to advanced capacity, efficiency, protection, or a combination? | Chooses the first practical anti-spam/tall-development lever; exact values can wait. |
| D005 • Recorded provisional timing, 2 November 2026 | For functioning research prerequisites, is a current operating snapshot enough, or must a capability have produced successfully before it qualifies? | Clarifies timing and avoids hidden demonstration histories or impossible gates. |
| D006 • Recorded, 2 November 2026 | What counts as civilian shelter initially: a defended settlement/outpost, a tile occupied by suitable troops, or either only when estimated enemy reach cannot kill the civilian? | Converts Q080/Q085 protection intent into a testable safety concept. |
| D007 • Recorded starting policy, 2 November 2026 | Should the initial garrison policy be a simple town/frontier baseline plus threat-triggered reinforcement, with numbers chosen in tactical trials? | Bridges fixed garrisons and contextual home safety without requiring a full battle simulator. |
| D008 • Recorded, 2 November 2026 | When army composition changes after losses, should the general re-estimate required power and useful weapon roles before another offensive wave? | Connects the 25% starting rule to rebuilding and avoids endlessly reusing an obsolete template. |
| D009 • Recorded testing order, 2 November 2026 | Which uncertainty should tactical trials resolve first: range/support timing, protection/retreat, or stacking/control? | Selects the most informative first tactical question; a concrete scenario still needs approval. |
| D010 • Proof-of-concept rule recorded, 2 November 2026 | What first benefit should a trained Merchant add beyond an untrained visitor's basic exchange: better offers, more capacity, information, or another service? | Makes training useful without blocking the agreed basic trade test. |
| D011 • Provisional layered map knowledge recorded, 2 November 2026 | What broad geography is known initially, what must be explored locally, and what does identifying an anomaly reveal or enable? | Distinguishes possible continent outlines from terrain knowledge and live fog; gives Explorer/anomalies a purpose without a large roster. |
| D012 • Health and accumulating pollution rules recorded, 2 November 2026 | What first concentration pressure is worth representing, and what unique benefit should make a larger town worth that pressure? | Designs costs and rewards together instead of adding punitive upkeep alone. |
| D013 • Animal-control priority recorded, 2 November 2026 | Of native interaction, biome-specific production and habitat engineering, which should first distinguish middle-game development? | Chooses a substantive specialization fork. |
| D014 • Technology progression recorded, 2 November 2026 | Should pacification, domestication and psi control grant different degrees of influence, and what does one psi user control at a nest? | Prevents several attractive terms becoming the same unexplained mechanic. |
| D015 • Ecology-first direction recorded, 2 November 2026 | Which two or three endgame ambitions most interest you: ecological coexistence/restoration, industrial/technological development, biological/cybernetic transformation, political/military control, or another direction? | Selects an initial destination from the rich late-game possibility set. |
| D016 • Discussed; ecology additions and world comprehension | Which reference-derived additions in A01–A16 deserve promotion, and which should remain parked? Discuss only the undecided subset after earlier answers. | Gives explicit direction on assistant recommendations without re-asking accepted decisions. |
| D017 • Discussed; projects and sustained conditions | Should a first endgame ambition be completed through a staged project, a sustained world condition, or a combination? | Makes victory observable and supports intermediate progress. |
| D018 • Discussed; mobile survivors may rebuild | If a civilization loses all towns but retains mobile people capable of founding another, does it remain alive? | Resolves full elimination versus the earlier survive-while-possible principle. |
| D019 • Discussed; compact lessons and five-to-ten detailed runs | For aggregate test memory, should we retain compact context, outcome and valid/obsolete lessons, with a provisional five recent detailed runs and up to ten for active comparisons? | Makes retention implementable without silently fixing a quota or pruning policy. |
| D020 • Discussed; whole-loop should-list and sequential refinement | After these directions, what should the first comparison with the build prioritize: the complete start/early loop or a narrower named capability chain within it? | Defines the scope of the later audit and repair/addition proposal; no implementation commitment yet. |

### D001 — recorded provisional opening and exploration direction, 2 November 2026

User: “Probably second with a single soldier and a single explorer, the map in actual playable state should be unexplored and have fog of war, maybe some small anomalies dot it and explorer reveals and identifies them; although smac option to see continent shapes might be entertained... the game and stakes suggest ‘unknown’ map but would a real expedition not know most of the macro information... hmmm”.

Provisional ordinary opening: a small established settlement and workforce rather than a mobile group required to choose its first founding site, with one Soldier and one Explorer. Exact civilian complement, initial facilities, stocks, training/equipment and whether those two units begin as field units or settlement residents are not specified. This is a future ordinary-play setup, not an instruction to replace existing supplied campaign test forces now.

Playable-map direction: initially unexplored, with fog of war. Small scattered anomalies that the Explorer reveals and identifies are a tentative opportunity. Their rewards, investigation duration, eligibility and any specialized analysis remain open; no automatic free resource reward is selected.

Possible broad knowledge of continent outlines remains open. The user weighs the theme/stakes of an unknown map against an expedition plausibly having prior macro-geographical information. The SMAC reference is user inspiration, not a verified claim about a specific map option. Do not infer full terrain, deposit, anomaly, settlement or enemy knowledge from continent outlines. A candidate interpretation is layered knowledge—broad survey geography, locally explored details and current visibility—but this is assistant reasoning for D011, not a settled rule.

Q123's first-map competence work and the later full-map playable design remain distinct. No fog, scenario, starting units or exploration mechanics changed. Next: D002, whether the four stages describe capabilities/circumstances rather than fixed eras.

### D002 — recorded answer, 2 November 2026

User: “They would meta explain how developed a given player is in aggregate, no formal eras for everyone; btw, how many prepared questions do you have right now?”

The four stages are meta-level descriptions of a given player's aggregate development, not formal shared eras. Assess each civilization in its own circumstances; do not impose global era transitions or invent a mandatory stage-unlock system. No exact development score, thresholds or automated classification is specified. The bins remain useful for organizing intended progression and later comparison without becoming gameplay gates.

Question-count answer at this boundary: twenty prepared second-round questions D001–D020; D001 and D002 addressed, eighteen remaining. The original Q001–Q128 round is already complete. Recorded only; no gameplay changes or simulations. Next: D003, Food accounting scope.

### D003 — provisional hybrid Food model and starting growth cap, 2 November 2026

User: “I guess local growth but global stockpile if some settlements are put on ‘no growth’ option and to feed the pops that work outside settlements; perhaps ability to spend global stockpile to grow in a chosen location? Repeatedly, even in one turn?” Follow-up user instruction: “Continue”.

Provisional direction: local settlement growth alongside a global Food reserve. Towns on a no-growth setting could contribute unused growth surplus to that reserve, and the reserve feeds population working outside settlements. The surplus-routing interpretation follows the user's wording but exact routing of growth-enabled town surplus, local resident upkeep and local deficits remains open. Do not count the same Food in both local growth and the global pool.

Possible additional action: spend global Food to grow a chosen settlement. Repeated growth, including multiple cohorts in one turn, is explicitly posed as a possibility/question rather than a finalized rule. It differs from Q031's rejected emergency free population: paid growth would use an earned Food resource, but its pace and military consequences still require a deliberate decision.

Assistant design analysis: immediate repeat spending is mechanically possible as a proposed rule, but makes stored Food a reserve of rapidly deployable labour/population. It could support deliberate new-town development or replace battlefield losses quickly. Candidate safeguards for testing include recalculating the next population cost after each addition, respecting any applicable capacity/infrastructure limits, reserving necessary upkeep and preventing double use of Food. These are recommendations, not adopted rules. Capacity checks do not imply housing limits have already been authored, and Food growth would not by itself grant specialist training or equipment.

D003 follow-up: provisionally allow repeated same-turn paid growth, rechecking each addition's cost/capacity and protecting upkeep reserves, or prefer global Food to accelerate growth over turns? Exact values can remain for testing. No additional prepared question ID added. D004 remains next after this clarification.

Recorded only; no gameplay changes, simulation or scenario approval. No changes to the four-stage synthesis until the direction round is consolidated.


#### D003 follow-up — recorded starting test rule, 2 November 2026

User: “I think to start testing allow one pop per settlement per turn growth through any means”.

Starting testing rule: at most one newly grown population cohort per settlement per turn, with the same cap shared by all growth methods, including local/natural growth and global-stockpile-funded growth if that option is used. These methods do not each receive a separate allowance. The cap supersedes repeated same-turn population growth as the initial test policy; it is provisional rather than a permanent balance commitment.

The cap does not itself create free population, specify Food prices, endorse every candidate upkeep safeguard or resolve all local/global accounting. Exact growth timing, overflow handling and stockpile action remain to be authored. Moving an existing person into a settlement is a distinct population transfer rather than creating a new cohort; whether arrivals should share any separate settlement-intake limit remains unspecified. Do not silently restrict existing relocation using this growth rule.

D003 is addressed at the provisional model level; remaining accounting details are retained for consolidation. No gameplay changes or simulations. Next: D004, the first concrete advantage of developing an existing town over minimally staffed expansion.

### D004 — recorded development and scale principle, 2 November 2026

User: “Yes, colonization, while an old game already had these constraints, mostly 3, and 8 pop in town, but its just a proof of concept, balancing runs would tweak costs and thresholds; the intention being, better supported larger settlements offer better yealds and economies of scale while requiring risk management and cleanup”.

Accepts advanced workplaces depending on developed local infrastructure, with population/housing requirements where useful, so minimally staffed outposts cannot provide all the same capabilities. The central intention is that better-supported larger settlements offer better yields and economies of scale, while requiring risk management and cleanup. This strengthens the intended reward side of concentration alongside its liabilities, not merely a higher upkeep tax.

The Colonization comparison and population values 3/8 are user-supplied proof-of-concept references, not independently verified historical claims or selected Alien Planet thresholds. Costs and thresholds should be tuned through balancing runs. Exact scale benefits, eligibility checks, pressure/risk systems and cleanup methods remain unspecified. Do not infer that every additional population cohort supplies a universal multiplier, or make repetitive individual cleanup mandatory against Q057's preference for meaningful prevention/management.

Read with Q027–Q029, Q057, M02/L02 and D003: a one-cohort-per-settlement-per-turn initial growth cap does not replace infrastructure and operating constraints. Recorded only; no gameplay changes, balancing runs or new scenario approval. Next: D005, timing of operational research prerequisites.

### D005 — recorded provisional prerequisite timing, 2 November 2026

User: “Good question, i guess to be counted as first a thing has to do second in a previous turn”. The offered alternatives were present operation alone versus first completing a turn of actual production.

Provisional interpretation: to count as functioning for an operational research prerequisite, the relevant facility/specialist combination must have actually produced in a previous turn. Merely completing construction, assigning a specialist or enabling inputs during the current turn is insufficient. This clarifies Q042 rather than replacing its requirement for working, functioning capability.

The user says “a previous turn”, not necessarily “the immediately preceding turn”. How long demonstrated operation remains valid, how interruptions affect qualification and which applicable non-yield capabilities can demonstrate operation remain unspecified. Do not convert one historical tick into permanent eligibility regardless of current operation, or silently impose an immediately-previous-turn rule. Exact output/operation evidence should follow the authored prerequisite and actual turn processing. No prerequisite-validation code changed.

Recorded only; no gameplay changes or simulations. Next: D006, initial civilian shelter/protection criteria.

### D006 — recorded shelter and information-limit criteria, 2 November 2026

User: “Yes, a physical barrier that offers a combat value and or a tile that seems unnacessible by known and seen enemies, fog of war might deceive”.

Shelter/protection can be a physical barrier offering actual combat value and/or a tile judged inaccessible to known, seen enemies. Safety assessment depends on available information; fog of war may hide a threat and make an apparently safe destination unsafe. Nearby friendly troops or a settlement label alone do not automatically establish protection under the prior question and answer.

A barrier's combat value need not mean absolute immunity or literal impassability; no exact defence bonus, interception, targeting priority or damage-absorption rule is fixed. Reach checks should follow relevant actual movement/attack rules while respecting what the player knows. No omniscient hidden-enemy check or guarantee of safety is implied. Treatment of remembered/suspected threats, current versus next-turn reach and information age remains open under the broader fog and tactical design.

Recorded only; no gameplay changes, barrier implementation, fog changes or simulations. Next: D007, the initial garrison baseline and threat-triggered reinforcement policy.

### D007 — recorded starting garrison policy, 2 November 2026

User: “Yes” to a small fixed garrison baseline, a larger baseline for outer/contested settlements, and reinforcement requests when assessed local threats exceed that protection, with actual numbers tuned through tactical trials.

Use this simple layered policy as the starting testing direction. Baseline defence and responsive reinforcement complement each other; the baseline is not a guarantee of adequate protection against every threat. Counts, outer/contested classification, threat comparison and reinforcement timing remain for testing. D006's information limits apply to assessments. Read with Q081/Q083/Q086 for town priority and tentative urgent sallies.

Recorded only; no gameplay changes, tactical trials or scenario approval. Next: D008, reassessing expedition requirements after losses or changed enemy conditions.

### D008 — recorded reassessment requirement, 2 November 2026

User: “Absolutely reconsider” to recalculating expedition strength and useful weapon mix after losses or new enemy information before another offensive wave, rather than rebuilding the original force unchanged.

Reassess current force adequacy and relevant composition against the updated enemy situation. Q089's 25% margin remains a provisional starting value applied to the updated estimate, not a reason to preserve an obsolete force template or a guarantee of success. Reassessment need not always change the result; changed requirements should follow current evidence and feasible means. Q093's larger-force rebuilding response to unlikely victory and defence/survival priority remain applicable.

No exact power formula, reassessment cadence, casualty trigger threshold or composition optimizer is selected. Recorded only; no gameplay changes or simulations. Next: D009, which tactical uncertainty to prioritize in later trials.

### D009 — recorded tactical-testing priority, 2 November 2026

User: “I agree and in the order you listed them”.

Priority order for later tactical trials: (1) weapon-range and usable-support coordination, (2) protection and retreat, (3) stacking and zones of control. This accepts the suggested first focus so rifles and vulnerable range-one flamers can contribute together. It does not settle the deferred mechanics or require each area to be perfected before any later investigation; their interactions still matter.

This is testing direction, not approval of an unspecified scenario or an implementation batch. Under Q127, concrete scenarios still need user suggestion or approval. No tests run or gameplay changed. Next: D010, trained Merchant benefit beyond basic visitor trade.

### D010 — recorded proof-of-concept Merchant benefit and shared site access, 2 November 2026

User: “Indeed, several, but for proof of concept and to train ai players to start using them, double the gains of a neutral tile, allow multiple players to have a single pop on one any such tile”.

Multiple later Merchant advantages remain possible. For the proof of concept, a trained Merchant should receive double the gains of an eligible neutral tile/site compared with basic untrained participation. Treat this as a clear starting incentive for AI-use testing, not a permanently balanced multiplier or a requirement that every civilization always choose it. “Train ai players” here refers to developing/testing programmed behaviour, not an instruction to introduce autonomous machine learning.

Shared neutral-site access: multiple players can each have one visiting population cohort on the same eligible neutral tile. This is a per-player visitor allowance, not a one-visitor-total exclusion or permission to multiply a single player's benefit through many visitors. Exact eligibility and how the visit occupies time remain open. Do not extend this exception automatically to hostile sites, every ordinary worked tile or all combat stacking.

Read with Q078: the intended first trade direction is actual exchanges during a visit, not unqualified free resource generation. If a neutral site implements an exchange, the 2× gains statement does not specify whether it improves received goods for the same payment, transaction throughput or some separately defined visit benefit. Costs, offer stock/refresh, cadence and one-time versus ongoing gains need explicit rules before implementation; do not silently double both incoming and outgoing amounts or remove payment. Distinguish this from ordinary settlement tile-yield employment.

Recorded only; no gameplay changes, AI training runs or scenario approval. Next: D011, initial geographical knowledge and discovery/anomaly purpose.

### D011 — recorded provisional layered map knowledge, 2 November 2026

User: “For gamey feel no info, but i want some plausible feel, so perhaps the map is visible but details unindentified, hence explorer units and fog of war”.

Tentative compromise: broad map geography can be visible while local details are unidentified, giving Explorer units a discovery/identification purpose alongside fog of war. The user values both unknown-map discovery and a plausible expedition perspective; preserve “perhaps” rather than claiming a finalized visibility specification. This refines D001's unknown-map direction without cancelling fog or exploration.

Separate broad survey geography, identified local information and current visibility. The question's fog-of-war concept remains applicable: broad map visibility does not reveal live enemy activity everywhere. Exact initial layer visibility—coastlines, relief, biomes, rivers, yields, deposits and site markers—remains open. Do not infer all terrain or exact useful yields are known merely because the map is visible. Anomaly identification/rewards and what any untrained unit can discover versus an Explorer remain unspecified.

Recorded only; no map, fog, scenario or exploration code changed. Next: D012, first pressure and corresponding reward for settlement concentration.

### D012 — recorded health and accumulating pollution systems, 2 November 2026

User: “Both: health is migitated by more and better medics, reducing growth penalties; pollution is reduced by engineers in waste disposal buildings, pop + industry count - some constant per settlement; pollution accumulates and overflows into progressingly worse overlays in map tiles”.

Both pressures should matter. Health causes growth penalties, mitigated by more and better Medics. This specifies a growth-related service, not automatic combat healing, a new Health stockpile or an unbounded growth bonus. Exact health-pressure causes, aggregation, Medic progression, staffing effectiveness and minimum/maximum penalties remain open.

Pollution is reduced by Engineers working in waste-disposal buildings. The intended source relationship is population plus industry minus a per-settlement constant/allowance. Preserve “industry count” without silently choosing industrial output, number of industrial jobs/buildings, gross manufacture or stored Industry. The constant, weighting, units, treatment below zero and whether disposal reduces generation, accumulated pollution or both remain to be specified. No precise numerical formula is fixed merely by this qualitative expression.

Pollution accumulates and overflows into map tiles as progressively worse pollution overlays. This establishes continuing generation/accumulation and severity escalation as intended mechanics, not merely pre-existing removable map obstacles. Settlement-level accumulation, spill threshold, tile selection/radius, overlay levels, penalties, cleanup/remediation rates and whether prevention can fully avoid spill remain open. Existing prototype overlay names/levels do not prove this new accumulation process is implemented.

Read with Q057: meaningful preventive/management tools, including forest/preserve possibilities, should avoid turning later play into endless repetitive manual tile cleanup. Staffed waste disposal supplies a concrete ongoing management role. D004's higher yields/economies of scale should coexist with these costs; do not tune only penalties while omitting large-town benefits.

Recorded only; no health, waste-disposal, pollution code or tests changed. Next: D013, the first middle-game specialization direction.

### D013 — recorded middle-game exploration priority, 2 November 2026

User: “They should be all interesting but lets aim for animal control first”.

Prioritize animal control as the first middle-game direction to explore among the offered alternatives. Biome-specific production and artificial habitats/local environmental change remain interesting longer-term directions, not rejected features. The answer chooses a design focus, not yet the exact control mechanism (psi, domestication or another means), acquisition rules or scope of controlled animals/nests.

This priority does not move speculative middle-game content ahead of the agreed foundation work or authorize implementation before clarification and comparison with the current build. No gameplay changes or tests run. Next: D014, the first animal-control relationship and its scope.

### D014 — recorded animal/nest technology progression, 2 November 2026

User: “In progressing techs: control one animal, then pacify one nest, then control one nest, then be able to improve one nest”.

Intended progressive capabilities, in order: (1) control one animal, (2) pacify one nest, (3) control one nest, (4) improve one nest. Use technology progression to expand the relationship rather than granting full nest management immediately. Pacification and control are distinct unlocks; pacification does not by itself grant command or improvements.

Exact technology nodes/costs and whether “one” is per psi user, per action or a civilization-wide limit remain unspecified. Preserve Q105's tentative one-psi-user-per-nest idea without silently applying it to every new stage or declaring a global one-nest cap. Control duration, connection/presence, target eligibility, acquisition risk and effects on a nest's associated animals remain open. “Improve” establishes a later management capability without selecting unit breeding, evolution, defences, yields or any specific upgrade. Human-controlled nest founding from Q109 remains a separate possible capability.

This prioritizes a design progression within D013's chosen focus, not immediate gameplay implementation. No tests or scenario approved/run. Next: D015, desired endgame ambitions.

### D015 — recorded ecology-first ambition direction, 2 November 2026

User: “They all sound good but lets aim to define and test ecology”.

Prioritize defining and testing ecology as the first direction among the offered endgame ambitions. Industrial/technological development, biological/cybernetic transformation and political/military ambitions remain interesting possibilities, not rejected or finalized content. This direction also connects the middle-game animal-control progression (D013–D014), health/waste management (D012), forests/preserves (Q057) and possible adaptation (Q061).

“Ecology” is not yet a selected victory condition, mandatory planetary intelligence/contact story, preserve-every-tile ideology or ban on industrial development. Its playable objective and relevant source-derived additions should be clarified before proposing a concrete approved test. This answer establishes testing direction, not approval of an unspecified scenario, code batch or simulations now.

Recorded only; no gameplay changes or tests run. Next: D016, ecology-focused selection from reference-derived additions; unrelated late options remain parked for now.

### D016 — recorded; ecology additions and world comprehension

User: “Yes, key test will be whether players can even understand the world theyre in”.

Promote productive forests/preserves as ecology options alongside engineered waste disposal and the animal-control progression. Orbital, gate and digital-society additions remain parked. Specific ecological effects, costs and interactions still require definition.

The key evaluation is whether AI players can understand their circumstances in an operational sense: recognize relevant conditions, opportunities and constraints from available information; choose useful actions; and respond to their consequences. Merely making the mechanics available or completing a scripted objective does not establish competence. This applies across the world and reinforces the first-map competence priority, not just a late ecology checklist. Respect fog of war and uncertainty; this answer does not grant hidden information or specify a new architecture.

Recorded only; no gameplay changes, scenarios or tests run. Next: D017, the form of an ecology objective.

### D017 — recorded; projects and sustained ecological conditions

User: “Both”.

The first ecology ambition should combine defined ecological projects/milestones with sustained world conditions: a functioning civilization, pollution under control and deliberate management of native life over several turns. Projects provide concrete achievements; maintaining the resulting conditions establishes that the civilization can sustain them. Exact projects, thresholds, duration and whether these constitute a formal victory remain open. This does not require completing every possible ecology option.

Recorded only; no gameplay changes or tests run. Next: D018, survival after loss of all settlements.

### D018 — recorded; mobile survivors may rebuild

User: “Yes”.

Losing every settlement does not automatically eliminate a player if surviving mobile people can still found a new settlement. They remain in the game and should attempt to rebuild. Elimination occurs when that recovery is no longer possible. This resolves the earlier full-wipe discussion in favor of surviving founding capacity rather than settlement count alone. Exact detection of impossible recovery still requires implementation judgment; no arbitrary turn limit is selected here.

Recorded only; no gameplay changes or tests run. Next: D019, compact aggregate experience and detailed-run retention.

### D019 — recorded; compact aggregate lessons and bounded detailed logs

User: “Yes”.

Retain compact aggregate summaries of test conditions, decisions, outcomes and lessons. Mark lessons outdated when relevant rules change so old conclusions do not silently govern new builds. Keep five recent detailed runs by default, with up to ten for active comparisons. This refines the earlier five-to-ten-run preference and preserves useful aggregate experience when older raw logs are cleaned up. No cleanup automation, deletion of existing files or new test run is performed by this answer.

Recorded only; no gameplay changes or tests run. Next: D020, the scope of the first comparison with the existing build.

### D020 — recorded; whole-loop should-list and sequential competence review

User: “First but make a list of "shoulds" and well fine tune one by one, inventories, mechanics and ai tweaks for each until we can agree: "ai got how to do this well enough"”.

Review the complete start/early-game loop rather than restricting the first comparison to nest clearance. First establish an ordered list of intended capabilities. Refine each in turn across its inventory, mechanics and AI decisions; define useful evidence and jointly judge when the AI handles it well enough. A proposal, legal command or one scripted success is not itself demonstrated competence. Keep the whole-loop view while focusing discussion on one capability at a time.

All D001–D020 are now addressed. The new working list is `Alien_Planet_Start_Early_Shoulds_Review_2026-11-02.md`, S01–S18. Its grouping, order and proposed competence checks are assistant recommendations for refinement, not eighteen newly imposed requirements. The original decisions retain their qualifications. Current review item: S01, opening inventory and world comprehension. No current-source audit, implementation or simulation has been performed by creating this list. The separate development thread will implement and test agreed changes; concrete scenarios remain subject to user suggestion or approval.
