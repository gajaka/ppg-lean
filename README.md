# Parameterized Proof-Preserving Certification (Lean 4)

**153 theorems. Zero sorry.**

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

## Author

Dragan Stosic, MSc

## License

© 2026 Dragan Stosic. All rights reserved.
