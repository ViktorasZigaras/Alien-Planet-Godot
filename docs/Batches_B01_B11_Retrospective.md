# Alien Planet B01–B11 review

## What the batches established

B01–B04 made the turn loop accountable. Movement and terrain costs became observable. The economy distinguished work plans from paid work. Construction became a queue with a reusable kit, blocked and held work, and leftover effort carrying into the next eligible project. That gives a player a reason to inspect a tile before committing a worker or stock.

B05–B08 added competing uses for the same people and supplies. Growth, training, research, scouting, pollution service and defence all draw on a small opening economy. The strongest link is scouting → work or construction opportunity → a decision about safety. The weakest link is how often those choices visibly change the best opening plan. The batch suites largely test an action or transition in isolation. They cannot establish that training, expansion or improvement are comparably attractive in the same playthrough.

B09 did the most to make the pieces feel like one game. The map remained central, Colony and Research became distinct views, and right-click previews made orders inspectable. The icon console made routine commands more compact and gave projects recognizable model thumbnails. Some actions still require hovering to learn their meaning. This is most noticeable for uncommon unit commands and tool-like top-bar controls. In the next play review, watch for repeated hovering after the first few turns and for places where the relevant cost or blocker sits outside the current view.

B10 and B11 start to test the design away from the original fixed opening. The founding trial showed that the player can reach, pay for and work an outpost from the starting stockpile. Connected roads affect routing. B11 tested 40 seed-and-size combinations for connected geography, legal starts and related invariants, with three native captures for visual review. These are good checks for broken maps and awkward camera framing. They are thin evidence for balance. Keeping the largest landmass and reserving two clear food sites deliberately narrows the starts the generator produces. The sample does not tell us whether rivers, coast and wildlife create materially different plans.

## Where the design is still provisional

The outpost is a one-cohort food operation with a shared reserve. It tests expansion, exclusive work areas and vulnerability. It has yet to prove a satisfying second settlement with its own production, storage and growth. The Survey Compact is passive. The value of roads and defensive posts will be easier to judge once there is a sustained reason to travel between places. Starting-stock and automated-turn tests can hide this gap because they can succeed without a meaningful frontier trade-off.

Tile art now supports a wider variety of starts. Biome blending improves continuity, but water and rivers still trace hex edges, and an explored tile looks more detailed than its surroundings. The current unit pass tackles the next readability problem. At map zoom, helmet, pack and shoulder shape need to identify a role before the player reads the roster. Detailed portraits reinforce that recognition. Walking timing has already been tuned and should be the comparison baseline.

## Six-turn comparison

I ran two scripted openings on each of two seeds at 16 × 11. Farm-first queued a legal visible farm and enabled automatic settlement work. Outpost-first sent a builder to the cheapest reachable hex three steps from Landing Station in hex distance, then tried to found and staff it on arrival. Automatic defence used its default setting. The scripts followed those plans for six turns without choosing an alternate destination or clearing terrain.

| Seed | Farm-first | Outpost-first |
| --- | --- | --- |
| 731 | Farm complete by turn 3. Food 7, Industry 0 at turn 7. | Obstruction blocked founding at 1,7. Food 4, Industry 2 at turn 7. |
| 984 | Farm complete by turn 3. Food 3, Industry 0 at turn 7. | Outpost founded on turn 1 at 1,6. Food 18, Industry 0 at turn 7. |

The two starts make expansion behave differently even under the same simple policy. On 731, the cheapest route reached a site that needed clearing. On 984, it reached a site the founder could use immediately. This is evidence that route cost alone is a poor founding criterion. It also exposes a presentation question: does a player understand the obstruction as soon as they can observe it, and can they switch to clearing or choose a different site without searching through panels? Farm-first spent time under automatic work assignments. The Food figures compare those specific scripts and do not rank the best versions of either strategy.

## Suggested next play review

Play the same short opening twice on the same seed, once improving Landing Station and once pursuing an outpost. Then try an alternate seed with a different shoreline or river. Record when the first real trade-off appears, which action is hard to find, how much food and industry the plans leave, and whether the road or garrison changes the decision. A meaningful difference between starts would tell us more about B11 than another large connectivity sweep. This also gives B12 a clear test for diplomacy: a faction contact should change a decision about access, security or resources already visible in play.
