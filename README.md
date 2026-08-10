# Parameterized Proof-Preserving Certification (Lean 4)

**Machine-checked. Zero sorry.**

A formal theory of parameterized certification over partially ordered specification spaces.
Certificate predicates are monotone: passing a stricter contract implies passing all weaker ones.
The specification graph carries proof-preserving graph (PPG) structure.

## Files

| File | Theorems | Scope |
|------|----------|-------|
| `PPGraph.lean` | 22 | Core PPG framework: validity, walks, paths, evolution, monotonicity, connectivity, separation, deterministic traversal, violation detection, certificate chains |
| `PPGraphCategorical.lean` | 10 | Categorical structure: morphisms, embeddings, quotients, refinement, simulation, composition |
| `PPGraphMeta.lean` | 10 | Meta-PPG: graphs over refinement relations, backward compatibility, upgrade chains, spec versioning |
| `PPGraphRefinement.lean` | 12 | Refinement relations: extension, RR definition, consistency, homogeneous specialization |
| `PPGraphRepair.lean` | 9 | Repair semantics: isolation reversal, route bypass, locality, convergence |
| `PPGraphParametric.lean` | 24 | Parametric certification: master refinement, canonical levels, lattice operators, PPG bridge, repair bounds, threshold instance |

## Central Theorems (PPGraphParametric.lean)

| # | Name | Statement |
|---|------|-----------|
| 1 | `master_refinement` | θ₁ ≤ θ₂ ∧ Cert(d,θ₁) → Cert(d,θ₂) |
| 2 | `certified_iff_above_canonical` | Cert(d,θ) ↔ θ_c ≤ θ (principal upper set) |
| 3 | `certified_subgraph_pp_valid` | Certified subgraph is pp_valid |
| 4 | `repair_raises_canonical` | After repair, canonical ≤ target |
| 5 | `canonical_spec_is_canonical` | In CompleteLattice + inf-closure, canonical exists |
| 6 | `no_repair_below_canonical` | Cannot certify below canonical level |

## Theory Layers

1. **Abstract framework**: Certificate families over any PartialOrder
2. **Master theorem**: Monotonicity of full certification
3. **Canonical characterization**: Satisfying set = principal upper set
4. **PPG bridge**: Specification graph is proof-preserving
5. **Relaxation vs Repair**: Formal distinction with canonical bounds
6. **Lattice operators**: Meet/join, inf-closure, compositional specs
7. **Canonical existence**: Constructive via sInf on CompleteLattice
8. **Concrete instance**: Threshold with Lattice, self-certifying canonical

## Author

Dragan Stosic, MSc

## License

© 2026 Dragan Stosic. All rights reserved.
