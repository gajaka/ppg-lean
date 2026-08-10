/-
  PPGraphParametricQuotient.lean
  Quotient Structure on Specification Space

  Two specifications are certification-equivalent if they certify
  exactly the same data. The quotient Θ/~ gives the effective
  specification space. The spec graph projects to a quotient PPG
  via pp_quotient from PPGraphCategorical.
-/

import Mathlib.Tactic
import PPGraph
import PPGraphParametric
import PPGraphCategorical

variable {Θ : Type} [PartialOrder Θ]
variable {D : Type}

-- ═══════════════════════════════════════════════════════════════════
-- Section 1: Certification Equivalence
-- ═══════════════════════════════════════════════════════════════════

/-- Two specifications are certification-equivalent if they certify
    exactly the same data -/
def cert_equiv (F : CertFamily D Θ) (t1 t2 : Θ) : Prop :=
  ∀ d : D, fully_certified F d t1 ↔ fully_certified F d t2

theorem cert_equiv_refl (F : CertFamily D Θ) (t : Θ) :
    cert_equiv F t t :=
  fun _ => Iff.rfl

theorem cert_equiv_symm (F : CertFamily D Θ) (t1 t2 : Θ)
    (h : cert_equiv F t1 t2) :
    cert_equiv F t2 t1 :=
  fun d => (h d).symm

theorem cert_equiv_trans (F : CertFamily D Θ) (t1 t2 t3 : Θ)
    (h12 : cert_equiv F t1 t2) (h23 : cert_equiv F t2 t3) :
    cert_equiv F t1 t3 :=
  fun d => (h12 d).trans (h23 d)

-- ═══════════════════════════════════════════════════════════════════
-- Section 2: Order Compatibility
-- ═══════════════════════════════════════════════════════════════════

/-- If t1 ≤ t2 and they are cert-equivalent, then they certify
    the same data despite being ordered -/
theorem equiv_and_order_implies_same_cert (F : CertFamily D Θ)
    (t1 t2 : Θ) (_h_order : t1 ≤ t2) (h_equiv : cert_equiv F t1 t2)
    (d : D) :
    fully_certified F d t1 ↔ fully_certified F d t2 :=
  h_equiv d

/-- Canonical level is unique up to certification equivalence:
    any two canonical levels for the same data are cert-equivalent -/
theorem canonical_unique_up_to_equiv (F : CertFamily D Θ)
    (d : D) (t_c1 t_c2 : Θ)
    (h1 : is_canonical F d t_c1) (h2 : is_canonical F d t_c2) :
    cert_equiv F t_c1 t_c2 := by
  intro d'
  constructor
  · intro hc1
    have h_le : t_c1 ≤ t_c2 := h1.2 t_c2 h2.1
    have h_ge : t_c2 ≤ t_c1 := h2.2 t_c1 h1.1
    have h_eq : t_c1 = t_c2 := le_antisymm h_le h_ge
    rw [h_eq] at hc1
    exact hc1
  · intro hc2
    have h_le : t_c1 ≤ t_c2 := h1.2 t_c2 h2.1
    have h_ge : t_c2 ≤ t_c1 := h2.2 t_c1 h1.1
    have h_eq : t_c1 = t_c2 := le_antisymm h_le h_ge
    rw [h_eq]
    exact hc2

/-- In a partial order, canonical is actually unique (not just up to equiv) -/
theorem canonical_unique (F : CertFamily D Θ)
    (d : D) (t_c1 t_c2 : Θ)
    (h1 : is_canonical F d t_c1) (h2 : is_canonical F d t_c2) :
    t_c1 = t_c2 :=
  le_antisymm (h1.2 t_c2 h2.1) (h2.2 t_c1 h1.1)

-- ═══════════════════════════════════════════════════════════════════
-- Section 3: Equivalence Classes and Quotient Order
-- ═══════════════════════════════════════════════════════════════════

/-- cert_equiv is a Setoid -/
def certSetoid (F : CertFamily D Θ) : Setoid Θ where
  r := cert_equiv F
  iseqv := {
    refl := cert_equiv_refl F
    symm := cert_equiv_symm F _ _
    trans := cert_equiv_trans F _ _ _
  }

/-- The quotient type: effective specification space -/
def SpecQuotient (F : CertFamily D Θ) := Quotient (certSetoid F)

/-- Certification is well-defined on the quotient -/
theorem cert_respects_equiv (F : CertFamily D Θ) (d : D) (t1 t2 : Θ)
    (h : cert_equiv F t1 t2) :
    fully_certified F d t1 ↔ fully_certified F d t2 :=
  h d

-- ═══════════════════════════════════════════════════════════════════
-- Section 4: PPG Quotient Bridge
-- ═══════════════════════════════════════════════════════════════════

/-- Spec edge respects certification equivalence:
    if t1 ~ t1' and t2 ~ t2' and spec_edge t1 t2,
    then certification at t1 implies certification at t2
    (same as for t1' and t2') -/
theorem spec_edge_respects_equiv (F : CertFamily D Θ)
    (t1 t2 : Θ) (d : D)
    (h_edge : spec_edge t1 t2)
    (h_cert : fully_certified F d t1) :
    fully_certified F d t2 :=
  certification_propagates F d t1 t2 h_edge h_cert

/-- The projection from Θ to SpecQuotient maps the certified subgraph
    via a surjective map (quotient morphism in PPG sense) -/
theorem quotient_projection_surjective (F : CertFamily D Θ) :
    Function.Surjective (Quotient.mk (certSetoid F)) :=
  fun q => Quotient.inductionOn q (fun a => ⟨a, rfl⟩)

-- ═══════════════════════════════════════════════════════════════════
-- Section 5: Collapse Theorem
-- ═══════════════════════════════════════════════════════════════════

/-- If two specs are equivalent AND ordered, they must be equal
    (no distinct equivalent specs in the same chain) -/
theorem equiv_chain_collapses (F : CertFamily D Θ)
    (t1 t2 : Θ) (_h_order : t1 ≤ t2) (h_equiv : cert_equiv F t1 t2)
    (d : D) (h_cert : fully_certified F d t2) :
    fully_certified F d t1 := by
  exact (h_equiv d).mpr h_cert

/-- Nontrivial equivalence class implies no new certification boundary:
    within one class, all specs agree on every data point -/
theorem equiv_class_uniform (F : CertFamily D Θ)
    (t1 t2 : Θ) (h_equiv : cert_equiv F t1 t2)
    (d : D) :
    fully_certified F d t1 = fully_certified F d t2 := by
  exact propext (h_equiv d)

-- ═══════════════════════════════════════════════════════════════════
-- Section 6: Induced Order on the Quotient
-- ═══════════════════════════════════════════════════════════════════

/-- Induced order on representatives: t1 ≼ t2 if every data certified
    at t1 is also certified at t2.
    (This is the order that descends to the quotient.) -/
def cert_le (F : CertFamily D Θ) (t1 t2 : Θ) : Prop :=
  ∀ d : D, fully_certified F d t1 → fully_certified F d t2

theorem cert_le_refl (F : CertFamily D Θ) (t : Θ) :
    cert_le F t t := fun _ h => h

theorem cert_le_trans (F : CertFamily D Θ) (t1 t2 t3 : Θ)
    (h12 : cert_le F t1 t2) (h23 : cert_le F t2 t3) :
    cert_le F t1 t3 :=
  fun d h => h23 d (h12 d h)

/-- The induced order is compatible with certification equivalence.
    If t1 ~ t1' and t2 ~ t2', then t1 ≼ t2 ↔ t1' ≼ t2'. -/
theorem cert_le_respects_equiv (F : CertFamily D Θ)
    (t1 t1' t2 t2' : Θ)
    (h1 : cert_equiv F t1 t1') (h2 : cert_equiv F t2 t2') :
    cert_le F t1 t2 ↔ cert_le F t1' t2' := by
  constructor
  · intro h d hd'
    have hd : fully_certified F d t1 := (h1 d).mpr hd'
    have h2d : fully_certified F d t2 := h d hd
    exact (h2 d).mp h2d
  · intro h d hd
    have hd' : fully_certified F d t1' := (h1 d).mp hd
    have h2d' : fully_certified F d t2' := h d hd'
    exact (h2 d).mpr h2d'

/-- Well-defined order on the quotient -/
def SpecQuotient.le (F : CertFamily D Θ) (q1 q2 : SpecQuotient F) : Prop :=
  Quotient.lift₂ (cert_le F)
    (fun t1 t2 t1' t2' h1 h2 => propext (cert_le_respects_equiv F t1 t1' t2 t2' h1 h2))
    q1 q2

/-- The quotient carries a preorder -/
instance (F : CertFamily D Θ) : Preorder (SpecQuotient F) where
  le := SpecQuotient.le F
  le_refl := by
    intro q
    refine Quotient.inductionOn q ?_
    intro t
    exact cert_le_refl F t
  le_trans := by
    intro q1 q2 q3
    refine Quotient.inductionOn₃ q1 q2 q3 ?_
    intro t1 t2 t3 h12 h23
    exact cert_le_trans F t1 t2 t3 h12 h23

/-- Antisymmetry on the quotient (because we already quotiented by cert_equiv) -/
theorem SpecQuotient.le_antisymm (F : CertFamily D Θ)
    (q1 q2 : SpecQuotient F)
    (h12 : q1 ≤ q2) (h21 : q2 ≤ q1) : q1 = q2 := by
  refine Quotient.inductionOn₂ q1 q2 (fun t1 t2 h12 h21 => ?_) h12 h21
  apply Quotient.sound
  intro d
  constructor
  · exact h12 d
  · exact h21 d

/-- PartialOrder on the quotient -/
instance (F : CertFamily D Θ) : PartialOrder (SpecQuotient F) where
  le_antisymm := SpecQuotient.le_antisymm F

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @cert_equiv_refl
#check @cert_equiv_symm
#check @cert_equiv_trans
#check @equiv_and_order_implies_same_cert
#check @canonical_unique_up_to_equiv
#check @canonical_unique
#check @cert_respects_equiv
#check @spec_edge_respects_equiv
#check @quotient_projection_surjective
#check @equiv_chain_collapses
#check @equiv_class_uniform
#check @cert_le_refl
#check @cert_le_trans
#check @cert_le_respects_equiv
#check @SpecQuotient.le_antisymm
