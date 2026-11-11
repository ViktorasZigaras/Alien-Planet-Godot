# B05 growth, support, training and research — 11 November 2026

Local play review. F5 opens `b05.tscn` in Godot 4.5.1 Standard. B04 and earlier
scenes remain available with their separate saves. This is the same single-town
seed-731 trial, not the final opening or broad economic balance acceptance.

## Trial rules and play

- **Growth:** Local growth Food is separate from the accessible stored Food
  reserve. With growth enabled and spare working support, transfer at most one
  Food from the turn's real surplus after upkeep. Explicit reserve acceleration
  transfers stored Food once into the local account; it never creates a person
  immediately. All routes share one birth per boundary, at 10 local Food each.
  New people keep distinct identities and start idle. No-growth or a support
  blocker leaves ordinary surplus in the reserve. No freight or second spendable
  copy of the Food pool exists.
- **Support:** Landing Station supports two working civilians. Each staffed,
  powered Greenhouse contributes two more places. An unstaffed/unpowered
  building contributes none. Capacity counts working residents; idle people and
  external builders still eat but don't fill these places. Excess work is idled
  on support loss, keeping operating support sources and useful Food work within
  the ordinary limit. No special over-cap Food exception. Loss events record
  displaced jobs and potential Food for later review.
- **Training:** Pick a resident and Biologist or Scientist in the progression
  panel. Training spends two unreserved Industry immediately and requires two
  supported boundaries. Enrolled people cannot produce in another job; an
  idled course retains progress. Completion changes qualification on the same
  person. Supported matching work gives +2 Food or Science. Idle or mismatched
  work gives no specialist bonus. Engineer rates and additional professions
  remain open.
- **Research:** Ordinary Study produces one Science; a Scientist studying makes
  three. Ordinary Generate produces two Energy. Cultivation costs four Science,
  requires a Biologist's actual Food output in the preceding turn, and unlocks
  Farm upgrades. Power Systems costs six Science, requires actual preceding-turn
  Energy generation, and raises Generate output from two to four. Purchases are
  instant, with cost/evidence rechecked on every click. Merely owning a building
  or having a trained idle person is insufficient. Evidence comes from realized
  ledger output, including the turn that spends the last unit of operating power.

The two-worker planner remains exhaustive for the original small case. With
growth it considers every person and retains at most 16 ranked partial plans
between people. The bounded search is a trial, not a claim of optimal allocation
or large-settlement performance. Human training, research and growth orders use
the existing stock reservation interface; the planner does not yet independently
propose training/research purposes. Construction still shares the same ledger.

## Evidence

Windows Godot 4.5.1 import and all eight suites passed. B05 passed **80 checks**:
conservation, combined cap, no-growth/export, grown identities and planner use,
paid training/identity/opportunity cost, project reservation protection,
support expansion/loss, specialist operation and evidence expiry, research
affordability after a first purchase, validation and separate real-file UI save.

In the ordinary start, Food work plus the initial raw materials funded a
Scientist's training; Study accumulated six Science; then Generate proved the
operational prerequisite. By turn 8 Power Systems was operating at four Energy
per turn, with eight Food left. No stocks or cohorts were granted in this run.
Other funded test arrangements are isolated unit checks on the same map, not
claimed opening balance. See `reports/b05` for the final measured suite timings.

No physical GPU or broad population-scale performance claim. Greenhouse power
uses available opening Energy; broader Energy emergency policy and multi-storage
eligibility remain unfinished. Growth rates, support values and prices are
provisional. B06 is knowledge, anomalies and safe exploration; its observation
and external-work rules are not introduced here. B05 is local pending play review;
B04 was uploaded on user instruction as `449b258`.
