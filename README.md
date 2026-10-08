# Proof-Preserving Graphs: Formal Certification, Self-Assessment, and Repair (Lean 4)

This public development contains **191 modules of generic PPG theory**. Concrete
LUCES/nfer models, firmware, binary-memory models and measured datasets are outside
this release. The embedded system below explains the motivation; its implementation
is a separate development.

## Motivation

### The system

I built a small embedded system, an adaptive-lighting controller: a four-node mesh of Seeed Studio XIAO ESP32 boards (ESP32-S3 and ESP32-C6) with an AS7341 spectral sensor and a TSL2591 lux sensor feeding a real-time control loop, running under 2 W with no cloud and no simulation. The nodes join, authenticate, and synchronize over a message protocol designed in the π-calculus: a three-way join handshake with self-healing re-join, HMAC-authenticated challenge and response, timing-synchronized beacons, and sensor-data and registry messages across all four agents. The control logic is currently being migrated onto a custom-designed LUCES board. Weather inputs (cloud cover, humidity, solar radiation) come from the Open-Meteo API as a baseline. On top of this sits a **Monge map controller**. Across many days and weather conditions, one thing holds: weather changes the cost, but not the map. That is what makes real-time control feasible, a single precomputed, certified transport map carries the system through its daily transitions by McCann displacement interpolation, at linear cost per step. The controller has been developed and validated in simulation.

The background is in three published papers:

- "Empirical Information Geometry on an Embedded Adaptive Lighting System: Multi-Chart Manifold Transitions Under Signal Collapse," 2026. [https://zenodo.org/records/20094759](https://zenodo.org/records/20094759)
- "Excitation-Dependent Observability Geometry on an Embedded Adaptive Lighting Manifold," 2026. [https://zenodo.org/records/20389804](https://zenodo.org/records/20389804)
- "Optimal Transport Geometry of Natural Spectral Regime Transitions," 2026. [https://zenodo.org/records/21956336](https://zenodo.org/records/21956336)

### The problem

The system produces logs, and I wanted to do more than check whether those logs passed or failed. A pass/fail answer throws away the useful information. For any given run I wanted to know three things: how far the system is certified, what is stopping it from being certified further, and whether that obstruction can be repaired.

The better question is "how far does certification reach, and what blocks it from reaching further?" Once certification is graded rather than binary, a failing run is no longer a dead end: it carries a boundary (how far it got), a reason (which checks block it), and a decision (whether the block can be removed).

Today this runs offline, certifying log files against formal specifications. The direction I find most interesting is live: running the certification against the system as it runs, on the hardware itself, so it continuously knows its certified boundary, localizes whatever is blocking it, and repairs that part while running rather than after the fact in a log. That is the use case this theory is built for: certificate-driven correction, with every outcome carrying its own proof.

This repository is the formalization behind that: the certification framework, the structure of blocking, and the repair layer, machine-checked in Lean 4. The applied side, with the information-geometry background and the concrete certificate examples, lives in the companion PVS development ([luces-pvs-theories](https://github.com/gajaka/luces-pvs-theories)).

## Overview

A certificate is a predicate that says a system meets a contract. Given data and a specification level, the certificate either holds or it does not.

*(Here the certificate is kept abstract, a predicate over data and level. The concrete certificates, together with the information-geometry quantities they test, are specified in the companion PVS development, and are out of scope for this repository, which presents the formalization.)*

The specifications are not a flat list: they are ordered, from weaker contracts to stricter ones. The basic property this theory is built on is monotonicity: if a system passes a stricter contract, it also passes every weaker one. So for each piece of data there is a highest level it can be certified at, and everything at or below that level holds. This highest reachable level is the canonical level, and certification is exactly the set of levels at or below it.

Once certification is ordered this way, three questions become precise, and the theory answers each one.

First, how far does certification reach. The canonical level is the answer: it is the top of the certified region, and the theory proves it exists under the usual lattice conditions and that nothing above it can be certified.

Second, what stops it from going further. At a given level, the blocking set is the collection of certificates that fail there. It is empty exactly when that level is certified: at the canonical level and at every weaker level. A stricter level has a nonempty blocking set. Two failing certificates are coupled when they read a shared variable, and connected components identify coupled groups for repair. Different components have disjoint variable footprints, so under the locality condition (each certificate reads only its own variables) a repair confined to one component cannot change the evaluation of any certificate in another. This is the blocking dependency decomposition.

Third, whether a failure can be contained and repaired. A violating element is
isolated so it cannot corrupt the certified core. Under the repair obligations,
repair changes the state while keeping the specification fixed and preserving
or advancing certification. Three further questions are kept separate: does a
repair path exist, does the chosen random procedure reach a good state almost
surely, and how much work does it need?

The probabilistic route begins with the General and lopsided Lovász Local Lemmas:
their conditions give positive probability of avoiding all bad events. In the
variable-resampling model, the Moser–Tardos development constructs a repair by
resampling violated events and bounds its expected work by E[T_LOG] ≤ Σ x(α)
under the declared budgets. Finite expectation then gives almost-sure
termination; termination is not assumed in the counting proof.

The certified region now extends beyond the original LLL criterion. Pegden's
independent-subset criterion and strict Shearer positivity provide stronger
expected-work bounds, including budgets for individual dependency components.
He–Li–Sun additionally uses lower bounds on intersections of matched bad events:
the reduced probability vector p⁻ = p − δ²/17 can satisfy the criterion even
when the original vector does not. The corresponding expected-work and
almost-sure termination results allow arbitrary measurable admissible selection
schedules, including history-dependent rules and independent auxiliary
randomization. Each result has its own probability, locality and policy
hypotheses; failure of a sufficient criterion does not prove that repair is
impossible.

There are also routes based on the repair process itself. A nonnegative
potential with a proved conditional expected decrease bounds the expected
number of active steps without an LLL, Shearer or HLS premise. For suitable
finite rational transition models, checked drift potentials give upper bounds,
and solutions of the first-step hitting-time equations give exact expectations.
Survival recurrences give exact timeout probabilities and checked geometric
tail bounds. Lumping and commuting-update projections transfer these results
to a smaller model when their probability-preservation obligations are proved.
A repair path alone does not establish a time bound, and these stochastic work
bounds do not establish hardware deadlines.

Finally, finite models with decidable tests, and potentially infinite models
supplied with a proved exact finite abstraction and executable realization,
admit complete reachability decisions by exhaustive finite search: a concrete
repair trace or a checked refutation that no good state is reachable. Minimal
infeasible cores, invariant refutations and sound rational Farkas certificates
provide additional explanations of impossibility under their model hypotheses.
A closed bad class instead concerns the specified random kernel and starting
state; it need not rule out another repair policy. For the encoded infinite
model family, a halting-problem reduction proves that no computable total
repairability decider can work uniformly. Moser–Tardos reachability instantiates
the abstract PPG repair relation, and an existing good target supplies an
existential path through a constant resampling table. That path is distinct from
a probabilistic guarantee about a randomly drawn table.

The whole development is machine-checked in Lean 4 with no `sorry` and no
additional axioms. The audit checks that each declaration depends on at most
Lean's standard foundational axioms (`propext`, `Classical.choice` and
`Quot.sound`); any subset, including the empty set, is allowed. Depending on the
model and available evidence, the repair layer supports a positive witness, a
bound for the chosen procedure, or a checked refutation. An inconclusive
sufficient test remains distinct from a proof of impossibility.

### Application background (separate development)

The certificates are checked against real logs at five ordered levels, S > A > B > C > D. The outcomes are not uniform, which is the point. Most logs reach canonical level C: the structure is sound, but the Monge concentration is too weak to certify at B. One run, boot334, fails at every level, because its generator coherence is negative, the spectral flow reverses mid-transition (cos = -0.74). The structural certificates pass everywhere; the dynamical one fails only on boot334. Different certificates read independent axes of the same data, and the canonical level plus the blocking set together say exactly how far each run is certified and why it stops there. The [certificate-runner results](https://github.com/gajaka/luces-pvs-theories/blob/main/CERT_RUNNER_RESULTS.md) show the certificates evaluated on these real transition logs.

The library has **1,824 explicitly declared theorems and lemmas**, with an explicit
`#check` for each. The diagram below maps certification, dependency decomposition,
probabilistic repair, finite-state decisions, expected work and stopping bounds.

The [complete module inventory](THEORY_INDEX.md) lists all 191 modules. Run
`python3 tools/audit_ppgraph.py` to rebuild and inspect every project declaration's
axiom dependencies, including generated theorem constants. The allowed set is
**any subset** of `{propext, Classical.choice, Quot.sound}`. The results and source
hashes are recorded in `PPGRAPH_AXIOM_AUDIT.txt` and `PPGRAPH_AXIOM_AUDIT.json`.

[![Proof-Preserving Graph Theory: certification and blocking, LLL/MT/Shearer/HLS repair, drift, exact finite models and tails, feasibility and refutation, abstraction, undecidability, and certified repair.](ppg-theory.png)](ppg-theory.png)

## Files

The table below describes the original layers. See [THEORY_INDEX.md](THEORY_INDEX.md)
for the complete current inventory, including the extensions above.

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
| `PPGraphQuotientBridge.lean` | 5 | Bridge: spec graph projects to quotient PPG via surjective morphism |
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

Selected results from the original framework and its extensions. Statements
abbreviate the declared type, measurability and locality assumptions; the source
contains the full hypotheses. Random-initialization bounds use slot zero of the
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

    In CompleteLattice + inf-closure, canonical exists

6. **Lower canonical bound**

    Lean: [no_repair_below_canonical](PPGraphParametric.lean).

    Cannot certify below canonical level

7. **Canonical blocking set**

    Lean: [canonical_blocking_empty](PPGraphBlocking.lean).

    At canonical level, blocking set is empty

8. **Separating certificate classes**

    Lean: [separating_equiv_eq](PPGraphParametricQuotient.lean).

    Under separating family, cert_equiv implies equality

9. **Hierarchical selection**

    Lean: [lens_master_refinement](PPGraphSelection.lean).

    One-liner from master_refinement via OrderDual Finset

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

    Moser-Tardos reachability makes the abstract proof-preserving repair globally hold


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
    steps gives **E[active steps] ≤ E[V₀]/δ**

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


The finite MT rows use the declared finite variables/domains, normalized rational
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

The layers below group the current development by purpose. The
[module inventory](THEORY_INDEX.md) gives the complete file-level view.

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
    component-local Shearer budgets. A counted component can be bounded without
    certifying the others; this does not assert fairness or component completion.

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
    repairability testing for the halting-encoding infinite-model family. This
    limits general automation; it is not a no-repair certificate for each
    individual infinite instance.

## Related

- **PVS formalization:** [luces-pvs-theories](https://github.com/gajaka/luces-pvs-theories) - 460 machine-checked results (340 theorems + 120 lemmas), 52 theories. This covers the PPG core, the General LLL, and the base Moser-Tardos infrastructure. The final arc published here in Lean (E[T_LOG], BDD, Lopsided/Variable LLL, repair bridge) is not yet in PVS.

## Probabilistic Repair: references and scope

The development combines existence criteria, resampling bounds, process-based
time certificates and reachability decisions. The references below identify the
mathematical sources and the corresponding formalized scope; the Lean files
contain the full hypotheses.

### Local Lemmas and Moser–Tardos

- **General LLL and resampling**: Alon and Spencer, *The Probabilistic Method*,
  4th ed., Wiley 2016, Lemma 5.1.1 and §5.7; Moser and Tardos,
  [*A constructive proof of the general Lovász Local Lemma*](https://arxiv.org/abs/0903.0544v3).
  [PPGraphLLL.lean](PPGraphLLL.lean) proves the General LLL division-free.
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
  each closed neighborhood. The same random-initialized process satisfies
  E[T_LOG] ≤ Σ x(α) under this criterion, without assuming termination.

- **Shearer**: Harvey and Vondrák,
  [*Short proofs for generalizations of the Lovász Local Lemma: Shearer's condition and cluster expansion*](https://arxiv.org/abs/1711.06797v1),
  §2, supplies the existence/lower-probability argument in
  [PPGraphShearer.lean](PPGraphShearer.lean), formalized with strict positivity.
  The expected-work result is the Kolipaka–Szegedy bound, presented in
  [Vondrák's 2018 Lecture 8](https://theory.stanford.edu/~jvondrak/MATH233A-2018/Math233-lec08.pdf),
  Lemma 8.1 and Theorem 8.8. Stable-family identities also follow Harvey and
  Vondrák's [resampling-oracles paper](https://arxiv.org/abs/1504.02044v3), §5.
  [PPGraphShearerExpectation.lean](PPGraphShearerExpectation.lean) proves
  E[T_LOG] ≤ Σ q_{α}/q_∅; slack and
  [component-local budgets](PPGraphShearerBDDExpectation.lean) extend this bound.
  A component-work bound does not assert fairness or eventual component repair.

- **He–Li–Sun**: [*Moser-Tardos Algorithm: Beyond Shearer's Bound*](https://arxiv.org/abs/2111.06527v1),
  Theorem 1.6 and §3.3. Matching-compatible intersection lower bounds give
  p⁻ = p − δ²/17. Strict Shearer at p⁻ yields finite expected work; at
  (1+ε)p⁻, with ε > 0, the bound is m/ε for m bad events.
  [PPGraphHLSPolicyExpectation.lean](PPGraphHLSPolicyExpectation.lean) covers
  arbitrary measurable admissible schedules, history-dependent rules and
  independent auxiliary randomization under its exact positive probability,
  intersection and measurability hypotheses. Initialization uses slot zero of
  the product table; almost-sure termination is derived.

### Potentials, stopping bounds and model reduction

- **Additive drift**: Lengler, [*Drift Analysis*](https://arxiv.org/abs/1712.00964v2),
  Theorem 1, provides the background for
  [PPGraphAdditiveDrift.lean](PPGraphAdditiveDrift.lean). The formalization uses
  a nonnegative integrable adapted stopped potential with conditional expected
  decrease δ > 0, giving E[active steps] ≤ E[V₀]/δ. Its
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
simulation, step-realization and good-state preservation obligations. Exhaustive
search is explicit; no general efficient search or automatic abstraction
discovery is claimed. [Minimal cores](PPGraphUnsatisfiableCore.lean) and
[correction-set duality](PPGraphCorrectionDuality.lean) describe infeasible
obligation families, while [invariant refutations](PPGraphReachabilityRefutation.lean)
exclude good states along the declared repair relation.

For linear models, [PPGraphFarkasCertificate.lean](PPGraphFarkasCertificate.lean)
proves soundness of accepted rational infeasibility certificates, following the
certificate direction of Dlask and Werner,
[*Bounding Linear Programs by Constraint Propagation: Application to Max-SAT*](https://cmp.felk.cvut.cz/~dlaskto2/papers/Dlask-Werner-CP2020a.pdf),
§2.1, Theorem 1. It does not assume that every infeasible model has a supplied
certificate. The infinite-model decision limit reuses the computability
apparatus described by Carneiro in
[*Formalizing computability theory via partial recursive functions*](https://arxiv.org/abs/1810.08380v3),
§§5.2–5.3. [PPGraphRepairUndecidability.lean](PPGraphRepairUndecidability.lean)
constructs the repair-family reduction to the halting problem.

[PPGraphMoserTardosRepairBridge.lean](PPGraphMoserTardosRepairBridge.lean)
connects resampling reachability to abstract repair. Existence of a good target,
almost-sure termination under a probability law, and bounded expected work are
distinct claims. Failure of a sufficient criterion remains inconclusive;
negative certificates must establish their own model-specific obstruction.
Stochastic work and cost bounds do not establish native execution correctness
or hardware deadlines.

The companion PVS development covers the PPG core, General LLL and base
Moser–Tardos infrastructure. The final expected-work, BDD, lopsided/variable-LLL
and repair-bridge arc documented here is not yet ported to PVS; the further Lean
extensions above should not be read as a claim of PVS parity.

## Future work

The theory now separates "the selected criterion does not certify repairability"
from "no repair exists." For finite models, and concrete models supplied with a
proved exact finite abstraction and executable realization, the decision layer
can return a repair path or a certificate that no such path exists. No algorithm
is claimed to synthesize an exact abstraction for every system.

The probabilistic repair criteria remain sufficient conditions. Shearer, Pegden
and He–Li–Sun extend the original LLL development. Finite potential witnesses and
tail certificates provide a separate route to termination and time bounds under
their checked transition-model hypotheses. A path alone does not imply such a
time bound. A closed bad class refutes repair under its specified transition
kernel; it does not refute every other repair policy.

For arbitrary infinite models, the library proves that a total general
repairability decider cannot exist. This is a limit on universal automation, not
an impossibility certificate for every individual infinite instance.

Open directions include finding useful repair witnesses beyond the available
criteria without exhaustive enumeration, and constructing tractable exact
abstractions or checked potentials for concrete systems. Physical acquisition,
native execution and hardware timing remain separate application obligations.

## Author

Dragan Stosic, MSc

## License

© 2026 Dragan Stosic. All rights reserved.

This work (theories, proofs, and source) is made available for reading, academic study, and non-commercial research use, with attribution. Redistribution, modification, derivative works, or any commercial use require prior written permission. If you are interested in using this work, including in a commercial or product setting, please get in touch: dragan.stosic@gmail.com
