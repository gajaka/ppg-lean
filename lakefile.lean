import Lake
open Lake DSL

package PPGraph where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "master"

@[default_target]
lean_lib PPGraph where
  srcDir := "."
  roots := #[`PPGraph, `PPGraphCategorical, `PPGraphMeta,
             `PPGraphRepair, `PPGraphRR, `PPGraphParametric,
             `PPGraphParametricQuotient, `PPGraphBlocking,
             `PPGraphQuotientBridge, `PPGraphSelection, `PPGraphEquivBridge, `PPGraphComplementarySlackness, `PPGraphSelfAssessment, `PPGraphAssessmentBridge, `PPGraphProbabilistic, `PPGraphLLL, `PPGraphMoserTardos, `PPGraphMoserTardosProcess, `PPGraphMoserTardosWitness, `PPGraphMoserTardosGrowing, `PPGraphMoserTardosInjectivity, `PPGraphMoserTardosWeight, `PPGraphMoserTardosConvergence, `PPGraphMoserTardosLogSpace, `PPGraphMoserTardosRandomTrajectory, `PPGraphMoserTardosCounting, `PPGraphMoserTardosPastIndependence,
             `PPGraphLopsidedLLL, `PPGraphVariableLLL, `PPGraphBDD, `PPGraphBDDMoserTardos,
             `PPGraphBDDCost, `PPGraphBDDMatrix, `PPGraphBDDLaplacian, `PPGraphBDDCount,
             `PPGraphMoserTardosCheckOrder, `PPGraphMoserTardosCheck,
             `PPGraphMoserTardosCheckBirth, `PPGraphMoserTardosCorrespondence,
             `PPGraphMoserTardosProbability, `PPGraphMoserTardosWeightSum, `PPGraphMoserTardosRealTree,
             `PPGraphMoserTardosExpectation, `PPGraphMoserTardosCanonical,
             `PPGraphMoserTardosInjectivityBridge, `PPGraphMoserTardosCheckInvariance,
             `PPGraphMoserTardosCheckShape, `PPGraphMoserTardosCheckBridge,
             `PPGraphMoserTardosProbabilityGeneral, `PPGraphMoserTardosWTreeToGrowingTree,
             `PPGraphMoserTardosLabelsAtDepthBridge, `PPGraphMoserTardosToGrowingTreeCheckBridge,
             `PPGraphMoserTardosWTreeCountable, `PPGraphMoserTardosResamplingCount,
             `PPGraphMoserTardosRandomInitialization, `PPGraphMoserTardosRandomInitExpectation,
             `PPGraphMoserTardosOccurrence, `PPGraphMoserTardosOccurrenceCounting,
             `PPGraphMoserTardosOccurrenceProbability, `PPGraphMoserTardosWitnessFamily,
             `PPGraphMoserTardosOccurrenceExpectation,
             `PPGraphMoserTardosTermination, `PPGraphMoserTardosConstantLog,
             `PPGraphMoserTardosRepairBridge]
