# B03 shared planning trial — 10 November 2026

Implemented and locally checked within the two-civilian economy trial. **Partial
B03; not full-game AI acceptance.** B02 travel commitments, multi-settlement
storage and real purchasing interfaces remain incomplete. This slice uses the
working B02 assignment/boundary ledger without activating legacy economic AI.

## Play review

Open `b03.tscn` in Godot 4.5.1 Standard and press F6. Propose an Industry reserve
(default 4), explicitly Authorize it, then enable Automatic authorized work.
End Turn shows ordinary work and resulting stocks. Add another goal to compare
shared prerequisites and reservations; Cancel releases only that goal's claim.
Disable automation to release assigned people for manual work. B03 uses its own
save file. B01 remains the F5 default; B02 remains independently playable.

The reserve goal explicitly earmarks stock, rather than inventing a new recipe
or a construction reward. Creating a proposal does not authorize it. Fulfillment
requires real Industry acquired through ordinary assignments and turn resolution;
it does not spawn resources. Reserved output is unavailable to another goal.
The reserved stock remains in storage and is released when its purpose is
cancelled. Future paid actions must use this allocator's availability interface.

## Decisions and enforcement

One joint allocator selects legal work for both people. It evaluates real Food
and raw-material workplaces plus basic manufacturing, forecasts the common
ledger, prioritizes avoiding Food shortage, values actual outstanding Industry
demand and missing Minerals, and uses assignment stability to break ties.
Candidate pruning keeps the three strongest Food and three strongest Minerals
choices plus current work, idle and manufacturing. Ties are deterministic.
This is bounded to the disclosed two-person fixture, not a general empire solver.

People receive one work commitment each; goals share one prerequisite work
package. Conflicting manual assignment goes through the same economy command
gate and is rejected. Available stocks subtract real reservations and recorded
obligations. No reserve is created for hypothetical future inputs. Same-turn
raw output may still feed manufacturing according to the B02 contract.

Every boundary observes actual output and recomputes purpose, blockers and
allocations. Removing a purpose stops its capital work; no arbitrary goal expiry
or standing universal Industry hoard is used. Food maintenance remains useful
after capital goals finish. Emergency Food reassignment can override routine
worker commitments. A review exposed an overly restrictive reservation check;
the emergency resolver now checks real occupancy without that routine lock.

Save validation checks goal identities and shape; saved commitments are derived
again from authorized purposes and actual stock, never trusted. A forged claim
cannot manufacture available Industry. A trace records before/after stocks and
the work package at each boundary. Trace retention is not pruned automatically.

## Evidence and limits

`tests/test_b03.gd` runs normal user goal/authorize/End Turn commands on the same
approved map. It checks unauthorized proposals, real worker locks, rejected
occupancy alternatives, shared prerequisites, saved-claim reconstruction,
emergency override, two-goal fulfillment, Food safety, JSON continuation,
nonduplicated stocks, cancellation and no purposeless Industry accumulation,
plus real UI save/load. The 20-turn check includes 16 turns with a saved replay
comparison and four after cancellation. Local logs retain failures from earlier
runs; final results are preserved separately under `reports/b03`.

This demonstrates material acquisition and goal completion, not construction,
military competence, general direct/derivative planning across arbitrary domains,
or whole-game balance. Performance measurements apply only to this two-person
fixture; bigger-state scaling, representative busy-scene/GPU review and human
interface acceptance remain outstanding. No historical campaign was rerun.

Next: user review, resolve remaining B02/B03 interfaces before batch acceptance,
then B04's labor-backed ordered construction queues. No B04 mechanics were added.
