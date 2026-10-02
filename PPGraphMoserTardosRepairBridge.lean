/-
  PPGraphMoserTardosRepairBridge.lean

  Moser-Tardos as an instance of the abstract PPG repair relation.

  Finite expected running time for random initialization supplies a
  good state. A separate constant-log descent argument then supplies
  an existential path to a good state from every initial state.

  The graph's edges remain a parameter; MT supplies reachability and
  the invariant "no bad event holds". Certificate interpretation,
  route-bypass edges, and preservation of a separate certified core
  require their own model-specific hypotheses.

  The existing repair_target still uses Classical.choose. The new
  result supplies its existence premise and an MT reachability witness;
  it does not turn the chosen target into an executable solver.
-/

import PPGraphRepair
import PPGraphMoserTardosConstantLog

open MeasureTheory Classical
open scoped NNReal ENNReal

variable {V : Type} [DecidableEq V] {S : VarSpaces V} {ι : Type}
    [Fintype ι] [DecidableEq ι] [Nonempty ι]

/-- Existential MT reachability. The log is arbitrary; this relation
    does not require its realization to have positive probability. -/
def mtReach (P : MTProcess S ι) (v w : MTState S) : Prop :=
  ∃ (ω : LogSpace S) (T : ℕ), randTraj P v ω T = w

/-- The abstract repair graph instantiated with MT reachability and
    the invariant that every bad event is absent. -/
def mtRepairGraph (P : MTProcess S ι)
    (edges : MTState S → MTState S → Prop) : RepairGraph (MTState S) where
  edges := edges
  reach_rel := mtReach P
  invariant_holds := MTGood P

theorem mtReach_refl (P : MTProcess S ι) (v : MTState S) : mtReach P v v := by
  exact ⟨constantLog v, 0, rfl⟩

/-- One good target suffices for existential reachability from every
    initial state when the variable set is finite. -/
theorem exists_mtReach_good_of_good_target [Fintype V]
    (P : MTProcess S ι) (z : MTState S) (hz : MTGood P z) (v : MTState S) :
    ∃ w : MTState S, mtReach P v w ∧ MTGood P w := by
  obtain ⟨T, _, hgood⟩ := exists_good_randTraj_constantLog P z hz v
  exact ⟨randTraj P v (constantLog z) T, ⟨constantLog z, T, rfl⟩, hgood⟩

/-- An isolated state has a distinct reachable good replacement.
    Distinctness follows from the failed and restored invariants. -/
theorem mtRepairGraph_repair_possible_of_good_target [Fintype V]
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (z : MTState S) (hz : MTGood P z) (v : MTState S)
    (hiso : isolated (mtRepairGraph P edges) v) :
    repair_possible (mtRepairGraph P edges) v := by
  obtain ⟨w, hreach, hgood⟩ := exists_mtReach_good_of_good_target P z hz v
  refine ⟨hiso, w, ?_, hreach, hgood⟩
  intro heq
  apply hiso
  change MTGood P v
  simpa only [heq] using hgood

theorem mtRepairGraph_globally_repairable_of_good_target [Fintype V]
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (z : MTState S) (hz : MTGood P z) :
    globally_repairable (mtRepairGraph P edges) := by
  intro v hiso
  exact mtRepairGraph_repair_possible_of_good_target P edges z hz v hiso

/-- The expectation result is used for random initialization only.
    The transition to arbitrary starts is the constant-log theorem. -/
theorem mtRepairGraph_globally_repairable_of_randomInitETLog_lt_top [Fintype V]
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (hbad : ∀ i, MeasurableSet (P.bad i))
    (hfinite : randomInitETLog P < ⊤) :
    globally_repairable (mtRepairGraph P edges) := by
  obtain ⟨z, hz⟩ := exists_MTGood_of_randomInitETLog_lt_top P hbad hfinite
  exact mtRepairGraph_globally_repairable_of_good_target P edges z hz

/-- The MT probability and budget hypotheses imply global abstract
    repairability for this concrete reachability/invariant pair. -/
theorem mtRepairGraph_globally_repairable [Fintype V]
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (hbad : ∀ i, MeasurableSet (P.bad i)) (p x : ι → ℝ≥0)
    (hp : ∀ i, Measure.pi (fun u => S.measure u) (P.bad i) ≤ (p i : ℝ≥0∞))
    (h_dom : ∀ α, p α ≤ x α)
    (h_self : ∀ α, p α * ∏ β ∈ plusNeighbors P α, (1 + x β) ≤ x α) :
    globally_repairable (mtRepairGraph P edges) := by
  exact mtRepairGraph_globally_repairable_of_randomInitETLog_lt_top P edges hbad
    (randomInitETLog_lt_top P hbad p x hp h_dom h_self)

theorem mtRepairGraph_repair_possible [Fintype V]
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (hbad : ∀ i, MeasurableSet (P.bad i)) (p x : ι → ℝ≥0)
    (hp : ∀ i, Measure.pi (fun u => S.measure u) (P.bad i) ≤ (p i : ℝ≥0∞))
    (h_dom : ∀ α, p α ≤ x α)
    (h_self : ∀ α, p α * ∏ β ∈ plusNeighbors P α, (1 + x β) ≤ x α)
    (v : MTState S) (hiso : isolated (mtRepairGraph P edges) v) :
    repair_possible (mtRepairGraph P edges) v := by
  exact mtRepairGraph_globally_repairable P edges hbad p x hp h_dom h_self v hiso

/-- The existing abstractly chosen repair target comes with a genuine
    MT log/time witness, a restored invariant, and distinctness. -/
theorem mtRepairGraph_repair_target_spec
    (P : MTProcess S ι) (edges : MTState S → MTState S → Prop)
    (v : MTState S) (h : repair_possible (mtRepairGraph P edges) v) :
    ∃ (ω : LogSpace S) (T : ℕ),
      randTraj P v ω T = repair_target (mtRepairGraph P edges) v h ∧
      MTGood P (repair_target (mtRepairGraph P edges) v h) ∧
      repair_target (mtRepairGraph P edges) v h ≠ v := by
  have hvalid := repair_target_valid (mtRepairGraph P edges) v h
  rcases hvalid with ⟨hne, hreach, hgood⟩
  rcases hreach with ⟨ω, T, hT⟩
  exact ⟨ω, T, hT, hgood, hne⟩

-- -------------------------------------------------------------------
-- Verification
-- -------------------------------------------------------------------

#check @mtReach
#check @mtRepairGraph
#check @mtReach_refl
#check @exists_mtReach_good_of_good_target
#check @mtRepairGraph_repair_possible_of_good_target
#check @mtRepairGraph_globally_repairable_of_good_target
#check @mtRepairGraph_globally_repairable_of_randomInitETLog_lt_top
#check @mtRepairGraph_globally_repairable
#check @mtRepairGraph_repair_possible
#check @mtRepairGraph_repair_target_spec
