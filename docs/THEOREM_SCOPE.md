# Theorem scope and local repair

The theorem inventory counts explicit Lean declarations. It includes definition
accessors, structural laws and applications of general results, alongside the
main mathematical arguments. Proof length does not classify their usefulness.

## Changes on 2026-10-28

The former `linear_strict_not_equiv_aux : True` declaration and its `#check`
were removed. The actual convexity theorem `equiv_convex` remains proved.
`linear_cert_le_iff_le` was renamed to `linear_cert_le_of_le`: its statement
establishes order preservation, with no converse for arbitrary families.

In [Core/Repair.lean](../PPGraph/Core/Repair.lean), four former statements were
replaced with before/after properties of an explicit local data update. A new
`repair_restores` theorem proves target restoration. The declaration count is
unchanged overall: one placeholder was removed and one restoration theorem was
added. Repair has nine declarations; ParametricQuotient has twenty-five.

## Local data model

Slots and values have type `V`; initially, each slot stores its own value.
The original predicate `G.invariant_holds : V -> Prop` evaluates stored values.
When repair is possible, `repair_choice` selects a healthy reachable candidate.
Otherwise, it selects the original value. The data update is:

```text
repair_state G v w = if w = v then repair_choice G v else w
```

`repair_at` is the graph view of those data. Its health at slot `w` is the
original predicate applied to `repair_state G v w`; edges and reachability
remain unchanged. The specification on values stays fixed.

| Result | Proven property |
| --- | --- |
| `repair_restores` | An available repair makes its target slot healthy. |
| `repair_locality` | Every other slot keeps exactly the same value and health. |
| `healthy_self_stable` | Repair selection and the graph view fix a healthy target. |
| `repair_no_cascade` | Every previously healthy slot remains healthy. |
| `active_independent_of_isolated` | An edge away from the target retains its activity. |

Candidate existence is an explicit hypothesis. Selection uses classical choice.
These are universal properties of the specified local-copy operation; concrete
software repair requires its own implementation and refinement argument.
This file supplies no repair-search or convergence algorithm.

## Scope of elementary helpers

The `Meta` and `Categorical` modules retain their structural laws and accessors.
Transporting correctness across a meta-edge uses a supplied relation-inclusion
proof. Graph-extension helpers in `SelfAssessment` use the same predicate on
unchanged vertex values. Its state-repair section separately requires target
restoration and preservation of the certified core.

`feasible_witness_exists` packages an already supplied numerical LLL assignment.
`repairable_or_coupled` is excluded middle for numerical budget feasibility;
neither gives a decision procedure. Failure of that sufficient LLL budget
system does not establish semantic impossibility of repair.

`Optimization/ComplementarySlackness.lean` proves pointwise tightness, entry-cost
equality and tight-entry uniqueness under its stated assumptions. Aggregate
primal/dual objectives and strong duality are outside that file's statements.

The whole-library axiom audit checks proof dependencies and declaration coverage.
Matching a comment or a paper's intended theorem remains a separate review task.
