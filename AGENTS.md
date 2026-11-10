# Current restart — 5 November 2026

Current local build is **0.911-b01-review**. Read `CONTINUE_HERE.md` and `docs/Batch_0911_B01_Review.md` first. The current grouped design and revised batch plan supersede historical S01/Q080 cursors, sprite-map direction and zoom controls. B01 is a deliberately reduced movement/inspection fixture. Await Viktoras's play review and final signoff before any repository push. Always save local source first, preserve a durable archive at completed versions, and keep new test reports separate from historical reconstruction evidence. Do not upload screenshots automatically. B02 accounting/phase decisions remain unresolved and are not silently adopted here.

# Reconstruction boundary — 3 November 2026

Read `docs/RECONSTRUCTION.md` and `CONTINUE_HERE.md` before development. This is newly reconstructed 0.910 code on recovered 0.904, not the original lost checkout. Current validation is under `reports/reconstruction/`; older numbers are historical. The current design review is S01–S18, with S01 first. Preserve a durable source archive at the end of a batch; temporary local Git alone is insufficient. Upload only on explicit instruction.

# Alien Planet project notes

For visual changes, follow `docs/Visual_Style_09.md`: the medium Illustrated Frontier treatment supersedes 0.8 for both sprite and 3D views. Shared palette/model definitions and a developer sprite bake keep them consistent. Also read `docs/Batch_0901_Notes.md` for ground-first rendering, visible-content sprite bounds, shared view/control directions, cargo and configurable base models. Read `docs/Batch_0902_Notes.md` for isolated civilization states, shared map projection, claims and the optional action recorder. Read `docs/Batch_0903_Notes.md` for non-civilization xeno ecology, provisional encounters, biomass/mineral costs, mat overlays and schema 10 / recorder v3. Future versions use 0.9xx. Game rules must not depend on rendering style. Capture real default opening scenes for previews; label any staged fixtures.

Keep source changes in the working directory and update the existing high-level development log after batches. Upload only when explicitly requested. The parent workspace AGENTS.md contains the log identity and working agreement.

Read `docs/Batch_0904_Notes.md` for current combat, cleansing, upkeep/capacity, schema 11/world 3 and recorder v4. Historical local-only upload notes in earlier batch documents are superseded by the explicit request to upload all work with 0.904. The archived 200-round test failed to disable the nest; retain that outcome rather than tuning/rerolling it into a victory without a new request.
