# B11 seeded maps and tile art

F5 opens a 16 × 11 hex world on seed 731. Open Orders → World survey → New map to try another seed or dimensions. A new map starts a new expedition. Save and Load use the B11 slot, which retains the seed, dimensions and played state. B10 and earlier fixtures can still be opened from their scenes.

Generation shapes the coast with seeded noise and keeps the largest connected landmass. The river follows adjacent land edges. The landing algorithm prefers a flat site with reachable work, then guarantees two clear nearby grassland work sites. The nest is distant and on reachable land. Deposits, vegetation and obstructions vary by seed. Exploration continues to mask unobserved deposits and wildlife. Founding, roads, and resource and movement costs use B10's rules.

The visual pass blends neighboring biome pigments in world space, joins the ground meshes, shades hill slopes, and adds sand, shallow water and foam along the coast. River edges use a bank and a separate water channel. The minimap scales to custom dimensions. Coast and river geometry still follows hex edges. The art samples show opening visibility and native game zoom.

The automated trial samples 40 seed and size combinations, including 9 × 7, 30 × 22 and both narrow aspect ratios. It checks deterministic geography, connectivity, starting jobs, wildlife and deposit disclosure, save validation, opening turns, and regenerating from the in-game dialog. The three native 1080p pan samples on this PC ran at about 17 ms median and 17–19 ms p95. The first terrain build took about 1.0 s with warm builds of 0.15–0.44 s in the same capture session. These samples cover playability and rendering under this workload. Starting positions still need broader balance testing.

The next proposed presentation pass is the civilian, Explorer and rifle soldier. B12 covers diplomacy.
