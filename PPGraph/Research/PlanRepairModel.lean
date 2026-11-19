module

public import Std

@[expose] public section

/-! A typed, parametric research-plan transition system. A problem includes its
domain, goal and assumptions. A proposed helper is not an accepted result.
The same source is checked in Thinker and PPGraph; it has no project imports. -/
namespace PlanRepair

set_option autoImplicit false

variable {P V W C : Type}

structure Semantics (P V W C : Type) where
  valid : P → V → Prop
  witnesses : P → V → W → Prop
  certificate : P → C → Prop
  refutes : ∀ p v w, witnesses p v w → ¬ valid p v
  extendsView : P → V → V → Prop

inductive Event (V W : Type) where
  | verified (view : V)
  | refuted (view : V) (witness : W)
  | proposed (parent : V) (children : List V)
  | unresolved (view : V)

structure State (P V W C : Type) where
  problem : P
  core : List C
  questions : List V
  accepted : List V
  rejected : List V
  obstructions : List (V × W)
  history : List (Event V W)
  revision : Nat

def Sound (m : Semantics P V W C) (s : State P V W C) : Prop :=
  (∀ c ∈ s.core, m.certificate s.problem c) ∧
  (∀ v ∈ s.accepted, m.valid s.problem v) ∧
  (∀ v ∈ s.rejected, ¬ m.valid s.problem v) ∧
  (∀ vw ∈ s.obstructions, m.witnesses s.problem vw.1 vw.2)

def record (s : State P V W C) (e : Event V W) : State P V W C :=
  { s with history := e :: s.history, revision := s.revision + 1 }

def verify (s : State P V W C) (v : V) : State P V W C :=
  record { s with accepted := v :: s.accepted } (.verified v)

def refute (s : State P V W C) (v : V) (w : W) : State P V W C :=
  record { s with rejected := v :: s.rejected, obstructions := (v, w) :: s.obstructions } (.refuted v w)

def propose (s : State P V W C) (parent : V) (children : List V) : State P V W C :=
  record { s with questions := children ++ s.questions } (.proposed parent children)

def unresolved (s : State P V W C) (v : V) : State P V W C :=
  record s (.unresolved v)

/-- Admission requires semantic evidence. Concrete executable checkers discharge
these premises in the Thinker instance; a timeout cannot discharge them. -/
inductive Step (m : Semantics P V W C) : State P V W C → State P V W C → Prop where
  | verified (s : State P V W C) (v : V)
      (known : v ∈ s.questions) (checked : m.valid s.problem v) :
      Step m s (verify s v)
  | refuted (s : State P V W C) (v : V) (w : W)
      (known : v ∈ s.questions) (checked : m.witnesses s.problem v w) :
      Step m s (refute s v w)
  | proposed (s : State P V W C) (v : V) (children : List V)
      (failed : v ∈ s.rejected) (extensions : ∀ c ∈ children, m.extendsView s.problem v c) :
      Step m s (propose s v children)
  | unresolved (s : State P V W C) (v : V) (known : v ∈ s.questions) :
      Step m s (unresolved s v)

/-- Equivalence of the fixed research contract, not equality of proof status. -/
def SameContext (s t : State P V W C) : Prop :=
  s.problem = t.problem ∧ s.core = t.core

theorem sameContext_equivalence : Equivalence (SameContext (P := P) (V := V) (W := W) (C := C)) :=
  ⟨fun _ => ⟨rfl, rfl⟩, fun h => ⟨h.1.symm, h.2.symm⟩,
    fun a b => ⟨a.1.trans b.1, a.2.trans b.2⟩⟩

theorem step_context {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : SameContext s t := by
  cases h <;> exact ⟨rfl, rfl⟩

theorem step_revision {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : t.revision = s.revision + 1 := by cases h <;> rfl

theorem step_distinct {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : s ≠ t := by
  intro equal
  have inc := step_revision h
  rw [equal] at inc
  omega

theorem step_history_tail {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : t.history.tail = s.history := by cases h <;> rfl

theorem step_history {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : ∃ e, t.history = e :: s.history := by
  cases h <;> exact ⟨_, rfl⟩

theorem step_not_reverse {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : ¬ Step m t s := by
  intro reverse
  have a := step_revision h
  have b := step_revision reverse
  omega

theorem step_preserves_accepted {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : ∀ v ∈ s.accepted, v ∈ t.accepted := by
  cases h <;> intro v hv <;> simp only [verify, refute, propose, unresolved, record]
  · exact List.mem_cons_of_mem _ hv
  all_goals exact hv

theorem step_preserves_obstructions {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) : ∀ vw ∈ s.obstructions, vw ∈ t.obstructions := by
  cases h <;> intro vw hv <;> simp only [verify, refute, propose, unresolved, record]
  · exact hv
  · exact List.mem_cons_of_mem _ hv
  all_goals exact hv

theorem step_sound {m : Semantics P V W C} {s t : State P V W C}
    (h : Step m s t) (hs : Sound m s) : Sound m t := by
  rcases hs with ⟨core, good, bad, witnesses⟩
  cases h with
  | verified v _ checked =>
      refine ⟨core, ?_, bad, witnesses⟩
      intro a ha
      rcases List.mem_cons.mp ha with eq | old
      · simpa [eq, verify, refute, record] using checked
      · exact good a old
  | refuted v w _ checked =>
      refine ⟨core, good, ?_, ?_⟩
      · intro a ha
        rcases List.mem_cons.mp ha with eq | old
        · simpa [eq, verify, refute, record] using m.refutes s.problem v w checked
        · exact bad a old
      · intro vw hw
        rcases List.mem_cons.mp hw with eq | old
        · simpa [eq, verify, refute, record] using checked
        · exact witnesses vw old
  | proposed => exact ⟨core, good, bad, witnesses⟩
  | unresolved => exact ⟨core, good, bad, witnesses⟩

theorem accepted_not_refuted {m : Semantics P V W C} {s : State P V W C}
    (hs : Sound m s) {v : V} (accepted : v ∈ s.accepted) : v ∉ s.rejected :=
  fun rejected => hs.2.2.1 v rejected (hs.2.1 v accepted)

theorem proposal_does_not_certify (s : State P V W C) (parent : V) (children : List V) :
    (propose s parent children).accepted = s.accepted ∧
    (propose s parent children).rejected = s.rejected := ⟨rfl, rfl⟩

theorem proposal_opens_question (s : State P V W C) (parent : V) (children : List V)
    {v : V} (new : v ∈ children) : v ∈ (propose s parent children).questions :=
  List.mem_append_left _ new

theorem unresolved_does_not_refute (s : State P V W C) (v : V) :
    (unresolved s v).accepted = s.accepted ∧
    (unresolved s v).rejected = s.rejected ∧
    (unresolved s v).obstructions = s.obstructions := ⟨rfl, rfl, rfl⟩

inductive Steps (m : Semantics P V W C) : State P V W C → State P V W C → Prop where
  | refl (s) : Steps m s s
  | cons {s t u} : Step m s t → Steps m t u → Steps m s u

theorem steps_sound {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) (hs : Sound m s) : Sound m t := by
  induction h with
  | refl => exact hs
  | cons step _ ih => exact ih (step_sound step hs)

theorem steps_context {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) : SameContext s t := by
  induction h with
  | refl => exact ⟨rfl, rfl⟩
  | cons step _ ih => exact sameContext_equivalence.trans (step_context step) ih

theorem steps_preserve_accepted {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) : ∀ v ∈ s.accepted, v ∈ t.accepted := by
  induction h with
  | refl => exact fun _ hv => hv
  | cons step _ ih => exact fun v hv => ih v (step_preserves_accepted step v hv)

theorem steps_preserve_obstructions {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) : ∀ vw ∈ s.obstructions, vw ∈ t.obstructions := by
  induction h with
  | refl => exact fun _ hw => hw
  | cons step _ ih => exact fun vw hw => ih vw (step_preserves_obstructions step vw hw)

theorem steps_retain_justification {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) (hs : Sound m s) {v : V} (old : v ∈ s.accepted) :
    v ∈ t.accepted ∧ m.valid t.problem v :=
  ⟨steps_preserve_accepted h v old, (steps_sound h hs).2.1 v (steps_preserve_accepted h v old)⟩

theorem steps_retain_history {m : Semantics P V W C} {s t : State P V W C}
    (h : Steps m s t) : ∃ newEvents, t.history = newEvents ++ s.history := by
  induction h with
  | refl => exact ⟨[], rfl⟩
  | cons step _ ih =>
      obtain ⟨e, he⟩ := step_history step
      obtain ⟨newEvents, hp⟩ := ih
      refine ⟨newEvents ++ [e], ?_⟩
      rw [hp, he, List.append_assoc]
      rfl

#check @sameContext_equivalence
#check @step_context
#check @step_revision
#check @step_distinct
#check @step_history_tail
#check @step_history
#check @step_not_reverse
#check @step_preserves_accepted
#check @step_preserves_obstructions
#check @step_sound
#check @accepted_not_refuted
#check @proposal_does_not_certify
#check @proposal_opens_question
#check @unresolved_does_not_refute
#check @steps_sound
#check @steps_context
#check @steps_preserve_accepted
#check @steps_preserve_obstructions
#check @steps_retain_justification
#check @steps_retain_history

end PlanRepair
