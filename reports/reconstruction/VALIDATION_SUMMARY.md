# Reconstruction validation — 3 November 2026

Godot 4.5.1 Standard, Linux headless. These are fresh reconstruction checks, not recovered 0.910 results.

## Checks

All **12 check groups pass**, totalling **2,187 numbered assertions** plus a separate UI smoke check. The reconstruction integration suite accounts for 232 assertions, including 186 recorded command-acceptance checks, physical replay comparison, private AI replay comparison, save/load continuation, migration, readiness, budget horizon, casualties/terrain memory and real founding costs. JSON continuation tolerates sub-nanounit floating-point serialization differences; it must preserve logical choices and state.

| Group | Assertions | Result |
|---|---:|---|
| test_batch | 421 | Pass |
| test_batch_ui | 22 | Pass |
| test_0901 | 185 | Pass |
| test_0903 | 163 | Pass |
| test_0904 | 80 | Pass |
| test_frontier | 39 | Pass |
| test_model_lab | 247 | Pass |
| test_visual_style | 55 | Pass |
| test_world | 381 | Pass |
| test_reconstruction | 232 | Pass |
| reconstruction_ui | UI smoke | Pass |
| test_0902 | 362 | Pass |

`regression_results.json`, suite logs, `checks.json`, `replay_12_rounds.json` and `replay_final_state.json` retain the evidence. Earlier policy failures are segregated under `pre_final_policy_diagnostic/`; they are not final validation. A dedicated recorder initialization reconstructs every faction and the ecology.

The original regression fixtures were updated for the reconstructed schema/recorder and three-player initialization. The old all-five-district policy quota was replaced with actual military-capacity development, because the reconstructed campaign does not prescribe building every district. This is not a claim that the original historical suites passed unchanged.

## Ordinary-economy campaign

One historical-scenario seed (731), 200 complete rounds, final world turn 201. Red/Green each start with five civilians and four explicitly supplied trained field Soldiers (three rifles and one flamer), as in the documented 0.909/0.910 scenario. There are no additional campaign stock/army grants. Every completed round validates.

| Measure | Blue | Red | Green |
|---|---:|---:|---:|
| Final population | 11 | 27 | 13 |
| Buildings | 4 | 6 | 8 |
| Districts | 1 | 2 | 3 |
| Final technologies | 15 | 10 | 12 |
| Human deaths | 0 | 0 | 4 |
| First release decision turn | — | 36 | 54 |
| Releases including remustering | — | 26 | 2 |

**The nest survives.** One animal death is recorded. Both economies assemble and dispatch the fixed force through ordinary legal commands, but frequent recovery/remustering remains a major bottleneck—especially Red's 26 releases. Dispatchability is demonstrated; effective nest clearance is not. There is no parity claim with original 0.910 timings or casualties.

`final_campaign/` holds the final summary, milestone log and full final checkpoint. This 200-round run was not fully command-recorded; do not describe it as a 200-round replay. Replay is independently exercised on the retained 12-round trace. The fixed-force, large-stock readiness fixtures in the integration suite are explicit artificial diagnostics, not economically earned campaign results.

## Interface and visual boundary

Headless checks construct both native views, Green inspection, the council/operation Testing panel, and Survey/Atlas, without changing game state. The attempted X11 screenshot capture could not establish a display in this environment. No new native screenshot, Windows executable, physical play test or representative GPU benchmark is claimed. Existing source assets/rendering tests remain available.

## Continue with evidence

Inspect the actual reconstructed tree and S01–S18 review before another implementation batch. Candidate follow-ups: stable civilian/military phase ownership; why provisioning flips into recovery; whether the force is adequate; usable ranged support and retreat; and parity gaps listed in `docs/RECONSTRUCTION.md`. Do not replace these with extra adviser names or forced victories.
