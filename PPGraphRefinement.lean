/-
  Refinement Relations for Proof-Preserving Graphs (Lean 4)
  Port of sets_aux@rr_rel (Stosic, NASA PVS Library)

  Formalizes the refinement relation RR between elements of two types
  partitioned by equivalence relations, connected by abstraction (f)
  and concretization (g) functions.

  Original PVS: https://github.com/nasa/pvslib/blob/master/sets_aux/rr_rel.pvs
-/

import Mathlib.Tactic

-- ═══════════════════════════════════════════════════════════════════
-- Section 1: Relation Extension
-- Port of relation_extension.pvs (Stosic, NASA PVS Library)
-- ═══════════════════════════════════════════════════════════════════

-- An equivalence relation (reflexive, symmetric, transitive)
structure EquivRel (T : Type) where
  rel : T → T → Prop
  refl : ∀ x, rel x x
  symm : ∀ x y, rel x y → rel y x
  trans : ∀ x y z, rel x y → rel y z → rel x z

-- Relation extension: product equivalence from two component equivalences
-- rel_extension(le_T, le_U)(m, n) ≡ le_T(m.1, n.1) ∧ le_U(m.2, n.2)
def rel_extension {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (m n : T × U) : Prop :=
  le_T.rel m.1 n.1 ∧ le_U.rel m.2 n.2

-- rel_extension is itself an equivalence
theorem rel_extension_refl {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (m : T × U) : rel_extension le_T le_U m m :=
  ⟨le_T.refl m.1, le_U.refl m.2⟩

theorem rel_extension_symm {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (m n : T × U) (h : rel_extension le_T le_U m n) :
    rel_extension le_T le_U n m :=
  ⟨le_T.symm _ _ h.1, le_U.symm _ _ h.2⟩

theorem rel_extension_trans {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (m n p : T × U) (h1 : rel_extension le_T le_U m n)
    (h2 : rel_extension le_T le_U n p) :
    rel_extension le_T le_U m p :=
  ⟨le_T.trans _ _ _ h1.1 h2.1, le_U.trans _ _ _ h1.2 h2.2⟩

-- ═══════════════════════════════════════════════════════════════════
-- Section 2: Refinement Relation RR
-- Port of rr_rel.pvs Definition 1 (Stosic, NASA PVS Library)
-- ═══════════════════════════════════════════════════════════════════

/-
  RR(le_T, le_U, f, g)(x, y) holds when at least one of three
  conditions is satisfied:
    1. rel_extension(le_T, le_U)( (x, f(x)), (g(y), y) )
    2. rel_extension(le_T, le_U)( (g(y), f(x)), (x, f(x)) )
    3. rel_extension(le_T, le_U)( (g(y), f(x)), (g(y), y) )

  Intuition:
    - f : T → U is the abstraction function
    - g : U → T is the concretization function
    - Fn = (x, f(x))     — element paired with its abstraction
    - Gn = (g(y), y)     — concretization paired with element
    - GFn = (g(y), f(x)) — cross pair
    - RR holds if any pair of {Fn, Gn, GFn} are equivalent under
      the product equivalence relation
-/
def RR {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (f : T → U) (g : U → T) (x : T) (y : U) : Prop :=
  let Fn := (x, f x)
  let Gn := (g y, y)
  let GFn := (g y, f x)
  rel_extension le_T le_U Fn Gn ∨
  rel_extension le_T le_U GFn Fn ∨
  rel_extension le_T le_U GFn Gn

-- Unfolded: RR holds iff one of:
--   (1) le_T(x, g(y)) ∧ le_U(f(x), y)
--   (2) le_T(g(y), x) ∧ le_U(f(x), f(x))  [second conjunct trivial]
--   (3) le_T(g(y), g(y)) ∧ le_U(f(x), y)   [first conjunct trivial]

-- ═══════════════════════════════════════════════════════════════════
-- Section 3: Consistency Lemmas
-- ═══════════════════════════════════════════════════════════════════

-- g_consistent: if le_T(x, g(y)) then RR holds
-- Uses second disjunct: rel_extension(GFn, Fn) where GFn=(g(y),f(x)), Fn=(x,f(x))
-- This requires le_T(g(y), x) ∧ le_U(f(x), f(x))
-- We get le_T(g(y), x) from symmetry of le_T(x, g(y))
-- and le_U(f(x), f(x)) from reflexivity
theorem g_consistent_with_RR {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (f : T → U) (g : U → T) (x : T) (y : U)
    (h : le_T.rel x (g y)) : RR le_T le_U f g x y := by
  right; left
  exact ⟨le_T.symm _ _ h, le_U.refl (f x)⟩

-- f_consistent: if le_U(y, f(x)) then RR holds
-- (corresponds to f_conistent_with_RR in PVS)
theorem f_consistent_with_RR {T U : Type} (le_T : EquivRel T) (le_U : EquivRel U)
    (f : T → U) (g : U → T) (x : T) (y : U)
    (h : le_U.rel y (f x)) : RR le_T le_U f g x y := by
  right; right
  exact ⟨le_T.refl (g y), le_U.symm _ _ h⟩

-- ═══════════════════════════════════════════════════════════════════
-- Section 4: Homogeneous Refinement (T = U, same equivalence)
-- This is what proof_preserving_graphs uses
-- ═══════════════════════════════════════════════════════════════════

-- Homogeneous RR: both types are the same, one equivalence relation
def RR_hom {T : Type} (le_T : EquivRel T) (f_abs : T → T) (g_con : T → T)
    (x y : T) : Prop :=
  RR le_T le_T f_abs g_con x y

-- Reflexivity: RR_hom holds when equivalence is reflexive and f=g=id
theorem RR_hom_refl_id {T : Type} (le_T : EquivRel T) (x : T) :
    RR_hom le_T id id x x := by
  left
  exact ⟨le_T.refl x, le_T.refl x⟩

-- g_consistent specialized for homogeneous case
theorem g_consistent_hom {T : Type} (le_T : EquivRel T)
    (f_abs : T → T) (g_con : T → T) (x y : T)
    (h : le_T.rel x (g_con y)) : RR_hom le_T f_abs g_con x y :=
  g_consistent_with_RR le_T le_T f_abs g_con x y h

-- f_consistent specialized for homogeneous case
theorem f_consistent_hom {T : Type} (le_T : EquivRel T)
    (f_abs : T → T) (g_con : T → T) (x y : T)
    (h : le_T.rel y (f_abs x)) : RR_hom le_T f_abs g_con x y :=
  f_consistent_with_RR le_T le_T f_abs g_con x y h

-- ═══════════════════════════════════════════════════════════════════
-- Section 5: Connection to PP-Graph
-- ═══════════════════════════════════════════════════════════════════

-- The pp_edge from PPGraph.lean uses an abstract rr_rel.
-- Here we show how to instantiate it with RR_hom:

structure PPGraphConfig (T : Type) where
  le_T : EquivRel T
  f_abs : T → T
  g_con : T → T
  invariant_holds : T → Prop

def pp_edge_concrete {T : Type} (cfg : PPGraphConfig T) (x y : T) : Prop :=
  x ≠ y ∧ cfg.invariant_holds x ∧ cfg.invariant_holds y ∧
  RR_hom cfg.le_T cfg.f_abs cfg.g_con x y

-- T1: g-consistent edge is a valid pp-edge (if invariants hold)
theorem g_consistent_pp_edge {T : Type} (cfg : PPGraphConfig T) (x y : T)
    (hne : x ≠ y)
    (hix : cfg.invariant_holds x)
    (hiy : cfg.invariant_holds y)
    (hg : cfg.le_T.rel x (cfg.g_con y)) :
    pp_edge_concrete cfg x y :=
  ⟨hne, hix, hiy, g_consistent_hom cfg.le_T cfg.f_abs cfg.g_con x y hg⟩

-- T2: f-consistent edge is a valid pp-edge (if invariants hold)
theorem f_consistent_pp_edge {T : Type} (cfg : PPGraphConfig T) (x y : T)
    (hne : x ≠ y)
    (hix : cfg.invariant_holds x)
    (hiy : cfg.invariant_holds y)
    (hf : cfg.le_T.rel y (cfg.f_abs x)) :
    pp_edge_concrete cfg x y :=
  ⟨hne, hix, hiy, f_consistent_hom cfg.le_T cfg.f_abs cfg.g_con x y hf⟩

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @rel_extension_refl
#check @rel_extension_symm
#check @rel_extension_trans
#check @RR
#check @g_consistent_with_RR
#check @f_consistent_with_RR
#check @RR_hom
#check @RR_hom_refl_id
#check @g_consistent_hom
#check @f_consistent_hom
#check @g_consistent_pp_edge
#check @f_consistent_pp_edge
