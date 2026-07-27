/-
  Secure Boot Chain Verification (Lean 4)
  Port of lowrisc_boot_verification.pvs and opentitan_boot_instance.pvs (Stosic)

  Layered proof-preserving graphs applied to hardware root-of-trust:
  ROM → ROM_EXT → BL0 → Kernel
-/

import Mathlib.Tactic

structure Graph (V : Type) where
  vertices : V → Prop
  edges : V → V → Prop
  edges_in_vertices : ∀ x y, edges x y → vertices x ∧ vertices y

def pp_edge {V : Type} (rr_rel : V → V → Prop) (invariant_holds : V → Prop) (x y : V) : Prop :=
  x ≠ y ∧ invariant_holds x ∧ invariant_holds y ∧ rr_rel x y

def pp_valid {V : Type} (G : Graph V) (rr_rel : V → V → Prop) (invariant_holds : V → Prop) : Prop :=
  ∀ x y, G.edges x y → pp_edge rr_rel invariant_holds x y

-- ═══════════════════════════════════════════════════════════════════
-- PART 1: Abstract Boot Chain Verification
-- ═══════════════════════════════════════════════════════════════════

variable {V : Type}

-- Layered: pp_valid + edges go strictly upward
def layered (G : Graph V) (level : V → Nat) (rr_rel : V → V → Prop)
    (invariant_holds : V → Prop) : Prop :=
  pp_valid G rr_rel invariant_holds ∧
  ∀ x y, G.edges x y → level x < level y

-- Lock-out: no edges to lower levels
def locked_below (G : Graph V) (level : V → Nat) (v : V) : Prop :=
  ∀ w, G.edges v w → level w ≥ level v

-- Full lock-out
def full_lockout (G : Graph V) (level : V → Nat) : Prop :=
  ∀ v, G.vertices v → locked_below G level v

-- Boot chain: layered + unique level per vertex
def boot_chain (G : Graph V) (level : V → Nat) (rr_rel : V → V → Prop)
    (invariant_holds : V → Prop) : Prop :=
  layered G level rr_rel invariant_holds ∧
  ∀ x y, G.vertices x → G.vertices y → level x = level y → x = y

-- Verification step
def verifies (G : Graph V) (level : V → Nat) (rr_rel : V → V → Prop)
    (invariant_holds : V → Prop) (x y : V) : Prop :=
  G.edges x y ∧ pp_edge rr_rel invariant_holds x y ∧ level x + 1 = level y

-- Secure boot
def secure_boot (G : Graph V) (level : V → Nat) (rr_rel : V → V → Prop)
    (invariant_holds : V → Prop) : Prop :=
  boot_chain G level rr_rel invariant_holds ∧
  ∀ v, G.vertices v → level v > 0 →
    ∃ u, verifies G level rr_rel invariant_holds u v

-- T1: layered implies full lock-out
theorem layered_implies_lockout (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (h : layered G level rr_rel invariant_holds) :
    full_lockout G level :=
  fun _ _ w he => Nat.le_of_lt (h.2 _ w he)

-- T2: layered implies pp_valid
theorem layered_is_valid (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (h : layered G level rr_rel invariant_holds) :
    pp_valid G rr_rel invariant_holds :=
  h.1

-- T3: layered edges connect distinct vertices
theorem layered_acyclic (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (h : layered G level rr_rel invariant_holds)
    (x y : V) (he : G.edges x y) : x ≠ y :=
  fun heq => Nat.lt_irrefl _ (heq ▸ h.2 x y he)

-- T4: failure blocks downstream
theorem boot_failure_blocks (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (_hbc : boot_chain G level rr_rel invariant_holds)
    (v : V) (hfail : ¬ invariant_holds v) :
    ∀ w, ¬ (G.edges v w ∧ pp_edge rr_rel invariant_holds v w) :=
  fun _ ⟨_, hpp⟩ => hfail hpp.2.1

-- T5: verification implies both invariants hold
theorem verification_implies_invariants (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (x y : V) (hv : verifies G level rr_rel invariant_holds x y) :
    invariant_holds x ∧ invariant_holds y :=
  ⟨hv.2.1.2.1, hv.2.1.2.2.1⟩

-- T6: verification implies refinement
theorem verification_implies_refinement (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (x y : V) (hv : verifies G level rr_rel invariant_holds x y) :
    rr_rel x y :=
  hv.2.1.2.2.2

-- T7: secure boot → all edges connect invariant-holding vertices
theorem secure_boot_invariants (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (hsb : secure_boot G level rr_rel invariant_holds)
    (x y : V) (he : G.edges x y) :
    invariant_holds x ∧ invariant_holds y := by
  have hpp := hsb.1.1.1 x y he
  exact ⟨hpp.2.1, hpp.2.2.1⟩

-- T8: failed stage isolated
theorem failed_stage_isolated (G : Graph V) (level : V → Nat)
    (rr_rel : V → V → Prop) (invariant_holds : V → Prop)
    (_hbc : boot_chain G level rr_rel invariant_holds)
    (v : V) (hfail : ¬ invariant_holds v) :
    ∀ w, ¬ G.edges v w :=
  fun w he => hfail (_hbc.1.1 v w he).2.1

-- ═══════════════════════════════════════════════════════════════════
-- PART 2: OpenTitan Concrete Instantiation
-- ═══════════════════════════════════════════════════════════════════

inductive BootStage where
  | ROM : BootStage
  | ROM_EXT : BootStage
  | BL0 : BootStage
  | KERNEL : BootStage
  deriving DecidableEq, Repr

open BootStage

def ot_level : BootStage → Nat
  | ROM => 0
  | ROM_EXT => 1
  | BL0 => 2
  | KERNEL => 3

def ot_edges : BootStage → BootStage → Prop
  | ROM, ROM_EXT => True
  | ROM_EXT, BL0 => True
  | BL0, KERNEL => True
  | _, _ => False

def ot_refines : BootStage → BootStage → Prop
  | ROM, ROM_EXT => True
  | ROM_EXT, BL0 => True
  | BL0, KERNEL => True
  | _, _ => False

def ot_invariant (signature_valid : BootStage → Prop)
    (hash_valid : BootStage → Prop) (policy_valid : BootStage → Prop) :
    BootStage → Prop
  | ROM => True
  | ROM_EXT => signature_valid ROM_EXT
  | BL0 => hash_valid BL0
  | KERNEL => policy_valid KERNEL

-- T9: levels strictly increasing
theorem ot_levels_increasing (x y : BootStage) (he : ot_edges x y) :
    ot_level x < ot_level y := by
  cases x <;> cases y <;> simp [ot_edges, ot_level] at *

-- T10: unique levels
theorem ot_unique_levels (x y : BootStage) (h : ot_level x = ot_level y) :
    x = y := by
  cases x <;> cases y <;> simp [ot_level] at *

-- T11: ROM is root
theorem ot_rom_is_root (s : BootStage) (h : ot_level s = 0) : s = ROM := by
  cases s <;> simp [ot_level] at *

-- T12: every non-ROM stage has verifier
theorem ot_single_verifier (y : BootStage) (hy : y ≠ ROM) :
    ∃ x, ot_edges x y ∧ ot_level x + 1 = ot_level y := by
  cases y with
  | ROM => exact absurd rfl hy
  | ROM_EXT => exact ⟨ROM, trivial, rfl⟩
  | BL0 => exact ⟨ROM_EXT, trivial, rfl⟩
  | KERNEL => exact ⟨BL0, trivial, rfl⟩

-- T13: edges imply refinement
theorem ot_edges_refine (x y : BootStage) (he : ot_edges x y) :
    ot_refines x y := by
  cases x <;> cases y <;> simp [ot_edges, ot_refines] at *

-- T14: no backward edges
theorem ot_no_backward (x y : BootStage) (he : ot_edges x y) :
    ¬ ot_edges y x := by
  cases x <;> cases y <;> simp [ot_edges] at *

-- T15: signature failure blocks
theorem ot_signature_failure_blocks (signature_valid hash_valid policy_valid : BootStage → Prop)
    (hfail : ¬ signature_valid ROM_EXT) :
    ¬ ot_invariant signature_valid hash_valid policy_valid ROM_EXT := by
  simp [ot_invariant]
  exact hfail

-- T16: full chain valid
theorem ot_full_chain_valid (signature_valid hash_valid policy_valid : BootStage → Prop)
    (hs : signature_valid ROM_EXT) (hh : hash_valid BL0) (hp : policy_valid KERNEL) :
    ∀ s, ot_invariant signature_valid hash_valid policy_valid s := by
  intro s
  cases s with
  | ROM => exact trivial
  | ROM_EXT => exact hs
  | BL0 => exact hh
  | KERNEL => exact hp

-- ═══════════════════════════════════════════════════════════════════
-- Verification
-- ═══════════════════════════════════════════════════════════════════

#check @layered_implies_lockout
#check @layered_is_valid
#check @layered_acyclic
#check @boot_failure_blocks
#check @verification_implies_invariants
#check @verification_implies_refinement
#check @secure_boot_invariants
#check @failed_stage_isolated
#check @ot_levels_increasing
#check @ot_unique_levels
#check @ot_rom_is_root
#check @ot_single_verifier
#check @ot_edges_refine
#check @ot_no_backward
#check @ot_signature_failure_blocks
#check @ot_full_chain_valid
