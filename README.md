# Proof-Preserving Graphs: Formal Certification, Self-Assessment, and Repair (Lean 4)

This Lean 4 development studies graded certification, blocking and repair. It
contains **191 modules of generic PPG theory**. The LUCES controller motivated the
work; concrete LUCES/nfer models, firmware, binary-memory models and measured
datasets are developed separately.

## Motivation

### The system

I built LUCES, an adaptive-lighting system with four Seeed Studio XIAO ESP32
boards (ESP32-S3 and ESP32-C6). An AS7341 spectral sensor and a TSL2591 lux sensor
feed a local control loop. The embedded network runs under 2 W. Its nodes join,
authenticate and synchronize through a protocol designed in the π-calculus:
a three-way handshake, HMAC challenge and response, synchronized beacons, and
sensor-data and registry messages. A node that loses its connection can rejoin.

The transport-control work uses a **Monge map controller** and McCann displacement
interpolation. The transition study found that the transport map remained stable
across the recorded weather conditions while the cost changed. This motivated
using a precomputed map for the daily transitions, with linear work per
interpolation step. Weather inputs such as cloud cover, humidity and solar
radiation come from Open-Meteo. The transport controller has been developed and
validated in simulation, and the control logic is being migrated to a custom
LUCES board.

Three papers describe the experimental background:

- [Empirical Information Geometry on an Embedded Adaptive Lighting System: Multi-Chart Manifold Transitions Under Signal Collapse](https://zenodo.org/records/20094759) (2026).
- [Excitation-Dependent Observability Geometry on an Embedded Adaptive Lighting Manifold](https://zenodo.org/records/20389804) (2026).
- [Optimal Transport Geometry of Natural Spectral Regime Transitions](https://zenodo.org/records/21956336) (2026).

### The problem

The controller produces logs, and I wanted each run to tell me more than whether
it passed or failed. Which contracts still hold? Which checks prevent stronger
certification? Can the state be repaired while preserving what is already
certified?

A failed check does not answer those questions on its own. It may rule out a
stricter contract while leaving weaker ones satisfied. It may share inputs with
other checks, so changing those inputs can fix one failure and introduce another.
And knowing that a good state exists does not tell us whether the controller can
reach it through the actions it is allowed to take.

The current application checks recorded logs against formal specifications. This
repository gives those checks a common mathematical framework: ordered
certification, blocking dependencies and proof-preserving repair, machine-checked
in Lean 4. The concrete certificates and their information-geometry background
are developed in the companion [PVS project](https://github.com/gajaka/luces-pvs-theories).

### Where this is heading

I want to run the certificate checks on the controller while it operates. As new
measurements arrive, it should report the contracts it currently satisfies and
the checks that block a stricter target. When a check fails, the next step is to
identify the affected variables, choose an allowed state change, and check the
result again.

The contract stays fixed during a repair. The state changes, and the repair must
preserve the properties already certified. That is the distinction I want the
running system to make: correcting its behavior and relaxing its requirements
are different decisions.

The aim is to make this part of the control loop, so the controller uses its own
telemetry to guide recovery. Reaching that point requires a proved connection
between the live measurements, the checker running on the board, and the state
and repair model used here. The Lean library supplies the theory for that work;
the controller implementation and its hardware behavior need their own proofs
and measurements.

## Overview

A certificate is a predicate over data and a specification level. It holds when
the data meets the contract at that level. The library keeps the data and
certificates abstract, so the same results can be used with different systems.

Specification levels are ordered. Passing a stricter contract entails passing
every weaker one; this is the monotonicity assumption on a certificate family.
When a strongest certified level exists, we call it the **canonical level**.
It describes the whole certified region. Existence needs additional hypotheses:
in the complete-lattice construction, the certified set must be nonempty and
closed under infima of nonempty subsets. Monotonicity alone is insufficient.

In the Lean order, smaller levels are stricter. The canonical level is therefore
the least certified element, and the characterization is
`Cert(d, θ) ↔ θ_c ≤ θ`. If no level passes, there is no canonical level in that
specification space.

At a target level, the **blocking set** consists of the certificates that fail.
It is empty exactly when the target is certified. To study repair, we also record
the variables each certificate reads. Shared variables give edges in a dependency
graph; its connected components group checks that may affect one another. Under
predicate locality, changes confined to one component's footprint leave the
other components unchanged. This guarantee applies to the selected certificate
family. Passing checks omitted from that family still need a preservation proof.

The repair layer requires a state change to restore the target while preserving
prior certification. It also separates three claims: a repair path exists, a
chosen random procedure reaches a good state almost surely, and its expected
work is bounded. Each claim needs its own evidence.

The General and lopsided Lovász Local Lemmas give sufficient conditions for a
positive probability of avoiding all bad events. In the product-variable model,
Moser–Tardos resampling constructs a satisfying assignment by redrawing the
variables of violated events. The library proves **E[T_LOG] ≤ Σ x(α)** under the
stated resampling budgets. Here `x` bounds expected resamplings, rather than event
probability; classical LLL parameters `q` give `x = q/(1−q)`. Finite expectation
then implies almost-sure termination. The counting proof does not assume that the
procedure terminates.

Pegden's independent-subset criterion and strict Shearer positivity give stronger
expected-work bounds, including bounds for individual dependency components.
The He–Li–Sun criterion also uses intersections of matched bad events: the
reduced vector `p⁻ = p − δ²/17` may satisfy the criterion when the original vector
does not.
The corresponding expected-work and termination results cover arbitrary
measurable admissible selection schedules, including history-dependent rules and
independent auxiliary randomization. The probability, locality and policy
hypotheses are stated in the Lean files. Failure of a sufficient criterion leaves
repairability unresolved.

Expected work can also be bounded from a potential for the repair process. A
nonnegative integrable adapted potential satisfying the conditional drift
inequality bounds the expected number of active steps. For finite rational
transition models, checked potentials give upper bounds, first-step equations
give exact expectations, and survival recurrences give timeout probabilities.
A uniform bound on survival over a block of steps yields a geometric tail bound.
Lumping and commuting-update projections transfer these results to smaller
models when the transition laws and good-state tests are preserved. These bounds
count model steps or resamplings; an execution-time argument is still needed for
a hardware deadline.

Finite models with decidable tests admit exhaustive reachability decisions.
Potentially infinite models can use the same procedure when supplied with a
proved exact finite abstraction and an executable way to realize its steps.
The result is a concrete repair trace or a checked refutation that no good state
is reachable. Minimal infeasible cores, invariant refutations and rational
Farkas certificates provide further explanations under their model hypotheses.
A closed bad class establishes failure for the specified random kernel and
starting state; another policy may still repair the state. For the encoded
infinite-model family, a reduction to halting proves that no total computable
repairability test can decide every instance.

Moser–Tardos reachability is connected to the abstract repair relation. Given a
good target, a constant resampling table supplies an existential path to it.
This path gives no probability guarantee for a randomly drawn table; the
expected-work and termination theorems establish those guarantees separately.

All proofs are checked in Lean 4, with no `sorry` or additional axioms. The audit
allows any subset of the standard foundational axioms `propext`,
`Classical.choice` and `Quot.sound`, including the empty set.

### Application background (separate development)

The companion application uses five levels, from the strictest `S` through `A`,
`B`, `C` and `D`. It reports the strongest passing level and the checks that block
stronger certification. The individual checks can give different results on the
same log. In the published `boot334` example, structural checks pass while the
spectral-direction check detects a reversal (`cos = −0.74`). A single verdict
would hide that distinction. The
[certificate-runner report](https://github.com/gajaka/luces-pvs-theories/blob/main/CERT_RUNNER_RESULTS.md)
contains the concrete results. Different checks use different aspects of the
measurements; shared data does not make them probabilistically independent.

The library has **1,824 explicitly declared theorems and lemmas**, with an explicit
`#check` for each. The diagram below shows how certification, dependency
analysis, repair, finite decisions and work bounds fit together.

The [module inventory](THEORY_INDEX.md) lists all 191 modules. Run
`python3 tools/audit_ppgraph.py` to rebuild and inspect the axiom dependencies of
every project declaration, including generated theorem constants. Results and
source hashes are recorded in `PPGRAPH_AXIOM_AUDIT.txt` and
`PPGRAPH_AXIOM_AUDIT.json`.

[![PPG theory: certification, blocking, probabilistic repair, drift, finite decisions, work and tail bounds, abstraction and undecidability.](ppg-theory.png)](ppg-theory.png)

## Files

The table lists the original modules. [THEORY_INDEX.md](THEORY_INDEX.md) contains
the full inventory, including the later probabilistic and decision results.

| File | Theorems | Scope |
|------|----------|-------|
| `PPGraph.lean` | 22 | Core PPG framework: validity, walks, paths, evolution, monotonicity, connectivity, separation, deterministic traversal, violation detection, certificate chains |
| `PPGraphCategorical.lean` | 10 | Categorical structure: morphisms, embeddings, quotients, refinement, simulation, composition |
| `PPGraphMeta.lean` | 10 | Meta-PPG: graphs over refinement relations, backward compatibility, upgrade chains, spec versioning |
| `PPGraphRepair.lean` | 8 | Repair semantics: isolation reversal, route bypass, locality, convergence |
| `PPGraphRR.lean` | 9 | Refinement relations: port of NASA pvslib sets_aux@rr_rel (rel_extension, RR, g/f-consistency, PPGConfig bridge) |
| `PPGraphParametric.lean` | 24 | Parametric certification: master refinement, canonical levels, lattice operators, PPG bridge, repair bounds, threshold instance |
| `PPGraphParametricQuotient.lean` | 26 | Quotient structure: cert_equiv, induced PartialOrder, CertInfClosed meet, LinearOrder separating |
| `PPGraphBlocking.lean` | 7 | Blocking certificates: diagnostic layer, canonical has empty blocking, stricter has nonempty |
| `PPGraphQuotientBridge.lean` | 5 | Surjective specification projection: an edge maps to a quotient edge or collapses within a class; certification is well-defined on classes |
| `PPGraphSelection.lean` | 23 | Hierarchical representative selection: pullback equiv, finest equiv, CertFamily instance via OrderDual Finset, pp_quotient bridge |
| `PPGraphComplementarySlackness.lean` | 5 | LP duality for optimal transport: pointwise CS, Monge structure, strict uniqueness, zero duality gap certificate |
| `PPGraphSelfAssessment.lean` | 12 | Failure containment, contamination impossibility, assessment trichotomy, monotone recovery (state-based, spec fixed), three evolution modes |
| `PPGraphAssessmentBridge.lean` | 8 | Bridge: self-assessment ↔ parametric certification. Complete repair cycle: strict growth + blocking cleared + canonical frontier advances |
| `PPGraphProbabilistic.lean` | 6 | Blocking dependency decomposition: dependency graph, LLL feasibility, pair infeasibility (quadratic discriminant), repair classification |
| `PPGraphLLL.lean` | 30 | General Lovász Local Lemma (Alon-Spencer 5.1.1): key inductive bound, denominator telescope, good-event lower bound, positive probability, good state exists |
| `PPGraphMoserTardos.lean` | 3 | Product probability space and resample operator |
| `PPGraphMoserTardosProcess.lean` | 2 | The resample-until-fixed algorithm as a process |
| `PPGraphMoserTardosWitness.lean` | 5 | Dependency graph and witness tree data structure |
| `PPGraphMoserTardosGrowing.lean` | 8 | Address-indexed growing tree, backward construction of the witness tree from a log |
| `PPGraphMoserTardosInjectivity.lean` | 14 | Injectivity of the witness-tree encoding: distinct resampling occurrences give distinct trees |
| `PPGraphMoserTardosWeight.lean` | 3 | Tree weight, the combinatorial quantity used in the convergence bound |
| `PPGraphMoserTardosConvergence.lean` | 2 | Algebraic core of the convergence bound (Alon-Spencer 5.7.3): tree weight bounded by the LLL weights |
| `PPGraphLopsidedLLL.lean` | 6 | Lopsided LLL (Erdős-Spencer / Harris): strict generalization of the General LLL via the lopsidependence inequality |
| `PPGraphVariableLLL.lean` | 29 | Variable-version LLL (He et al., FOCS 2017), Lemma 10: geometric GLLL reformulation, cylinder growth, boundary-point existence |
| `PPGraphBDD.lean` | 13 | Blocking dependency decomposition: components, disjoint footprints, repair non-interference (single and all-components) |
| `PPGraphBDDCost.lean` | 5 | Cost-valued non-interference: the optimal cost over a blocking set splits over disjoint components |
| `PPGraphBDDMatrix.lean` | 3 | Incidence/Gram-matrix view of dependence: dependent iff positive Gram entry |
| `PPGraphBDDLaplacian.lean` | 9 | Laplacian view: component count equals the Laplacian nullspace dimension |
| `PPGraphBDDCount.lean` | 6 | Component count equals the number of safe, independently repairable parallel units |
| `PPGraphBDDMoserTardos.lean` | 2 | Dynamic non-interference: the whole MT process confined to one component never changes another component |
| `PPGraphMoserTardosLogSpace.lean` | 1 | The C[v,t] coin-flip sample space via Measure.infinitePi (Ionescu-Tulcea) |
| `PPGraphMoserTardosRandomTrajectory.lean` | 10 | Measurable random trajectory from the log space; a concrete measurable resample policy |
| `PPGraphMoserTardosPastIndependence.lean` | 2 | The resample decision at time t depends only on log coordinates before t |
| `PPGraphMoserTardosCorrespondence.lean` | 9 | Lemma 2.1(ii): a witness tree from a genuine real trajectory passes its own τ-check |
| `PPGraphMoserTardosCheckOrder.lean` | 14 | Lemma 2.1(i) properness: equal-depth vertices have disjoint footprints |
| `PPGraphMoserTardosCheck.lean` | 1 | localCount and the decreasing-depth deterministic τ-check |
| `PPGraphMoserTardosCheckBirth.lean` | 22 | Birth step/time of tree vertices; injectivity support |
| `PPGraphMoserTardosCheckShape.lean` | 8 | τ-check depends only on the canonical shape |
| `PPGraphMoserTardosCheckInvariance.lean` | 5 | localCount/checkState/τ-check are shape-invariant (address-free counting) |
| `PPGraphMoserTardosProbability.lean` | 15 | Theorem 5.7.2: Pr[τ-check passes] factors as a product over vertices; reusable infinitePi independence lemmas |
| `PPGraphMoserTardosProbabilityGeneral.lean` | 6 | 5.7.2 for any SameDepthIndependent growing tree, not only τ_C |
| `PPGraphMoserTardosWeightSum.lean` | 16 | Σ p[T] over proper trees of depth ≤ D equals the mtWeight recursion |
| `PPGraphMoserTardosRealTree.lean` | 13 | GrowingTree → WTree bridge: real trees embed as well-formed proper WTrees |
| `PPGraphMoserTardosCanonical.lean` | 15 | Canonicalization: real tree is weight-equal to a canonical member of the enumeration |
| `PPGraphMoserTardosWTreeToGrowingTree.lean` | 11 | Direct WTree → GrowingTree embedding; same-depth independence transfers |
| `PPGraphMoserTardosWTreeCountable.lean` | 1 | Countable (WTree ι), by stratification on tree size |
| `PPGraphMoserTardosCheckBridge.lean` | 2 | Address-to-shape τ-check bridge for τ_C-built trees |
| `PPGraphMoserTardosToGrowingTreeCheckBridge.lean` | 6 | Address-to-shape τ-check bridge for toGrowingTree, no τ_C roundtrip |
| `PPGraphMoserTardosLabelsAtDepthBridge.lean` | 5 | Labels-at-depth transfer between tree representations |
| `PPGraphMoserTardosInjectivityBridge.lean` | 7 | Distinct occurrence times give distinct canonical trees; weight preserved through conversion |
| `PPGraphMoserTardosExpectation.lean` | 4 | T_LOG as a countable sum of indicators; E[T_LOG] = Σ Pr[still running] |
| `PPGraphMoserTardosResamplingCount.lean` | 14 | Decompose the stopped log by resampled event: T_LOG = Σ_α N_α; N_α = distinct canonical witnesses |
| `PPGraphMoserTardosRandomInitialization.lean` | 3 | Initial state from log slot 0, with measurability |
| `PPGraphMoserTardosRandomInitExpectation.lean` | 14 | Expectation decomposition for the random-initialization law |
| `PPGraphMoserTardosOccurrence.lean` | 7 | Witness occurrence events and their measurability |
| `PPGraphMoserTardosOccurrenceCounting.lean` | 3 | Count of distinct witnesses, canonical family |
| `PPGraphMoserTardosOccurrenceProbability.lean` | 4 | Pr[witness U occurs] ≤ weight(U) via the 5.7.2 product bound |
| `PPGraphMoserTardosWitnessFamily.lean` | 6 | Canonical enumeration of the witness family rooted at a label |
| `PPGraphMoserTardosOccurrenceExpectation.lean` | 7 | The final bound: E[T_LOG] ≤ Σ x(α); finite budgets give finite expectation |
| `PPGraphMoserTardosConstantLog.lean` | 9 | Reach a good state from any initial state via the constant log |
| `PPGraphMoserTardosTermination.lean` | 7 | E[T_LOG] < ∞ ⟹ almost-sure termination ⟹ a good state exists (measure-one, not Classical.choose) |
| `PPGraphMoserTardosRepairBridge.lean` | 8 | Moser-Tardos reachability instantiates the abstract proof-preserving repair relation |

## Central Theorems

The results below cover the original framework and later developments. Their
summaries omit some type, measurability and locality assumptions; each linked
Lean file gives the full statement. Random-initialization bounds use slot zero of the
resampling table. Fixed-start results specify the initial state separately.
Each theorem name links to its Lean source file.

### Certification, blocking and Moser–Tardos

1. **Master refinement**

    Lean: [master_refinement](PPGraphParametric.lean).

    θ₁ ≤ θ₂ ∧ Cert(d,θ₁) → Cert(d,θ₂)

2. **Canonical characterization**

    Lean: [certified_iff_above_canonical](PPGraphParametric.lean).

    Cert(d,θ) ↔ θ_c ≤ θ (principal upper set)

3. **Certified subgraph validity**

    Lean: [certified_subgraph_pp_valid](PPGraphParametric.lean).

    Certified subgraph is pp_valid

4. **Canonical bound after repair**

    Lean: [repair_raises_canonical](PPGraphParametric.lean).

    After repair, canonical ≤ target

5. **Canonical existence**

    Lean: [canonical_spec_is_canonical](PPGraphParametric.lean).

    In a complete lattice, a nonempty certified set closed under infima of nonempty
    subsets has a canonical level

6. **Lower canonical bound**

    Lean: [no_repair_below_canonical](PPGraphParametric.lean).

    For a fixed datum, no level outside the canonical upper set is certified

7. **Canonical blocking set**

    Lean: [canonical_blocking_empty](PPGraphBlocking.lean).

    At canonical level, blocking set is empty

8. **Separating certificate classes**

    Lean: [separating_equiv_eq](PPGraphParametricQuotient.lean).

    In a linear order with a separating certificate family, cert_equiv implies equality

9. **Hierarchical selection**

    Lean: [lens_master_refinement](PPGraphSelection.lean).

    Master refinement applied to the OrderDual Finset certificate family

10. **Quotient projection**

    Lean: [proj_is_pp_quotient](PPGraphSelection.lean).

    With pp_valid and edges separating classes, the finest-equivalence projection is
    surjective and preserves graph edges

11. **Pointwise complementary slackness**

    Lean: [cs_pointwise](PPGraphComplementarySlackness.lean).

    dual_feasible ∧ P(i,j)>0 ∧ P·slack=0 → u(i)+v(j)=C(i,j)

12. **Strict Monge uniqueness**

    Lean: [monge_cs_strict_unique](PPGraphComplementarySlackness.lean).

    Monge + CS + strict → unique tight entry per row

13. **General Local Lemma existence**

    Lean: [lll_good_state_exists](PPGraphLLL.lean).

    General LLL (Alon-Spencer 5.1.1): a state avoiding all bad events exists

14. **Lopsided generalization**

    Lean: [independence_implies_lopsidependence](PPGraphLopsidedLLL.lean).

    Lopsided LLL subsumes the General LLL (equality ⟹ the ≤ hypothesis)

15. **Component repair non-interference**

    Lean: [repair_noninterference](PPGraphBDD.lean).

    A repair confined to one component cannot change any obligation in another

16. **Localized Moser–Tardos trajectories**

    Lean: [mt_trajectory_localizes](PPGraphBDDMoserTardos.lean).

    The whole MT process in one component never changes another component, at any step

17. **Real-trajectory witness check**

    Lean: [τCheck_holds_of_real_trajectory](PPGraphMoserTardosCorrespondence.lean).

    Lemma 2.1(ii): a genuine real trajectory passes its own witness-tree check

18. **Witness-check probability factorization**

    Lean: [logMeasure_τCheck_eq_prod_p](PPGraphMoserTardosProbability.lean).

    Theorem 5.7.2: Pr[τ-check passes] = ∏ p(label) over the tree vertices

19. **Algebraic Moser–Tardos budget**

    Lean: [sum_mtWeight_le](PPGraphMoserTardosConvergence.lean).

    Σ_α w(D,α) ≤ Σ_α x(α) (algebraic MT budget bound)

20. **Moser–Tardos expected work**

    Lean: [randomInitETLog_le_sum](PPGraphMoserTardosOccurrenceExpectation.lean).

    **E[T_LOG] ≤ Σ_α x(α)**: the Moser-Tardos expected-work bound, no termination assumption

21. **Finite expected resampling work**

    Lean: [randomInitETLog_lt_top](PPGraphMoserTardosOccurrenceExpectation.lean).

    Finite MT budgets ⟹ finite expected work (E[T_LOG] < ∞)

22. **Moser–Tardos repair bridge**

    Lean: [mtRepairGraph_globally_repairable](PPGraphMoserTardosRepairBridge.lean).

    Under the bridge hypotheses, Moser–Tardos reachability satisfies the abstract
    proof-preserving repair relation


### Extended probabilistic repair and drift

23. **Pegden expected-work bound**

    Lean: [Pegden.randomInitETLog_le_sum](PPGraphMoserTardosPegden.lean).

    Pegden's independent-subset budget on each closed neighborhood gives random-initialized
    **E[T_LOG] ≤ Σ x(α)**

24. **Shearer expected-work bound**

    Lean: [Shearer.randomInitETLog_le_sum_stableBudget](PPGraphShearerExpectation.lean).

    Probability upper bounds satisfying strict Shearer positivity give **E[T_LOG] ≤ Σ
    q_{α}/q_∅**

25. **Component-local Shearer budget**

    Lean: [Shearer.randomInitExpectedComponentCount_le_budget](PPGraphShearerBDDExpectation.lean).

    Strict Shearer on one full dependency component bounds its expected resampling count,
    without certifying the other components

26. **He–Li–Sun expected work for admissible policies**

    Lean: [HLS.Policy.randomized_expectedWork_le_sum_stableBudget](PPGraphHLSPolicyExpectation.lean).

    Positive event probabilities, matching-compatible intersection lower bounds and strict
    Shearer at **p⁻ = p − δ²/17** bound expected work by the singleton Shearer budgets, for
    jointly measurable admissible schedules with independent auxiliary randomness

27. **He–Li–Sun slack bound**

    Lean: [HLS.Policy.randomized_expectedWork_le_card_div_slack](PPGraphHLSPolicyExpectation.lean).

    Under the same policy/overlap assumptions, ε > 0 and strict Shearer at **(1+ε)p⁻** give
    **E[T] ≤ card(ι)/ε**

28. **He–Li–Sun almost-sure repair**

    Lean: [HLS.Policy.randomized_ae_exists_good](PPGraphHLSPolicyExpectation.lean).

    Under the HLS policy criterion, a good state is reached almost surely under the
    seed/table product law; termination is a conclusion

29. **Conditional additive drift**

    Lean: [RepairDrift.ConditionalCertificate.expectedActiveCount_le](PPGraphAdditiveDrift.lean).

    A nonnegative integrable adapted potential with conditional decrease δ > 0 on active
    steps and conditional nonincrease on inactive steps gives
    **E[active steps] ≤ E[V₀]/δ**

30. **Full-resampling expected work**

    Lean: [RepairDrift.fullResampling_expected_work_eq](PPGraphMoserTardosFullResampling.lean).

    If every event resamples all variables, random-initialized **E[T_LOG] = b/(1−b)** in
    extended nonnegative reals, with b = Pr[bad]; positive good-state mass gives finite work
    without an LLL test


Here `x` denotes a resampling budget, and `q_{α}/q_∅` denotes the singleton
Shearer coefficient ratio. A component-work bound does not assert scheduling
fairness or eventual repair of that component.

### Exact finite models, stopping bounds and reduction

31. **Exact finite potential synthesis**

    Lean: [FinitePotential.synthesize_iff_accessible](PPGraphFinitePotential.lean).

    For a fixed finite stochastic kernel with absorbing good states, checked potential
    synthesis succeeds **iff every state has a positive-mass path to good**

32. **Fixed-start exact expectation**

    Lean: [FiniteResampling.ETLog_eq_potential](PPGraphFinitePotentialExpectationMT.lean).

    In a valid finite MT model with global positive-mass accessibility, fixed-start
    **E[T_LOG] equals the exact rational potential**

33. **Random-start exact expectation**

    Lean: [FiniteResampling.randomInitETLog_eq_potential_sum](PPGraphFinitePotentialExpectationMT.lean).

    Under the same accessibility hypothesis, slot-zero initialization gives **E[T_LOG] = Σₛ
    productMass(Q,s) · potential(s)**

34. **Exact stopping probability**

    Lean: [FiniteResampling.TLog_timeout_eq_survival](PPGraphFinitePotentialTailMT.lean).

    A valid finite MT model and fixed start give **Pr[T_LOG > N] = survival(N,s₀)**, the
    exact rational recurrence, without a termination premise

35. **Checked timeout bounds**

    Lean: [FiniteResampling.TLog_timeout_checkedTable_blocks_le](PPGraphFinitePotentialTailMT.lean).

    An accepted survival table with every H-step survival value ≤ b and b ≥ 0 gives
    **Pr[T_LOG > kH] ≤ bᵏ**, with geometric decay when b < 1 and H > 0

36. **Closed bad set and infinite expected work**

    Lean: [FiniteResampling.ETLog_checkedClosedBad_eq_top](PPGraphFinitePotentialTailMT.lean).

    An accepted closed-bad-set certificate containing the fixed start gives **E[T_LOG] = ∞**
    for that kernel/policy

37. **Exact stopped-count reduction**

    Lean: [FiniteLumpingUpdate.hitCount_projection](PPGraphFiniteLumpingUpdate.lean).

    Commuting updates and preserved good tests give pointwise equality of concrete/reduced
    stopped counts on the same input stream; concrete state may be infinite


The finite MT results use the declared finite variables and domains, normalized rational
marginals and first-violated-event process. Reduction transfers laws and checked
bounds under its additional mass/model hypotheses. A closed-bad-set certificate
concerns the specified kernel and starting state, rather than every possible
repair policy.

### Feasibility, refutation and decision limits

38. **Finite witness decision**

    Lean: [RepairFeasibility.solve_isWitness_iff](PPGraphCertifiedDecision.lean).

    Decidable tests and an enumeration covering all admissible states give a witness **iff
    the obligations are satisfiable**; the other branch carries a refutation

39. **Repair through exact finite abstraction**

    Lean: [RepairFeasibility.repairByFiniteAbstraction_spec](PPGraphFiniteAbstractionRepair.lean).

    A supplied executable exact finite abstraction gives a concrete repair trace or checked
    invariant refutation; the repaired flag is true **iff a concrete good state is
    reachable**

40. **Minimal infeasible core**

    Lean: [RepairFeasibility.minimalCore_exists](PPGraphUnsatisfiableCore.lean).

    Every finite infeasible obligation family contains a minimal infeasible subfamily

41. **Core/correction duality**

    Lean: [RepairFeasibility.minimalCore_iff_minimalCorrectionHittingSet](PPGraphCorrectionDuality.lean).

    For K ⊆ B, K is a minimal infeasible core **iff it is an inclusion-minimal hitting set of
    B's minimal correction sets**

42. **Farkas reachability refutation**

    Lean: [RepairFeasibility.farkasCheck_noReachableGood](PPGraphFarkasCertificate.lean).

    An accepted rational Farkas certificate and a sound linear model for good states imply
    **no reachable good state exists**

43. **Limit of uniform repairability decisions**

    Lean: [RepairFeasibility.ComputabilityLimit.no_total_repairability_decider](PPGraphRepairUndecidability.lean).

    **No computable total repairability test** exists uniformly for the halting-encoding
    infinite graph family, despite decidable state tests


Exact abstraction requires its proved local realization obligations and an
exhaustive abstract enumeration. Correction sets remove obligations from the
chosen family. Failure of a sufficient probabilistic criterion alone remains
distinct from an impossibility certificate.


## Theory Layers

These groups describe what each part of the library does. The
[module inventory](THEORY_INDEX.md) lists the individual files.

### Certification, structure and assessment

1. **Certification and canonical levels**: Ordered certificate families,
   monotonicity, and the principal-upper-set characterization under the declared
   canonicality and closure hypotheses.

2. **Graph and refinement structure**: Proof-preserving graphs, morphisms,
   embeddings, quotients, simulations, refinement relations, and specification
   evolution.

3. **Specification composition and selection**: Lattice operations, certification
   quotients, separating families, hierarchical lenses, and threshold instances.

4. **Assessment and repair**: Failure containment, blocking diagnostics, repair
   versus relaxation, and the cycle from blocking through repair to canonical
   frontier advancement under the repair obligations.

5. **Optimal-transport certificates**: Complementary slackness, zero-duality-gap
   certificates, Monge structure, and strict uniqueness under the declared
   feasibility and strictness assumptions.

### Dependency and probabilistic repair

6. **Dependency decomposition**: Shared-variable components, disjoint footprints,
   repair non-interference, cost decomposition, matrix/Laplacian
   characterizations, and localization of resampling trajectories.

7. **Local Lemma existence criteria**: General and lopsided LLL, plus the
   geometric boundary lemma (Lemma 10) from the variable-version development.

8. **Moser–Tardos execution and witnesses**: Measurable table-driven trajectories,
   witness checks, injective encodings, occurrence counting, expected resampling
   bounds, and almost-sure termination under the stated budget hypotheses.

9. **Repair reachability bridge**: A good target supplies an existential
   Moser–Tardos repair path through a constant table; resampling reachability
   instantiates the abstract repair relation. Probabilistic termination is a
   separate result with its own hypotheses.

10. **Shearer and Pegden bounds**: Strict Shearer positivity, stable-sequence
    budgets and slack bounds; Pegden's independent-subset witness-tree criterion.

11. **Component expected work**: Exact decomposition of resampling counts and
    component-local Shearer budgets. The expected count for one component can be
    bounded without certifying the others. This bound alone does not guarantee
    that the schedule eventually serves or repairs that component.

12. **Intersection-sensitive policies**: He–Li–Sun overlap discounts,
    witness-DAG bounds, expected work, and almost-sure termination for measurable
    admissible schedules, including history-dependent rules and independent
    auxiliary randomization, under the stated probability/intersection hypotheses.

13. **Drift and full resampling**: Conditional additive-drift certificates for
    expected steps and modeled costs; exact geometric tails and expectation when
    every event resamples all variables. Positive good-state mass gives finite
    expected work in the full-resampling case without an LLL test.

### Exact stochastic models and stopping bounds

14. **Finite stochastic models and potentials**: Rational transition kernels,
    finite Moser–Tardos laws, checked drift witnesses, exact potential synthesis,
    and expected hitting-time identities under their kernel hypotheses.

15. **Stopping tails and closed bad classes**: Exact finite survival recurrences,
    checked geometric block bounds, and kernel-specific certificates of infinite
    expected work. These are stochastic model results, not hardware deadlines.

16. **Exact stochastic reduction**: Lumping and commuting-update projections
    preserve stopped counts, expectations, and tails under their model hypotheses;
    the update-level concrete state space need not be finite.

### Feasibility, refutation and decision limits

17. **Feasibility and refutation**: Positive witnesses, infeasibility
    certificates, minimal cores, correction-set duality, rational Farkas
    certificates, invariant reachability refutations, and finite decision
    procedures. Correction sets relax obligations; repair changes the state.

18. **Constructive finite abstraction**: A supplied exact finite abstraction
    with exhaustive enumeration and proved executable realization produces a
    concrete repair trace or a checked reachability refutation. The abstraction
    itself is not automatically discovered.

19. **Limits of general decision procedures**: Undecidability of uniform
    repairability testing for the halting-encoding infinite-model family. A
    particular infinite instance may still admit a repair witness or a refutation;
    the theorem rules out a uniform total decision procedure.

## Related

- [**luces-pvs-theories**](https://github.com/gajaka/luces-pvs-theories): the companion
  PVS development, with 460 machine-checked results (340 theorems and 120 lemmas)
  in 52 theories. It covers the PPG core, General LLL and base Moser–Tardos
  infrastructure. The later expected-work, BDD, lopsided/variable-LLL and repair
  results described here have not yet been ported to PVS.

## Probabilistic Repair: references and scope

The references below are the mathematical sources for the repair, work-bound
and decision results. Each linked Lean file states the assumptions and the part
of the source result that it formalizes.

### Local Lemmas and Moser–Tardos

- **General LLL and resampling**: Alon and Spencer, *The Probabilistic Method*,
  4th ed., Wiley 2016, Lemma 5.1.1 and §5.7; Moser and Tardos,
  [*A constructive proof of the general Lovász Local Lemma*](https://arxiv.org/abs/0903.0544v3).
  [PPGraphLLL.lean](PPGraphLLL.lean) proves the General LLL using unconditional
  measures, avoiding division by conditioning probabilities.
  The Moser–Tardos files cover the product resampling table, measurable
  trajectories, witness trees, injectivity, check probabilities and occurrence
  counting. [PPGraphMoserTardosOccurrenceExpectation.lean](PPGraphMoserTardosOccurrenceExpectation.lean)
  proves E[T_LOG] ≤ Σ x(α) in the library's resampling-budget parametrization;
  [PPGraphMoserTardosTermination.lean](PPGraphMoserTardosTermination.lean)
  derives almost-sure termination from finite expectation.

- **Lopsided LLL**: The Erdős–Spencer criterion, as recalled by Harris in
  [*Lopsidependency in the Moser-Tardos framework: Beyond the Lopsided Lovász Local Lemma*](https://arxiv.org/abs/1610.02420v4),
  §1.2. [PPGraphLopsidedLLL.lean](PPGraphLopsidedLLL.lean) weakens independence
  to the stated lopsidependence inequality. Harris's stronger orderability
  criterion is outside this formalization.

- **Variable-version geometry**: He, Li, Liu, Wang and Xia,
  [*Variable Version Lovász Local Lemma: Beyond Shearer's Bound*](https://arxiv.org/abs/1709.05143v1),
  §3, Lemma 10. [PPGraphVariableLLL.lean](PPGraphVariableLLL.lean) formalizes
  the geometric boundary lemma and the cylinder-growth argument it needs;
  it does not claim the paper's full necessary-and-sufficient characterization.

### Stronger probabilistic bounds

- **Pegden**: [*An extension of the Moser-Tardos algorithmic local lemma*](https://arxiv.org/abs/1102.2853v2),
  Theorem 1.4. [PPGraphMoserTardosPegden.lean](PPGraphMoserTardosPegden.lean)
  replaces the original product budget by a sum over independent subsets of
  each closed neighborhood. With product-table initialization, the process
  satisfies E[T_LOG] ≤ Σ x(α) under this criterion, without assuming termination.

- **Shearer**: Harvey and Vondrák,
  [*Short proofs for generalizations of the Lovász Local Lemma: Shearer's condition and cluster expansion*](https://arxiv.org/abs/1711.06797v1),
  §2. The existence and probability lower-bound proofs in
  [PPGraphShearer.lean](PPGraphShearer.lean) follow this presentation, using
  strict positivity.
  The expected-work result is the Kolipaka–Szegedy bound, presented in
  [Vondrák's 2018 Lecture 8](https://theory.stanford.edu/~jvondrak/MATH233A-2018/Math233-lec08.pdf),
  Lemma 8.1 and Theorem 8.8. Stable-family identities also follow Harvey and
  Vondrák's [resampling-oracles paper](https://arxiv.org/abs/1504.02044v3), §5.
  [PPGraphShearerExpectation.lean](PPGraphShearerExpectation.lean) proves
  E[T_LOG] ≤ Σ q_{α}/q_∅, with further bounds using slack and
  [individual component budgets](PPGraphShearerBDDExpectation.lean). Bounding
  a component's resampling count does not guarantee that the schedule eventually
  serves or repairs it.

- **He–Li–Sun**: [*Moser-Tardos Algorithm: Beyond Shearer's Bound*](https://arxiv.org/abs/2111.06527v1),
  Theorem 1.6 and §3.3. Here p is the vector of actual positive event
  probabilities. Lower bounds δ on intersections along a matching give
  p⁻ = p − δ²/17. Strict Shearer at p⁻ yields finite expected work; at
  (1+ε)p⁻, with ε > 0, the bound is m/ε for m bad events.
  [PPGraphHLSPolicyExpectation.lean](PPGraphHLSPolicyExpectation.lean) covers
  arbitrary measurable admissible schedules, including history-dependent rules
  and independent auxiliary randomization, under the stated probability,
  intersection and measurability hypotheses. Initialization uses slot zero of
  the product table. The expected-work bound implies almost-sure termination.

### Potentials, stopping bounds and model reduction

- **Additive drift**: Lengler, [*Drift Analysis*](https://arxiv.org/abs/1712.00964v2),
  Theorem 1, provides the background for
  [PPGraphAdditiveDrift.lean](PPGraphAdditiveDrift.lean). The formalization uses
  a nonnegative integrable adapted potential whose conditional expectation
  decreases by at least δ > 0 on active steps and does not increase on inactive
  steps, giving E[active steps] ≤ E[V₀]/δ. Its
  [Moser–Tardos instance](PPGraphMoserTardosDrift.lean) uses the existing
  first-violated-event policy. Modeled costs are bounded separately; when every
  event resamples all variables, [full resampling](PPGraphMoserTardosFullResampling.lean)
  gives exact geometric tails and the product-table random-initialization mean
  E[T_LOG] = b/(1−b) in extended nonnegative reals, where b is the initial
  bad-state probability.

- **Finite rational models**: Mitzenmacher and Upfal,
  [*Probability and Computing*, 2nd ed.](https://doi.org/10.1017/9781316651124),
  §7.1.1 and Exercise 7.25; Levin and Peres,
  [*Markov Chains and Mixing Times*, 2nd ed.](https://pages.uoregon.edu/dlevin/MARKOV/mcmt2e.pdf),
  Exercise 10.22 and the uniform-block argument in the proof of Lemma 1.13.
  [PPGraphFinitePotential.lean](PPGraphFinitePotential.lean) synthesizes checked
  rational potentials through first-step hitting-time equations. The
  [MT expectation bridge](PPGraphFinitePotentialExpectationMT.lean) gives exact
  fixed-start and random-start means; the [tail bridge](PPGraphFinitePotentialTailMT.lean)
  gives exact survival probabilities, checked geometric block bounds and
  closed-bad-set certificates for the specified kernel and start.

- **Exact reduction**: Levin and Peres, §2.3.1, Lemma 2.5 and equation (2.10).
  [PPGraphFiniteLumping.lean](PPGraphFiniteLumping.lean) uses the local
  transition-fiber mass identity and preservation of the good-state test.
  [PPGraphFiniteLumpingUpdate.lean](PPGraphFiniteLumpingUpdate.lean) derives
  reduction from commuting updates and a shared input law, allowing an infinite
  concrete state space. A reachability abstraction alone does not justify
  transferring expectations or tails.

### Reachability, refutation and decision limits

The [finite decision](PPGraphCertifiedDecision.lean) and
[exact-abstraction repair](PPGraphFiniteAbstractionRepair.lean) layers return
positive witnesses or checked refutations under their declared enumeration,
forward simulation, executable step realization and good-state equivalence
obligations. These procedures use exhaustive finite search. Constructing an
exact abstraction is a separate task. [Minimal cores](PPGraphUnsatisfiableCore.lean) and
[correction-set duality](PPGraphCorrectionDuality.lean) describe infeasible
obligation families, while [invariant refutations](PPGraphReachabilityRefutation.lean)
exclude good states along the declared repair relation.

For linear models, [PPGraphFarkasCertificate.lean](PPGraphFarkasCertificate.lean)
proves soundness of accepted rational infeasibility certificates, following the
certificate direction of Dlask and Werner,
[*Bounding Linear Programs by Constraint Propagation: Application to Max-SAT*](https://cmp.felk.cvut.cz/~dlaskto2/papers/Dlask-Werner-CP2020a.pdf),
§2.1, Theorem 1. The theorem checks a supplied certificate; it does not construct
one for every infeasible model. The infinite-model decision limit reuses the
computability apparatus described by Carneiro in
[*Formalizing computability theory via partial recursive functions*](https://arxiv.org/abs/1810.08380v3),
§§5.2–5.3. [PPGraphRepairUndecidability.lean](PPGraphRepairUndecidability.lean)
constructs the repair-family reduction to the halting problem.

[PPGraphMoserTardosRepairBridge.lean](PPGraphMoserTardosRepairBridge.lean)
connects resampling reachability to abstract repair. A good target gives an
existence witness; almost-sure termination and expected work require the
probability-law hypotheses of their respective theorems. Refuting a repair
requires evidence about the allowed model, beyond failure of a sufficient test.
To apply work bounds on hardware, the model steps must also be linked to native
execution and its timing.

## Future work

The next application step is to connect the formal model to certification on the
running controller. Live measurements must have a defined meaning in that model,
and the board's checker must evaluate the corresponding predicates correctly.
The allowed control actions then need repair semantics: which part of the state
they can change, which contracts they restore, and which already-certified
properties they preserve. Measurements of execution time and physical response
are needed alongside those proofs.

The intended loop is to observe the state, check the target,
identify the blockers, apply a justified repair, and check again. When the
available evidence does not justify a repair, the controller should report that
limit. Relaxing a requirement must remain an explicit decision, rather than an
unreported change to the contract during recovery.

The mathematical work also leaves practical search problems. The finite decision
procedures are complete for their declared models, but they use exhaustive
search. An exact finite abstraction can reduce a larger model to a finite search,
provided its simulation, realization and good-state obligations are proved.
Finding such abstractions, repair witnesses and checked potentials efficiently
is an open direction.

The Local Lemma criteria provide sufficient conditions for a good state to
exist; the resampling theorems give work and termination guarantees under their
additional model hypotheses. More instances may be repairable even when none of
those tests applies. Further work could identify classes for which repair
witnesses or process certificates can be found and checked efficiently, and
bound the work of the procedures used there. A path to a good state establishes
reachability; a time bound still needs a proof about the chosen process.

The undecidability result rules out a total computable repairability test for the
encoded infinite-model family. For concrete infinite systems, open work includes
constructing repair witnesses or refutations and identifying classes with
computable decisions and work bounds.

## Author

Dragan Stosic, MSc

## License

© 2026 Dragan Stosic. All rights reserved.

This work (theories, proofs, and source) is made available for reading, academic study, and non-commercial research use, with attribution. Redistribution, modification, derivative works, or any commercial use require prior written permission. If you are interested in using this work, including in a commercial or product setting, please get in touch: dragan.stosic@gmail.com
