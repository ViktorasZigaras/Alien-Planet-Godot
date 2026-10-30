# 0.904 — single seeded test

200 rounds, seed 731. Outcome: turn limit; nest survived. Deaths: blue 0, red 2, animals 1. All 2,041 recorded actions replay to the same result. See `docs/Batch_0904_Notes.md` for mechanics and interpretation.

`simulation_report.json.gz` contains the full recorder; `final_state.json.gz` contains the importable game save. Decompress either with a gzip-capable archive tool before use. `summary.json` is the compact readable result.

From the project directory: `python3 -m gzip -d -k reports/0904/simulation_report.json.gz`, then run Godot headless with `--script tests/replay_0904_report.gd -- reports/0904/simulation_report.json`. To inspect the final game interactively, decompress `final_state.json.gz` and use Import save.
