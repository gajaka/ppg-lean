#!/usr/bin/env python3
"""Regression checks for the whole-library audit's rejection boundaries."""

from pathlib import Path
import unittest

import audit_ppgraph as audit


class AuditTests(unittest.TestCase):
    def test_comments_strings_and_lean_identifiers(self):
        source = '''/- theorem fake : sorry /- axiom nested -/ -/
def text := "theorem fake native_decide"
@[simp] theorem Scope.answer' : True := by trivial
  theorem Scope.read?_step : True := by trivial
#check @Scope.answer'
#check @Scope.read?_step
-- #check @fake
'''
        declarations, checks = audit.inspect_source(source, "fixture")
        self.assertEqual(declarations, [("Scope.answer'", 3), ("Scope.read?_step", 4)])
        self.assertEqual(checks, ["Scope.answer'", "Scope.read?_step"])

    def test_missing_check_is_not_covered_by_an_import(self):
        entries = [{"name": "Local.proof", "kind": "theorem", "line": 1},
                   {"name": "Local.model", "kind": "definition", "line": 2}]
        names, missing = audit.missing_checks(
            [("proof", 1)], ["Imported.proof", "Local.model"], entries)
        self.assertEqual(names, ["Local.proof"])
        self.assertEqual(missing, ["Local.proof"])
        self.assertEqual(audit.missing_checks(
            [("proof", 1)], ["Local.proof"], entries)[1], [])

    def test_unapproved_source_mechanisms_are_rejected(self):
        for mechanism in ("sorry", "admit", "native_decide", "bv_decide"):
            with self.subTest(mechanism=mechanism), self.assertRaises(AssertionError):
                audit.inspect_source(f"theorem x : True := by {mechanism}\n", "fixture")
        for source in ("axiom x : True\n", "#print axioms x\n",
                       "unsafe def x : Nat := 0\n",
                       '@[extern "foreign"] def x : Nat := 0\n',
                       "@[implemented_by replacement] def x : Nat := 0\n"):
            with self.subTest(source=source), self.assertRaises(AssertionError):
                audit.inspect_source(source, "fixture")

    def test_any_allowed_subset_and_apostrophes(self):
        raw = ("'proof' does not depend on any axioms\n"
               "'Scope.answer'' depends on axioms: [propext,\nQuot.sound]\n"
               "'other' depends on axioms: [Classical.choice]\n")
        result = audit.dependencies_from_output(raw, ["proof", "Scope.answer'", "other"])
        self.assertEqual(result["proof"], [])
        self.assertEqual(result["Scope.answer'"], ["Quot.sound", "propext"])

    def test_unapproved_incomplete_and_duplicate_dependencies(self):
        for raw in (
            "'proof' depends on axioms: [sorryAx]\n",
            "'proof' depends on axioms: [CompilerCorrectness]\n",
            "",
            "'proof' does not depend on any axioms\n" * 2,
        ):
            with self.subTest(raw=raw), self.assertRaises(AssertionError):
                audit.dependencies_from_output(raw, ["proof"])

    def test_unreferenced_project_axioms_are_rejected(self):
        with self.assertRaisesRegex(AssertionError, "project-owned axiom"):
            audit.inventory_from_output(
                "PPG_INVENTORY|PPGraphFixture|unused|axiom|1\n",
                [Path("PPGraphFixture.lean")])


if __name__ == "__main__":
    unittest.main(verbosity=2)
