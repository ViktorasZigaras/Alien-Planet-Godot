# Local version 0.903 — xeno nest ecology

Viktoras requested a non-player nest in purple terrain, worker larvae, ordinary and armored predators, limited populations, biomass feeding/births, mineral-dependent heavy bodies and worker-spread dark-green xenomass. Zerg supplied the broad biological inspiration; the segmented worms, hooked runners, shield-backed predators and rooted brood mound are original code-native models with matching sprite bakes. Power values are deliberately provisional. **Do not upload this batch.**

## Wildlife rather than another civilization

The starting brood is at **18,12**, in fungal terrain. It begins with two larvae, two Hookrunners, 18 biomass and three coated tiles. Each nest has local biomass/mineral stocks and a cap of **three workers plus six predators combined**, including armored ones. No Science, Culture, Industry, tech tree, town claims or civilization turn is created. `CivilizationSession.players` still returns only blue and red.

The ecology advances once after both civilizations complete a world round. It uses persisted deterministic RNG for roaming, explicit unit ordering and ordinary land adjacency. Larvae forage within three hexes of their nest. Predators normally wander/linger within five hexes; when they detect a person within three hexes, they pursue them and can leave that roaming radius. They target either civilization. A transported passenger is protected inside the carrier until unloaded or the driver is lost.

## Feeding, breeding and the mat

| Body | Health | Attack | Armor | Birth cost | Movement |
| --- | ---: | ---: | ---: | --- | --- |
| Mandible larva | 4 | 0 | 0 | 6 biomass | One forage/spread step |
| Hookrunner | 6 | 2 | 0 | 8 biomass | One random roam step; up to two pursuit steps |
| Carapace predator | 11 | 4 | 2 | 14 biomass + 4 minerals | One roam/pursuit step |

A worker harvests three base biomass, plus one on fungal terrain and one on xenomass. Hills/ore provide one mineral, plus one on xenomass. It searches useful nearby terrain rather than using civilization stocks or buildings. One staggered worker action in three attempts to spread the mat to adjacent uncoated land, costing one biomass. The mat is limited to radius three for this initial nest version and avoids town tiles; it does not become a political claim. Other worker actions harvest. The mat does not improve human yields.

Every living body consumes one biomass per ecology tick. A shortage damages the whole brood by one health; it can kill unfed bodies. At most one affordable body hatches per nest/tick. Missing larvae are replaced first; otherwise minerals permit armored births, with ordinary predators as the biomass-only option. All births pay their costs and respect separate worker/combined-predator caps. Killed workers cannot harvest, and a brood with no surviving workers or biomass can become dormant rather than receiving free recovery stock.

The mat follows actual 3D terrain relief and has transparent dark-green organic shading. Sprite mode has matching flat/hill variants. It currently boosts **harvesting only**; `FUTURE_MASS_COMBAT_BONUS = 1` is reserved and is **not applied** yet. Spreading the initial colony means expanding this overlay, not automatically establishing additional nests.

## Small provisional encounter rule

The user requested predators seeking victims and arbitrary testable power levels. This pass therefore adds a small xeno-only contact encounter, not a full civilization warfare system:

- A predator attacks once when within one hex of a detected person. People start with ten health. Damage is `max(1, predator attack − floor(existing human defence / 2))`.
- A surviving defender can retaliate once per world turn, using its existing combat profile and the predator's armor. Armed Soldiers therefore use the existing stronger profile; untrained/unarmed people chip at one damage. No city capture, diplomacy, human-versus-human attack or red military deployment policy is introduced.
- Select a mobile person and inspect a xeno tile for **Attack** controls. Direct attacks need one movement point, adjacency and an unused attack for that turn. Their damage is `max(1, existing attack − xeno armor)`. Existing movement queues are not silently cancelled.
- Nest health is 24, armor one. A destroyed nest currently collapses its dependent brood and mat. This simple colony-collapse rule is provisional.
- Human deaths remove their job/queue/site-visitor references and cancel their own unfinished training/construction without a refund. Equipment carried by the lost person is lost. If a driver dies, surviving cargo people are released on that tile with zero movement. Human wounds persist; no new Medic healing or regeneration rule has been invented.

The encounter layer stores wounds by persistent human ID, logs attacks/casualties in the affected civilization's report/warnings, and records extraction, spread, births, hunger, orders, hits and losses in the testing trace. Formal combat rules can replace these small encounter formulas later.

## Rendering and inspection

All six new assets—nest, larva, runner, armored predator, flat mat and hill mat—appear in the model catalogue and shipped sprite atlas. Total bake entries are **124**, with **69** base catalogue entries. Bodies have simple reusable leg/segment/mandible motion only while travelling. Hidden views pause wildlife too. A stacked xeno tile renders one representative body, prioritising heavy/predator over larva; its inspector lists every body. Nests are separate static objects. Foliage is suppressed visually on the nest's own footprint so the mound is readable; underlying forest mechanics are unchanged. Ordinary foliage can remain over the spreading mat.

The tile inspector shows nest stocks/caps, body health/activity and encounter controls, without unrelated settlement orders. The Testing tab has a separate wildlife summary and nest-focus button. Neither treats the ecology as a human civilization.

## Saves, records and verification

Save schema **10** and world extension **2** add the ecology and migrate supported prior saves, including the unpublished 0.902 world. Existing civilization stocks and progress are retained. Recorder exports now use `alien-planet-test-v3`, including the starting ecology snapshot and deterministic `xenoTick` events with detailed environmental outcomes. Recorded commands can replay both civilizations and ecology without language-model decisions. Start a fresh recording after migration for a complete ecology run. JSON numeric representation is normalised in summaries; deterministic checks tolerate serialization rounding in cosmetic facing while comparing the logical ecology exactly.

**1,757 current checks pass:** 421 rules, 22 UI, 247 model lab, 335 world/art, 55 style, 39 frontier, 185 0.901, 290 0.902 and 163 new 0.903 checks. New coverage includes purple placement, caps, harvesting bonuses, paid mineral births, deterministic ecology through save/load, pursuit/attacks, human retaliation/direct attacks, carrier-casualty cleanup, colony collapse, hunger, invalid references, migration, recorder replay and hidden-view animation. Native OpenGL captures show the unchanged starting scene and a labelled twelve-normal-turn growth fixture. No physical desktop performance test or executable export is claimed.

**Local only.** Versions 0.902 and 0.903 remain unuploaded; GitHub is still 0.901. These notes and preview images are not a backup of the cloud working source.
