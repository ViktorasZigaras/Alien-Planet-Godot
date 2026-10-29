# Technology demo — local 0.3

These are starter capabilities for testing interactions. Costs, outputs, staffing and prerequisites are provisional; no deeper economy analysis or balance work was performed.

| Area | First capability | Second capability | District / workplace | Terrain work | Resource specialist |
| --- | --- | --- | --- | --- | --- |
| Biology | Cultivation | Closed Ecology | Agriculture District / Greenhouse | Farm remains a known starter improvement | Farmer → Food |
| Industry | Standard Tooling | Precision Assembly | Production District / Workshop | Roads remain known; Precision Assembly unlocks Mine | Engineer → Industry |
| Military | Field Security | Perimeter Defence | Security District / Guard Post | Watchtower → +1 Influence when worked | Security for Guard Post; Administrator also benefits |
| Exploration / Research | Field Methods | Field Coordination | Research District / Research Lab | Survey Beacon → +1 Research when worked | Scientist → Research |
| Social | Technical Education | Civic Exchange | Civic District / Exchange | Trade Post → +1 Credit when worked | Administrator → Influence; Merchant → Credits |

Field Coordination keeps the earlier demo's cross-area prerequisites and Influence cost. Precision Assembly still requires both Standard Tooling and Technical Education. Other new second-level capabilities depend on their first capability. The Technology view displays these actual prerequisites and resource costs.

## Simple operating rules

- All training requires Technical Education. A resource specialist also requires its own named capability. Training is still a resident Worker service at Main Base: 4 Credits, two turns.
- General Specialist remains available for old saves and the existing demo. The population atlas also supplies its own sprite.
- Farmer, Engineer, Merchant, Scientist and Administrator add one unit of their matching resource to tile jobs that already produce that resource. They do not produce that resource from every terrain type.
- Buildings have one staffed job. Their card names the resource, base output and upkeep; qualified staff has a simple bonus. Empty buildings produce nothing.
- Every town can have one of each district type. Every district occupies its own suitable hex and contains its corresponding workplace. Districts cost 2 Industry / one turn; workplaces cost 6 Industry + 2 Credits / two turns and maintain one Credit per turn. Existing starter facilities retain their old rules.
- Idle Workers and Engineers can construct. The shared construction slot remains.
- New improvements use 1 Industry / one turn. A hex may have one site improvement plus a Road. Mines require hills; Farms require clear flat plains; other site improvements need passable land outside towns/districts. All remain local construction within two hexes and cohort supply.
- Military additions currently demonstrate training, staffing, Influence and map work. There are no enemies, combat or invented defensive bonuses.

## Technology view and art

The top toolbar opens a larger Technology window with a tab for every area and two cards per tab. Cards show prerequisites, costs, available stock, unlocks, missing requirements and completion. The side Technology tab opens the relevant area directly.

`assets/population/population_roles_v1.png` is the generated transparent atlas. The eight roles are Worker, Farmer, Engineer, Merchant, Scientist, Administrator, Security and General Specialist. Region metadata in `data/population_sprites.json` selects each sprite without modifying the original PNG. Map markers and UI portraits use these alpha-bearing sprites; the old opaque population crops are no longer selected for known roles.

New saves use schema/rules version 5. Import migrates old saves and old Production Districts, including projects in progress, without changing population IDs or production totals.

This batch and the previous 0.2 batch are cloud-only, awaiting an explicit GitHub upload request.
