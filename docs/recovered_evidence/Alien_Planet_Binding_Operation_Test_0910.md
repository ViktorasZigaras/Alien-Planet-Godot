# Alien Planet 0.910 — binding operations: implementation and experiment

2026-10-31 · Godot · local development, not uploaded to GitHub

The ruler–general–economy–lieutenant chain can now carry out a binding military decision: Red and Green each assembled and dispatched the requested expedition through ordinary game actions. That does not yet make them effective commanders. In the main 200-round run the nest survived, despite both civilizations having functioning expedition machinery.

## What changed

An approved nest-cleansing operation now persists as a charter: a particular target, assembly hub, staging hexes, required force, protected ownership, preparation tasks, deployment conditions and recovery state. Red and Green use this mechanism; Blue retains its existing policy.

For this experiment the contract is four rifle Soldiers and two flamer Soldiers, plus a separate home guard and sufficient civilian support. Six is a fixed test template, not an estimate of what defeating the current nest requires. Initial support requirements can rise when domestic staffing is blocked.

The operation authorizes its prerequisites across adviser boundaries. Growth, research, buildings, training, equipment and economic assignments can therefore serve one approved objective. Other discretionary work is deferred. The existing action helpers still execute ordinary legal actions with ordinary costs; this is a mission-specific supervisor, not a general dependency solver or optimal production planner.

Preparation may dock expedition personnel and use them domestically. Before release, military domestic assignments must be cleared, the correct equipment and composition assembled, health checked and the whole force provisioned. A forged ready status cannot bypass the readiness checks. The lieutenant keeps tactical attack and retreat decisions, but cannot begin the offensive advance before release. Attrition or insufficient supply triggers recovery.

The initial supply approval covers 24 turns. After deployment its remaining horizon decreases, with a four-turn minimum. A regression test prevents the former mistake of recalling an expedition merely because it spent resources from its approved budget.

## Recorded results

All cases use seed 731. They are diagnostics of mechanisms, not a statistical balance study. The normal scenario already starts each faction with civilians and four trained field Soldiers; preparation still has to obtain the missing personnel, equipment, capacity and operating support.

| Case | Setup and duration | Result | Human / animal deaths |
|---|---|---|---|
| Preparation only | Normal starting economy; deployment deliberately held; 200 rounds | First full readiness certificate: Red decision 104, Green 141 | Red 0, Green 0 / 0 |
| Ordinary economy: main run | Normal scenario, full operation, 200 rounds | Red releases at 104; Green at 141 and another wave at 200. Nest remains active | Red 4, Green 4, Blue 0 / 4 |
| Early supplied execution | Explicitly supplied complete forces and large stocks; 100 rounds | Red steps onto the nest and disables it at world turn 21 | Red 0, Green 0 / 9 |
| Mature-world supplied execution | Existing world at turn 142; complete forces restored, healed, staged and supplied; run to world 201 | Nest remains active; both release at 142; Green releases again at 193 | Additional Red 8, Green 4, Blue 0 / 3 |

Supplied fixtures grant six offensive Soldiers plus a home guard, proper gear and stocks of 2,000 Food and 300 each of Industry, Energy and Minerals. Their success or failure must not be presented as economically earned. The mature fixture began with cumulative Red 3 and animal 3 deaths; its table reports subsequent deaths only.

The main ordinary-economy run began under the final policy. A cloud interruption stopped it at its turn-30 checkpoint; it resumed that checkpoint without rerolling or resource grants. Its full 5,215-command trace exactly replays both the physical outcome and all three complete private AI states. No recorded commands were dropped.

## Observations

**The binding decision works.** A target and force requirement survive adviser competition. The economy can grow, equip and stage a force, and the lieutenant can receive it. The former disconnect between wanting an expedition and authorizing its prerequisites has been substantially addressed.

**Preparation is slow and wasteful.** Across the main 200 rounds Red performs 57 mobilisations and 56 docks; Green performs 19 and 13. These are repeated actions, not distinct soldiers. The charter persists, but domestic staffing and commissioning still oscillate. Red finishes with population 12 and Green 17. This is evidence for improving joint staffing and phase transitions, rather than adding another advisory role.

**A dispatchable army is not necessarily an adequate army.** The six-unit requirement is unchanged as the nest matures. In the ordinary campaign Red records 27 rifle ranged attacks and one flamer melee attack; Green records eight rifle ranged attacks. Neither produces a flamer ranged attack. The mature supplied case likewise produces rifle fire and flamer melee attacks, but no flamer ranged attacks.

Flamers have adjacent range while heavy predators can spit from two tiles away. Individual movement, target selection, retreat thresholds and costly terrain can prevent a coordinated close approach. These are plausible explanations to investigate, not proven causes from attack counts alone. The existing coarse threat heuristic also underestimates the heavy predator's move-plus-two-tile attack envelope.

**Stocks alone do not solve the late encounter.** In the mature supplied case, the first withdrawals occur while supply remains ready: Green at turn 158 and Red at 166, each down to two assigned offensive members. Attrition, rather than an immediate economic veto, breaks these waves. The early supplied force succeeds against a younger nest; timing, enemy state, restored forces and encounter history differ, so this comparison does not isolate a single cause.

## Limits and recommended next work

The preparation-only certificates are first achievements, not proof of uninterrupted readiness through turn 200. Artificially holding a force consumes resources, and the current high-water progress detector can misclassify plateaus or rebuilding below previous peaks as stalled progress. The adviser display may also retain older proposals; the binding operation panel and actual authorized actions determine execution.

Next, estimate force requirements from observed enemy strength and replacement capacity; make civilian staffing and commissioning stable phases; then give the lieutenant a joint approach plan that explicitly uses weapon ranges, terrain, formation and retreat routes. Keep these changes measurable and separate. This batch does not add ammunition, freight, supply-radius or new combat balance rules, and it does not claim a general-purpose planner.

## Verification and retained evidence

Sixteen suites pass, totalling 3,424 checks, including 369 operation-specific checks. Complete final-policy replays pass for preparation (5,027 commands), the main campaign (5,215), the early supplied fixture (2,990), the mature supplied fixture (1,390) and an earned continuation diagnostic (2,053). Physical and private AI outcomes match. Native Godot rendering was inspected; no parse or runtime errors were observed in the checks.

The comparison atlas uses actual saved states. The native army screenshot shows Green's assembled six-unit force and the operation panel; its global resource header belongs to the selected human civilization, not Green. Repository reports retain complete compressed traces/states, summary metrics and the earlier pre-budget draft, explicitly marked version-bound. Earlier failed experiments remain intact. No GitHub push or executable export was performed.