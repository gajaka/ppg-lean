import Lake
open Lake DSL

package PPGraph where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.37.0-rc1"

@[default_target]
lean_lib PPGraph where
  srcDir := "."
  roots := #[`PPGraph]
  globs := #[.andSubmodules `PPGraph]
