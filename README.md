# Proof-Preserving Graph Theory (Lean 4)

**22 machine-checked theorems. Zero sorry. Zero warnings.**

A formal mathematical framework for structural resilience: graphs where every edge satisfies a refinement relation and both endpoints maintain their local invariants.

Port of `proof_preserving_graphs.pvs` (originally in PVS, NASA Langley).

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

See `PPGraphBoot.lean` — concrete instantiation for OpenTitan secure boot (ROM → ROM_EXT → BL0 → Kernel). Layered DAG, failure isolation, lock-out property.

## PVS Version

The original PVS formalization with 177 theorems across 26 theories: [luces-pvs-theories](https://github.com/gajaka/luces-pvs-theories)

## Author

Dragan Stosic, MSc — [NASA PVS Libraries contributor](https://github.com/nasa/pvslib/blob/master/sets_aux/rr_rel.pvs)

## License

© 2026 Dragan Stosic. All rights reserved.
