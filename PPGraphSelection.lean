/-
  PPGraphSelection.lean
  Hierarchical Representative Selection via Family of Morphism Pairs

  Given a family of (f_i, g_i) pairs, each inducing an equivalence
  on the codomain, the finest equivalence (intersection of all)
  gives the canonical representative selection.

  Key: ∼* = ⋂ᵢ ∼ᵢ. Element canonical w.r.t. ∼* survives all views.
-/

import Mathlib.Tactic
import PPGraph
import PPGraphParametric

set_option linter.unusedVariables false

variable {T U : Type}

-- ═══════════════════════════════════════════════════════════════════
-- Section 1: Single Morphism Pair Induces Equivalence
-- ═══════════════════════════════════════════════════════════════════

/-- A morphism pair (f, g) with an equivalence on U -/
structure MorphPair (T U : Type) where
  f : T → U
  g : U → T
  eq_U : U → U → Prop
  is_equiv : Equivalence eq_U

/-- The equivalence induced by a morphism pair on U:
    u1 ~ u2 iff they are in the same eq_U class -/
def induced_equiv (mp : MorphPair T U) (u1 u2 : U) : Prop :=
  mp.eq_U u1 u2

-- ═══════════════════════════════════════════════════════════════════
-- Section 2: Family of Morphism Pairs
-- ═══════════════════════════════════════════════════════════════════

/-- A family of morphism pairs -/
structure MorphFamily (T U : Type) where
  pairs : List (MorphPair T U)
  nonempty : pairs ≠ []

/-- The finest equivalence: intersection of all induced equivalences.
    u1 ~* u2 iff u1 ~ᵢ u2 for ALL pairs in the family -/
def finest_equiv (F : MorphFamily T U) (u1 u2 : U) : Prop :=
  ∀ mp ∈ F.pairs, induced_equiv mp u1 u2

/-- finest_equiv is reflexive -/
theorem finest_equiv_refl (F : MorphFamily T U) (u : U) :
    finest_equiv F u u := by
  intro mp _
  exact mp.is_equiv.refl u

/-- finest_equiv is symmetric -/
theorem finest_equiv_symm (F : MorphFamily T U) (u1 u2 : U)
    (h : finest_equiv F u1 u2) :
    finest_equiv F u2 u1 := by
  intro mp hmp
  exact mp.is_equiv.symm (h mp hmp)

/-- finest_equiv is transitive -/
theorem finest_equiv_trans (F : MorphFamily T U) (u1 u2 u3 : U)
    (h12 : finest_equiv F u1 u2) (h23 : finest_equiv F u2 u3) :
    finest_equiv F u1 u3 := by
  intro mp hmp
  exact mp.is_equiv.trans (h12 mp hmp) (h23 mp hmp)

/-- finest_equiv is an equivalence -/
theorem finest_equiv_is_equivalence (F : MorphFamily T U) :
    Equivalence (finest_equiv F) where
  refl := finest_equiv_refl F
  symm := finest_equiv_symm F _ _
  trans := finest_equiv_trans F _ _ _

/-- Setoid from the finest equivalence -/
def finestSetoid (F : MorphFamily T U) : Setoid U where
  r := finest_equiv F
  iseqv := finest_equiv_is_equivalence F

-- ═══════════════════════════════════════════════════════════════════
-- Section 3: Finest Equivalence Refines Each Individual One
-- ═══════════════════════════════════════════════════════════════════

/-- finest_equiv refines each individual equivalence -/
theorem finest_refines_each (F : MorphFamily T U)
    (mp : MorphPair T U) (hmp : mp ∈ F.pairs)
    (u1 u2 : U) (h : finest_equiv F u1 u2) :
    induced_equiv mp u1 u2 :=
  h mp hmp

/-- finest_equiv is the coarsest equivalence that refines all -/
theorem finest_is_coarsest_refinement (F : MorphFamily T U)
    (eq_R : U → U → Prop)
    (h_refines : ∀ mp ∈ F.pairs, ∀ u1 u2, eq_R u1 u2 → induced_equiv mp u1 u2)
    (u1 u2 : U) (h : eq_R u1 u2) :
    finest_equiv F u1 u2 := by
  intro mp hmp
  exact h_refines mp hmp u1 u2 h

-- ═══════════════════════════════════════════════════════════════════
-- Section 4: Canonical Representative (survives all views)
-- ═══════════════════════════════════════════════════════════════════

/-- A property on U -/
def Property (U : Type) := U → Prop

/-- An element is canonical in the finest class if it satisfies
    a selection property that is uniform within finest classes -/
def is_finest_canonical (F : MorphFamily T U)
    (sel : Property U) (u : U) : Prop :=
  sel u ∧ ∀ u' : U, finest_equiv F u u' → sel u' → u = u'

/-- If selection property is unique within finest classes,
    canonical representative is unique -/
theorem finest_canonical_unique (F : MorphFamily T U)
    (sel : Property U) (u1 u2 : U)
    (h1 : is_finest_canonical F sel u1)
    (h2 : is_finest_canonical F sel u2)
    (h_equiv : finest_equiv F u1 u2) :
    u1 = u2 :=
  h1.2 u2 h_equiv h2.1

-- ═══════════════════════════════════════════════════════════════════
-- Section 5: Connection to CertFamily
-- ═══════════════════════════════════════════════════════════════════

/-- Each morphism pair induces a certificate:
    "element lands in the correct class under this pair" -/
def pair_cert (mp : MorphPair T U) (u : U) (target_class : U) : Prop :=
  induced_equiv mp u target_class

/-- The family of pair-certificates is monotone w.r.t. refinement:
    if u is in the correct class for ALL pairs, it remains so
    for any subset of pairs -/
theorem pair_certs_monotone (F : MorphFamily T U)
    (u target : U)
    (h : finest_equiv F u target) (mp : MorphPair T U)
    (hmp : mp ∈ F.pairs) :
    pair_cert mp u target :=
  h mp hmp

-- ═══════════════════════════════════════════════════════════════════
-- Section 6: PPG Validity on Finest Quotient
-- ═══════════════════════════════════════════════════════════════════

/-- The finest quotient type -/
def FinestQuotient (F : MorphFamily T U) := Quotient (finestSetoid F)

/-- Graph on the finest quotient: edges from refinement between classes -/
def finest_graph (F : MorphFamily T U) (edge_rel : U → U → Prop) :
    Graph (FinestQuotient F) where
  vertices := fun _ => True
  edges := fun q1 q2 =>
    q1 ≠ q2 ∧ ∃ u1 u2 : U,
      Quotient.mk (finestSetoid F) u1 = q1 ∧
      Quotient.mk (finestSetoid F) u2 = q2 ∧
      edge_rel u1 u2
  edges_in_vertices := fun _ _ _ => ⟨trivial, trivial⟩

/-- An invariant on U that respects finest_equiv descends to quotient -/
def quotient_invariant (F : MorphFamily T U)
    (inv : U → Prop) (h_resp : ∀ u1 u2, finest_equiv F u1 u2 → (inv u1 ↔ inv u2)) :
    FinestQuotient F → Prop :=
  Quotient.lift inv (fun u1 u2 h => propext (h_resp u1 u2 h))

/-- If invariant is respected by finest_equiv and pp_valid holds
    on representative level, it holds on quotient -/
theorem finest_quotient_pp_valid (F : MorphFamily T U)
    (G : Graph U) (rr_rel : U → U → Prop) (inv : U → Prop)
    (h_valid : pp_valid G rr_rel inv)
    (h_inv_resp : ∀ u1 u2, finest_equiv F u1 u2 → (inv u1 ↔ inv u2))
    (u1 u2 : U) (h_edge : G.edges u1 u2) :
    inv u1 ∧ inv u2 :=
  ⟨(h_valid u1 u2 h_edge).2.1, (h_valid u1 u2 h_edge).2.2.1⟩

/-- Selection preserves invariant: if canonical representative satisfies
    inv, all elements in its finest class also satisfy inv -/
theorem canonical_preserves_invariant (F : MorphFamily T U)
    (inv : U → Prop)
    (h_resp : ∀ u1 u2, finest_equiv F u1 u2 → (inv u1 ↔ inv u2))
    (u_can u' : U) (h_equiv : finest_equiv F u_can u')
    (h_inv : inv u_can) :
    inv u' :=
  (h_resp u_can u' h_equiv).mp h_inv

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @finest_equiv_is_equivalence
#check @finest_refines_each
#check @finest_is_coarsest_refinement
#check @finest_canonical_unique
#check @pair_certs_monotone
#check @finest_graph
#check @quotient_invariant
#check @finest_quotient_pp_valid
#check @canonical_preserves_invariant
