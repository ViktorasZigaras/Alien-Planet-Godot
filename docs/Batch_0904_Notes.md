# 0.904 — terrain cleansing, combat and one seeded test

Viktoras requested the pending environmental overlays, Civ IV-inspired combat, rifle/flamer/spit ranged attacks, healing, military infrastructure limits, maintenance, no supply ranges, simple effects, a red hunting army and a maximum 200-turn experiment. This batch is authorised for upload, including the previously local 0.902 and 0.903 work. HTML is unchanged.

## Combat choices

This is a small repeated-round implementation inspired by Civilization, not a claim to reproduce Civ IV exactly. Every person/animal has 100 HP. Healthy rifle Soldiers have strength 1, untrained armed people 0.4, unarmed people 0.2, larvae 0.25, Hookrunners 1 and Carapace predators 1.5. No separate exoskeleton armour bonus is applied.

Starting effective strength is `base × (0.5 + 0.5 × HP/100)`. Each melee round awards one hit with attacker probability `A/(A+D)`. Hit damage is `round(20 × (3A+D)/(3D+A))`, clamped 5–60. Strength/damage are fixed at the start of the duel; rounds continue until one combatant dies. Thus equally healthy, equally modified units have exactly 50% survival odds, while superior strength compounds over the rounds. The inspector computes the exact duel win probability by a small probability grid. No arbitrary exponent or sampled forecast is used.

Defending terrain multiplies strength: hills +25%, forest +25%, light vegetation +10%, brambles/stones +15%, fungal terrain +10%, settlement +25%, additive. Clear open plains have no terrain bonus. Wounds reduce power. Terrain applies to the defender against melee and ranged attacks. There is no separate river-crossing attack modifier in this shell.

One attack requires one movement point and consumes that person's attack for the world turn. Melee kills one participant. Ranged attacks inflict one damage packet without retaliation; they can kill. Rifle Soldiers shoot at range two at half strength. A trained Soldier equipped with a Flamer Exoskeleton fires at range one; flame gets double **offensive** power against animals, without improving defensive strength. Heavy predators spit at range two using 65% of their base power. Ranged damage is `round(25 × effectiveAttack/effectiveDefence)`, clamped 3–45. Cargo passengers are protected inside their carrier; a dead driver releases survivors with no movement.

People heal on quiet world rounds: 5 HP in the field or 20 on their own settlement tile. Animals heal 5 in the field or 15 at their nest. A combat round postpones healing. Wounds/cooldowns/random state persist through saves. This pass provides human-versus-animal combat; human-versus-human warfare remains outside the test scenario.

## Equipment, upkeep and occupation

Flamer manufacture costs 8 Industry and needs Protective Equipment technology; equipping requires a trained Soldier. Transports still cost 5 Industry and need Surveying. Each completed Security District provides **one Flamer slot and one Transport slot**; Guard Posts add one slot each at tier one, two each at tier two. Capacity counts settlement stock and equipped items, across the civilization. Existing initial/saved transports are retained even if over the new limit; further manufacture requires free capacity.

Everyone already consumes normal population Food. A deployed or carried Soldier additionally costs **1 Food per round**. Each deployed/carried Flamer and Transport additionally costs **1 Industry per round**. Keeping equipment in settlement stock costs no field maintenance. A food shortage, or Industry shortage for a Flamer/Transport, reduces that person's combat power by 25% (one readiness penalty, not compounded). This makes mobilisation consume supplies without an expedition-distance restriction. Supply ranges and their UI controls are removed; hard terrain, rivers, roads and queued movement still work.

Animals block entry to their tile; a blocked route pauses without losing the queue. Clear nest defenders and step onto/cross its tile with a mobilised Soldier to set `burned=true`. The nest then stops harvesting, spreading, upkeep and births. The ruined nest, existing animals and mat remain; occupation is not colony collapse or a city capture rule. The flag does not spread fire across the map.

## Pending environmental batch now implemented

- Dark-green xenomass improves animal biomass/mineral extraction by one where produced, and subtracts one from each human tile yield. Human suited workers can cleanse it. Future xenomass combat bonuses remain inactive.
- Scattered biomass patches supply one extra biomass when a larva forages there, consuming one patch charge. They are distinct from the spreading mat.
- Waste/sludge is a separate overlay. Level 3 suppresses all tile extraction; level 2 subtracts two from each yield; level 1 subtracts one. This affects animals as well as human workers. Cleaning removes one severity level per action.
- Brambles and stone formations subtract one/two **Minerals**, respectively. This is the provisional interpretation of the user's “production” penalty; Industry remains a settlement conversion resource. Penalties stack and outputs floor at zero. Specialist extraction bonuses apply before environmental penalties.
- Biome-specific light vegetation has no yield effect. Forests retain their existing food/mineral effects and have temperate/lush/cold/fungal visual variants. Desert generation has no trees. Light vegetation, forests and obstacles must be cleared before district/improvement/road construction.
- A Work Suit builder can cleanse one selected overlay per round. An idle resident works within two hexes; a deployed worker must stand on the tile and spend one movement. There is no Industry charge or multi-turn cleansing project yet. Cleanup changes shared geography for both civilizations; claims still limit economic orders.

Shared geometric assets are baked into **144 shipped sprite variants** (89 base catalogue entries). Both map styles show pollution, biomass, obstacles, vegetation, biome forests, the flamer and the disabled nest. Attacks emit muzzle flashes/tracers, short flame bursts, spit projectiles or claw sparks; 3D figures have a brief lunge. These are view-only effects and do not alter random state or outcomes. Live terrain caching excludes wildlife counters so ecological movement does not rebuild all ground geometry.

## Test controller and result

Red retains the existing economy/technology controller and adds a small ordinary-command military rule list: obtain military capacity, train up to three Soldiers, manufacture/equip rifles or a flamer and a transport, deploy a hunting party, attack nearby animals, retreat wounded troops and approach an active nest. It does not search for an optimal strategy, receive free resources or use GPT decisions. Military upkeep competes with economic development.

**Final-build test: one seed (731), one attempt, 200 complete rounds.** Blue only ends turns. Red builds all five district types, reaches 15 technologies, trains/deploys troops and contacts wildlife. At the limit: **blue deaths 0; red deaths 2; animal deaths 1; nest still active**. Red has 18 people, three Soldiers (one deployed flamer, two unequipped residents), zero Energy and zero Industry. Nest population is three larvae and six predators, five armored. This is a stalled/unsuccessful expedition, not a victory. Five districts with no advanced economic buildings and maintenance draining starter Industry reveal a controller/economy bottleneck; no balancing or reroll-to-win was performed.

A preliminary diagnostic exposed missing pollution penalties in animal extraction. That bug was fixed before the final-build experiment. Regression fixtures also exercise deterministic saves, so they are not extra balance attempts or independent outcome samples.

The recorder contains **2,041 actions, no dropped events**, initial states, rule labels, environmental combat events, final summaries and explicit turn-limit outcome. Replaying the exact actions without the policy produces the same final summary and deaths. Full report and final save are under `reports/0904/` as gzip JSON; decompress before reading/importing. `tests/run_0904_simulation.gd` reproduces the experiment; `tests/replay_0904_report.gd` validates the decompressed report. No general victory/diplomacy system is inferred.

## Validation and compatibility

**1,880 checks pass:** 421 rules, 22 UI, 247 model lab, 378 world/art, 55 visual style, 39 frontier, 185 0.901, 290 0.902, 163 0.903 and 80 new combat/overlay checks. Explicit old expectations for provisional damage, nest collapse, unlimited prototype equipment and the old schema/catalogue counts were updated to the new contract. Existing economy tests now account for Transport maintenance separately from gross conversion output. Older controller checks retain development/military acquisition goals rather than requiring all technologies during a military expedition.

Save schema 11 / world extension 3 migrate supported prior saves and scale former health values into 100 HP. New death counters start at zero when importing older games. Recorder exports use `alien-planet-test-v4`. Default-opening native OpenGL captures preserve the simulation; combat/overlay and frozen-flame images are labelled staged fixtures. Software rendering was used; physical desktop play/performance testing and executable exports are not claimed.
