# B02 economy trial — 10 November 2026

Disposition: **revise / partial implementation**, awaiting play review and the
remaining integrations. This does not accept the complete B02 batch.

Open `b02.tscn` in Godot 4.5.1 Standard and press F6. B01 remains the default F5
scene and its movement fixture is unchanged. B02 deliberately uses the same
seed-731 9×7 map with two ordinary civilians and provisional reserves of 8 Food,
2 Minerals and 8 Energy. This is an economy trial, not the full four-cohort opening.

## Implemented contract

Assignments are plans, freely replaceable before End Turn. They produce no output
and have performed no work. Each person performs one final job once at End Turn.
Existing explicitly recorded obligations remain payable after reassignment.
Tile jobs use actual accessible terrain yields; a hex cannot be staffed twice.
The center offers a provisional basic manufacturing task: up to 2 Minerals become
2 Industry per worker per turn, partially affordable, with no specialist gate.

The boundary gathers staffed tile yields, processes Minerals into Industry using
the shared pile including newly gathered material, then pays upkeep and recorded
obligations once. Productive jobs cost 2 Food; idle civilians cost 1. Output has no
recursive processing loop. A forecast uses exactly the same resolver on a copy.

Before resolution, Food emergency handling seeks a real unoccupied Food tile,
then idles non-Food jobs when still necessary. Negative Food remains negative;
the shortage amount is explicit. It is a persistent stock deficit in this trial,
not a selected combat-power formula or a complete emergency policy. Production
can repay a deficit. Nothing silently clears it or heals combat damage.

Food/Minerals/Industry are stored in the Landing Station record; the other three
resources are global. The aggregate is derived. This fixture does not yet prove
multi-settlement source selection. No warehouse caps or freight are introduced.

The interface offers assignment selectors with potential outputs, six-resource
stock/gross/input/upkeep/obligation/net forecasts, End Turn, restart, and a separate
B02 save. Loads validate before replacing state. B01 saves remain separate.

## Evidence and limits

`Run-Local-Tests.ps1` uses the user's standalone Windows Godot 4.5.1 executable,
copies source into timestamped `builds/local-tests` directories, imports, and
runs B01, B02, 0.901, world, and reconstruction suites. Logs and `results.json`
identify each local run. Historical evidence remains unchanged.

B02 checks cover conservation, repeated reassignment, same-turn input use,
obligations, duplicate occupancy, read-only forecasts, JSON continuation/replay,
malformed saves, persistent shortage, 100 boundary steps, a known-map 12-turn
Food/material bootstrap, and real UI save/load. Headless UI startup exercises
the map renderer but is not visual or GPU acceptance.

Remaining B02 work: integrate travel/performed-work commitments with the active
economy, real immediate paid actions, multi-storage eligible-source withdrawal,
installation Energy shutdown/restart, stronger emergency allocation review,
representative larger-state accounting benchmarks, and user interface/play
review. Complete combat shortage effects belong to the later tactical integration.
AI goals, construction queues, growth, research and fauna remain inactive here.

No cloud work was performed, and no new commit or repository upload is implied.
