/-
  PPGraphQuotientBridge.lean
  Bridge: Spec Graph → Quotient via PP-Quotient Morphism

  The projection from the specification graph (Θ, spec_edge) to the
  quotient (Θ/~, induced order) is a surjective pp-morphism, i.e.,
  a pp_quotient in the sense of PPGraphCategorical.
-/

import Mathlib.Tactic
import PPGraph
import PPGraphParametric
import PPGraphParametricQuotient
import PPGraphCategorical

set_option linter.unusedVariables false

variable {Θ : Type} [PartialOrder Θ]
variable {D : Type}

-- ═══════════════════════════════════════════════════════════════════
-- Section 1: Quotient Graph Construction
-- ═══════════════════════════════════════════════════════════════════

/-- The quotient graph: vertices are equivalence classes,
    edges are induced by cert_le (strict) -/
def quotient_graph (F : CertFamily D Θ) : Graph (SpecQuotient F) where
  vertices := fun _ => True
  edges := fun q1 q2 => q1 ≤ q2 ∧ q1 ≠ q2
  edges_in_vertices := fun _ _ _ => ⟨trivial, trivial⟩

-- ═══════════════════════════════════════════════════════════════════
-- Section 2: Projection is PP-Morphism
-- ═══════════════════════════════════════════════════════════════════

/-- The projection Θ → Θ/~ maps vertices to vertices -/
theorem proj_preserves_vertices (F : CertFamily D Θ) (t : Θ)
    (h : (spec_graph Θ).vertices t) :
    (quotient_graph F).vertices (Quotient.mk (certSetoid F) t) :=
  trivial

/-- The projection preserves edge structure:
    spec_edge t1 t2 → quotient edge [t1] [t2] (or collapsed) -/
theorem proj_preserves_edges (F : CertFamily D Θ) (t1 t2 : Θ)
    (h_edge : spec_edge t1 t2) :
    (quotient_graph F).edges
      (Quotient.mk (certSetoid F) t1)
      (Quotient.mk (certSetoid F) t2) ∨
    Quotient.mk (certSetoid F) t1 = Quotient.mk (certSetoid F) t2 := by
  by_cases h_eq : Quotient.mk (certSetoid F) t1 = Quotient.mk (certSetoid F) t2
  · right; exact h_eq
  · left
    constructor
    · -- Need: [t1] ≤ [t2] in quotient, i.e., cert_le F t1 t2
      intro d h_cert
      exact master_refinement F d t1 t2 h_edge.1 h_cert
    · exact h_eq

/-- The projection is surjective (already proved) -/
theorem proj_surjective (F : CertFamily D Θ) :
    Function.Surjective (Quotient.mk (certSetoid F)) :=
  quotient_projection_surjective F

-- ═══════════════════════════════════════════════════════════════════
-- Section 3: Certification Descends to Quotient
-- ═══════════════════════════════════════════════════════════════════

/-- Certification is well-defined on the quotient graph -/
def quotient_certified (F : CertFamily D Θ) (d : D) :
    SpecQuotient F → Prop :=
  Quotient.lift (fully_certified F d)
    (fun t1 t2 h_equiv => propext (h_equiv d))

/-- Quotient certification at a class = certification at any representative -/
theorem quotient_certified_iff (F : CertFamily D Θ) (d : D) (t : Θ) :
    quotient_certified F d (Quotient.mk (certSetoid F) t) ↔
    fully_certified F d t :=
  Iff.rfl

/-- Quotient certification propagates along quotient edges -/
theorem quotient_cert_propagates (F : CertFamily D Θ) (d : D)
    (q1 q2 : SpecQuotient F)
    (h_edge : (quotient_graph F).edges q1 q2)
    (h_cert : quotient_certified F d q1) :
    quotient_certified F d q2 := by
  revert h_cert h_edge
  refine Quotient.inductionOn₂ q1 q2 ?_
  intro t1 t2 h_edge h_cert
  exact h_edge.1 d h_cert

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @quotient_graph
#check @proj_preserves_vertices
#check @proj_preserves_edges
#check @proj_surjective
#check @quotient_certified
#check @quotient_certified_iff
#check @quotient_cert_propagates
