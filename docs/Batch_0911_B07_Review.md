# B07 ecology review

Godot 4.5.1 import and all ten suites passed. B07 passed 23 checks. Results
are stored under reports/b07.

F5 opens the same settlement map with flora, obstacles and a resource-driven
nest. The nest prefers distant fungal ground and falls back to the farthest
land hex. Larvae collect biomass and minerals, gain harvesting benefits on
xenomass, and spend nest biomass to spread it. Nests spend stocks on upkeep
and hatching. Vegetation replenishes one biomass every third turn up to three
when pollution is below two. Predators roam and pause movement through occupied
hexes. Human attacks and pursuit are deferred to B08.

The management panel displays health, containment, backlog and the latest
waste ledger. The provisional rules are:

- One waste per actual Industry output, plus one per two productive residents
  rounded up. A local forest reduces generation by one.
- The tank holds four. A staffed Waste service treats up to three contained
  waste per turn. Excess deposits up to three pollution per land hex around
  the station. Any overflow remains in the backlog.
- Existing terrain penalties apply to polluted or obstructed land. Flora,
  forest and obstacles block new farms and districts. A builder with the
  reusable kit needs two stationary turns on the selected hex to clear it
  or remove up to two units of spilled pollution. Terrain work uses the
  builder's construction time.
- Health changes by two recovery per turn, six more per staffed Medic and
  three less per unit of local exposure. Growth pauses below 70. Medics
  use the existing training time and cost.
- Repellent costs two unreserved Energy and covers one visible land hex
  for three wildlife turns. Roaming predators avoid that hex where a
  clear step exists. It has no effect on nest ownership or larval work.

Automatic settlement planning considers waste treatment and penalizes
forecast spills. The player orders field cleanup, clearing and repellent.
The map uses observed terrain snapshots under fog. The fixture gives a
local pressure and route test. Full campaign balance and regional scale
remain to be reviewed. B07 has its own save.
