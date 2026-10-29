# Godot port validation

Engine: Godot 4.5.1 stable, Linux x86_64, Compatibility renderer.

- Editor import completed without script errors.
- Main scene starts headlessly and exits cleanly.
- `tests/test_rules.gd`: 239 checks, zero failures.
- All 44 reference command steps generated from the actual HTML engine match the entire Godot simulation state, excluding presentation log strings. This includes rejected commands, economy, training, construction, specialist output, supply changes, travel, joining, persistent identity and movement budgets.
- Each step validates invariants and JSON round trips, including projects in progress.
- Invalid save variants, duplicate jobs, unsupported versions, missing references, orphan project participants and food shortage recovery are checked.
- `tests/test_ui.gd`: 58 checks, zero failures. Instantiates the actual main scene, emits actual button/dropdown signals, plays the turn-10 construction walkthrough, mobilises and relocates the same Specialist, staffs Field Station, saves/loads via the native handlers, rejects a bad save without replacing state, resets, checks hex picking, wheel zoom and Fit Map.
- UI layout rectangles were checked at normal and minimum window sizes, accounting for Godot's canvas scaling. Overflow found during testing was fixed.

The UI tests are headless native integration tests, not a claim of manual mouse play on Windows. Desktop executable export requires matching export templates. No Windows executable is claimed as tested or included.

The original artwork remains unchanged and is loaded from numbered base64 text chunks, avoiding upload-size limits without a user-run asset assembly step.
