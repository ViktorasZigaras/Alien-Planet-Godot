# Post-B09 visual pass

F5 opens the integrated B09 game with its first visual furnishing pass. The map stays central in the opening, Colony and Research. The new command dock groups the unit readout, contextual commands and minimap in separate bays with a recessed cable run. Colony and Research share the monitor framing. The map toolbar uses compact icon buttons with tooltips for Center station and Overlay. Common unit and production commands combine matching pictograms with labels.

Model Lab opens directly to the Farm in the World asset catalogue. Toggle **Pump and irrigation lines** to preview the crop beds with or without the service assembly. The game uses the furnished assembly when a Farm is completed. The same catalogue includes coastal gravel, hill rocks and ground cover, previewed on their native surfaces. Map dressing uses the known terrain and varies placement deterministically by hex. The kit and terrain studies are presentation-only.

Review at native 1920×1080. `Opening.png`, `Colony.png`, and `Research.png` capture the default opening. `BusyColony.png` stages additional cohorts, wildlife, a built Farm and a second project in the queue. `FarmLab.png` shows the assembled model at catalogue scale. The farm should read by its rows and reservoir at normal zoom, with the pipework visible in the lab. Reserve brighter colours for cohorts and active selection. The first capture prompted darker hill accents and more separation between the dock bays.

On this PC the final 90-frame samples were 17.5 ms median / 30.5 ms p95 for
the opening and 16.7 ms median / 29.9 ms p95 for the staged colony pan.
A single run is sensitive to frame pacing and fixture content. The staged
farm was added for the capture, while the automated opening test builds a
Farm through the production queue.

Re-run the fresh-copy suite with `Run-Local-Tests.ps1`. B09 covers the command icons, the Model Lab toggle and return to the unchanged game state. Native capture runs via `tests/capture_visual_pass.gd` and writes 90-frame samples for the default opening and a staged colony pan. B10 covers expansion, roads and faction presence.
