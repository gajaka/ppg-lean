# Proof-Preserving Graph Theory (Lean 4)

**94 machine-checked theorems. Zero sorry. Zero warnings.**

A formal mathematical framework for structural resilience: graphs where every edge satisfies a refinement relation and both endpoints maintain their local invariants.

Port of `proof_preserving_graphs.pvs` and `lowrisc_boot_verification.pvs` (originally in PVS, NASA Langley).

## Files

| File | Theorems | Scope |
|------|----------|-------|
| `PPGraph.lean` | 22 | Core framework: validity, walks, paths, evolution, monotonicity, connectivity, separation, deterministic traversal, violation detection, certificate chains |
| `PPGraphBoot.lean` | 16 | Secure boot chain: layered DAG, failure isolation, lock-out, OpenTitan instantiation (ROM --> ROM_EXT --> BL0 --> Kernel) |
| `PPGraphRefinement.lean` | 12 | Refinement relations: relation extension, RR definition, consistency lemmas, homogeneous specialization, PPGraphConfig (port of NASA `sets_aux/rr_rel.pvs`) |
| `PPGraphMeta.lean` | 10 | Meta-PPG: graphs over refinement relations, backward compatibility, upgrade chains, spec versioning |
| `PPGraphMetaLowRISC.lean` | 14 | OpenTitan instance: spec v1-->v2-->v3, upgrade safety, failure propagation, correctness forward-propagation |
| `PPGraphCategorical.lean` | 10 | Categorical structure: morphisms, embeddings, quotients, refinement, simulation, composition |
| `PPGraphCategoricalLowRISC.lean` | 10 | LUCES ≅ OpenTitan isomorphism: proof portability between domains |

## Theorems

| # | Name | Statement |
|---|------|-----------|
| T1 | `valid_implies_weak` | pp_valid → pp_valid_weak |
| T2 | `pp_valid_implies_invariants` | pp_valid edge → both endpoints satisfy invariant |
| T3 | `pp_path_is_walk` | pp_path → pp_walk |
| T4 | `pp_walk_invariants` | all vertices on pp_walk satisfy invariant |
| T5 | `pp_path_endpoints_invariant` | start and end of pp_path satisfy invariant |
| T6 | `subgraph_valid` | subgraph of pp_valid graph is pp_valid |
| T7 | `pp_transform_reflexive` | pp_transform is reflexive |
| T8 | `pp_transform_transitive` | pp_transform is transitive |
| T9 | `pp_transform_antisymmetric` | pp_transform is antisymmetric |
| T10 | `invariant_monotone` | invariant set grows under transformation |
| T11 | `vertex_partition` | invariant_set and violation_set partition vertices |
| T12 | `invariant_violation_disjoint` | invariant_set and violation_set are disjoint |
| T13 | `pp_connected_invariants` | pp-connected endpoints satisfy invariant |
| T14 | `violating_isolated` | violating vertices have no outgoing edges |
| T15 | `violating_no_incoming` | violating vertices have no incoming edges |
| T16 | `deterministic_is_valid` | deterministic graph is pp_valid |
| T17 | `inference_function_exists` | deterministic → inference function exists |
| T18 | `empty_separates_iff_disconnected` | empty separator ↔ not connected |
| T19 | `certificate_chain_sound` | certificate chain → all invariants hold |
| T20 | `certificate_chain_connects` | certificate chain → endpoints connected |
| T21 | `walk_resilience` | pp_walk persists under transformation |
| T22 | `connectivity_resilience` | connectivity persists under transformation |

## Key Results

**Structural Resilience:** Graph evolution forms a partial order (T7+T8+T9). Invariant sets grow monotonically (T10). Paths persist once established (T21).

**Deterministic Traversal:** Inference function extraction without Axiom of Choice (T17). Via classical choice on unique successor.

**Fault Tolerance:** Byzantine (violating) vertices are completely isolated — no outgoing edges (T14), no incoming edges (T15). Connected vertices are always honest (T13).

**Secure Boot Application:** Certificate chains formalize verified boot sequences (T19, T20). Failure at any point is detectable and isolating.

## Application: Hardware Root-of-Trust

See `PPGraphBoot.lean` — concrete instantiation for OpenTitan secure boot (ROM --> ROM_EXT --> BL0 --> Kernel). Layered DAG, failure isolation, lock-out property.

### Boot Chain Theorems

| # | Name | Statement |
|---|------|-----------|
| T1 | `layered_implies_lockout` | layered → full lock-out |
| T2 | `layered_is_valid` | layered → pp_valid |
| T3 | `layered_acyclic` | layered edge → endpoints distinct |
| T4 | `boot_failure_blocks` | invariant fails → no pp-edge out |
| T5 | `verification_implies_invariants` | verification → both invariants hold |
| T6 | `verification_implies_refinement` | verification → refinement holds |
| T7 | `secure_boot_invariants` | secure boot → all edge endpoints valid |
| T8 | `failed_stage_isolated` | failed stage → no outgoing edges |
| T9 | `ot_levels_increasing` | OpenTitan edges go strictly upward |
| T10 | `ot_unique_levels` | one stage per level |
| T11 | `ot_rom_is_root` | ROM is the only level-0 stage |
| T12 | `ot_single_verifier` | every non-ROM stage has a verifier |
| T13 | `ot_edges_refine` | edges imply refinement |
| T14 | `ot_no_backward` | no backward edges |
| T15 | `ot_signature_failure_blocks` | invalid signature → invariant fails |
| T16 | `ot_full_chain_valid` | all signatures valid → full chain valid |

## PVS Version

The original PVS formalization with 177 theorems across 26 theories: [luces-pvs-theories](https://github.com/gajaka/luces-pvs-theories)

## Author

Dragan Stosic, MSc — [NASA PVS Libraries contributor](https://github.com/nasa/pvslib/blob/master/sets_aux/rr_rel.pvs)

## License

© 2026 Dragan Stosic. All rights reserved.
