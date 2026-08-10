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
  roots := #[`PPGraph, `PPGraphBoot, `PPGraphRefinement, `PPGraphMeta,
             `PPGraphMetaLowRISC, `PPGraphCategorical, `PPGraphCategoricalLowRISC,
             `PPGraphRepair, `PPGraphParametric, `PPGraphParametricQuotient, `PPGraphEquivRepair]
