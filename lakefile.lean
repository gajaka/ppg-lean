import Lake
open Lake DSL

package PPGraph where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "master"

@[default_target]
lean_lib PPGraph where
  srcDir := "."
  roots := #[`PPGraph, `PPGraphCategorical, `PPGraphMeta,
             `PPGraphRepair, `PPGraphRR, `PPGraphParametric,
             `PPGraphParametricQuotient, `PPGraphBlocking,
             `PPGraphQuotientBridge, `PPGraphSelection, `PPGraphEquivBridge, `PPGraphComplementarySlackness, `PPGraphSelfAssessment, `PPGraphAssessmentBridge]
