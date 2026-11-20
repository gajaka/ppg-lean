import PPGraph.All
import Lean
open Lean Elab Command
run_cmd do
  let env ← getEnv
  let modules := env.header.moduleNames
  for (name, info) in env.constants do
    if let some idx := env.getModuleIdxFor? name then
      if modules[idx.toNat]!.toString.startsWith "PPGraph" then
        let safety := match info with
          | .defnInfo v => toString (repr v.safety)
          | _ => if info.isUnsafe then "unsafe" else "safe"
        logInfo m!"EXPORT_SAFETY|{name}|{safety}"
