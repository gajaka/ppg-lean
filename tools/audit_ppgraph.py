#!/usr/bin/env python3
"""Audit all current PPGraph library declarations, with Lean-owned inventory.

The temporary Lean harness uses the environment's module ownership and ordinary
#print axioms commands, including for generated constants. It is an inspection
tool, not a proof oracle. Library files retain #check, never #print axioms.
"""

import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
IDENTIFIER = r"[\w.'?!]+"
DECLARATION = re.compile(
    rf"^[ \t]*(?:@\[[^\n]*\][ \t]*)*"
    rf"(?:(?:private|protected|noncomputable)[ \t]+)*"
    rf"(?:theorem|lemma)[ \t]+({IDENTIFIER})", re.M)
CHECK = re.compile(rf"^[ \t]*#check[ \t]+@?({IDENTIFIER})", re.M)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def code_only(source):
    """Mask nested Lean comments and strings, retaining source line positions."""
    out = list(source)
    index = depth = 0
    string = line_comment = False
    while index < len(source):
        char = source[index]
        pair = source[index:index + 2]
        if line_comment:
            if char == "\n":
                line_comment = False
            else:
                out[index] = " "
            index += 1
        elif depth:
            if pair == "/-":
                out[index:index + 2] = "  "
                depth += 1
                index += 2
            elif pair == "-/":
                out[index:index + 2] = "  "
                depth -= 1
                index += 2
            else:
                if char != "\n":
                    out[index] = " "
                index += 1
        elif string:
            if char == "\\" and index + 1 < len(source):
                out[index] = " "
                if source[index + 1] != "\n":
                    out[index + 1] = " "
                index += 2
            else:
                if char != "\n":
                    out[index] = " "
                if char == '"':
                    string = False
                index += 1
        elif pair in ("/-", "--"):
            out[index:index + 2] = "  "
            depth = int(pair == "/-")
            line_comment = pair == "--"
            index += 2
        elif char == '"':
            out[index] = " "
            string = True
            index += 1
        else:
            index += 1
    if depth or string:
        raise AssertionError("unterminated Lean comment/string")
    return "".join(out)


def inspect_source(source, label):
    code = code_only(source)
    if re.search(r"\b(?:sorry|admit|native_decide|bv_decide|unsafe|extern|implemented_by)\b", code):
        raise AssertionError(f"unapproved proof mechanism: {label}")
    if re.search(r"^\s*(?:axiom|constant)\s", code, re.M):
        raise AssertionError(f"axiom declaration: {label}")
    if re.search(r"#print\s+axioms\b", code):
        raise AssertionError(f"permanent #print axioms: {label}")
    declarations = [(m.group(1), code.count("\n", 0, m.start(1)) + 1)
                    for m in DECLARATION.finditer(code)]
    # Fail closed if a new syntax form is not understood by this scanner.
    keyword_count = len(re.findall(r"\b(?:theorem|lemma)\b", code))
    if keyword_count != len(declarations):
        raise AssertionError(f"unsupported theorem syntax: {label}")
    check_lines = re.findall(r"^[ \t]*#check[^\n]*", code, re.M)
    checks = CHECK.findall(code)
    if len(check_lines) != len(checks):
        raise AssertionError(f"unsupported #check syntax: {label}")
    return declarations, checks


def resolve_name(token, entries, line=None):
    token = token.removeprefix("_root_.")
    matches = [entry for entry in entries
               if entry["name"] == token or entry["name"].endswith("." + token)]
    if line is not None and len(matches) > 1:
        matches = [entry for entry in matches if entry["line"] == line]
    if len(matches) != 1:
        raise AssertionError(f"ambiguous/absent Lean declaration: {token} at {line}")
    return matches[0]["name"]


def missing_checks(declarations, checks, entries):
    theorems = [entry for entry in entries if entry["kind"] == "theorem"]
    names = [resolve_name(token, theorems, line) for token, line in declarations]
    if len(names) != len(set(names)):
        raise AssertionError("duplicate explicit theorem name")
    checked = set()
    for token in checks:
        # Additional checks of definitions/structures are permitted.
        # A check of an imported declaration is also valid; the build resolves
        # it, but it cannot cover a theorem declared in this source file.
        if not any(entry["name"] == token or entry["name"].endswith("." + token)
                   for entry in entries):
            continue
        resolved = resolve_name(token, entries)
        if resolved in names:
            checked.add(resolved)
    return names, sorted(set(names) - checked)


INVENTORY_BODY = r'''
import Lean
open Lean Elab Command
set_option maxHeartbeats 0
run_cmd do
  let env ← getEnv
  -- Cache this array: rebuilding it for every imported constant is expensive.
  let moduleNames := env.header.moduleNames
  for (name, info) in env.constants do
    if let some index := env.getModuleIdxFor? name then
      let moduleName := moduleNames[index.toNat]!
      if moduleName.toString.startsWith "PPGraph" then
        let kind := match info with
          | .axiomInfo _ => "axiom"
          | .thmInfo _ => "theorem"
          | .defnInfo _ => "definition"
          | .opaqueInfo _ => "opaque"
          | .quotInfo _ => "quotient"
          | .inductInfo _ => "inductive"
          | .ctorInfo _ => "constructor"
          | .recInfo _ => "recursor"
        let line := (← findDeclarationRanges? name).map (·.selectionRange.pos.line) |>.getD 0
        logInfo m!"PPG_INVENTORY|{moduleName}|{name}|{kind}|{line}"
'''

DEPENDENCY_BODY = r'''
import Lean
open Lean Elab Command
set_option maxHeartbeats 0
run_cmd do
  let env ← getEnv
  let moduleNames := env.header.moduleNames
  let mut names : Array Name := #[]
  for (name, _) in env.constants do
    if let some index := env.getModuleIdxFor? name then
      if moduleNames[index.toNat]!.toString.startsWith "PPGraph" then
        names := names.push name
  for name in names.qsort (fun a b => a.toString < b.toString) do
    -- mkIdent retains internal numeric name components in generated constants.
    -- This elaborates exactly the same command as a literal #print axioms.
    elabCommand (← `(command| #print axioms $(mkIdent name)))
'''


def lean_harness(lake, modules, body, log):
    with tempfile.TemporaryDirectory(prefix="ppg-whole-audit-") as directory:
        path = Path(directory) / "Audit.lean"
        path.write_text("\n".join("import " + p.stem for p in modules) + "\n" + body)
        with log.open("w") as output:
            result = subprocess.run([str(lake), "env", "lean", str(path)], cwd=ROOT,
                                    text=True, stdout=output, stderr=subprocess.STDOUT)
    if result.returncode:
        raise AssertionError(f"Lean audit harness failed; see {log}")
    return log.read_text()


def inventory_from_output(output, modules):
    entries = defaultdict(list)
    expected = {p.stem for p in modules}
    rows = re.findall(r"^PPG_INVENTORY\|([^|]+)\|([^|]+)\|([^|]+)\|(\d+)$",
                      output, re.M)
    if not rows:
        raise AssertionError("empty Lean declaration inventory")
    for module, name, kind, line in rows:
        if module not in expected:
            raise AssertionError(f"unexpected project module: {module}")
        if kind == "axiom":
            raise AssertionError(f"project-owned axiom: {name}")
        entries[module].append({"name": name, "kind": kind, "line": int(line)})
    if set(entries) != expected:
        raise AssertionError(f"missing modules in inventory: {expected - set(entries)}")
    all_names = [e["name"] for values in entries.values() for e in values]
    if len(all_names) != len(set(all_names)):
        raise AssertionError("duplicate environment declaration")
    return entries


def dependencies_from_output(output, names):
    # Lean declaration names themselves can contain apostrophes.
    # Match complete lines first, taking the final quote before the message.
    rows = []
    pattern = r"^'([^\n]*)' depends on axioms:\s*\[(.*?)\]"
    for name, raw in re.findall(pattern, output, re.M | re.S):
        rows.append((name, sorted(x.strip() for x in raw.split(",") if x.strip())))
    for name in re.findall(r"^'(.*)' does not depend on any axioms$", output, re.M):
        rows.append((name, []))
    deps = dict(rows)
    if len(rows) != len(deps) or set(deps) != set(names):
        raise AssertionError(f"incomplete/duplicate axiom output: "
                             f"missing={set(names) - set(deps)}, extra={set(deps) - set(names)}")
    for name, axioms in deps.items():
        if not set(axioms) <= ALLOWED:
            raise AssertionError(f"unapproved dependency: {name}: {set(axioms) - ALLOWED}")
    return deps


def build(lake, log):
    print("Building all Lake roots before proof inspection...", flush=True)
    with log.open("w") as output:
        result = subprocess.run([str(lake), "build"], cwd=ROOT, text=True,
                                stdout=output, stderr=subprocess.STDOUT)
    if result.returncode:
        raise AssertionError(f"full build failed; see {log}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--add-missing-checks", action="store_true",
                        help="Append fully qualified #check commands, then rebuild.")
    args = parser.parse_args()
    modules = sorted(ROOT.glob("PPGraph*.lean"))
    root_names = re.findall(r"`(PPGraph\w*)", (ROOT / "lakefile.lean").read_text())
    if Counter(root_names) != Counter(p.stem for p in modules):
        raise AssertionError("Lake roots and current PPGraph library files differ")
    for path in modules + sorted((ROOT / "tools").glob("*.lean")):
        inspect_source(path.read_text(), path.name)
    toolchain = (ROOT / "lean-toolchain").read_text().strip()
    directory = toolchain.replace("/", "--").replace(":", "---")
    lake = Path.home() / ".elan/toolchains" / directory / "bin/lake"
    logs = {name: Path("/tmp/ppg-whole-" + name + ".log")
            for name in ("build", "inventory", "axioms")}
    build(lake, logs["build"])
    print("Discovering declarations from Lean module ownership...", flush=True)
    inventory = inventory_from_output(
        lean_harness(lake, modules, INVENTORY_BODY, logs["inventory"]), modules)
    explicit = {}
    missing = {}
    for path in modules:
        declarations, checks = inspect_source(path.read_text(), path.name)
        names, absent = missing_checks(declarations, checks, inventory[path.stem])
        explicit[path.stem] = names
        if absent:
            missing[path] = absent
    if missing:
        if not args.add_missing_checks:
            raise AssertionError("missing theorem #check: " + repr(
                {p.name: names for p, names in missing.items()}))
        for path, names in missing.items():
            with path.open("a") as output:
                output.write("\n-- Explicit checks for all remaining helper theorems.\n")
                output.write("\n".join("#check @" + name for name in names) + "\n")
        print(f"Added {sum(map(len, missing.values()))} #checks in {len(missing)} modules.",
              flush=True)
        build(lake, logs["build"])
        inventory = inventory_from_output(
            lean_harness(lake, modules, INVENTORY_BODY, logs["inventory"]), modules)
        for path in modules:
            declarations, checks = inspect_source(path.read_text(), path.name)
            names, absent = missing_checks(declarations, checks, inventory[path.stem])
            if absent:
                raise AssertionError(f"remaining missing checks: {path}: {absent}")
            explicit[path.stem] = names
    source_paths = modules + [ROOT / name for name in
                             ("lakefile.lean", "lean-toolchain", "lake-manifest.json")]
    source_hashes = {str(p.relative_to(ROOT)): digest(p) for p in source_paths}
    all_entries = {entry["name"]: {"module": module, **entry}
                   for module, entries in inventory.items() for entry in entries}
    print(f"Printing axiom dependencies of {len(all_entries)} project declarations...",
          flush=True)
    raw = lean_harness(lake, modules, DEPENDENCY_BODY, logs["axioms"])
    dependencies = dependencies_from_output(raw, all_entries)
    for relative, expected in source_hashes.items():
        if digest(ROOT / relative) != expected:
            raise AssertionError(f"source changed during audit: {relative}")
    theorem_names = sorted(name for names in explicit.values() for name in names)
    count = len(theorem_names)
    generated = sum(e["kind"] == "theorem" for e in all_entries.values()) - count
    date = datetime.now(timezone.utc).date().isoformat()
    summary = (
        f"PPGraph whole-library axiom audit — {date}\n\n"
        f"PASS: {count} explicitly declared theorems in {len(modules)} Lake roots.\n"
        f"Also audited: {generated} generated theorem constants and all remaining "
        f"project declarations, {len(all_entries)} declarations in total.\n"
        "Every explicitly declared theorem has an explicit #check.\n"
        "Module ownership comes from the imported Lean environment.\n"
        "Every project declaration is inspected with a temporary #print axioms command.\n"
        "Allowed dependencies: any subset of {propext, Classical.choice, Quot.sound}.\n"
        "No project-owned axioms, sorry/admit, native_decide, bv_decide, or unsafe/extern overrides.\n"
        "Full Lake build passed before inspection; source hashes checked afterward.\n"
        "Scope: the current PPGraph library roots, not .changes archival copies or Mathlib's "
        "own declarations. Transitive dependencies on imported proofs ARE checked.\n"
        "This audit does not prove paper fidelity, C compiler preservation, native hardware "
        "execution, acquisition, or optical response.\n"
        "Reproduce: python3 tools/audit_ppgraph.py\n"
        "Source hashes and per-declaration details: PPGRAPH_AXIOM_AUDIT.json\n\n")
    report = {
        "date_utc": date, "toolchain": toolchain,
        "full_build_passed": True, "kernel_checked_library": True,
        "axiom_audit_passed": True, "every_explicit_theorem_has_check": True,
        "allowed_dependencies": sorted(ALLOWED), "project_owned_axioms": 0,
        "module_count": len(modules), "explicit_theorem_count": count,
        "generated_theorem_count": generated,
        "environment_declaration_count": len(all_entries),
        "source_sha256": source_hashes,
        "audit_tool_sha256": digest(Path(__file__)),
        "full_build_log_sha256": digest(logs["build"]),
        "inventory_log_sha256": digest(logs["inventory"]),
        "axiom_log_sha256": digest(logs["axioms"]),
        "modules": {module: {"explicit_theorems": names,
                              "environment_declaration_count": len(inventory[module])}
                    for module, names in explicit.items()},
        "declarations": {name: {"module": all_entries[name]["module"],
                                 "kind": all_entries[name]["kind"],
                                 "explicit_theorem": name in theorem_names,
                                 "axioms": dependencies[name]}
                         for name in sorted(all_entries)},
        "fidelity_to_papers_proved_by_audit": False,
        "native_hardware_or_compiler_correctness_proved_by_audit": False,
    }
    (ROOT / "PPGRAPH_AXIOM_AUDIT.txt").write_text(summary + raw)
    (ROOT / "PPGRAPH_AXIOM_AUDIT.json").write_text(json.dumps(report, indent=2) + "\n")
    print(summary.split("\n\n")[1].split("\n")[0], flush=True)
    print(f"All {len(all_entries)} declaration dependencies allowed.", flush=True)
    print("Reports: PPGRAPH_AXIOM_AUDIT.txt, PPGRAPH_AXIOM_AUDIT.json", flush=True)


if __name__ == "__main__":
    main()
