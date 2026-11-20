# Lean 4.37.0-rc1 migration

Migration date: 20 November 2026. This is a release candidate, not a stable
Lean release. The matching Mathlib release is pinned to
`31ce06eaadf4a200c0e1407c5f10953cf606b8f8`.

## Source baseline

The migration branch is `upgrade/lean-4.37.0-rc1`. Commit `8b33f44` preserves
the existing research-plan extension and its successful Lean 4.35 checks
before changing the toolchain. The original working directory and its local
edits were not reset, stashed or overwritten.

The baseline and migrated library each contain 208 canonical modules, two
import facades and 2,079 explicitly declared theorems/lemmas. All theorem
headers are textually unchanged. Source text outside theorem proofs and the
proof-valued `VarSpaces.isProb` constructor proofs is unchanged. The source
comparison is a textual check, not a formal semantic equivalence proof
between Lean or Mathlib releases.

Compatibility edits replace deprecated finite-set and infinite-sum APIs,
make set membership arguments explicit where inference changed, and reduce
function applications before rewriting indicator expressions. No axiom,
proof placeholder, warning suppression or weaker theorem statement was added.
The standard-library research-plan model is unchanged.

## Current checks

```sh
lake --wfail build
python3 -B tools/audit_ppgraph.py
```

Both commands pass. The whole-library audit inspects 6,073 declarations,
including generated helpers, and permits only `propext`, `Classical.choice`
and `Quot.sound`. The baseline audit inspected 5,975 declarations; the explicit
theorem count remains 2,079. Generated declaration counts can change with
compiler and proof extraction changes.

Fresh external-checker outcomes and the timing comparison are recorded in
[`reports/LEAN_4_37_MIGRATION.json`](../reports/LEAN_4_37_MIGRATION.json).
Historical Lean 4.35 checker outcomes in the main README are not receipts for
this toolchain. Logs, input hashes and the source comparison are preserved in
[`reports/lean-4.37.0-rc1/`](../reports/lean-4.37.0-rc1/).

On macOS, the command for a new complete kernel replay is:

```sh
lake check --paranoid --inadvisably-no-sandbox
```

The flag disables the Linux sandbox, not kernel or axiom checks. A nonzero
combined exit must remain visible even when some individual checkers accept.
These are local macOS checks; they do not provide isolation from adversarial
build scripts or prove correctness of native execution.

The complete project command finished with **exit 0**. Lean default, Lean
paranoid, lean4lean, bundled Nanoda, con-leche and con-ron each accepted the
export. The before/after input check confirmed that all 216 bound source,
configuration and literal-input files stayed unchanged during the replay.
An additional bundled replay of the smaller export was stopped after the
complete project run succeeded; its raw interrupted outcome and cancellation
reason are retained separately. It is not counted as another successful
combined run.

## Strict dependency-closed replay

A separate upstream Nanoda 0.4.24 replay accepted **63,334 declarations** with
no errors. Its export contains **all 6,016 logical project declarations** and
their dependencies, including all 2,079 explicit theorems. An independent
streaming inventory checked root membership, declaration kinds, source/input
hashes, absence of unsafe or partial declarations, and exactly three declared
axioms: `propext`, `Classical.choice` and `Quot.sound`. This inventory is separate
from Nanoda's typechecking.

The 6,073-entry Lean environment inventory also includes 57 compiler-generated
unsafe or partial runtime implementations. Their exact names and safety flags
are recorded. They are excluded from this logical replay; their native
implementations are not claimed verified. The safe logical definitions remain
in the replay. No explicit theorem was excluded.

The Nanoda executable is the previously built upstream revision
`f67473ba5f9397266f89c7852082c9c914b5d219`, with 256 MiB worker stacks.
The configuration uses one worker and rejects any axiom outside the three-name
allowlist. Export SHA-256:
`01b29cbec2ecda34dbbb67a87c627df93fb3a6985d9519d261cf2ef7863fdcd9`.

Two earlier diagnostics are retained rather than relabeled as successes:

- The raw whole-environment export includes the unused imported `sorryAx`
  declaration. Strict Nanoda rejected that file. The project axiom audit found
  no dependency on it; the final dependency-closed export contains no `sorryAx`.
  Lake's bundled Nanoda run skips exported but unpermitted axioms and reports
  that explicitly in its log.
- Requesting every environment entry also requested generated partial runtime
  implementations, which strict Nanoda's parser rejects. The corrected export
  selects logical declarations using Lean's actual safety metadata, without
  deleting arbitrary lines from the export or extending the axiom allowlist.

Large NDJSON exports remain outside Git under
`~/.local/state/lean-migrations/2026-11-20-v4.37.0-rc1/ppg-lean/`.
The checked-in receipts preserve their identities and original local paths.
On this machine the strict saved-export replay is:

```sh
~/.local/state/ppg-lean-upgrade/2026-10-18-v4.35.0/nanoda-fixed-source/target/release/nanoda_bin \
  ~/.local/state/lean-migrations/2026-11-20-v4.37.0-rc1/ppg-lean/nanoda-logical-closure-config.json
```

The `v4.35.0` component identifies the checker's earlier build directory, not
the export's Lean version. The export metadata identifies Lean 4.37.0-rc1 and
the matching bundled exporter. Both executable and export hashes are recorded.

## Timing scope

The comparison rebuilds this project's outputs with cached dependencies on
each pinned toolchain. It does not rebuild all of Mathlib from source or
measure retired processor instructions. Single-run elapsed times are
indicative and do not reproduce the Lean FRO instruction-count benchmark.
The measured project rebuild took 93.911 seconds on Lean 4.35.0 and 51.044
seconds on Lean 4.37.0-rc1. This pair alone is not a general performance claim.

## Subsequent revisions

Treat this release candidate as a separate checked revision. For a subsequent
Lean release, preserve the current receipt, select its matching Mathlib pin,
and migrate in an isolated branch. Repeat the strict build, complete axiom
audit, source-statement comparison and kernel replays before promoting it.
Record new results under a new versioned evidence directory. Preserve MT's
historical manifests and register its compatibility edits through the MT
migration layer. NFER remains on its existing toolchain until separately
requested.
