# Alien Planet · tactical notebook 0.908

31 October 2026. First lieutenant experiment; working hypotheses for later review.

**The operation failed in both retained runs.** Lieutenants now issue real field orders and retain tactical evidence, but this has not yet produced a sustainable campaign against the nest. Blue's participation is especially weak. These failures are preserved alongside the implementation.

## What exists now

Each civilization has one campaign lieutenant, receiving the general's nest objective and allocated offensive force. The general still recruits, equips, budgets and retains a home force. A tactical decision path runs before further recruitment/building preparation: deployed soldiers can shoot, charge, retreat or take a short movement order even while the general waits on infrastructure. Immediate self-defence includes home/escort soldiers; their allocation is retained.

Both rulers want the nest gone. Blue retains its research/specialisation emphasis. The city planner now explicitly values sites that advance towards the nest, and asks for roads between populated settlements. These are ordinary competing projects, using existing workers, costs, access and construction; a requested road or settlement is not counted as a completed one.

Three armed, mobile trained Soldiers per tile is an AI preference, including armed transport drivers and excluding carried passengers. Ordinary deployment and military movement avoid adding a fourth. Retreat can use an overcrowded escape if necessary, with an exception recorded. This is sequential local planning: the two civilizations do not share a commander or coordinate future arrivals. Human controls and engine stacking are unchanged.

Roads accelerate existing movement; settlements provide existing healing/refit opportunities. No ammunition, freight delivery or new supply-radius system has been invented. “Supply” decisions currently mean sustainable Food/Industry upkeep and the general's wider economic forecast.

## The rules that actually execute

| Rule | Current action | What it does not yet establish |
|---|---|---|
| Immediate field attention | Fire/retreat/movement precede further general preparation. | There is still a 12-command turn budget, shared with bookkeeping and civil development. |
| Concentrate fire | Reachable enemies ordered by lowest HP, then stable ID. | No weapon-aware volley schedule or prediction of every comrade's remaining actions. |
| Charge | Exact duel odds at least 60%, plus either target HP ≤45 or a flamer with at least two nearby friendly soldiers. | “Nearby” means within two hexes, includes the attacker and does not guarantee that the others can assist this turn. |
| Preserve wounded | Below 55 HP, prefer movement towards the nearest own settlement. | Greedy movement is not a complete evacuation/medical plan; retreat is not guaranteed safe. |
| Advance | Two allocated offensive field members; sufficient supply forecast; healthy unit takes a single edge, preferring progress, cover and comrades. | A few local movement preferences are not a coordinated assault timetable. |
| Formation | Prefer at most three field combatants on a destination; count own pending destinations. | No simultaneous global formation solver or knowledge of every foreign future order. |
| Forward support | Prefer legal safe founding progress towards the nest; fund actual road work. | Founding ahead of a protective force can create victims rather than support. |

Persistent evidence includes order context, support/cover, target HP, predicted duel odds, actual damage and deaths, interval soldier losses and revisions. The in-game tail is bounded to 128 events; the full recording preserves the experiment. Intent calculation is read-only; actual commands change the game and evidence.

“Learning” here is deliberately narrow and inspectable: saved counters change a few authored thresholds inside the current match. A fresh game starts with the initial rules. There is no model thinking in the game, cross-match training, automatic discovery of arbitrary tactics or proof that an adjustment caused improvement.

| Trigger | Bounded adjustment | Observed in final run? |
|---|---|---|
| Two observed field-Soldier deaths | Retreat threshold 55 → 70 HP | Yes, red decision turn 192. |
| Two deaths while fewer than two soldiers were nearby | Minimum support 1 → 2 | No. Happened in diagnostic A. |
| A charge kills its attacker | Required charge odds 60% → 78% | No; no charge deaths in either run. |

The recorder's world clock can be one higher than red's decision clock while blue has already ended its turn; the final state after 200 complete rounds is world turn 201.

## What happened on the map

Default seed 731, two civilizations, unchanged nest strengths, 200 rounds each. No resources or armies granted by the test. No favourable-seed search. The map timeline accompanies this notebook and shows the actual final-version save at 50, 100, 150 and 200 rounds.

| Outcome | Diagnostic A | Final B |
|---|---:|---:|
| Nest disabled | No | No |
| Blue shots / charges | 0 / 0 | 0 / 0 |
| Red shots / charges | 13 / 3 | 9 / 0 |
| Red direct attack kills | 3 | 0 |
| Deaths: blue / red / animals | 1 / 4 / 3 | 0 / 9 / 2 |
| Red movement cancellations | 214 | 3 |
| Red road tiles constructed | 8 | 4 |
| Red dedicated road-plan ordinary orders | 0 | 7 |
| Final people: blue / red | 8 / 21 | 7 / 8 |
| Final sites: blue / red | 2 / 3 | 2 / 2 |

A exposed the lieutenant advancing while the general recalled the same force over supplies. B fixes that conflict, completes formation safeguards and increases the forward-site preference. **Several planning choices change together: this is a development comparison, not a controlled trial of one tactical rule.** B is not “better” just because the order conflict is gone; its campaign outcomes are worse.

In B, blue retains its original two sites, one empty, and reaches 15 technologies. It has only one allocated offensive field member and never departs. Its military preparation did not become a real attack; it learned no combat lesson.

Red founds a real forward outpost at 10,11, towards the nest at 18,12. It builds four road tiles; the dedicated road adviser issues seven real orders, including its preparation work. The outpost ends empty. Red finishes with eight people, thirteen technologies and three surviving Soldiers. Its general still suspends the offensive over the economic forecast: Energy reaches zero and Minerals are scarce despite substantial stored Food/Industry.

Red's first recorded shot is at world turn 161. Nine ranged attacks inflict 66 immediate HP damage in total. Seven of those shots hit the same armored predator, reducing it from 100 to 58 HP across those attacks. There are no direct attack kills and no qualifying charges. Two animals nevertheless die in human defensive combat; earlier fire may have contributed to their condition, so these are not evidence that shooting had no value.

Red records thirteen offensive movement orders and twenty-nine retreat orders. Nine humans die in total, while the lieutenant observes two field-Soldier deaths; these counters have different scopes. At decision turn 192 it raises the retreat threshold to 70 HP. That leaves too little of this run to judge the adjustment.

## Evolving hypotheses, with evidence and next tests

| ID | Hypothesis / suggestion | Evidence so far | Status and useful next test |
|---|---|---|---|
| T1 | Existing troops need independent tactical attention while the general prepares replacements. | A produced 16 real attacks rather than preparation alone; B also fires while preparation is unfinished. | Architecture supported. Measure missed legal fire opportunities next, rather than just attack counts. |
| T2 | Finish softened targets with supported flamers instead of spreading damage indefinitely. | A's three flamer charges all killed armored opponents without attacker deaths; their predicted win chances were about 62%, 68%, 70%. B demonstrates repeated low-damage rifle fire without a finish. | Promising, only three selected cases. Test the same saved encounter with explicit rifle-then-flamer ordering and compare casualties. Do not infer a guaranteed or 100% effective tactic. |
| T3 | Defensive cover and nearby comrades help survival. | In B, 18 damaged/lost observation intervals had cover; 2 ended in death. 17 had nearby support; 2 ended in death. No damaged/lost open-ground intervals were recorded. | Unresolved. These are selected damage intervals, not all exposures or independent units. Compare matched encounters on open/covered tiles and hold equipment, HP and enemy force constant. |
| T4 | Higher retreat thresholds preserve scarce troops. | Red raises 55 → 70 only near the end; retreat orders already outnumber attacks. | Unresolved, with a risk of perpetual withdrawal. Check whether units actually reach safety, heal and return, rather than treating every retreat order as a rescue. |
| T5 | Two nearby soldiers are enough coordination for an attack. | Some supported soldiers still die; the supported group can lack usable actions or an appropriate weapon. | Weak rule. Next proposal: measure ready-to-fire support and shared target access, not merely distance. Not implemented yet. |
| T6 | A forward town and roads make an offensive easier. | B constructs a forward town and road tiles, but the town becomes empty and the campaign fails. | Conditional. Establish protection, staffing and reliable Energy/Minerals before treating the outpost as a functioning base. No causal claim from A/B. |
| T7 | A general supply veto is sufficient strategic discipline. | It removes contradictory orders, but Blue never attacks and Red spends long periods suspended. Food/Industry stocks remain large while other flows fail. | Incomplete. Next proposal: an explicit recovery commitment with a measurable unblock condition and a retained minimal combat force. Not a reason to silently ignore upkeep. |
| T8 | A three-unit tile preference will produce useful formations. | Guarded by fixtures; neither run logs a retreat-stack exception. | Only the preference is demonstrated. Test deliberate congestion, narrow approaches and retreat through occupied towns; no evidence yet for improved combat performance. |

The next meaningful tactical comparison should start from a retained contact situation and change one decision rule at a time. It should count survival, damage, time-to-objective, successful recovery and civilian losses. Raw “more attacks” or “more retreats” are inadequate success measures.

## Verification and status

Both complete runs validated each round. Final B records 3,758 commands with zero dropped events. Replaying every command reproduces the physical result and both full private AI states exactly. Tactical fixtures exercise real fire and charges, adaptation, spreading, supply suspension, save/load and replay; the existing regression checks also pass, including the longer 200-turn red-only deterministic expansion check. An actual native game capture opens the final saved state and displays the lieutenant panel.

Source, raw recordings and implementation notes remain in the working project. Nothing uploaded to GitHub. Existing one-off 0.906 review documents remain unchanged. This notebook records the implemented rules and evidence; proposed next tests above are not additional implemented mechanics.