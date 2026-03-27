import Foundation

struct SymptomDatabase {
    /// Returns all diseases that can present with a given set of symptoms,
    /// along with a rough prior probability based on symptom match
    static func initialDifferential(for symptoms: [SymptomPresentation]) -> [DifferentialEntry] {
        let symptomSet = Set(symptoms.map { $0.symptom })
        var entries: [DifferentialEntry] = []

        for disease in DiseaseDatabase.all {
            let diseaseSymptoms = Set(disease.symptoms.map { $0.symptom })
            let overlap = symptomSet.intersection(diseaseSymptoms)

            guard !overlap.isEmpty else { continue }

            // Calculate match score based on symptom weights
            var score = 0.0
            var totalWeight = 0.0

            for ds in disease.symptoms {
                totalWeight += ds.weight
                if let presentation = symptoms.first(where: { $0.symptom == ds.symptom }) {
                    score += ds.weight * ds.probability * presentation.severity
                }
            }

            // Penalize for symptoms the patient has that aren't in this disease
            let unexplainedSymptoms = symptomSet.subtracting(diseaseSymptoms)
            let unexplainedPenalty = Double(unexplainedSymptoms.count) * 0.1

            let rawProbability = max(0.01, (score / max(totalWeight, 1.0)) - unexplainedPenalty)

            entries.append(DifferentialEntry(
                diseaseId: disease.id,
                diseaseName: disease.name,
                probability: rawProbability
            ))
        }

        // Normalize probabilities to sum to 1.0
        let total = entries.reduce(0.0) { $0 + $1.probability }
        if total > 0 {
            for i in entries.indices {
                entries[i].probability /= total
            }
        }

        // Sort by probability descending, limit to top 8
        entries.sort { $0.probability > $1.probability }
        return Array(entries.prefix(8))
    }

    /// Update differential diagnosis based on a test result
    static func updateDifferential(
        current: [DifferentialEntry],
        testType: DiagnosticTestType,
        actualDisease: Disease,
        doctorSkill: Double
    ) -> [DifferentialEntry] {
        var updated = current

        // Determine if test is "positive" for the actual disease
        let testIsRelevant = actualDisease.requiredTests.contains(testType)

        for i in updated.indices {
            guard !updated[i].ruledOut else { continue }

            let disease = DiseaseDatabase.find(id: updated[i].diseaseId)
            let thisDiseasNeedsTest = disease?.requiredTests.contains(testType) ?? false

            if testIsRelevant {
                // Test is relevant to actual disease
                if updated[i].diseaseId == actualDisease.id {
                    // Boost the actual disease (with some noise based on doctor skill)
                    let boost = 0.15 + (doctorSkill * 0.15) // 15-30% boost
                    let noise = Double.random(in: -0.05...0.05) * (1.0 - doctorSkill)
                    updated[i].probability = min(0.99, updated[i].probability + boost + noise)
                } else if thisDiseasNeedsTest {
                    // Other diseases that also need this test - small boost (false positive potential)
                    let smallBoost = 0.03 * (1.0 - doctorSkill)
                    updated[i].probability = min(0.95, updated[i].probability + smallBoost)
                } else {
                    // Diseases that don't need this test - reduce
                    let reduction = 0.05 + (doctorSkill * 0.05)
                    updated[i].probability = max(0.01, updated[i].probability - reduction)
                }
            } else {
                // Test is not relevant to actual disease (negative/normal result)
                if thisDiseasNeedsTest {
                    // Negative result for a disease that needs this test - reduce that disease
                    let reduction = 0.08 + (doctorSkill * 0.07)
                    updated[i].probability = max(0.01, updated[i].probability - reduction)

                    // Rule out if probability drops very low
                    if updated[i].probability < 0.03 {
                        updated[i].ruledOut = true
                        updated[i].probability = 0
                    }
                }
            }
        }

        // Renormalize
        let activeEntries = updated.filter { !$0.ruledOut }
        let total = activeEntries.reduce(0.0) { $0 + $1.probability }
        if total > 0 {
            for i in updated.indices where !updated[i].ruledOut {
                updated[i].probability /= total
            }
        }

        updated.sort { $0.probability > $1.probability }
        return updated
    }

    /// Generate the symptom set a patient presents with for a given disease
    static func generatePresentingSymptoms(for disease: Disease) -> [SymptomPresentation] {
        var symptoms: [SymptomPresentation] = []

        for ds in disease.symptoms {
            // Each symptom has a probability of presenting
            if Double.random(in: 0...1) < ds.probability {
                let severity = Double.random(in: 0.3...1.0) * ds.weight
                symptoms.append(SymptomPresentation(
                    symptom: ds.symptom,
                    severity: severity
                ))
            }
        }

        // Ensure at least 2 symptoms present
        if symptoms.count < 2 {
            let remaining = disease.symptoms.filter { ds in
                !symptoms.contains { $0.symptom == ds.symptom }
            }
            for ds in remaining.prefix(2 - symptoms.count) {
                symptoms.append(SymptomPresentation(
                    symptom: ds.symptom,
                    severity: Double.random(in: 0.3...0.7)
                ))
            }
        }

        // Occasionally add a "noise" symptom not related to the disease
        if Double.random(in: 0...1) < 0.2 {
            let diseaseSymptoms = Set(disease.symptoms.map { $0.symptom })
            let noiseSymptoms = Symptom.allCases.filter { !diseaseSymptoms.contains($0) }
            if let noise = noiseSymptoms.randomElement() {
                symptoms.append(SymptomPresentation(symptom: noise, severity: Double.random(in: 0.2...0.5)))
            }
        }

        return symptoms
    }
}
