# Local version 0.902 — civilization claims, a separate red player and testing records

## Requested scope

Viktoras requested a two-tile claim radius around both blue starting settlements, showing only the combined outer ring with small stones at hex corners. Add a separate red civilization farther south in green terrain, with the same rules and technology tree but no shared economy or progress. Its initial interests are population, tile development and research; defence will follow when combat is introduced. Prepare action/outcome logging for later function-driven simulated games. **Do not upload this batch.**

## World and ownership

Blue retains Main Base and Field Station. Red Haven is at **10,8**, in a clear grassland/lush starting patch, with an ore hill at 8,9. This small test landing area provides room for work and district testing; it is not a balanced competitive start. Red begins with five Workers, ordinary starting resource stocks, local equipment stock and the same basic Lab/Civic/Training services. It receives no completed technologies or automatic free construction.

Each civilization has its own complete rule state: stocks, people, equipment, completed research, buildings, districts, improvements, visits, movement queues, training and construction. Both use the existing `GameRules` engine and immutable content definitions. Only map geography and the world-turn schedule are shared. Red's commands cannot spend blue stocks, advance blue research or select blue people. Home population/food calculations remain local. This is not diplomacy, trade, war or fog of war.

`CivilizationSession` retains blue's compatible rule-state fields at the top level and holds red's independent state in `civilizations.red`. Rendering uses a combined, presentation-only projection with explicit person/town owners; supply/yield context retains blue's perspective. Selecting red people/towns is observational. The Testing tab intentionally exposes both players' summaries for development.

Claims are the union of radius-two hexes per player's settlements. Adjacent same-player claims have no internal border. The renderer draws boundary edges and deduplicated corner stones with blue/red caps, in both sprite and 3D modes. Existing map grid lines remain. A thin coloured line connects the stones; water remains part of the radius, without a separate sea-ownership mechanic. Where future claims overlap, the nearest town currently wins, with stable blue-first tie breaking. No capture mechanic is implied. Foreign claims block new tile assignments/construction/improvement commands; visiting/moving through land is not combat.

## Function-driven red policy

`CivilizationAgent.pick(state)` returns an ordinary command and a short rule label. It does not call a language model or use hidden stock grants. Each blue End Turn advances blue, lets red choose up to eight actions, then advances red's economy/projects once. Both are saved at the same completed world turn.

The small deterministic policy assigns food/workplace staff, reserves a suited builder, researches available nodes, trains missing professions, builds districts/workplaces and farms worked tiles. Five clear plots are reserved for districts to avoid trapping the builder behind its own tile assignments/farms. Stable ordering of people, tiles and jobs makes choices independent of JSON dictionary order. It is deliberately simple and has not been strategically optimised or balanced. Energy/input shortages and other weak decisions remain useful observations for future balance tests.

The policy profile records population/tile-development/research interests and **defence deferred until combat**. Soldier training and existing security facilities can develop through the ordinary tree, but no fighting, retaliation, opponents' damage, capture or victory logic has been invented in this pass.

## Testing tool

Open **Testing** to focus either side, compare separate summaries, start a recording, finish it manually, and export JSON. Recording is off by default. Starting a new recording replaces the previous trace and captures full initial states. While on, accepted/rejected commands from either civilization record:

- logical sequence and turn, player ID and exact command;
- the selecting policy-rule label, or `human_command`;
- accepted/rejected status and engine message;
- before/after resource, population, growth, technology and development summaries.

These are observable action traces and condition labels, not private GPT reasoning. Red and blue can both be driven through `CivilizationSession.command_for`; the normal UI's End Turn is the current two-player coordinator. Future simulated controllers can supply ordinary commands through the same interface. A dedicated batch runner and combat controller are not part of this preparation.

Exports use `alien-planet-test-v1`: map seed, initial states, ordered events, dropped-event count, final summaries and an outcome object. Manual finish records `stopped`; no winner is inferred. `finish_recording(state,status,detail)` is the future outcome hook for combat/test code. The trace is bounded at 10,000 events and reports dropped events explicitly; a truncated trace must not be assumed fully replayable. The save import limit is 64 MiB to accommodate recordings. Exports and saves are local until the user chooses otherwise.

## Persistence and checks

Save schema **9** prevents the older 0.901 game from silently ignoring civilization state. Supported older saves migrate: blue people/progress are kept and red is added to the shared map. Full world saves preserve both civilizations, the red policy profile and the optional recorder. Invalid nested rival states, duplicate object identities, mismatched geography/turns and malformed record fields are rejected.

Current checks total **1,579**: 421 rules, 22 UI, 247 model lab, 323 world/art, 55 style, 39 frontier, 185 0.901 and 287 new 0.902 checks. They cover closed claim rings, radii/ownership, separate equipment/research/economy, foreign-order rejection, both rendered players, save migration, recording rejected/accepted commands, exported-command replay and two deterministic 65-turn runs (one repeatedly saved/reloaded). In the current scenario red grows beyond five people, develops five districts and improvements, and completes all twenty technologies within that run; blue receives no research or infrastructure from it.

Actual native OpenGL captures include both starting claim borders, Red Haven in 3D, and a labelled 65-turn development fixture produced through normal commands. Opening captures assert unchanged simulation state. No physical desktop performance test or executable export is claimed. Source changes remain local; GitHub is still 0.901.
