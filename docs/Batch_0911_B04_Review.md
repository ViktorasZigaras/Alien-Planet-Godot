# B04 construction review — 11 November 2026

Local implementation for play review. F5 now opens `b04.tscn`; earlier B01–B03
scenes and the historical `main.tscn` remain available. Not a final full opening.

## Play

Select a recipe and a hex, then Queue project. One ordinary civilian can gather
Food while the other Manufactures, Constructs, or splits effort. Enable Automatic
authorized work for the existing planner to acquire inputs and construct the
queued project. The command to queue a project authorizes its remaining cost.
Every row shows work, paid Industry and the next-turn blocker. Hold/Resume is
explicit. Started/completed progress survives the separate B04 save.

For a physical builder, disable automatic work or release their existing goals,
choose the person and Equip kit / deploy, then select a hex and Travel (right
click also orders travel). End Turn advances rough-terrain routes. Select On-site
builder after arrival. A turn used for travel cannot also produce work. To return
the kit, physically travel to the Landing Station then Return kit. The single
kit is reusable and cannot be equipped by both people simultaneously.

## Contract and provisional numbers

The user selected **skip held/blocked entries and carry unused effort forward**.
One settlement worker has two effort points: manufacturing uses both for up to
two Minerals→Industry, construction uses both for work, or Mixed uses one for
each. A stationary equipped on-site builder supplies two effort and eats one
Food. A productive settlement worker eats two. No Engineer bonus or training
rule is silently selected; Engineer specialization remains B05 work.

Recipes are disclosed trial values, not balance-final content: Farm 4 work and
4 Industry, Farm upgrade 4/4, Agriculture district 6/6, Greenhouse 6/6. Each actual
work point pays one Industry. Underfunded work progresses only as far as paid;
unused supplies and previously paid work remain. No up-front full-cost debit or
instant completion from a large stockpile. Newly manufactured Industry can pay
construction at the same boundary. Completed output takes effect for future
production, not retroactive same-turn income.

Boundary: ordinary output and manufacturing, once-only upkeep/obligations, then
construction using the remaining unreserved pile and labor. Funding goals own
their reservations; construction can spend its own allocation but cannot spend
another purpose's. Paid progress reduces its remaining funding goal. Hold releases
funding and work; Resume authorizes remaining work. Cancelling the funding purpose
also holds the project. Completion releases its funding purpose.

Settlement labor is restricted to the existing work area. Remote work needs a
real builder at the site; pooled materials do not teleport people or tools. The
kit must be in storage or at the target project; an absent kit blocks that entry.
Deploying a tile worker preserves their actual location. Travel activity survives
save/load and prevents both manufacturing and construction in that turn.

A new district requires its existing tile worker to be reassigned before it can
start. From the first paid work, its natural output is suppressed even while held.
No unfinished district benefit is granted. A Farm upgrade keeps its old yield
until completion, then adds one more Food. A completed Greenhouse provides a
staffed three-Food workplace consuming one Energy; exhausted Energy shuts off
its output. This is a simple operating gate, not the later full shutdown policy.

## Evidence, fixes and limits

Windows Godot 4.5.1 local checks cover settlement-only, builder-only and combined
contributions, overflow and blocked-entry skipping, split labor conservation,
partial payments, cancellation and reservation ownership, persistent district
suppression, upgrade yield, building operation, physical travel/arrival and kit
reuse, malformed progress rejection and separate real-file UI save/load.

The ordinary initial-map run completes a useful Farm by turn 4, without granting
test resources. Funded accounting unit tests are explicitly isolated and do not
claim ordinary-game balance. A pure held-queue timing probe measures ten passes
over 10/100/1000 held entries without spending or work. Final logs/results are
under `reports/b04`; full timestamped runs remain under ignored `builds/local-tests`.

Checks exposed and fixed a variable-name collision during script loading,
funding cancellation leaving labor active, and the need to detect engine crashes
even when the Windows executable returns zero. The test launcher now rejects
crash signatures as well as script errors and failures. Historical reports were
not overwritten.

Limits: one settlement/two civilians on the approved fixed map; no whole-game
balance or busy-scene GPU conclusion. Engineer bonuses, growth, training,
research and new AI domains are not added. Existing B02 multi-storage and full
Energy-emergency interfaces and broader B03 planning remain unfinished. No
cancellation salvage/refund mechanic or district upgrade tree is invented.
Human visual/interface acceptance remains pending; headless UI tests are not a
manual visual review. Next planned B05: growth, support, training and operational
research, after review of the relevant remaining interfaces.
