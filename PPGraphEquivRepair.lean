/-
  PPGraphEquivRepair.lean
  Graph-Level Equivalence and Repair via Representative Selection

  Key idea: within one equivalence class of graphs (same certification
  output), we can select a better representative when the current
  graph has operational problems (isolated vertices, broken paths).
  Repair = choosing a different representative in the same class.
-/

import Mathlib.Tactic
import PPGraph
import PPGraphParametric
import PPGraphCategorical

variable {V : Type}

-- ═══════════════════════════════════════════════════════════════════
-- Section 1: Graph Certification Equivalence
-- ═══════════════════════════════════════════════════════════════════

/-- Two graphs are certification-equivalent if pp_valid holds on one
    iff it holds on the other, for all rr_rel and invariants -/
def graph_cert_equiv (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  pp_valid G1 rr_rel invariant ↔ pp_valid G2 rr_rel invariant

theorem graph_cert_equiv_refl (G : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) :
    graph_cert_equiv G G rr_rel invariant :=
  Iff.rfl

theorem graph_cert_equiv_symm (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h : graph_cert_equiv G1 G2 rr_rel invariant) :
    graph_cert_equiv G2 G1 rr_rel invariant :=
  h.symm

theorem graph_cert_equiv_trans (G1 G2 G3 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h12 : graph_cert_equiv G1 G2 rr_rel invariant)
    (h23 : graph_cert_equiv G2 G3 rr_rel invariant) :
    graph_cert_equiv G1 G3 rr_rel invariant :=
  h12.trans h23

-- ═══════════════════════════════════════════════════════════════════
-- Section 2: Operational Quality Predicates
-- ═══════════════════════════════════════════════════════════════════

/-- A graph has no isolated violating vertices -/
def no_isolated_violations (G : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  ∀ v, G.vertices v → ¬ invariant v →
    ∃ w, G.edges w v ∨ G.edges v w

/-- A graph is fully connected among invariant-holding vertices -/
def invariant_connected (G : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  ∀ x y, G.vertices x → G.vertices y → invariant x → invariant y →
    pp_connected G rr_rel invariant x y

/-- A graph has a repair path: every violating vertex has a
    neighbor satisfying the invariant -/
def has_repair_paths (G : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  ∀ v, G.vertices v → ¬ invariant v →
    ∃ w, G.vertices w ∧ invariant w ∧ rr_rel w v

-- ═══════════════════════════════════════════════════════════════════
-- Section 3: Representative Selection (Repair as Choice)
-- ═══════════════════════════════════════════════════════════════════

/-- A graph is a better representative if it is cert-equivalent
    AND has repair paths (operational improvement) -/
def better_representative (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  graph_cert_equiv G1 G2 rr_rel invariant ∧
  has_repair_paths G2 rr_rel invariant

/-- Switching to a better representative preserves pp_valid -/
theorem better_rep_preserves_validity (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h_better : better_representative G1 G2 rr_rel invariant)
    (h_valid : pp_valid G1 rr_rel invariant) :
    pp_valid G2 rr_rel invariant :=
  h_better.1.mp h_valid

/-- Switching to a better representative gains repair paths -/
theorem better_rep_gains_repair (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h_better : better_representative G1 G2 rr_rel invariant) :
    has_repair_paths G2 rr_rel invariant :=
  h_better.2

-- ═══════════════════════════════════════════════════════════════════
-- Section 4: Equivalence-Preserving Graph Morphism
-- ═══════════════════════════════════════════════════════════════════

/-- A repair morphism maps G1 to G2 within the same equivalence class -/
def repair_morphism (f : V → V) (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) : Prop :=
  pp_morphism f G1 G2 rr_rel invariant rr_rel invariant ∧
  graph_cert_equiv G1 G2 rr_rel invariant

/-- Repair morphism preserves pp_valid -/
theorem repair_morphism_preserves (f : V → V) (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h_rm : repair_morphism f G1 G2 rr_rel invariant)
    (h_valid : pp_valid G1 rr_rel invariant) :
    pp_valid G2 rr_rel invariant :=
  h_rm.2.mp h_valid

/-- Identity is always a repair morphism (trivial repair) -/
theorem id_repair_morphism (G : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop) :
    repair_morphism id G G rr_rel invariant :=
  ⟨id_morphism G rr_rel invariant, graph_cert_equiv_refl G rr_rel invariant⟩

-- ═══════════════════════════════════════════════════════════════════
-- Section 5: Repair Composition
-- ═══════════════════════════════════════════════════════════════════

/-- Repair is transitive: if G1 → G2 → G3 are repair morphisms,
    then G1 → G3 is also a valid repair -/
theorem repair_transitive (G1 G2 G3 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h12 : graph_cert_equiv G1 G2 rr_rel invariant)
    (h23 : graph_cert_equiv G2 G3 rr_rel invariant) :
    graph_cert_equiv G1 G3 rr_rel invariant :=
  graph_cert_equiv_trans G1 G2 G3 rr_rel invariant h12 h23

/-- Validity is invariant across the entire equivalence class -/
theorem validity_class_invariant (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h_equiv : graph_cert_equiv G1 G2 rr_rel invariant)
    (h_valid : pp_valid G1 rr_rel invariant) :
    pp_valid G2 rr_rel invariant :=
  h_equiv.mp h_valid

/-- Within an equivalence class, we can always go back (repair is reversible) -/
theorem repair_reversible (G1 G2 : Graph V)
    (rr_rel : V → V → Prop) (invariant : V → Prop)
    (h_equiv : graph_cert_equiv G1 G2 rr_rel invariant)
    (h_valid : pp_valid G2 rr_rel invariant) :
    pp_valid G1 rr_rel invariant :=
  h_equiv.mpr h_valid

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @graph_cert_equiv_refl
#check @graph_cert_equiv_symm
#check @graph_cert_equiv_trans
#check @better_rep_preserves_validity
#check @better_rep_gains_repair
#check @repair_morphism_preserves
#check @id_repair_morphism
#check @repair_transitive
#check @validity_class_invariant
#check @repair_reversible
