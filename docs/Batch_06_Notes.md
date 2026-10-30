# Version 0.6 — economy, people and geography playground

Local working version; no GitHub upload is authorised by “note and begin.” These are provisional testing rules, not a balance pass. The HTML prototype and the existing 3D model lab are unchanged.

## Geography and navigation

A reproducible **24×16** axial-hex world (seed **731**) replaces the 9×7 test map. Five broad regions use warped nearest-region seeds: Temperate, Lush, Dry, Cold and Fungal; Coastal marks water. This is a small region generator inspired by the idea of Minecraft biome patches, with original content. It does not simulate a planet's weather or tectonics. `PlanetMapGenerator.generate(seed,width,height)` allows other seeds/dimensions; landing/site examples remain deliberately fixed for repeatable tests.

Regions guide Plains, Grassland, Desert, Tundra and Fungal terrain, forest likelihood and food-deposit context. Water is impassable. Forest and Hills are independent overlays, each −1 Food/+1 Minerals; both may coexist. Food floors at zero after all modifiers. A river is a shared edge, adds +1 Food to each bank (once per tile), and costs +1 to cross. Ore/vent occurrences are hilly; desert food bonuses are Oasis Fruit. Food and Mineral occurrences outnumber each rare bonus category. All five bonus-yield categories are deliberately demonstrated near Main Base; a cultural inhabited site is at 8,3 and a research site at 15,7.

Click selects on release. Left or middle drag pans, the wheel zooms, and Fit map shows the whole world. Startup focuses the landing area. Reference-art terrain is tinted by base terrain, with separate hill/forest marks; compact hexes have a narrow grid. Yields wrap into small two-column panels. The strategy view is still 2D.

## Economy and growth

| Resource | Role |
| --- | --- |
| Food | Shared stock; people consume 1/turn; local food output contributes to growth |
| Minerals | Raw extraction; consumed by conversion |
| Industry | Secondary construction/manufacturing stock; never extracted directly from terrain |
| Energy | Shared stored resource; operating costs gate building/district output |
| Science | Research costs; rudimentary baseline/passive and terrain sources, stronger staffed facilities |
| Culture | Social technologies/developments and cultural workplaces/sites |

Each inhabited settlement has a tiny starter supply: 3 Food, 1 Mineral, 3 Energy, 1 Science and 1 Culture per turn, plus a one-unit Minerals→Industry converter. That converter consumes the baseline Mineral. This is intentionally enough for bootstrapping. Stocks remain shared; growth and equipment stocks belong to towns. A mobile person remains part of their home settlement until joining another.

**Growth/turn = local Food output − consumption − population size + medical reduction.** It is distinct from the shared Food stock. Accumulate 20 growth for an idle Worker, automatically; negative growth reduces the meter toward zero and does not kill people. Food is not charged a second time at birth. Empty Food stock prevents positive growth. A powered Clinic contributes medical reduction; Medics are better at it, and surplus above the size penalty genuinely increases growth. This supersedes the earlier instant 20-Food town button.

Profession workplaces use 1 Energy/turn at tier 1, 2 at tier 2; districts use 1. They provide small passive output plus per-worker output, with role bonuses. Tier 1 has one distinct job slot, tier 2 has two. The Training Module is a service rather than an income workplace. Workshops convert 1 Mineral per Industry produced; Generators convert 1 Mineral per Energy produced. Shortage caps conversion to available inputs. Unpowered facilities produce nothing; powered districts do not guarantee enough remaining Energy to run their buildings. Generators run first so they can bootstrap from basic town power, followed by other facilities in stable identifier order. Tier 2 upgrades cost 6 Industry, require an idle local suited builder, and are immediate in this shell.

## People, equipment and professions

Eleven roles: Worker, Biologist, Extractor, Engineer, Scientist, Medic, Merchant, Administrator, Soldier, Explorer and Artist. Training costs 2 Industry and two turns, requires Technical Education plus the specific role technology, and works at either town. One shared training project and one shared construction project keep this a small shell.

Biologists improve Food extraction, forest timber Minerals and biological specimen/Fungal Science. Extractors improve Minerals. Engineers improve industrial conversion and generation. Scientists improve Science. Medics improve Clinic reduction. Artists improve Culture. Merchants double inhabited-site visit rewards; Administrator and Soldier have workplace examples. Further Soldier/Explorer benefits remain for later development.

People retain identity separately from profession, job and equipment. Equipment stocks are local: **Small Arms, Rover, Work Suit, Survey Kit, Reinforced Suit**. Manufacture spends Industry and adds one item immediately to the selected stock. Equip/return is a free town action for residents, with one of each item per person and no durability system. Any profession can combine transport, arms and suits. A Rover gives its wearer 3 movement/turn; ordinary foot movement is 1. The old standalone Rover becomes an equipped persistent person on import; there are no detached vehicle units.

**Builder** means a person wearing a Work Suit or Reinforced Suit, not a twelfth profession. Only idle resident builders construct buildings/districts/improvements. Costs: district 2 Industry/1 turn, building 6 Industry/2 turns, improvement 1 Industry/1 turn. Clear specialty restores Worker qualification while retaining identity, gear and current resident job, allowing later retraining.

Small Arms and Soldier training expose different attack/defence capability values, including weak ordinary defence. This batch does **not** introduce enemies, combat resolution or a combat sandbox; these values are preparation for those later systems. Survey Kits improve worked Science. New profession portraits reuse the closest existing transparent sprite as a temporary visual proxy; no claim of eleven newly generated portraits. The earlier eight-outfit 3D art studies keep their original labels.

Both inhabited sites accept an explicit Visit by any deployed person. Rewards go to shared supply, once per person/site: +3 Culture or Science, doubled for Merchants. This is a deliberately small, persistent example, not recurring trade/diplomacy.

Repeated professions, settlement equipment stock and tile/building job categories show `(count)`; individual people, job slots and locations remain selectable beneath their grouping.

## Technology and movement

There are **20 technologies, four per existing group**. They cover training, five equipment types, nine improvements, eight district workplace types and tier 2 upgrades. Advanced nodes can require earlier technologies, a building, a qualified person and retained resource stocks; the cards explain every condition. Requirements are checked when purchasing a tech, globally across the expedition; only its Science/Culture price is spent. Losing a prerequisite worker or consuming the retained Minerals later does not erase already learned technology.

| Biology | Industry | Military | Exploration / Research | Social |
| --- | --- | --- | --- | --- |
| Applied Biology | Standard Tooling | Field Security | Field Methods | Technical Education |
| Managed Ecology | Material Extraction | Perimeter Defence | Planetary Surveying | Civic Exchange |
| Clinical Practice | Power Systems | Protective Equipment | Field Coordination | Creative Practice |
| Regenerative Care | Precision Assembly | Defence Logistics | Scientific Instrumentation | Public Institutions |

Ordinary land steps cost 1, Forest +1, Hills +1, river crossing +1. Road→Road costs ⅓ plus the crossing cost. Entering a road from off-road and leaving roads use destination terrain cost. There are no automatic bridges. Expensive terrain is traversable across turns: paid progress toward the next step is saved while the person remains at the origin. Shift-right-click appends and retains this progress; right-click replaces the route and moves immediately with remaining movement. Replacing/cancelling discards progress tied to the abandoned step and never refreshes the turn allowance. Invalid replacement leaves the previous valid order intact. The Move button follows the same queue rules, without confirmation.

Expedition reach is deliberately generous (100, then 120 with Field Coordination) so the larger map can be explored. It limits a planned path's cost; displayed supply distance is the nearest settlement's hex distance. This is an explicit simplification of the old Main-Base-only logistics demonstration, pending future supply design.

## Saves and checks

New saves use schema/rules version **6**. Old versions 1–5 migrate resource names, qualification names, building slots, district types, training/construction projects and queued Rover orders. Existing terrain is retained inside the expanded generated world. Existing completed technologies receive newly introduced prerequisite technologies so previously earned unlocks survive. Initial stock defaults apply only to new games, not imported saves.

Current checks: `tests/test_batch.gd`, `tests/test_batch_ui.gd`, `tests/test_model_lab.gd`. Earlier economy/HTML parity tests are retained under `tests/legacy_v5` as historical specifications, not counted as passing current tests. The initial-state template is separate from the legacy migration fixture. No physical Windows testing or standalone export is claimed.
