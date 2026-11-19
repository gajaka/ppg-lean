module

public import PPGraph.Research.PlanRepairModel
public import PPGraph.Core.RR

@[expose] public section

/-! Research plans as a PPG instance. Vertices are justified research states,
not individual conjectures. RR preserves the problem and protected contract;
directed edges additionally require an admitted evidence-bearing transition. -/
namespace PlanRepair.PPG

variable {P V W C : Type}

def configuration (m : Semantics P V W C) : PPGConfig (State P V W C) where
  le_eq := SameContext
  is_equiv := sameContext_equivalence
  f_abs := id
  g_con := id
  invariant := Sound m

theorem rr_iff_same_context (m : Semantics P V W C) (s t : State P V W C) :
    (configuration m).rr_rel s t ↔ SameContext s t := by
  constructor
  · intro h
    change (SameContext s t ∧ SameContext s t) ∨
      (SameContext t s ∧ SameContext s s) ∨
      (SameContext t t ∧ SameContext s t) at h
    rcases h with a | b | c
    · exact a.1
    · exact sameContext_equivalence.symm b.1
    · exact c.2
  · intro h
    exact rr_rel_id SameContext (fun _ => ⟨rfl, rfl⟩) s t h

theorem configured_rr_is_equivalence (m : Semantics P V W C) :
    Equivalence (configuration m).rr_rel := by
  constructor
  · intro s; exact (rr_iff_same_context m s s).mpr ⟨rfl, rfl⟩
  · intro s t h
    exact (rr_iff_same_context m t s).mpr
      (sameContext_equivalence.symm ((rr_iff_same_context m s t).mp h))
  · intro s t u a b
    exact (rr_iff_same_context m s u).mpr
      (sameContext_equivalence.trans ((rr_iff_same_context m s t).mp a)
        ((rr_iff_same_context m t u).mp b))

def graph (m : Semantics P V W C) : Graph (State P V W C) where
  vertices := Sound m
  edges s t := Sound m s ∧ Step m s t
  edges_in_vertices _ _ h := ⟨h.1, step_sound h.2 h.1⟩

theorem admitted_step_is_pp_edge (m : Semantics P V W C) {s t : State P V W C}
    (hs : Sound m s) (h : Step m s t) :
    (configuration m).pp_edge_concrete s t :=
  ⟨step_distinct h, hs, step_sound h hs,
    (rr_iff_same_context m s t).mpr (step_context h)⟩

theorem research_graph_is_pp_valid (m : Semantics P V W C) :
    (configuration m).valid (graph m) := by
  apply PPGConfig.graph_valid_of_concrete_edges
  intro s t h
  exact admitted_step_is_pp_edge m h.1 h.2

theorem research_path_preserves_invariant (m : Semantics P V W C)
    {s t : State P V W C} (hs : Sound m s) (path : Steps m s t) :
    Sound m t ∧ (configuration m).rr_rel s t :=
  ⟨steps_sound path hs, (rr_iff_same_context m s t).mpr (steps_context path)⟩

#check @rr_iff_same_context
#check @configured_rr_is_equivalence
#check @admitted_step_is_pp_edge
#check @research_graph_is_pp_valid
#check @research_path_preserves_invariant

end PlanRepair.PPG
