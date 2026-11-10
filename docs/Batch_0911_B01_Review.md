# Alien Planet — B01 implementation review

5 November 2026 • 0.911-b01-review • Pending Viktoras's download/play review and final signoff

## Source and scope

Remote main was refreshed and remains `8a9f3d6a9f9787bc11e8489f5426f9d3a650395c`. The reconstructed archive SHA-256 is `61d512d90935a03dcb82e047c465d514bc7928a521979edca12e752224a7a288`; all entries in its source manifest matched before edits. The untouched R00 local copy and already preserved baseline archive remain available. The original lost 0.910 is not recovered.

Implemented the first approved batch only: a 9×7 crop of the existing seed-731 map, one existing settlement identity and one mobile untrained Worker. This is the batch plan's reduced development fixture, not a new final opening/scenario. Its stocks are zero/inactive and ordinary End Turn refreshes movement only. No legacy economy, growth, research, construction, ecology or AI is silently active. The prior complete three-faction scene and its source/assets remain available separately.

## Changes and ownership

- Added `shell_fixture.gd`, `shell_ui.gd` and `b01.tscn`; default project view is 1920×1080 and actual 3D with a fixed camera scale, contextual inspector, route preview, bottom unit strip, top save controls and optional command recording.
- Selection/camera/motion live in presentation. Selecting a person no longer runs `mark_used`, changes representative priority in saved game state, triggers a council, or copies the recorder. The renderer chooses the selected stack representative without changing cohorts.
- A permitted map snapshot updates only after a world-changing command, load or reset. Hover and selection reuse it. The unused full-map supply query is removed from the 3D renderer. `own_state` excludes rivals/history before copying rather than copying and discarding them.
- B01 has one authoritative terrain/ecology record and no rival map copies. The broader historical multi-faction ownership migration is deferred to the relevant capability; this batch does not claim it is solved globally.
- Shell commands use the shared session interface and existing movement legality/effects. Legacy focus commands are harmless read-only compatibility calls. Unsupported shell mechanics give explicit reasons.
- Separate B01 save envelope stores game and view independently, including route/partial payment, selected hex/unit, camera and motion. Strict fixture identity checks prevent a malformed renamed cohort from passing validation then crashing the UI. Bad imports retain the current game.
- Historical reports are retained byte-for-byte. The reconstruction test can direct new outputs to a different directory; fresh replay/check data is in `reports/b01/reconstruction`.

## Functionality

Godot 4.5.1 Standard on Linux. B01 checks cover legal/illegal movement, rough-terrain partial payments, available route choices, append/cancel, one intent applied/recorded once, JSON continuation, full physical replay, read-only selection, unchanged projection count during selection, camera pan/fixed scale, ray picking, real file save/load, malformed import rejection, motion-off versus no-presentation parity, and Space with a focused button advancing once.

| Suite | Checks | Result |
|---|---:|---|
| B01 | 39 | Pass |
| 0.901 movement/person regression | 185 | Pass |
| Reconstruction/session/replay | 232 | Pass |
| 3D world/stack/model regression | 381 | Pass |
| Total | 837 | Pass |

These are fresh targeted checks, not a rerun of every historical suite or the long campaign. A renderer regression exposed selected-stack visibility after selection became read-only; this was fixed in presentation, then the renderer suite passed. Test teardown now waits for deferred terrain construction, avoiding a false shutdown error. Native screenshot is the actual default fixture; no artificial supplied actors or generated concept art.

## Performance

Same-host sequential comparison of the same saved B01 fixture, same camera, same 1080p viewport and software OpenGL; 100 calls for each CPU measurement. The common script is `tests/bench_b01.gd`, with its immutable input `reports/b01/benchmark_state.json`. The baseline is the unchanged reconstructed source; candidate code changes were loaded before the run. Recording mode uses the same bounded existing trace; it is not a stress benchmark of 10,000 events.

| Measurement | R00 | B01 |
|---|---:|---:|
| 100 focus commands, recording off | 77.53 ms | 0.37 ms |
| 100 focus commands, recording on | 89.12 ms | 0.28 ms |
| 100 own snapshots, recording off | 29.33 ms | 16.94 ms |
| 100 projections, recording off | 52.30 ms | 33.84 ms |
| 100 repeated 3D updates | 148.53 ms | 13.12 ms |
| Map-only frame median / p95 | 76.09 / 240.70 ms | 56.26 / 106.39 ms |
| Static memory, map-only sample | 39.10 MB | 39.02 MB |
| Identical serialized sample | 32,543 bytes | 32,543 bytes |

CPU improvements have a direct cause: eliminated focus work, earlier exclusion of irrelevant data, and removal of unused routes. One short software-rendering sample cannot establish a reliable frame-speed improvement; render geometry is essentially unchanged and scheduler noise is substantial. The actual full-shell capture separately sampled 120 frames: median 36.65 ms, p95 47.19 ms, maximum 89.84 ms; 144 draw calls, ~44.72 MB static memory, terrain build 97.96 ms. It preserved gameplay state exactly. These are host measurements, not promises for the user's GPU or full busy-scene performance. No 30/40/60 FPS target has been adopted.

B01 save in the functionality test is ~21 KB; the fresh fixture is ~14.5 KB and recorded state ~31 KB. Selection made 200 local updates with no new projection or gameplay mutation. A 100-turn movement-only microbenchmark is included; it does not simulate an economy or prove strategic performance. No log pruning/deletion was performed.

## Balance and disposition

**Local functionality: pass. Local performance: measurable CPU improvement; GPU/busy-scene conclusions deferred. Local balance: pass for movement choice only. User acceptance: pending.**

The station has multiple legal land exits, a connected area of at least twenty land hexes, and both rough and cheaper alternatives. Movement costs, return routes and saved partial travel work without resource funding or a forced deadlock. There is no economic, combat or AI balance claim. Tests reuse this approved first fixture; no new campaign scenario, hidden resource grants, animal nerfs or victory rerolls were introduced.

The machinery/instrument surface is provisional; existing terrain/models are reused. Dedicated settlement management, minimap, knowledge/fog, complete four-cohort opening and final sci-fi art remain later work. B01 does not establish AI competence. The useful production→project→plan milestone still spans subsequent B02–B04 work.

## Preservation and review

Source is saved locally first. Deliver the source archive and portable Windows play package for review. The Windows package uses the official Godot 4.5.1 Windows engine with a launch script and PCK; the PCK is smoke-tested on Linux. Physical Windows execution remains for the user's play test. It is not a Windows-tested export-template build.

Repository is unchanged. New screenshots are excluded from automatic repository inclusion. Push only after explicit final signoff. Later tests should continue writing fresh evidence under the batch directory and retain historical evidence separately.
