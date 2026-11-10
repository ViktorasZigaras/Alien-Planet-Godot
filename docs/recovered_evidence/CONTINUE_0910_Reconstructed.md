# Continue Alien Planet from this source package

3 November 2026. Open `project.godot` in **Godot 4.5.1 Standard** and press F5. This is a source project, not a Windows executable. Its version is `0.910-reconstructed`, rebuilt on the recovered 0.904 repository snapshot after the unuploaded 0.905–0.910 source was lost.

1. Read `AGENTS.md`, `docs/RECONSTRUCTION.md` and `reports/reconstruction/VALIDATION_SUMMARY.md`.
2. Read `docs/current_design/Alien_Planet_Start_Early_Shoulds_Review_2026-11-02.md`: the next design/build comparison starts at **S01**, not Q080. The full current decision ledger and four-stage synthesis are beside it.
3. Inspect the actual reconstructed source before claiming a historical capability is present. The saved architecture and 0.908–0.910 reports in `docs/recovered_evidence/` describe the original lost implementation. Their test counts are historical.
4. Use the Testing tab for private council proposals, operation blockers and lieutenant memory. End Turn keeps Blue human-controlled and runs Red/Green; the explicit all-AI button runs all three. Survey/Atlas inspects the selected tile and settlement access.
5. To verify: `python3 tests/run_reconstruction_checks.py --godot /absolute/path/to/godot`. Optional historical-scenario diagnostic: run `tests/run_reconstruction_campaign.gd` headlessly; it writes under `reports/reconstruction/final_campaign/`. It is deliberately not a victory script. Check the user’s current testing authorization before proposing new scenarios.
6. Save a persistent source archive at the end of the next batch. A local Git commit in temporary storage is not a backup. Upload to GitHub only when the user authorizes it.

The two highest-value follow-ups are auditing reconstruction parity against the retained reports, and then reviewing S01–S18 one capability at a time across inventory, mechanics, AI and meaningful evidence. Avoid adding new roles to explain a blocked path until its existing caller, prerequisites, actor ownership and legal action have been traced.

The original source commit `838460b3d376c40d3d013103956be640422670cc` is not in this package. Local reconstruction commits, if present, are new history, not recovered ancestry. Do not claim that the package reproduces the original 0.910 results.

## Durable references

- Decision ledger: https://chatgpt.com/library?file_id=libfile_4bb48d3203e881919b9014182cedbcc8&account_id=personal
- Current early-game review: https://chatgpt.com/library?file_id=libfile_06b76f8c5320819197c968c4e5ad530f&account_id=personal
- Four-stage synthesis: https://chatgpt.com/library?file_id=libfile_5959be2c4f608191bc9f83915f9cc710&account_id=personal
- Historical AI reference: https://chatgpt.com/library?file_id=libfile_34969fd37e648191b7f9b54c31023a61&account_id=personal
- Development log: https://chatgpt.com/library?file_id=libfile_45168cb0036081919cff15db493efd5f&account_id=personal

Library versions may advance after this package. Read current references before updating them; preserve their identities and newer answers.
