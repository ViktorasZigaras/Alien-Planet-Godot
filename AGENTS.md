# Current handoff — 11 November 2026

B08 integrates civilian survival and first military operations. The user
approved B07 and B08 ahead of the B09 interface review. Next is B09, the
integrated 1080p opening and UI rebuild, with Alienopedia at the end.
The roadmap also records early researchable wildlife-repellent towers and
the open mid-game question about repeated district types.

B06 is on GitHub at f8dbb38. B07 is the local F5 ecology review build.
See docs/Batch_0911_B07_Review.md for trial rules and tests. B08 covers
civilian survival and first military operations.

B05 is on GitHub at c2ac076. B06 is the local F5 review build. Open the
exploration controls, right-click to travel, and investigate an identified
site on a stationary turn. See docs/Batch_0911_B06_Review.md. Next B07 covers
foundational ecology, obstructions and settlement pressure.

For future batches, choose reasonable provisional rules or values when the design
leaves them open. State the choice in the progress update and batch review, then
continue without waiting for a reply. Keep those choices easy to revise. Ask only
when a material decision cannot reasonably be inferred or requires approval.

B04 uploaded as `449b258` on explicit instruction. Latest local F5 is B05
(`b05.tscn`): approved provisional growth/support/training numbers, actual
previous-turn operational research, same stock/work interfaces and bounded
larger-population planning. See `docs/Batch_0911_B05_Review.md`. All eight local
suites passed, B05 80 checks. Preserve new evidence under `reports/b05`. B05
awaits play review; next B06 concerns knowledge/anomalies/exploration. Do not
adopt unselected support exceptions or Engineer rates. Earlier notes are historical.

B04 construction is now the default F5 scene (`b04.tscn`). Read
`docs/Batch_0911_B04_Review.md` before further changes. User explicitly chose skip
blocked/held entries and carry effort forward. Preserve separate B01–B03 scenes.
B04 is locally implemented for review; no blanket whole-game acceptance. Next
planned B05 is growth/support/training/research. Do not silently adopt support
exceptions, Engineer bonuses, growth charging or unselected operational gates.
New evidence belongs under `reports/b04`. No upload requested this turn.

Permanent working checkout: `D:\[GPT Playground]\[Alien Planet]\Alien-Planet`.
Update this folder in place; do not work in version-named ZIP extraction folders.
ZIPs beside it are backups. The user removes old extracted versions.
Latest requested presentation adjustment: travel speed and walking cadence 1.5×
the previous B03 trial, with route-duration proportionality preserved.

Latest work: user requested implement/upload; B03 trial in `b03.tscn` now uses
`economy_planner.gd`, actual authorized reserve goals and shared prerequisites.
Read `docs/Batch_0911_B03_Review.md` for scope/evidence. B02 and B03 remain partial
until their documented integrations and user review are complete. B04 queues
have not started. Preserve new evidence under `reports/b03`, not historical paths.

B01 is on main at `c138f6f`. The user reviewed the local B02 trial and explicitly
requested upload after distance-based walking timing changes. B02 is a partial
economy implementation: see `docs/Batch_0911_B02_Review.md` for remaining work.
Run `Run-Local-Tests.ps1` with the standalone Godot 4.5.1 executable in the parent
folder; fresh results go to ignored timestamped `builds/local-tests` directories.

Next planned batch is **B03: shared proposals, legal actions and commitments**.
Trace purpose → prerequisite → allocation → legal command → observed useful
outcome → revision. Enforce actual authorization and reservations of people and
resources, share reusable prerequisites, expose blockers, release commitments
when purpose disappears, and reconsider failed or bad alternatives. No duplicate
reservations, decorative authorization, arbitrary expiry, fixed success scripts,
or claims of competence from command counts. Complete/review the required B02
accounting interfaces before accepting B03. Construction queues belong to B04.

The older restart notes below are historical; current explicit user authorization
supersedes their upload hold. Do not upload screenshots automatically.

# Previous restart — 5 November 2026

Current local build is **0.911-b01-review**. Read `CONTINUE_HERE.md` and `docs/Batch_0911_B01_Review.md` first. The current grouped design and revised batch plan supersede historical S01/Q080 cursors, sprite-map direction and zoom controls. B01 is a deliberately reduced movement/inspection fixture. Await Viktoras's play review and final signoff before any repository push. Always save local source first, preserve a durable archive at completed versions, and keep new test reports separate from historical reconstruction evidence. Do not upload screenshots automatically. B02 accounting/phase decisions remain unresolved and are not silently adopted here.

# Reconstruction boundary — 3 November 2026

Read `docs/RECONSTRUCTION.md` and `CONTINUE_HERE.md` before development. This is newly reconstructed 0.910 code on recovered 0.904, not the original lost checkout. Current validation is under `reports/reconstruction/`; older numbers are historical. The current design review is S01–S18, with S01 first. Preserve a durable source archive at the end of a batch; temporary local Git alone is insufficient. Upload only on explicit instruction.

# Alien Planet project notes

For visual changes, follow `docs/Visual_Style_09.md`: the medium Illustrated Frontier treatment supersedes 0.8 for both sprite and 3D views. Shared palette/model definitions and a developer sprite bake keep them consistent. Also read `docs/Batch_0901_Notes.md` for ground-first rendering, visible-content sprite bounds, shared view/control directions, cargo and configurable base models. Read `docs/Batch_0902_Notes.md` for isolated civilization states, shared map projection, claims and the optional action recorder. Read `docs/Batch_0903_Notes.md` for non-civilization xeno ecology, provisional encounters, biomass/mineral costs, mat overlays and schema 10 / recorder v3. Future versions use 0.9xx. Game rules must not depend on rendering style. Capture real default opening scenes for previews; label any staged fixtures.

Keep source changes in the working directory and update the existing high-level development log after batches. Upload only when explicitly requested. The parent workspace AGENTS.md contains the log identity and working agreement.

Read `docs/Batch_0904_Notes.md` for current combat, cleansing, upkeep/capacity, schema 11/world 3 and recorder v4. Historical local-only upload notes in earlier batch documents are superseded by the explicit request to upload all work with 0.904. The archived 200-round test failed to disable the nest; retain that outcome rather than tuning/rerolling it into a victory without a new request.
