# Version 0.901 — visibility fixes and people transports

## Debugging findings

The published 0.9 files matched the development files, including all SVGs. A fresh source-only import reproduced the sparse picture without a missing-resource error. The failure was in presentation: the sprite map interleaved ground and objects, allowing later neighbour ground to cover earlier objects; object atlas cells also contained substantial camera padding. Presence/nonempty-image tests did not establish useful visible size.

The map now draws the ground first, then objects. Visible-content bounds are cached as flat atlas regions and sized by category. Resources, forests, structures and people gain usable screen space; hills retain their ground footprint. Worker portraits also use tight regions. Figures and resources are offset from one another, and a vehicle stands in front of a settlement rather than covering its tower. Unknown map sprite keys now produce a warning and a visible pink fallback, rather than silently disappearing. The existing medium geometric art remains an approximation of the earlier generated art concepts; this fixes visibility, not the entire difference in illustration quality.

## Shared view / controls

Both views now have the same cardinal orientation: increasing q/east is screen right, increasing r/south is down. The 3D camera has zero azimuth; it retains its isometric elevation. Both initially frame the same 4,3 area. Horizontal dragging keeps its existing direction; vertical dragging is inverted in both. This changes camera navigation, not tile adjacency or pathfinding. In 3D the existing ground-projected drag formula already had inverted vertical behaviour; only the sprite sign needed changing. Checks measure actual projected screen displacement.

## Transports

Rover is displayed as **Transport**. The saved equipment key `rover` and five-bone model class remain stable implementation identifiers.

- The existing equipped person drives the Transport. It can carry **two additional people** of any of the eleven professions. This retains the existing driver model rather than adding independent vehicle entities during this prototype pass.
- Select the deployed Transport in the mobile bar. Its orders panel lists eligible co-located people and cargo. Set a resident to Idle before boarding; a co-located mobile person can also board. No profession, gear requirement or Industry charge is imposed on a passenger.
- Boarding cancels that passenger's independent route and makes them carried cargo. The same ID, qualification, equipment and home remain. They continue to count for home Food consumption/population. Their effective tile follows the carrier; they do not render or move independently.
- Unload one person at a time onto the Transport's current tile. They become mobile with zero current movement, refreshed next turn. They may join a settlement on that tile. This avoids gaining free movement from load/unload loops.
- The driver must unload passengers before joining a settlement. A loaded Transport cannot itself board another Transport; self-carrying, invalid carrier references and capacity overflow are rejected. Rejected commands preserve state.
- Schema **8** records the new cargo state. Schema 7, 6 and older supported saves migrate; existing equipment, identities and queues are retained. Version 0.9 cannot load new schema-8 saves.

Transport travel takes **0.40 seconds per crossed hex**, twice the former 0.20. Wheel spin is **3 radians/second**, half the former 6. Walking people retain 0.20-second steps. Turn movement points, terrain costs and queue progress are unchanged. Motion Off still snaps to the authoritative destination.

## Model library

The World asset catalogue lists **63 base entries**, including one entry for each of eleven people. Profession tools, Small Arms and exoskeleton type are independent controls for the selected person, not six duplicate dropdown entries per profession. Tools use separate attachment groups, without new bones or a second person. The complete **118-variant sprite bake** remains internal so all in-game loadouts still have sprites. The original comparative study tabs remain reference studies.

## Checks and visual review

1,291 current automated checks pass: 421 rules/content/migration, 22 native UI, 247 model lab, 322 world/art, 55 style, 39 frontier and 185 new 0.901 checks. New coverage includes every profession as a passenger, capacity, upkeep, saved cargo, invalid carrier/overload rejection, movement/unload, base/configuration catalogue behaviour, actual screen directions and halved animation speed. Headless editor import and native OpenGL opening/developed-fixture captures are checked. Opening captures assert unchanged starting simulation; developed fixtures are labelled in their capture script and are not new-game content. Physical desktop play/performance testing and executable export remain pending.
