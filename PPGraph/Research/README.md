# Research-plan transitions as a PPG

`PlanRepairModel.lean` is a parametric state/transition model depending only on
Lean's standard library. States retain the problem, protected certificates,
questions, accepted and refuted helpers, witnesses, history and revision.
Twenty theorems prove soundness and retention over admitted finite sequences.

`PlanRepair.lean` connects that model to the existing `PPGConfig`, `RR`, `Graph`
and `pp_valid` definitions. Five theorems show that admitted transitions between
justified research states form a proof-preserving graph. The invariant is
sound classification of results, not truth of every candidate conjecture.

The chosen equivalence is equality of the problem and protected certificate
list. Identity abstraction/concretization makes the derived RR exactly that
equivalence; this is proved for this configuration, not asserted for every RR.
Edges additionally require evidence-bearing transitions and preserve soundness.
Their direction comes from increasing revision, not from asymmetric RR.

The same generic model is byte-identical to
`thinker/thinker-lean/ThinkerLean/PlanRepairModel.lean`. Thinker's separate finite
interface instance connects its native checks, counterexamples and proposals
to admitted transitions, with a proved decoder and two successive refutations.
Neither repository imports the other. Keep both copies synchronized when
changing the generic model; the verification receipt records their hashes.

```sh
lake --wfail build PPGraph.Research.PlanRepair
python3 tools/audit_ppgraph.py
```

The new modules are included in `PPGraph.All` and the whole-library audit map.
There are no new project axioms or proof placeholders. This extension does not
prove a Python coordinator, an automatic research policy or paper interpretation.
