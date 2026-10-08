# Pure-theory module inventory

This inventory covers 191 generic PPG modules and 1,824 explicit theorem/lemma declarations.
Generated theorem constants are counted separately in the whole-library axiom audit.
Counts describe declarations, not distinct applications or measured hardware cases.

The complete per-declaration dependency report is `PPGRAPH_AXIOM_AUDIT.json`.
Reproduce the build and audit with `python3 tools/audit_ppgraph.py`.

| Module | Explicit theorems/lemmas | Direct PPG imports |
| --- | ---: | --- |
| [PPGraph](./PPGraph.lean) | 22 | - |
| [PPGraphAdditiveDrift](./PPGraphAdditiveDrift.lean) | 10 | - |
| [PPGraphAssessmentBridge](./PPGraphAssessmentBridge.lean) | 8 | [PPGraphParametric](./PPGraphParametric.lean), [PPGraphBlocking](./PPGraphBlocking.lean), [PPGraphSelfAssessment](./PPGraphSelfAssessment.lean) |
| [PPGraphBDD](./PPGraphBDD.lean) | 13 | [PPGraphProbabilistic](./PPGraphProbabilistic.lean) |
| [PPGraphBDDCost](./PPGraphBDDCost.lean) | 5 | [PPGraphBDD](./PPGraphBDD.lean) |
| [PPGraphBDDCount](./PPGraphBDDCount.lean) | 6 | [PPGraphBDD](./PPGraphBDD.lean), [PPGraphBDDLaplacian](./PPGraphBDDLaplacian.lean) |
| [PPGraphBDDInfeasibility](./PPGraphBDDInfeasibility.lean) | 10 | [PPGraphBDDPartition](./PPGraphBDDPartition.lean), [PPGraphUnsatisfiableCore](./PPGraphUnsatisfiableCore.lean) |
| [PPGraphBDDLaplacian](./PPGraphBDDLaplacian.lean) | 9 | [PPGraphBDD](./PPGraphBDD.lean) |
| [PPGraphBDDMatrix](./PPGraphBDDMatrix.lean) | 3 | [PPGraphProbabilistic](./PPGraphProbabilistic.lean) |
| [PPGraphBDDMoserTardos](./PPGraphBDDMoserTardos.lean) | 2 | [PPGraphBDD](./PPGraphBDD.lean), [PPGraphMoserTardosProcess](./PPGraphMoserTardosProcess.lean) |
| [PPGraphBDDPartition](./PPGraphBDDPartition.lean) | 4 | [PPGraphBDD](./PPGraphBDD.lean) |
| [PPGraphBlocking](./PPGraphBlocking.lean) | 7 | [PPGraphParametric](./PPGraphParametric.lean) |
| [PPGraphCategorical](./PPGraphCategorical.lean) | 10 | - |
| [PPGraphCertifiedDecision](./PPGraphCertifiedDecision.lean) | 6 | [PPGraphRepairDecision](./PPGraphRepairDecision.lean) |
| [PPGraphComplementarySlackness](./PPGraphComplementarySlackness.lean) | 5 | - |
| [PPGraphCorrectionDuality](./PPGraphCorrectionDuality.lean) | 5 | [PPGraphUnsatisfiableCore](./PPGraphUnsatisfiableCore.lean) |
| [PPGraphEquivBridge](./PPGraphEquivBridge.lean) | 4 | [PPGraphParametric](./PPGraphParametric.lean), [PPGraphParametricQuotient](./PPGraphParametricQuotient.lean), [PPGraphSelection](./PPGraphSelection.lean) |
| [PPGraphFarkasCertificate](./PPGraphFarkasCertificate.lean) | 7 | [PPGraphInfeasibility](./PPGraphInfeasibility.lean) |
| [PPGraphFiniteAbstraction](./PPGraphFiniteAbstraction.lean) | 22 | [PPGraphReachabilityRefutation](./PPGraphReachabilityRefutation.lean) |
| [PPGraphFiniteAbstractionRepair](./PPGraphFiniteAbstractionRepair.lean) | 12 | [PPGraphFiniteAbstraction](./PPGraphFiniteAbstraction.lean) |
| [PPGraphFiniteCore](./PPGraphFiniteCore.lean) | 3 | [PPGraphFiniteFeasibility](./PPGraphFiniteFeasibility.lean), [PPGraphUnsatisfiableCore](./PPGraphUnsatisfiableCore.lean) |
| [PPGraphFiniteDrift](./PPGraphFiniteDrift.lean) | 17 | [PPGraphAdditiveDrift](./PPGraphAdditiveDrift.lean) |
| [PPGraphFiniteDriftProcess](./PPGraphFiniteDriftProcess.lean) | 20 | [PPGraphFiniteDrift](./PPGraphFiniteDrift.lean) |
| [PPGraphFiniteFeasibility](./PPGraphFiniteFeasibility.lean) | 13 | [PPGraphInfeasibility](./PPGraphInfeasibility.lean) |
| [PPGraphFiniteLumping](./PPGraphFiniteLumping.lean) | 15 | [PPGraphFinitePotentialTailCertificate](./PPGraphFinitePotentialTailCertificate.lean) |
| [PPGraphFiniteLumpingUpdate](./PPGraphFiniteLumpingUpdate.lean) | 25 | [PPGraphFiniteLumping](./PPGraphFiniteLumping.lean), [PPGraphFiniteUpdateIID](./PPGraphFiniteUpdateIID.lean) |
| [PPGraphFiniteMTDrift](./PPGraphFiniteMTDrift.lean) | 18 | [PPGraphFiniteTableLaw](./PPGraphFiniteTableLaw.lean), [PPGraphMoserTardosDrift](./PPGraphMoserTardosDrift.lean) |
| [PPGraphFinitePotential](./PPGraphFinitePotential.lean) | 27 | [PPGraphFiniteDrift](./PPGraphFiniteDrift.lean) |
| [PPGraphFinitePotentialExpectation](./PPGraphFinitePotentialExpectation.lean) | 19 | [PPGraphFinitePotential](./PPGraphFinitePotential.lean), [PPGraphFiniteDriftProcess](./PPGraphFiniteDriftProcess.lean) |
| [PPGraphFinitePotentialExpectationMT](./PPGraphFinitePotentialExpectationMT.lean) | 7 | [PPGraphFinitePotentialExpectation](./PPGraphFinitePotentialExpectation.lean), [PPGraphFinitePotentialMT](./PPGraphFinitePotentialMT.lean) |
| [PPGraphFinitePotentialMT](./PPGraphFinitePotentialMT.lean) | 15 | [PPGraphFinitePotential](./PPGraphFinitePotential.lean), [PPGraphFiniteMTDrift](./PPGraphFiniteMTDrift.lean) |
| [PPGraphFinitePotentialRefutation](./PPGraphFinitePotentialRefutation.lean) | 10 | [PPGraphFinitePotential](./PPGraphFinitePotential.lean) |
| [PPGraphFinitePotentialTail](./PPGraphFinitePotentialTail.lean) | 23 | [PPGraphFinitePotentialExpectation](./PPGraphFinitePotentialExpectation.lean), [PPGraphFinitePotentialRefutation](./PPGraphFinitePotentialRefutation.lean) |
| [PPGraphFinitePotentialTailCertificate](./PPGraphFinitePotentialTailCertificate.lean) | 4 | [PPGraphFinitePotentialTail](./PPGraphFinitePotentialTail.lean) |
| [PPGraphFinitePotentialTailMT](./PPGraphFinitePotentialTailMT.lean) | 9 | [PPGraphFinitePotentialTailCertificate](./PPGraphFinitePotentialTailCertificate.lean), [PPGraphFinitePotentialExpectationMT](./PPGraphFinitePotentialExpectationMT.lean) |
| [PPGraphFiniteResampling](./PPGraphFiniteResampling.lean) | 31 | [PPGraphFiniteUpdateIID](./PPGraphFiniteUpdateIID.lean), [PPGraphMoserTardosProcess](./PPGraphMoserTardosProcess.lean) |
| [PPGraphFiniteTable](./PPGraphFiniteTable.lean) | 19 | [PPGraphFiniteResampling](./PPGraphFiniteResampling.lean), [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) |
| [PPGraphFiniteTableLaw](./PPGraphFiniteTableLaw.lean) | 10 | [PPGraphFiniteTable](./PPGraphFiniteTable.lean), [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) |
| [PPGraphFiniteUpdate](./PPGraphFiniteUpdate.lean) | 16 | [PPGraphFiniteDriftProcess](./PPGraphFiniteDriftProcess.lean) |
| [PPGraphFiniteUpdateIID](./PPGraphFiniteUpdateIID.lean) | 15 | [PPGraphFiniteUpdate](./PPGraphFiniteUpdate.lean) |
| [PPGraphHLSAugmentedCoordinates](./PPGraphHLSAugmentedCoordinates.lean) | 5 | [PPGraphHLSAugmentedSpace](./PPGraphHLSAugmentedSpace.lean), [PPGraphHLSMatchingSelection](./PPGraphHLSMatchingSelection.lean), [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) |
| [PPGraphHLSAugmentedDependence](./PPGraphHLSAugmentedDependence.lean) | 4 | [PPGraphHLSAugmentedPair](./PPGraphHLSAugmentedPair.lean), [PPGraphHLSAugmentedCoordinates](./PPGraphHLSAugmentedCoordinates.lean) |
| [PPGraphHLSAugmentedExistence](./PPGraphHLSAugmentedExistence.lean) | 2 | [PPGraphHLSOrientationScore](./PPGraphHLSOrientationScore.lean), [PPGraphHLSPrefixCheck](./PPGraphHLSPrefixCheck.lean) |
| [PPGraphHLSAugmentedPair](./PPGraphHLSAugmentedPair.lean) | 5 | [PPGraphHLSCoinQueryLaw](./PPGraphHLSCoinQueryLaw.lean), [PPGraphHLSRelativeCoins](./PPGraphHLSRelativeCoins.lean), [PPGraphHLSPairProbability](./PPGraphHLSPairProbability.lean), [PPGraphHLSAugmentedExistence](./PPGraphHLSAugmentedExistence.lean) |
| [PPGraphHLSAugmentedSpace](./PPGraphHLSAugmentedSpace.lean) | 5 | [PPGraphHLSCoinSaving](./PPGraphHLSCoinSaving.lean), [PPGraphHLSQueryLaw](./PPGraphHLSQueryLaw.lean), [PPGraphMoserTardosRandomInitExpectation](./PPGraphMoserTardosRandomInitExpectation.lean) |
| [PPGraphHLSBlockAssembly](./PPGraphHLSBlockAssembly.lean) | 9 | [PPGraphHLSQueryLaw](./PPGraphHLSQueryLaw.lean) |
| [PPGraphHLSBlockIntersection](./PPGraphHLSBlockIntersection.lean) | 3 | [PPGraphHLSBlockAssembly](./PPGraphHLSBlockAssembly.lean), [PPGraphHLSCoinSaving](./PPGraphHLSCoinSaving.lean) |
| [PPGraphHLSBlockQueries](./PPGraphHLSBlockQueries.lean) | 4 | [PPGraphHLSFootprintBlocks](./PPGraphHLSFootprintBlocks.lean), [PPGraphHLSReversalSlots](./PPGraphHLSReversalSlots.lean) |
| [PPGraphHLSCanonicalEncoding](./PPGraphHLSCanonicalEncoding.lean) | 9 | [PPGraphHLSStableEncoding](./PPGraphHLSStableEncoding.lean) |
| [PPGraphHLSChoiceRecovery](./PPGraphHLSChoiceRecovery.lean) | 4 | [PPGraphHLSOriginalIso](./PPGraphHLSOriginalIso.lean), [PPGraphHLSMatchingArcUniqueness](./PPGraphHLSMatchingArcUniqueness.lean) |
| [PPGraphHLSChoiceSum](./PPGraphHLSChoiceSum.lean) | 2 | [PPGraphHLSExpansionWeight](./PPGraphHLSExpansionWeight.lean) |
| [PPGraphHLSCliqueRanks](./PPGraphHLSCliqueRanks.lean) | 12 | [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean), [PPGraphHLSMatching](./PPGraphHLSMatching.lean) |
| [PPGraphHLSCoinQueryLaw](./PPGraphHLSCoinQueryLaw.lean) | 1 | [PPGraphHLSAugmentedSpace](./PPGraphHLSAugmentedSpace.lean) |
| [PPGraphHLSCoinSaving](./PPGraphHLSCoinSaving.lean) | 9 | [PPGraphMoserTardosIntersection](./PPGraphMoserTardosIntersection.lean), [PPGraphHLSParameters](./PPGraphHLSParameters.lean) |
| [PPGraphHLSColoredExpansion](./PPGraphHLSColoredExpansion.lean) | 8 | [PPGraphHLSOriginRecovery](./PPGraphHLSOriginRecovery.lean), [PPGraphHLSNormalizationReversal](./PPGraphHLSNormalizationReversal.lean) |
| [PPGraphHLSDecisionBridge](./PPGraphHLSDecisionBridge.lean) | 9 | [PPGraphHLSRepairBridge](./PPGraphHLSRepairBridge.lean), [PPGraphMoserTardosInfeasibility](./PPGraphMoserTardosInfeasibility.lean), [PPGraphRepairDecision](./PPGraphRepairDecision.lean) |
| [PPGraphHLSDecoratedBudget](./PPGraphHLSDecoratedBudget.lean) | 6 | [PPGraphHLSWitnessBudget](./PPGraphHLSWitnessBudget.lean), [PPGraphHLSMatching](./PPGraphHLSMatching.lean) |
| [PPGraphHLSExpansionDecoder](./PPGraphHLSExpansionDecoder.lean) | 4 | [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean) |
| [PPGraphHLSExpansionFamily](./PPGraphHLSExpansionFamily.lean) | 4 | [PPGraphHLSChoiceRecovery](./PPGraphHLSChoiceRecovery.lean), [PPGraphHLSDecoratedBudget](./PPGraphHLSDecoratedBudget.lean) |
| [PPGraphHLSExpansionGraph](./PPGraphHLSExpansionGraph.lean) | 8 | [PPGraphHLSExpansionVertices](./PPGraphHLSExpansionVertices.lean), [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean) |
| [PPGraphHLSExpansionReversibility](./PPGraphHLSExpansionReversibility.lean) | 5 | [PPGraphHLSExpansionGraph](./PPGraphHLSExpansionGraph.lean), [PPGraphHLSOrderedReversal](./PPGraphHLSOrderedReversal.lean) |
| [PPGraphHLSExpansionVertices](./PPGraphHLSExpansionVertices.lean) | 7 | [PPGraphHLSExpansionDecoder](./PPGraphHLSExpansionDecoder.lean), [PPGraphHLSTopologicalOrder](./PPGraphHLSTopologicalOrder.lean), [PPGraphHLSOrderedDAG](./PPGraphHLSOrderedDAG.lean) |
| [PPGraphHLSExpansionWeight](./PPGraphHLSExpansionWeight.lean) | 4 | [PPGraphHLSExpansionFamily](./PPGraphHLSExpansionFamily.lean) |
| [PPGraphHLSExpectation](./PPGraphHLSExpectation.lean) | 8 | [PPGraphHLSRefinedProbability](./PPGraphHLSRefinedProbability.lean), [PPGraphHLSRootUnion](./PPGraphHLSRootUnion.lean), [PPGraphMoserTardosTermination](./PPGraphMoserTardosTermination.lean) |
| [PPGraphHLSFiniteDAG](./PPGraphHLSFiniteDAG.lean) | 6 | [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean) |
| [PPGraphHLSFootprintBlocks](./PPGraphHLSFootprintBlocks.lean) | 9 | [PPGraphHLSBlockIntersection](./PPGraphHLSBlockIntersection.lean) |
| [PPGraphHLSLabelRanks](./PPGraphHLSLabelRanks.lean) | 10 | [PPGraphHLSCanonicalEncoding](./PPGraphHLSCanonicalEncoding.lean), [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) |
| [PPGraphHLSMatching](./PPGraphHLSMatching.lean) | 13 | [PPGraphHLSParameters](./PPGraphHLSParameters.lean) |
| [PPGraphHLSMatchingArcUniqueness](./PPGraphHLSMatchingArcUniqueness.lean) | 1 | [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean) |
| [PPGraphHLSMatchingSelection](./PPGraphHLSMatchingSelection.lean) | 15 | [PPGraphHLSParitySelection](./PPGraphHLSParitySelection.lean), [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean) |
| [PPGraphHLSNodeIso](./PPGraphHLSNodeIso.lean) | 5 | [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean) |
| [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean) | 12 | [PPGraphHLSLabelRanks](./PPGraphHLSLabelRanks.lean) |
| [PPGraphHLSNormalizationCheck](./PPGraphHLSNormalizationCheck.lean) | 5 | [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean), [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) |
| [PPGraphHLSNormalizationReversal](./PPGraphHLSNormalizationReversal.lean) | 3 | [PPGraphHLSNormalization](./PPGraphHLSNormalization.lean) |
| [PPGraphHLSOrderedDAG](./PPGraphHLSOrderedDAG.lean) | 5 | [PPGraphHLSWitnessDAG](./PPGraphHLSWitnessDAG.lean) |
| [PPGraphHLSOrderedReversal](./PPGraphHLSOrderedReversal.lean) | 2 | [PPGraphHLSOrderedDAG](./PPGraphHLSOrderedDAG.lean) |
| [PPGraphHLSOrdinalOccurrence](./PPGraphHLSOrdinalOccurrence.lean) | 6 | [PPGraphHLSRealDAGCounts](./PPGraphHLSRealDAGCounts.lean), [PPGraphMoserTardosOccurrence](./PPGraphMoserTardosOccurrence.lean) |
| [PPGraphHLSOrientationScore](./PPGraphHLSOrientationScore.lean) | 4 | [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean), [PPGraphHLSFiniteDAG](./PPGraphHLSFiniteDAG.lean) |
| [PPGraphHLSOriginRecovery](./PPGraphHLSOriginRecovery.lean) | 5 | [PPGraphHLSExpansionReversibility](./PPGraphHLSExpansionReversibility.lean), [PPGraphHLSMatchingSelection](./PPGraphHLSMatchingSelection.lean) |
| [PPGraphHLSOriginalIso](./PPGraphHLSOriginalIso.lean) | 4 | [PPGraphHLSColoredExpansion](./PPGraphHLSColoredExpansion.lean), [PPGraphHLSNodeIso](./PPGraphHLSNodeIso.lean) |
| [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean) | 6 | [PPGraphHLSCliqueRanks](./PPGraphHLSCliqueRanks.lean) |
| [PPGraphHLSPairProbability](./PPGraphHLSPairProbability.lean) | 5 | [PPGraphHLSBlockQueries](./PPGraphHLSBlockQueries.lean), [PPGraphHLSSwappedTests](./PPGraphHLSSwappedTests.lean) |
| [PPGraphHLSParameters](./PPGraphHLSParameters.lean) | 12 | - |
| [PPGraphHLSParitySelection](./PPGraphHLSParitySelection.lean) | 6 | [PPGraphHLSCliqueRanks](./PPGraphHLSCliqueRanks.lean) |
| [PPGraphHLSPolicyCounting](./PPGraphHLSPolicyCounting.lean) | 14 | [PPGraphHLSPolicyDAG](./PPGraphHLSPolicyDAG.lean), [PPGraphHLSRootUnion](./PPGraphHLSRootUnion.lean) |
| [PPGraphHLSPolicyDAG](./PPGraphHLSPolicyDAG.lean) | 16 | [PPGraphMoserTardosPolicy](./PPGraphMoserTardosPolicy.lean) |
| [PPGraphHLSPolicyExpectation](./PPGraphHLSPolicyExpectation.lean) | 13 | [PPGraphHLSRefinedProbability](./PPGraphHLSRefinedProbability.lean), [PPGraphHLSPolicyCounting](./PPGraphHLSPolicyCounting.lean), [PPGraphMoserTardosHistoryPolicy](./PPGraphMoserTardosHistoryPolicy.lean) |
| [PPGraphHLSPrefixCheck](./PPGraphHLSPrefixCheck.lean) | 8 | [PPGraphHLSReversalSlots](./PPGraphHLSReversalSlots.lean) |
| [PPGraphHLSProductDiscount](./PPGraphHLSProductDiscount.lean) | 7 | [PPGraphHLSRefinedBudget](./PPGraphHLSRefinedBudget.lean) |
| [PPGraphHLSQueryLaw](./PPGraphHLSQueryLaw.lean) | 5 | [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) |
| [PPGraphHLSRealDAG](./PPGraphHLSRealDAG.lean) | 10 | [PPGraphHLSTimeDAG](./PPGraphHLSTimeDAG.lean), [PPGraphHLSPrefixCheck](./PPGraphHLSPrefixCheck.lean), [PPGraphHLSWitnessBudget](./PPGraphHLSWitnessBudget.lean), [PPGraphMoserTardosRandomInitExpectation](./PPGraphMoserTardosRandomInitExpectation.lean) |
| [PPGraphHLSRealDAGCounts](./PPGraphHLSRealDAGCounts.lean) | 8 | [PPGraphHLSRealDAG](./PPGraphHLSRealDAG.lean) |
| [PPGraphHLSRefinedBudget](./PPGraphHLSRefinedBudget.lean) | 4 | [PPGraphHLSChoiceSum](./PPGraphHLSChoiceSum.lean) |
| [PPGraphHLSRefinedProbability](./PPGraphHLSRefinedProbability.lean) | 3 | [PPGraphHLSUnitChecks](./PPGraphHLSUnitChecks.lean), [PPGraphHLSProductDiscount](./PPGraphHLSProductDiscount.lean) |
| [PPGraphHLSRelativeCoins](./PPGraphHLSRelativeCoins.lean) | 6 | [PPGraphHLSAugmentedSpace](./PPGraphHLSAugmentedSpace.lean), [PPGraphHLSPairKeys](./PPGraphHLSPairKeys.lean) |
| [PPGraphHLSRepairBridge](./PPGraphHLSRepairBridge.lean) | 3 | [PPGraphHLSExpectation](./PPGraphHLSExpectation.lean), [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean) |
| [PPGraphHLSReversal](./PPGraphHLSReversal.lean) | 9 | - |
| [PPGraphHLSReversalSlots](./PPGraphHLSReversalSlots.lean) | 10 | [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) |
| [PPGraphHLSRootUnion](./PPGraphHLSRootUnion.lean) | 6 | [PPGraphHLSOrdinalOccurrence](./PPGraphHLSOrdinalOccurrence.lean), [PPGraphHLSUnitChecks](./PPGraphHLSUnitChecks.lean) |
| [PPGraphHLSStableEncoding](./PPGraphHLSStableEncoding.lean) | 14 | [PPGraphHLSWitnessLayers](./PPGraphHLSWitnessLayers.lean) |
| [PPGraphHLSSwappedTests](./PPGraphHLSSwappedTests.lean) | 3 | [PPGraphHLSPrefixCheck](./PPGraphHLSPrefixCheck.lean) |
| [PPGraphHLSTableCheck](./PPGraphHLSTableCheck.lean) | 11 | [PPGraphHLSWitnessDAG](./PPGraphHLSWitnessDAG.lean), [PPGraphShearerBDD](./PPGraphShearerBDD.lean), [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) |
| [PPGraphHLSTimeDAG](./PPGraphHLSTimeDAG.lean) | 7 | [PPGraphHLSNormalizationCheck](./PPGraphHLSNormalizationCheck.lean) |
| [PPGraphHLSTopologicalOrder](./PPGraphHLSTopologicalOrder.lean) | 7 | [PPGraphHLSWitnessLayers](./PPGraphHLSWitnessLayers.lean) |
| [PPGraphHLSUnitChecks](./PPGraphHLSUnitChecks.lean) | 9 | [PPGraphHLSAugmentedDependence](./PPGraphHLSAugmentedDependence.lean) |
| [PPGraphHLSWitnessBudget](./PPGraphHLSWitnessBudget.lean) | 7 | [PPGraphHLSCanonicalEncoding](./PPGraphHLSCanonicalEncoding.lean), [PPGraphShearerSlack](./PPGraphShearerSlack.lean) |
| [PPGraphHLSWitnessDAG](./PPGraphHLSWitnessDAG.lean) | 15 | [PPGraphHLSReversal](./PPGraphHLSReversal.lean) |
| [PPGraphHLSWitnessLayers](./PPGraphHLSWitnessLayers.lean) | 14 | [PPGraphHLSWitnessDAG](./PPGraphHLSWitnessDAG.lean), [PPGraphShearerStable](./PPGraphShearerStable.lean) |
| [PPGraphInfeasibility](./PPGraphInfeasibility.lean) | 14 | [PPGraphRepair](./PPGraphRepair.lean) |
| [PPGraphInfeasibilityCounting](./PPGraphInfeasibilityCounting.lean) | 10 | [PPGraphFiniteFeasibility](./PPGraphFiniteFeasibility.lean) |
| [PPGraphLLL](./PPGraphLLL.lean) | 30 | [PPGraphProbabilistic](./PPGraphProbabilistic.lean) |
| [PPGraphLopsidedLLL](./PPGraphLopsidedLLL.lean) | 6 | [PPGraphLLL](./PPGraphLLL.lean) |
| [PPGraphMeta](./PPGraphMeta.lean) | 10 | - |
| [PPGraphMoserTardos](./PPGraphMoserTardos.lean) | 3 | [PPGraphProbabilistic](./PPGraphProbabilistic.lean), [PPGraphLLL](./PPGraphLLL.lean) |
| [PPGraphMoserTardosCanonical](./PPGraphMoserTardosCanonical.lean) | 15 | [PPGraphMoserTardosWeightSum](./PPGraphMoserTardosWeightSum.lean) |
| [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean) | 1 | [PPGraphMoserTardosCheckOrder](./PPGraphMoserTardosCheckOrder.lean), [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) |
| [PPGraphMoserTardosCheckBirth](./PPGraphMoserTardosCheckBirth.lean) | 22 | [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean) |
| [PPGraphMoserTardosCheckBridge](./PPGraphMoserTardosCheckBridge.lean) | 2 | [PPGraphMoserTardosCheckShape](./PPGraphMoserTardosCheckShape.lean), [PPGraphMoserTardosRealTree](./PPGraphMoserTardosRealTree.lean), [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean) |
| [PPGraphMoserTardosCheckInvariance](./PPGraphMoserTardosCheckInvariance.lean) | 5 | [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean), [PPGraphMoserTardosInjectivityBridge](./PPGraphMoserTardosInjectivityBridge.lean) |
| [PPGraphMoserTardosCheckOrder](./PPGraphMoserTardosCheckOrder.lean) | 14 | [PPGraphMoserTardosGrowing](./PPGraphMoserTardosGrowing.lean) |
| [PPGraphMoserTardosCheckShape](./PPGraphMoserTardosCheckShape.lean) | 8 | [PPGraphMoserTardosCheckInvariance](./PPGraphMoserTardosCheckInvariance.lean), [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean) |
| [PPGraphMoserTardosConstantLog](./PPGraphMoserTardosConstantLog.lean) | 9 | [PPGraphMoserTardosTermination](./PPGraphMoserTardosTermination.lean) |
| [PPGraphMoserTardosConvergence](./PPGraphMoserTardosConvergence.lean) | 2 | [PPGraphMoserTardosWeight](./PPGraphMoserTardosWeight.lean) |
| [PPGraphMoserTardosCorrespondence](./PPGraphMoserTardosCorrespondence.lean) | 9 | [PPGraphMoserTardosCheckBirth](./PPGraphMoserTardosCheckBirth.lean), [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) |
| [PPGraphMoserTardosCounting](./PPGraphMoserTardosCounting.lean) | 3 | [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean), [PPGraphMoserTardosInjectivity](./PPGraphMoserTardosInjectivity.lean) |
| [PPGraphMoserTardosDrift](./PPGraphMoserTardosDrift.lean) | 20 | [PPGraphAdditiveDrift](./PPGraphAdditiveDrift.lean), [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean) |
| [PPGraphMoserTardosDriftCost](./PPGraphMoserTardosDriftCost.lean) | 6 | [PPGraphMoserTardosDrift](./PPGraphMoserTardosDrift.lean) |
| [PPGraphMoserTardosDriftRegion](./PPGraphMoserTardosDriftRegion.lean) | 8 | [PPGraphMoserTardosFullResampling](./PPGraphMoserTardosFullResampling.lean), [PPGraphShearerBDD](./PPGraphShearerBDD.lean), [PPGraphShearerSlack](./PPGraphShearerSlack.lean), [PPGraphHLSMatching](./PPGraphHLSMatching.lean) |
| [PPGraphMoserTardosExpectation](./PPGraphMoserTardosExpectation.lean) | 4 | [PPGraphMoserTardosCorrespondence](./PPGraphMoserTardosCorrespondence.lean) |
| [PPGraphMoserTardosFullResampling](./PPGraphMoserTardosFullResampling.lean) | 18 | [PPGraphMoserTardosDrift](./PPGraphMoserTardosDrift.lean), [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) |
| [PPGraphMoserTardosGrowing](./PPGraphMoserTardosGrowing.lean) | 8 | [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean) |
| [PPGraphMoserTardosHistoryPolicy](./PPGraphMoserTardosHistoryPolicy.lean) | 9 | [PPGraphMoserTardosPolicy](./PPGraphMoserTardosPolicy.lean) |
| [PPGraphMoserTardosInfeasibility](./PPGraphMoserTardosInfeasibility.lean) | 9 | [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean), [PPGraphUnsatisfiableCore](./PPGraphUnsatisfiableCore.lean), [PPGraphFiniteFeasibility](./PPGraphFiniteFeasibility.lean) |
| [PPGraphMoserTardosInjectivity](./PPGraphMoserTardosInjectivity.lean) | 14 | [PPGraphMoserTardosGrowing](./PPGraphMoserTardosGrowing.lean) |
| [PPGraphMoserTardosInjectivityBridge](./PPGraphMoserTardosInjectivityBridge.lean) | 7 | [PPGraphMoserTardosRealTree](./PPGraphMoserTardosRealTree.lean), [PPGraphMoserTardosCanonical](./PPGraphMoserTardosCanonical.lean), [PPGraphMoserTardosInjectivity](./PPGraphMoserTardosInjectivity.lean) |
| [PPGraphMoserTardosIntersection](./PPGraphMoserTardosIntersection.lean) | 13 | - |
| [PPGraphMoserTardosLabelsAtDepthBridge](./PPGraphMoserTardosLabelsAtDepthBridge.lean) | 5 | [PPGraphMoserTardosCheckInvariance](./PPGraphMoserTardosCheckInvariance.lean), [PPGraphMoserTardosWTreeToGrowingTree](./PPGraphMoserTardosWTreeToGrowingTree.lean) |
| [PPGraphMoserTardosLogSpace](./PPGraphMoserTardosLogSpace.lean) | 1 | [PPGraphMoserTardos](./PPGraphMoserTardos.lean) |
| [PPGraphMoserTardosOccurrence](./PPGraphMoserTardosOccurrence.lean) | 7 | [PPGraphMoserTardosRandomInitExpectation](./PPGraphMoserTardosRandomInitExpectation.lean), [PPGraphMoserTardosWTreeCountable](./PPGraphMoserTardosWTreeCountable.lean) |
| [PPGraphMoserTardosOccurrenceCounting](./PPGraphMoserTardosOccurrenceCounting.lean) | 3 | [PPGraphMoserTardosOccurrence](./PPGraphMoserTardosOccurrence.lean) |
| [PPGraphMoserTardosOccurrenceExpectation](./PPGraphMoserTardosOccurrenceExpectation.lean) | 7 | [PPGraphMoserTardosOccurrenceCounting](./PPGraphMoserTardosOccurrenceCounting.lean), [PPGraphMoserTardosOccurrenceProbability](./PPGraphMoserTardosOccurrenceProbability.lean), [PPGraphMoserTardosWitnessFamily](./PPGraphMoserTardosWitnessFamily.lean) |
| [PPGraphMoserTardosOccurrenceProbability](./PPGraphMoserTardosOccurrenceProbability.lean) | 4 | [PPGraphMoserTardosOccurrence](./PPGraphMoserTardosOccurrence.lean), [PPGraphMoserTardosCheckBridge](./PPGraphMoserTardosCheckBridge.lean), [PPGraphMoserTardosCheckShape](./PPGraphMoserTardosCheckShape.lean), [PPGraphMoserTardosProbabilityGeneral](./PPGraphMoserTardosProbabilityGeneral.lean) |
| [PPGraphMoserTardosPastIndependence](./PPGraphMoserTardosPastIndependence.lean) | 2 | [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) |
| [PPGraphMoserTardosPegden](./PPGraphMoserTardosPegden.lean) | 44 | [PPGraphMoserTardosOccurrenceExpectation](./PPGraphMoserTardosOccurrenceExpectation.lean), [PPGraphMoserTardosLabelsAtDepthBridge](./PPGraphMoserTardosLabelsAtDepthBridge.lean), [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean) |
| [PPGraphMoserTardosPolicy](./PPGraphMoserTardosPolicy.lean) | 14 | [PPGraphHLSRealDAGCounts](./PPGraphHLSRealDAGCounts.lean), [PPGraphMoserTardosTermination](./PPGraphMoserTardosTermination.lean), [PPGraphMoserTardosCounting](./PPGraphMoserTardosCounting.lean) |
| [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) | 15 | [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean), [PPGraphMoserTardosCheckBirth](./PPGraphMoserTardosCheckBirth.lean), [PPGraphMoserTardosLogSpace](./PPGraphMoserTardosLogSpace.lean) |
| [PPGraphMoserTardosProbabilityGeneral](./PPGraphMoserTardosProbabilityGeneral.lean) | 6 | [PPGraphMoserTardosCheckBirth](./PPGraphMoserTardosCheckBirth.lean), [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) |
| [PPGraphMoserTardosProcess](./PPGraphMoserTardosProcess.lean) | 2 | [PPGraphMoserTardos](./PPGraphMoserTardos.lean) |
| [PPGraphMoserTardosRandomInitExpectation](./PPGraphMoserTardosRandomInitExpectation.lean) | 14 | [PPGraphMoserTardosRandomInitialization](./PPGraphMoserTardosRandomInitialization.lean), [PPGraphMoserTardosResamplingCount](./PPGraphMoserTardosResamplingCount.lean) |
| [PPGraphMoserTardosRandomInitialization](./PPGraphMoserTardosRandomInitialization.lean) | 3 | [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) |
| [PPGraphMoserTardosRandomTrajectory](./PPGraphMoserTardosRandomTrajectory.lean) | 10 | [PPGraphMoserTardosLogSpace](./PPGraphMoserTardosLogSpace.lean), [PPGraphMoserTardosProcess](./PPGraphMoserTardosProcess.lean) |
| [PPGraphMoserTardosRealTree](./PPGraphMoserTardosRealTree.lean) | 13 | [PPGraphMoserTardosWeightSum](./PPGraphMoserTardosWeightSum.lean), [PPGraphMoserTardosCheckBirth](./PPGraphMoserTardosCheckBirth.lean), [PPGraphMoserTardosCheckOrder](./PPGraphMoserTardosCheckOrder.lean) |
| [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean) | 8 | [PPGraphRepair](./PPGraphRepair.lean), [PPGraphMoserTardosConstantLog](./PPGraphMoserTardosConstantLog.lean) |
| [PPGraphMoserTardosResamplingCount](./PPGraphMoserTardosResamplingCount.lean) | 14 | [PPGraphMoserTardosExpectation](./PPGraphMoserTardosExpectation.lean), [PPGraphMoserTardosInjectivityBridge](./PPGraphMoserTardosInjectivityBridge.lean) |
| [PPGraphMoserTardosTermination](./PPGraphMoserTardosTermination.lean) | 7 | [PPGraphMoserTardosOccurrenceExpectation](./PPGraphMoserTardosOccurrenceExpectation.lean) |
| [PPGraphMoserTardosToGrowingTreeCheckBridge](./PPGraphMoserTardosToGrowingTreeCheckBridge.lean) | 6 | [PPGraphMoserTardosWTreeToGrowingTree](./PPGraphMoserTardosWTreeToGrowingTree.lean), [PPGraphMoserTardosCheckInvariance](./PPGraphMoserTardosCheckInvariance.lean), [PPGraphMoserTardosCheckShape](./PPGraphMoserTardosCheckShape.lean), [PPGraphMoserTardosCheck](./PPGraphMoserTardosCheck.lean) |
| [PPGraphMoserTardosWTreeCountable](./PPGraphMoserTardosWTreeCountable.lean) | 1 | [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean) |
| [PPGraphMoserTardosWTreeToGrowingTree](./PPGraphMoserTardosWTreeToGrowingTree.lean) | 11 | [PPGraphMoserTardosGrowing](./PPGraphMoserTardosGrowing.lean), [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean), [PPGraphMoserTardosCheckOrder](./PPGraphMoserTardosCheckOrder.lean) |
| [PPGraphMoserTardosWeight](./PPGraphMoserTardosWeight.lean) | 3 | [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean) |
| [PPGraphMoserTardosWeightSum](./PPGraphMoserTardosWeightSum.lean) | 16 | [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean), [PPGraphMoserTardosWeight](./PPGraphMoserTardosWeight.lean), [PPGraphMoserTardosConvergence](./PPGraphMoserTardosConvergence.lean) |
| [PPGraphMoserTardosWitness](./PPGraphMoserTardosWitness.lean) | 5 | [PPGraphMoserTardosProcess](./PPGraphMoserTardosProcess.lean) |
| [PPGraphMoserTardosWitnessFamily](./PPGraphMoserTardosWitnessFamily.lean) | 6 | [PPGraphMoserTardosWeightSum](./PPGraphMoserTardosWeightSum.lean), [PPGraphMoserTardosConvergence](./PPGraphMoserTardosConvergence.lean) |
| [PPGraphParametric](./PPGraphParametric.lean) | 24 | - |
| [PPGraphParametricQuotient](./PPGraphParametricQuotient.lean) | 26 | [PPGraphParametric](./PPGraphParametric.lean), [PPGraphCategorical](./PPGraphCategorical.lean) |
| [PPGraphProbabilistic](./PPGraphProbabilistic.lean) | 6 | - |
| [PPGraphQuotientBridge](./PPGraphQuotientBridge.lean) | 5 | [PPGraphParametric](./PPGraphParametric.lean), [PPGraphParametricQuotient](./PPGraphParametricQuotient.lean), [PPGraphCategorical](./PPGraphCategorical.lean) |
| [PPGraphRR](./PPGraphRR.lean) | 9 | - |
| [PPGraphReachabilityRefutation](./PPGraphReachabilityRefutation.lean) | 12 | [PPGraphInfeasibility](./PPGraphInfeasibility.lean) |
| [PPGraphRepair](./PPGraphRepair.lean) | 8 | - |
| [PPGraphRepairDecision](./PPGraphRepairDecision.lean) | 13 | [PPGraphFiniteFeasibility](./PPGraphFiniteFeasibility.lean) |
| [PPGraphRepairUndecidability](./PPGraphRepairUndecidability.lean) | 14 | [PPGraphReachabilityRefutation](./PPGraphReachabilityRefutation.lean) |
| [PPGraphSelection](./PPGraphSelection.lean) | 23 | [PPGraphParametric](./PPGraphParametric.lean) |
| [PPGraphSelfAssessment](./PPGraphSelfAssessment.lean) | 12 | [PPGraphRepair](./PPGraphRepair.lean) |
| [PPGraphShearer](./PPGraphShearer.lean) | 9 | [PPGraphShearerPolynomial](./PPGraphShearerPolynomial.lean), [PPGraphShearerInduction](./PPGraphShearerInduction.lean), [PPGraphLopsidedLLL](./PPGraphLopsidedLLL.lean), [PPGraphShearerBDD](./PPGraphShearerBDD.lean) |
| [PPGraphShearerBDD](./PPGraphShearerBDD.lean) | 4 | [PPGraphShearerPolynomial](./PPGraphShearerPolynomial.lean), [PPGraphBDD](./PPGraphBDD.lean) |
| [PPGraphShearerBDDBudget](./PPGraphShearerBDDBudget.lean) | 8 | [PPGraphShearerStable](./PPGraphShearerStable.lean), [PPGraphShearerBDD](./PPGraphShearerBDD.lean) |
| [PPGraphShearerBDDExpectation](./PPGraphShearerBDDExpectation.lean) | 9 | [PPGraphBDDPartition](./PPGraphBDDPartition.lean), [PPGraphShearerBDDBudget](./PPGraphShearerBDDBudget.lean), [PPGraphShearerComponentOccurrence](./PPGraphShearerComponentOccurrence.lean) |
| [PPGraphShearerComponentOccurrence](./PPGraphShearerComponentOccurrence.lean) | 6 | [PPGraphShearerExpectation](./PPGraphShearerExpectation.lean) |
| [PPGraphShearerExpectation](./PPGraphShearerExpectation.lean) | 9 | [PPGraphShearerSequenceProbability](./PPGraphShearerSequenceProbability.lean), [PPGraphMoserTardosTermination](./PPGraphMoserTardosTermination.lean), [PPGraphLLL](./PPGraphLLL.lean) |
| [PPGraphShearerInduction](./PPGraphShearerInduction.lean) | 5 | - |
| [PPGraphShearerLayerProfile](./PPGraphShearerLayerProfile.lean) | 11 | [PPGraphShearerWitness](./PPGraphShearerWitness.lean) |
| [PPGraphShearerMT](./PPGraphShearerMT.lean) | 7 | [PPGraphShearer](./PPGraphShearer.lean), [PPGraphMoserTardosRepairBridge](./PPGraphMoserTardosRepairBridge.lean), [PPGraphMoserTardosProbability](./PPGraphMoserTardosProbability.lean) |
| [PPGraphShearerOccurrence](./PPGraphShearerOccurrence.lean) | 10 | [PPGraphShearerLayerProfile](./PPGraphShearerLayerProfile.lean), [PPGraphMoserTardosOccurrence](./PPGraphMoserTardosOccurrence.lean) |
| [PPGraphShearerPolynomial](./PPGraphShearerPolynomial.lean) | 14 | - |
| [PPGraphShearerSequenceProbability](./PPGraphShearerSequenceProbability.lean) | 8 | [PPGraphMoserTardosProbabilityGeneral](./PPGraphMoserTardosProbabilityGeneral.lean), [PPGraphMoserTardosOccurrenceProbability](./PPGraphMoserTardosOccurrenceProbability.lean), [PPGraphShearerOccurrence](./PPGraphShearerOccurrence.lean) |
| [PPGraphShearerSlack](./PPGraphShearerSlack.lean) | 10 | [PPGraphShearerStable](./PPGraphShearerStable.lean) |
| [PPGraphShearerSlackExpectation](./PPGraphShearerSlackExpectation.lean) | 2 | [PPGraphShearerSlack](./PPGraphShearerSlack.lean), [PPGraphShearerExpectation](./PPGraphShearerExpectation.lean) |
| [PPGraphShearerStable](./PPGraphShearerStable.lean) | 37 | [PPGraphShearerPolynomial](./PPGraphShearerPolynomial.lean) |
| [PPGraphShearerWitness](./PPGraphShearerWitness.lean) | 12 | [PPGraphShearerStable](./PPGraphShearerStable.lean), [PPGraphShearerBDD](./PPGraphShearerBDD.lean), [PPGraphMoserTardosLabelsAtDepthBridge](./PPGraphMoserTardosLabelsAtDepthBridge.lean) |
| [PPGraphUnsatisfiableCore](./PPGraphUnsatisfiableCore.lean) | 10 | [PPGraphInfeasibility](./PPGraphInfeasibility.lean) |
| [PPGraphVariableLLL](./PPGraphVariableLLL.lean) | 29 | - |
