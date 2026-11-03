# Alien Planet 0.909 · red/green terrain-learning experiment

**Both starting forces approached and fought. Neither disabled the nest.** Their encounters produced separate terrain-caution memories, followed by a failure to remuster a sufficient offensive force. These are the final retained run's results, not a claim of successful strategy learning.

## Setup

Green Reach starts at **16,2**, in the existing eastern brown/dry desert biome near its lush boundary. Red remains at **10,8**. The map geography is retained. Both settlements keep five civilian starters and normal starting stocks; each receives **four additional trained mobile Soldiers: three rifles and one flamer**, spread across two hexes. These are explicitly supplied scenario troops, not manufactured units or free research. Existing equipped starting gear is retained under the engine's existing capacity rules; replacement manufacture still needs normal technology, capacity and Industry.

Each general identifies **nest hex 18,12** as its explicit target and allocates an offensive force to its lieutenant while retaining a home guard. Stocks, technology, projects, people and learning remain private. They share a target and map, not a commander, supply pool or reinforcement schedule. Blue keeps its existing policy and receives no extra troops.

The new red/green campaign uses a two-turn **Food and Industry** upkeep check for field departure. Unrelated building/research Energy problems no longer automatically veto those units. Real upkeep/shortage rules still apply. Old saves retain their players and troops; Reset/new game creates this new three-player scenario.

Default seed **731**, **200 complete rounds**, final world turn 201. No wildlife strength changes, favourable-seed search, ammunition system or hard stacking limit.

## The rule set that executes

1. Keep the nest hex as the objective; consider home defence, then move the allocated offensive members towards it.
2. Prefer at most **three armed field Soldiers on a tile**. Carried passengers are excluded; emergency retreat may make a recorded exception. This is a sequential AI preference, not a simultaneous multi-faction formation solver.
3. Fire at a reachable low-HP target first. A finishing charge requires at least **60% exact duel win odds** and either enemy HP ≤45 or a flamer with nearby support. Nearby support counts the attacker and other Soldiers within two hexes; it does not guarantee ready supporting fire.
4. Withdraw below **55 HP** initially. Two observed field-Soldier deaths raise this to **70 HP**. Two isolated deaths would raise minimum support from one to two; a fatal charge would raise required charge odds to 78%.
5. Choose a single neighbouring step, favouring target progress, defensive cover and comrades, while accounting for threats, crowding and movement cost. Hills/forest/river/road costs use actual game movement rules; unfinished movement payments persist.
6. Keep a private memory for each encountered **base terrain / flat-or-hills / forest-or-clear** class. Record review observations, movement orders and their quoted costs, outgoing attacks, and incoming enemy-initiated hits, damage and deaths.
7. **After at least three incoming hits and 60 total HP damage**, assign caution band **1** to that class; with a recorded death, assign band **2**. Subtract **2.5 points per band** from that terrain's next-step score. The penalty can change the chosen step, but does not forbid advancing or retreating through the class. It never changes combat bonuses or actual movement costs.

This is bounded, authored adaptation within the saved match. It does not invent arbitrary tactics, infer causal terrain effects or train across new games. In particular, an unflagged class is **unproven**, not “safe.”

## Rules actually produced

| Civilization | Observed terrain class | Enemy-initiated hits | HP damage received | Deaths on that class | Final learned caution |
|---|---|---:|---:|---:|---|
| Red | Fungal / hills / clear | 10 | 255 | 2 | Band 2; next-step penalty 5 |
| Red | Tundra / hills / clear | 2 | 53 | 1 | Band 0; insufficient sample |
| Red | Tundra / flat / forest | 2 | 47 | 0 | Band 0; insufficient sample |
| Green | Desert / hills / clear | 7 | 135 | 2 | Band 2; next-step penalty 5 |
| Green | Fungal / hills / clear | 10 | 185 | 0 | Band 1; next-step penalty 2.5 |
| Green | Desert / flat / clear | 2 | 45 | 1 | Band 0; insufficient sample |

Other observed classes have no recorded incoming hits. All data above are **actual combat-location records**. The earlier interval health observations remain useful for general casualty counters, but no longer supply this terrain attribution.

Red's fungal-hill caution changes 0→1→2 at stored event turn **14**. Its retreat threshold rises 55→70 at decision turn **15**. Green flags fungal hills at turn **18**, desert hills at **23**, and raises retreat HP at **25**. The turn labels are stored event/decision clocks; a red/green review may appear one higher on the recorder's world clock while blue has already ended its turn.

Neither side changes its charge-odds or support threshold. There are no charges in this run, hence no evidence for revising the charge rule. Red has only one isolated field death; green has none.

One green movement order enters a class whose caution band is already nonzero. This shows the penalty remains soft. It does **not** prove that another live-game choice would have been better. A separate fixture verifies that learned caution changes the next step when otherwise comparable alternatives exist.

## What happened

The accompanying six-frame map comes from actual command-replayed states at rounds **0, 5, 10, 20, 30 and 200**. White circles are settlements; numbered colored circles are armed mobile Soldiers. Dark green triangles are animals. The nest is the black X; orange rings mark recent human attack locations.

| Final-run measure | Red | Green |
|---|---:|---:|
| Starting civilian people + field troops | 5 + 4 | 5 + 4 |
| Closest observed distance to nest | 4 hexes | 2 hexes |
| Offensive movement orders | 26 | 30 |
| Retreat movement orders | 4 | 8 |
| Ranged attacks / charges | 3 / 0 | 5 / 0 |
| Direct attack kills | 1 | 1 |
| Immediate outgoing HP damage | 100 | 112 |
| Human deaths | 3 | 3 |
| Final population | 17 | 6 |
| Final Soldiers, including replacements | 2 | 2 |
| Final technologies | 7 | 10 |
| Final settlements | 1 | 1 |

**Blue deaths: 0. Animal deaths: 4 total. Nest: still active**, ending with three larvae and six predators, all armored. Two animal deaths were direct human attack kills; the others occurred in defensive combat. The armored count is a subset of the six predators, not six additional units.

Both sides' early ranged attacks kill a larva. Green also fires twice at an armored predator for **6 HP each time**. By the later game, each side has a surviving original home guard and one replacement flamer at home. Neither remusters the minimum two offensive field members. Red reports an Industry budget reservation blocker; green remains at assembly/preparation. Supplying initial troops successfully bypassed initial recruitment, but did not solve replacement logistics.

## What the evidence suggests, and what it cannot show

- **The explicit target works:** the forces leave their settlements and approach the same nest from different directions. Green reaches two hexes away; this is not a completed assault or nest occupation.
- **The terrain learner works mechanically:** the armies accumulate different memories and persist bounded rule changes. Their field-supply decision no longer depends on unrelated Energy output.
- **“Hills are bad” would be the wrong lesson.** Hills still provide their authored defence bonus. These hill encounters also involve predators, changing HP/equipment and proximity to the nest. There is no matched open-ground comparison. The recorded caution is a risk association from this route, not an estimate of terrain's causal effect.
- **Generic terrain classes are coarse.** Remembering dangerous fungal hills everywhere may overgeneralise one encounter. Per-location danger, enemy ranged reach and retreat routes are candidate next refinements, not implemented rules.
- **Support by distance remains crude.** Being within two tiles does not mean comrades can shoot the same enemy, cover a retreat or reach the wounded unit. An actual readiness/combined-fire test remains useful.
- **Target/threat reasoning is still rudimentary.** Both direct kills are larvae; lowest-HP target ordering is not a threat-priority plan. The movement heuristic counts enemy movement plus one tile, so it underestimates the heavy predator's move-plus-two-tile spit envelope. Actual attacks still use the proper ranged legality/damage rules. Testing retreat corridors and correcting that threat estimate are proposed follow-ups, not changes hidden in this recorded run.
- **Troop replacement is still a strategic bottleneck.** The next proposed campaign test should explicitly track the general's replacement commitment and what unblocks its Industry budget. That is separate from improving the terrain score.

Exposure counts include repeated quiet garrison observations and are not independent trials. Movement counts are issued orders; quoted cost totals are not a measurement of elapsed travel or successful arrivals. Incoming terrain damage covers enemy-initiated hits; human-initiated duel outcomes are logged separately. The map has no fog, and the nest location is known.

## Verification and retained work

**3,133 checks pass across fifteen suites**, including 445 new three-player/terrain checks. Checks cover independent stocks/casualties, starting force composition/formation, explicit target allocation, actual-location event data, learned path preference, corrupted memory rejection, old-save compatibility and deterministic JSON continuation.

All **5,421** final-run commands replay to the same physical result and all three complete private councils/terrain memories. Zero events dropped; each round validates. Reviewed the native game rendering of Green Reach, its faction markers and lieutenant panel, plus the data-map timeline.

A 20-turn diagnostic and an earlier full validation before restricting the supply refinement to the requested campaign players were also retained. These are engineering checks, not independent trials demonstrating effectiveness. The earlier full trace has the same red/green casualties and animal deaths. Headline results above refer only to the final run.

Game **0.909**, recorder v9. Schema/rules 14 and world 4 continue to support older two-player saves; terrain memory and third-player state are optional validated additions. No source/build uploaded to GitHub. Original HTML and frozen earlier reviews are unchanged.