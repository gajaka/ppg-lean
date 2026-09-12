# Proof-Preserving Graphs: Formal Certification, Self-Assessment, and Repair (Lean 4)

**209 theorems. Zero sorry.**

**Core is closed.** Four questions, each with a machine-checked answer: How far does certification reach? What stops it from going further? Can the failure be safely contained and repaired? Did repair provably advance certification?

A formal theory of parameterized certification over partially ordered specification spaces.
Certificate predicates are monotone: passing a stricter contract implies passing all weaker ones.
The specification graph carries proof-preserving graph (PPG) structure.

## Files

| File | Theorems | Scope |
|------|----------|-------|
| `PPGraph.lean` | 22 | Core PPG framework: validity, walks, paths, evolution, monotonicity, connectivity, separation, deterministic traversal, violation detection, certificate chains |
| `PPGraphCategorical.lean` | 10 | Categorical structure: morphisms, embeddings, quotients, refinement, simulation, composition |
| `PPGraphMeta.lean` | 10 | Meta-PPG: graphs over refinement relations, backward compatibility, upgrade chains, spec versioning |
| `PPGraphRepair.lean` | 8 | Repair semantics: isolation reversal, route bypass, locality, convergence |
| `PPGraphRR.lean` | 14 | Refinement relations: port of NASA pvslib sets_aux@rr_rel (rel_extension, RR, g/f-consistency, PPGConfig bridge) |
| `PPGraphParametric.lean` | 24 | Parametric certification: master refinement, canonical levels, lattice operators, PPG bridge, repair bounds, threshold instance |
| `PPGraphParametricQuotient.lean` | 25 | Quotient structure: cert_equiv, induced PartialOrder, CertInfClosed meet, LinearOrder separating |
| `PPGraphBlocking.lean` | 7 | Blocking certificates: diagnostic layer, canonical has empty blocking, stricter has nonempty |
| `PPGraphQuotientBridge.lean` | 7 | Bridge: spec graph projects to quotient PPG via surjective morphism |
| `PPGraphSelection.lean` | 17 | Hierarchical representative selection: pullback equiv, finest equiv, CertFamily instance via OrderDual Finset, pp_quotient bridge |
| `PPGraphComplementarySlackness.lean` | 5 | LP duality for optimal transport: pointwise CS, Monge structure, strict uniqueness, zero duality gap certificate |
| `PPGraphSelfAssessment.lean` | 12 | Failure containment, contamination impossibility, assessment trichotomy, monotone recovery (state-based, spec fixed), three evolution modes |
| `PPGraphAssessmentBridge.lean` | 8 | Bridge: self-assessment ↔ parametric certification. Complete repair cycle: strict growth + blocking cleared + canonical frontier advances |
| `PPGraphProbabilistic.lean` | 6 | Blocking dependency decomposition: dependency graph, LLL feasibility, pair infeasibility (quadratic discriminant), repair classification |
| `PPGraphLLL.lean` | 30 | General Lovász Local Lemma (Alon-Spencer 5.1.1): key inductive bound, denominator telescope, good-event lower bound, positive probability, good state exists |

## Central Theorems

| # | Name | File | Statement |
|---|------|------|-----------|
| 1 | `master_refinement` | Parametric | θ₁ ≤ θ₂ ∧ Cert(d,θ₁) → Cert(d,θ₂) |
| 2 | `certified_iff_above_canonical` | Parametric | Cert(d,θ) ↔ θ_c ≤ θ (principal upper set) |
| 3 | `certified_subgraph_pp_valid` | Parametric | Certified subgraph is pp_valid |
| 4 | `repair_raises_canonical` | Parametric | After repair, canonical ≤ target |
| 5 | `canonical_spec_is_canonical` | Parametric | In CompleteLattice + inf-closure, canonical exists |
| 6 | `no_repair_below_canonical` | Parametric | Cannot certify below canonical level |
| 7 | `canonical_blocking_empty` | Blocking | At canonical level, blocking set is empty |
| 8 | `separating_equiv_eq` | Quotient | Under separating family, cert_equiv implies equality |
| 9 | `lens_master_refinement` | Selection | One-liner from master_refinement via OrderDual Finset |
| 10 | `proj_is_pp_quotient` | QuotientBridge | Spec graph → quotient is surjective pp_morphism |
| 11 | `cs_pointwise` | ComplementarySlackness | dual_feasible ∧ P(i,j)>0 ∧ P·slack=0 → u(i)+v(j)=C(i,j) |
| 12 | `monge_cs_strict_unique` | ComplementarySlackness | Monge + CS + strict → unique tight entry per row |

## Theory Layers

1. **Abstract framework**: Certificate families over any PartialOrder
2. **Master theorem**: Monotonicity of full certification
3. **Canonical characterization**: Satisfying set = principal upper set
4. **PPG bridge**: Specification graph is proof-preserving
5. **Blocking certificates**: Diagnostic layer (why certification stops)
6. **Relaxation vs Repair**: Formal distinction with canonical bounds
7. **Lattice operators**: Meet/join, inf-closure, compositional specs
8. **Quotient structure**: PartialOrder on quotient, LinearOrder separating
9. **Hierarchical selection**: Family of lenses, finest equiv, CertFamily instance
10. **Concrete instance**: Threshold with Lattice, self-certifying canonical
11. **Self-assessment**: Failure containment, contamination impossibility, assessment trichotomy, repair operator (S→V→S with spec fixed), monotone recovery via proof obligations
12. **Assessment bridge**: Parametric certification as instance of self-assessment. Complete cycle: canonical → blocking → repair → strict growth → blocking cleared → canonical frontier advances
13. **Blocking dependency decomposition and Local Lemma**: the blocking set decomposes by shared variable; the General Lovász Local Lemma decides whether a coupled component can be repaired (existence), division-free proof, positive probability of a good state
14. **Constructive repair (Moser-Tardos)**: when a component is repairable, resampling reaches a good state; resample operator, witness tree, injectivity, algebraic convergence bound (forthcoming in this Lean development; currently in the PVS one)

## Related

- **PVS formalization:** [luces-pvs-theories](https://github.com/gajaka/luces-pvs-theories) — 460 machine-checked results (340 theorems + 120 lemmas), 52 theories
- **Paper:** D. Stosic, "Optimal Transport Geometry of Natural Spectral Regime Transitions," 2026. [DOI: 10.5281/zenodo.21956336](https://zenodo.org/records/21956336)

## Probabilistic Repair: the Local Lemma, and what remains open

The blocking dependency decomposition reveals that some certificate components are locally repairable while others are genuinely coupled (negative discriminant proves infeasibility of the General LLL condition for certain pairs). This raises the question: can we formally guarantee that a randomized repair operator converges to a good state?

The framework is the Lovász Local Lemma (Alon and Spencer, "The Probabilistic Method", 4th ed., Wiley 2016, Lemma 5.1.1): given bad events with bounded dependency and probabilities satisfying the General LLL condition, a configuration where no bad event occurs exists with positive probability. The General LLL is now formalized here (`PPGraphLLL.lean`), machine-checked with zero sorry, division-free, in both this Lean development and the PVS one.

The constructive side, the Moser-Tardos resampling procedure with its witness tree, injectivity, and algebraic convergence bound, is now formalized (currently in the PVS development, with a Lean version forthcoming). What remains open is the final probabilistic step: the expected-polynomial bound (E[T_LOG]) linking the algebraic weight to the expected number of resamplings. This is active ongoing work.

## Availability

The core theory is closed. I am available for formal verification, runtime verification, or theorem proving positions (remote, B2B contract from Belgrade, Serbia). Contact: dragan.stosic@gmail.com

## Author

Dragan Stosic, MSc

## License

© 2026 Dragan Stosic. All rights reserved.

This work (theories, proofs, and source) is made available for reading, academic study, and non-commercial research use, with attribution. Redistribution, modification, derivative works, or any commercial use require prior written permission. If you are interested in using this work, including in a commercial or product setting, please get in touch: dragan.stosic@gmail.com
