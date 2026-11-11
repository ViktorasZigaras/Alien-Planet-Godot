# Local Windows checks

Godot is a standalone executable. No system-wide installation, PATH change,
Python installation or export templates are needed for these checks.
The recorded project baseline is **Godot 4.5.1 Standard**, not .NET.
Use the console executable supplied in the Windows editor ZIP when available.

From PowerShell in this project folder:

```powershell
.\Run-Local-Tests.ps1 -GodotPath 'D:\Tools\Godot\Godot_v4.5.1-stable_win64_console.exe'
```

Replace the example path with your actual executable. Alternatively set
`GODOT_BIN` to that path. The launcher also accepts `godot` on PATH.

The launcher imports the project, then runs B01, B02, B03, B04, B05, B06, B07, movement/person, world/renderer,
and reconstruction/replay checks. These include a short deterministic simulation;
they do not establish full-game AI competence or GPU performance and do not run
the long historical campaign. Every process has a ten-minute default timeout.

Each run uses a fresh copy under `builds/local-tests/<timestamp>/project`.
Logs, engine version and `results.json` stay beside it. Source reports remain
unchanged, and the existing Git ignore excludes these local test outputs.
Tests can also write Godot user-data saves, as the existing suites already do.
Exit code 0 means all ten suites and import passed; 1 means failure.

B02's trial accounting suite is included. Existing historical economy tests
alone do not verify the B02 contract or finish its remaining integrations.
