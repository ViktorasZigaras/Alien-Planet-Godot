# B09 opening and interface review

F5 opens Landing Station with two ordinary civilians, a rifle Soldier, an
Explorer and one reusable build kit. The provisional stores are 16 Food,
4 Minerals, 2 Industry and 10 Energy. The two civilians start on the best
available Food jobs and can be reassigned. The initial Food forecast is
neutral on this fixed map.

The interface follows the map-first organization, status bars, city
management and contextual actions of Civilization IV. The slate panels,
brass borders, 3D unit portraits and field assets belong to Alien Planet.
[Reference map and city views](https://www.sullla.com/Civ4/WCLT.html)

- Double-click Landing Station or use Colony to see contributors on the
  left, the map in the center, and assignments and production on the right.
- Pan with middle drag or arrows and click or drag on the minimap. Home
  centers Landing Station. I cycles idle cohorts. Click a shared hex
  again to cycle its occupants.
- Right-hold previews a route or legal attack. Release to order it.
  Esc cancels. The unit dock shows the selection, conditions and orders.
- Research cards show effects, costs, recent operation requirements and
  blockers. The resource strip shows stock and forecast together.
- F1 opens Alienopedia. Special sites appear after identification and
  wildlife entries after a sighting. The reference can stay open beside
  the map. B09 uses its own save.

## Visual passes

The first native captures showed excess negative space and a station label
with too little contrast. The second pass brought the camera closer,
lowered its angle, added local shadows and a quieter backdrop, and put the
station and shared occupancy in clear plaques. Portraits were rendered from
the existing 3D models. A staged crowded view exposed yield icons covering
the station banner. The final pass puts the banner above yields, shows the
project blocker inline and retains the route preview and shortage cues.

Final 1920×1080 captures are in reports/b09. Opening is the ordinary state.
BusyColony and Alienopedia use a staged set of field crews and observed
animals so the crowded UI can be inspected without changing the opening.
Research and Colony show the ordinary opening.

## Checks

Godot 4.5.1 import and all twelve suites passed. B09 passed 20 checks,
including the five UI tasks, the opening roster, save validation and an
automated Farm completion with nonnegative Food. The checks exercised
the native controls and selection signals. The visual passes used actual
GPU captures, including a 90-frame busy pan.

On the Radeon RX 7700 XT used for capture, the opening median was 17.2 ms
and the busy pan median 30.5 ms. The corresponding 95th percentiles were
30.8 and 31.0 ms. This is a local fixed-map measurement. The busier pan
remains slower than the opening, and a longer campaign balance assessment
is pending.

Next B10 covers deliberate expansion, roads and faction presence. Early
repellent towers and the open mid-game district-type limit remain in the
roadmap.
