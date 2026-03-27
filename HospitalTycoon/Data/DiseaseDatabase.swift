import Foundation

struct DiseaseDatabase {
    static let all: [Disease] = [
        // === RESPIRATORY ===
        Disease(
            id: "pneumonia", name: "Community-Acquired Pneumonia", drgCode: "DRG 193", icdCode: "J18.9",
            department: .internalMedicine, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .fever, probability: 0.90, weight: 0.8),
                DiseaseSymptom(symptom: .cough, probability: 0.95, weight: 0.9),
                DiseaseSymptom(symptom: .chestPain, probability: 0.60, weight: 0.5),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.70, weight: 0.7),
                DiseaseSymptom(symptom: .fatigue, probability: 0.50, weight: 0.3),
            ],
            requiredTests: [.completeBloodCount, .chestXRay, .bloodCulture],
            treatmentRoom: .generalWard, treatmentTicks: 72,
            baseMedicarePayment: 6_500, description: "Lung infection requiring antibiotics and monitoring",
            mortalityRisk: 0.05
        ),
        Disease(
            id: "copd-exacerbation", name: "COPD Exacerbation", drgCode: "DRG 190", icdCode: "J44.1",
            department: .internalMedicine, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.95, weight: 0.9),
                DiseaseSymptom(symptom: .cough, probability: 0.90, weight: 0.7),
                DiseaseSymptom(symptom: .fatigue, probability: 0.70, weight: 0.4),
                DiseaseSymptom(symptom: .chestPain, probability: 0.30, weight: 0.3),
            ],
            requiredTests: [.chestXRay, .arterialBloodGas, .completeBloodCount],
            treatmentRoom: .generalWard, treatmentTicks: 60,
            baseMedicarePayment: 5_800, description: "Acute worsening of chronic obstructive pulmonary disease",
            mortalityRisk: 0.04
        ),
        Disease(
            id: "bronchitis", name: "Acute Bronchitis", drgCode: "DRG 202", icdCode: "J20.9",
            department: .internalMedicine, severity: .mild,
            symptoms: [
                DiseaseSymptom(symptom: .cough, probability: 0.95, weight: 0.9),
                DiseaseSymptom(symptom: .fever, probability: 0.50, weight: 0.4),
                DiseaseSymptom(symptom: .chestPain, probability: 0.40, weight: 0.3),
                DiseaseSymptom(symptom: .fatigue, probability: 0.60, weight: 0.3),
                DiseaseSymptom(symptom: .soreThroat, probability: 0.40, weight: 0.3),
            ],
            requiredTests: [.completeBloodCount],
            treatmentRoom: .pharmacyDispensary, treatmentTicks: 2,
            baseMedicarePayment: 3_200, description: "Inflammation of bronchial tubes, usually viral",
            mortalityRisk: 0.01
        ),
        Disease(
            id: "asthma-attack", name: "Asthma Exacerbation", drgCode: "DRG 202", icdCode: "J45.21",
            department: .emergencyDepartment, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .cough, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .chestPain, probability: 0.50, weight: 0.4),
            ],
            requiredTests: [.chestXRay, .arterialBloodGas],
            treatmentRoom: .emergencyBay, treatmentTicks: 8,
            baseMedicarePayment: 4_500, description: "Acute asthma attack requiring emergency bronchodilator therapy",
            mortalityRisk: 0.02
        ),

        // === CARDIAC ===
        Disease(
            id: "acute-mi", name: "Acute Myocardial Infarction (Heart Attack)", drgCode: "DRG 280", icdCode: "I21.9",
            department: .cardiology, severity: .critical,
            symptoms: [
                DiseaseSymptom(symptom: .chestPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .nausea, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .sweating, probability: 0.70, weight: 0.7),
                DiseaseSymptom(symptom: .palpitations, probability: 0.50, weight: 0.5),
            ],
            requiredTests: [.ecg, .troponinLevel, .chestXRay, .completeBloodCount],
            treatmentRoom: .cathLab, treatmentTicks: 12,
            baseMedicarePayment: 15_000, description: "Blocked coronary artery requiring emergent catheterization",
            mortalityRisk: 0.15
        ),
        Disease(
            id: "heart-failure", name: "Congestive Heart Failure", drgCode: "DRG 291", icdCode: "I50.9",
            department: .cardiology, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .fatigue, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .swelling, probability: 0.75, weight: 0.8),
                DiseaseSymptom(symptom: .palpitations, probability: 0.50, weight: 0.5),
                DiseaseSymptom(symptom: .cough, probability: 0.40, weight: 0.3),
            ],
            requiredTests: [.ecg, .chestXRay, .completeBloodCount, .basicMetabolicPanel, .ultrasoundCardiac],
            treatmentRoom: .cardiacMonitoringUnit, treatmentTicks: 96,
            baseMedicarePayment: 8_500, description: "Heart unable to pump blood effectively",
            mortalityRisk: 0.08
        ),
        Disease(
            id: "atrial-fib", name: "Atrial Fibrillation", drgCode: "DRG 308", icdCode: "I48.91",
            department: .cardiology, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .palpitations, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.60, weight: 0.5),
                DiseaseSymptom(symptom: .dizziness, probability: 0.50, weight: 0.5),
                DiseaseSymptom(symptom: .fatigue, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .chestPain, probability: 0.30, weight: 0.3),
            ],
            requiredTests: [.ecg, .completeBloodCount, .basicMetabolicPanel],
            treatmentRoom: .cardiacMonitoringUnit, treatmentTicks: 24,
            baseMedicarePayment: 5_200, description: "Irregular heart rhythm requiring rate/rhythm control",
            mortalityRisk: 0.03
        ),

        // === GI / SURGICAL ===
        Disease(
            id: "appendicitis", name: "Acute Appendicitis", drgCode: "DRG 343", icdCode: "K35.80",
            department: .surgery, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .nausea, probability: 0.80, weight: 0.5),
                DiseaseSymptom(symptom: .vomiting, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .fever, probability: 0.60, weight: 0.4),
            ],
            requiredTests: [.completeBloodCount, .ctScanAbdomen],
            treatmentRoom: .operatingTheater, treatmentTicks: 6,
            baseMedicarePayment: 9_000, description: "Inflamed appendix requiring surgical removal",
            mortalityRisk: 0.02
        ),
        Disease(
            id: "cholecystitis", name: "Acute Cholecystitis", drgCode: "DRG 418", icdCode: "K81.0",
            department: .surgery, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.95, weight: 0.9),
                DiseaseSymptom(symptom: .nausea, probability: 0.75, weight: 0.5),
                DiseaseSymptom(symptom: .vomiting, probability: 0.50, weight: 0.3),
                DiseaseSymptom(symptom: .fever, probability: 0.50, weight: 0.4),
            ],
            requiredTests: [.completeBloodCount, .comprehensiveMetabolicPanel, .ultrasoundAbdomen],
            treatmentRoom: .operatingTheater, treatmentTicks: 6,
            baseMedicarePayment: 8_200, description: "Gallbladder inflammation, usually requires cholecystectomy",
            mortalityRisk: 0.02
        ),
        Disease(
            id: "gi-bleed", name: "GI Hemorrhage", drgCode: "DRG 377", icdCode: "K92.2",
            department: .surgery, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.70, weight: 0.6),
                DiseaseSymptom(symptom: .nausea, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .dizziness, probability: 0.60, weight: 0.5),
                DiseaseSymptom(symptom: .fatigue, probability: 0.70, weight: 0.5),
                DiseaseSymptom(symptom: .vomiting, probability: 0.50, weight: 0.4),
            ],
            requiredTests: [.completeBloodCount, .comprehensiveMetabolicPanel, .endoscopy],
            treatmentRoom: .operatingTheater, treatmentTicks: 8,
            baseMedicarePayment: 7_800, description: "Bleeding in the gastrointestinal tract",
            mortalityRisk: 0.06
        ),

        // === ORTHOPEDICS ===
        Disease(
            id: "hip-fracture", name: "Hip Fracture", drgCode: "DRG 480", icdCode: "S72.009A",
            department: .orthopedics, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .hipPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .swelling, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .inabilityToWalk, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .bruising, probability: 0.60, weight: 0.4),
            ],
            requiredTests: [.chestXRay, .completeBloodCount, .basicMetabolicPanel],
            treatmentRoom: .operatingTheater, treatmentTicks: 8,
            baseMedicarePayment: 12_000, description: "Fractured hip requiring surgical repair",
            mortalityRisk: 0.05
        ),
        Disease(
            id: "knee-osteoarthritis", name: "Severe Knee Osteoarthritis", drgCode: "DRG 469", icdCode: "M17.11",
            department: .orthopedics, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .jointPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .swelling, probability: 0.70, weight: 0.6),
                DiseaseSymptom(symptom: .inabilityToWalk, probability: 0.50, weight: 0.5),
            ],
            requiredTests: [.chestXRay, .completeBloodCount, .basicMetabolicPanel],
            treatmentRoom: .operatingTheater, treatmentTicks: 10,
            baseMedicarePayment: 20_000, description: "End-stage knee arthritis requiring total knee replacement",
            mortalityRisk: 0.01
        ),

        // === NEUROLOGY ===
        Disease(
            id: "stroke-ischemic", name: "Ischemic Stroke", drgCode: "DRG 061", icdCode: "I63.9",
            department: .neurology, severity: .critical,
            symptoms: [
                DiseaseSymptom(symptom: .headache, probability: 0.60, weight: 0.5),
                DiseaseSymptom(symptom: .numbness, probability: 0.85, weight: 0.9),
                DiseaseSymptom(symptom: .dizziness, probability: 0.70, weight: 0.6),
                DiseaseSymptom(symptom: .blurredVision, probability: 0.60, weight: 0.6),
                DiseaseSymptom(symptom: .inabilityToWalk, probability: 0.50, weight: 0.5),
            ],
            requiredTests: [.ctScanHead, .completeBloodCount, .basicMetabolicPanel, .ecg],
            treatmentRoom: .icuBay, treatmentTicks: 72,
            baseMedicarePayment: 11_000, description: "Blood clot blocking blood flow to the brain",
            mortalityRisk: 0.12
        ),
        Disease(
            id: "migraine", name: "Severe Migraine", drgCode: "DRG 102", icdCode: "G43.909",
            department: .neurology, severity: .mild,
            symptoms: [
                DiseaseSymptom(symptom: .headache, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .nausea, probability: 0.70, weight: 0.5),
                DiseaseSymptom(symptom: .blurredVision, probability: 0.50, weight: 0.5),
                DiseaseSymptom(symptom: .dizziness, probability: 0.40, weight: 0.3),
            ],
            requiredTests: [.ctScanHead],
            treatmentRoom: .pharmacyDispensary, treatmentTicks: 3,
            baseMedicarePayment: 2_800, description: "Severe headache requiring IV medication",
            mortalityRisk: 0.0
        ),

        // === INFECTIONS ===
        Disease(
            id: "sepsis", name: "Sepsis", drgCode: "DRG 871", icdCode: "A41.9",
            department: .intensiveCare, severity: .critical,
            symptoms: [
                DiseaseSymptom(symptom: .fever, probability: 0.90, weight: 0.8),
                DiseaseSymptom(symptom: .fatigue, probability: 0.80, weight: 0.5),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.60, weight: 0.5),
                DiseaseSymptom(symptom: .dizziness, probability: 0.50, weight: 0.4),
                DiseaseSymptom(symptom: .nausea, probability: 0.40, weight: 0.3),
                DiseaseSymptom(symptom: .sweating, probability: 0.60, weight: 0.5),
            ],
            requiredTests: [.completeBloodCount, .bloodCulture, .comprehensiveMetabolicPanel, .arterialBloodGas, .chestXRay],
            treatmentRoom: .icuBay, treatmentTicks: 120,
            baseMedicarePayment: 18_000, description: "Life-threatening systemic infection requiring ICU care",
            mortalityRisk: 0.20
        ),
        Disease(
            id: "uti", name: "Urinary Tract Infection", drgCode: "DRG 689", icdCode: "N39.0",
            department: .internalMedicine, severity: .mild,
            symptoms: [
                DiseaseSymptom(symptom: .urinarySymptoms, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .fever, probability: 0.40, weight: 0.3),
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.40, weight: 0.3),
                DiseaseSymptom(symptom: .nausea, probability: 0.20, weight: 0.2),
            ],
            requiredTests: [.urinalysis, .completeBloodCount],
            treatmentRoom: .pharmacyDispensary, treatmentTicks: 2,
            baseMedicarePayment: 3_000, description: "Bacterial infection of the urinary tract",
            mortalityRisk: 0.01
        ),
        Disease(
            id: "cellulitis", name: "Cellulitis", drgCode: "DRG 602", icdCode: "L03.90",
            department: .internalMedicine, severity: .mild,
            symptoms: [
                DiseaseSymptom(symptom: .rash, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .fever, probability: 0.50, weight: 0.4),
                DiseaseSymptom(symptom: .swelling, probability: 0.80, weight: 0.7),
            ],
            requiredTests: [.completeBloodCount],
            treatmentRoom: .pharmacyDispensary, treatmentTicks: 4,
            baseMedicarePayment: 4_200, description: "Skin infection requiring IV antibiotics",
            mortalityRisk: 0.01
        ),

        // === RENAL ===
        Disease(
            id: "kidney-stones", name: "Nephrolithiasis (Kidney Stones)", drgCode: "DRG 693", icdCode: "N20.0",
            department: .internalMedicine, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.90, weight: 0.8),
                DiseaseSymptom(symptom: .backPain, probability: 0.80, weight: 0.8),
                DiseaseSymptom(symptom: .nausea, probability: 0.70, weight: 0.4),
                DiseaseSymptom(symptom: .vomiting, probability: 0.50, weight: 0.3),
                DiseaseSymptom(symptom: .urinarySymptoms, probability: 0.60, weight: 0.6),
            ],
            requiredTests: [.urinalysis, .completeBloodCount, .ctScanAbdomen],
            treatmentRoom: .generalWard, treatmentTicks: 12,
            baseMedicarePayment: 5_500, description: "Kidney stones causing severe pain, may require intervention",
            mortalityRisk: 0.01
        ),
        Disease(
            id: "acute-kidney-injury", name: "Acute Kidney Injury", drgCode: "DRG 682", icdCode: "N17.9",
            department: .internalMedicine, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .fatigue, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .nausea, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .swelling, probability: 0.50, weight: 0.5),
                DiseaseSymptom(symptom: .urinarySymptoms, probability: 0.70, weight: 0.7),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.40, weight: 0.3),
            ],
            requiredTests: [.completeBloodCount, .comprehensiveMetabolicPanel, .urinalysis, .ultrasoundAbdomen],
            treatmentRoom: .generalWard, treatmentTicks: 72,
            baseMedicarePayment: 7_800, description: "Sudden decline in kidney function",
            mortalityRisk: 0.08
        ),

        // === PULMONARY EMBOLISM ===
        Disease(
            id: "pe", name: "Pulmonary Embolism", drgCode: "DRG 175", icdCode: "I26.99",
            department: .emergencyDepartment, severity: .critical,
            symptoms: [
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .chestPain, probability: 0.80, weight: 0.7),
                DiseaseSymptom(symptom: .palpitations, probability: 0.50, weight: 0.4),
                DiseaseSymptom(symptom: .dizziness, probability: 0.40, weight: 0.3),
                DiseaseSymptom(symptom: .cough, probability: 0.30, weight: 0.2),
            ],
            requiredTests: [.dDimer, .ctScanChest, .ecg, .completeBloodCount],
            treatmentRoom: .icuBay, treatmentTicks: 72,
            baseMedicarePayment: 10_500, description: "Blood clot in the lungs requiring anticoagulation",
            mortalityRisk: 0.10
        ),

        // === DIABETIC ===
        Disease(
            id: "dka", name: "Diabetic Ketoacidosis", drgCode: "DRG 637", icdCode: "E11.10",
            department: .internalMedicine, severity: .severe,
            symptoms: [
                DiseaseSymptom(symptom: .nausea, probability: 0.80, weight: 0.6),
                DiseaseSymptom(symptom: .vomiting, probability: 0.70, weight: 0.5),
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.60, weight: 0.4),
                DiseaseSymptom(symptom: .shortnessOfBreath, probability: 0.50, weight: 0.4),
                DiseaseSymptom(symptom: .fatigue, probability: 0.70, weight: 0.4),
            ],
            requiredTests: [.completeBloodCount, .comprehensiveMetabolicPanel, .arterialBloodGas, .urinalysis],
            treatmentRoom: .icuBay, treatmentTicks: 48,
            baseMedicarePayment: 7_200, description: "Dangerous complication of diabetes with high blood sugar and acidosis",
            mortalityRisk: 0.05
        ),

        // === GI MEDICAL ===
        Disease(
            id: "pancreatitis", name: "Acute Pancreatitis", drgCode: "DRG 438", icdCode: "K85.9",
            department: .internalMedicine, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .abdominalPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .nausea, probability: 0.85, weight: 0.5),
                DiseaseSymptom(symptom: .vomiting, probability: 0.70, weight: 0.4),
                DiseaseSymptom(symptom: .fever, probability: 0.40, weight: 0.3),
            ],
            requiredTests: [.completeBloodCount, .comprehensiveMetabolicPanel, .ctScanAbdomen],
            treatmentRoom: .generalWard, treatmentTicks: 72,
            baseMedicarePayment: 6_800, description: "Inflammation of the pancreas, usually from gallstones or alcohol",
            mortalityRisk: 0.04
        ),

        // === DVT ===
        Disease(
            id: "dvt", name: "Deep Vein Thrombosis", drgCode: "DRG 294", icdCode: "I82.409",
            department: .internalMedicine, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .swelling, probability: 0.90, weight: 0.9),
                DiseaseSymptom(symptom: .jointPain, probability: 0.70, weight: 0.6),
                DiseaseSymptom(symptom: .numbness, probability: 0.30, weight: 0.3),
            ],
            requiredTests: [.dDimer, .ultrasoundAbdomen, .completeBloodCount],
            treatmentRoom: .generalWard, treatmentTicks: 24,
            baseMedicarePayment: 5_000, description: "Blood clot in a deep vein, risk of pulmonary embolism",
            mortalityRisk: 0.02
        ),

        // === BACK PAIN ===
        Disease(
            id: "disc-herniation", name: "Lumbar Disc Herniation", drgCode: "DRG 551", icdCode: "M51.16",
            department: .orthopedics, severity: .moderate,
            symptoms: [
                DiseaseSymptom(symptom: .backPain, probability: 0.95, weight: 0.95),
                DiseaseSymptom(symptom: .numbness, probability: 0.70, weight: 0.7),
                DiseaseSymptom(symptom: .inabilityToWalk, probability: 0.30, weight: 0.4),
            ],
            requiredTests: [.mriSpine, .completeBloodCount],
            treatmentRoom: .generalWard, treatmentTicks: 24,
            baseMedicarePayment: 8_000, description: "Herniated disc causing nerve compression",
            mortalityRisk: 0.0
        ),
    ]

    static func find(id: String) -> Disease? {
        all.first { $0.id == id }
    }

    static func diseases(for department: Department) -> [Disease] {
        all.filter { $0.department == department }
    }

    static func diseasesWithSymptom(_ symptom: Symptom) -> [Disease] {
        all.filter { disease in
            disease.symptoms.contains { $0.symptom == symptom }
        }
    }

    /// Returns a random disease weighted by severity (more common diseases more likely)
    static func randomDisease() -> Disease {
        let weights: [DiseaseSeverity: Double] = [
            .mild: 0.35, .moderate: 0.35, .severe: 0.20, .critical: 0.10
        ]

        let roll = Double.random(in: 0...1)
        var cumulative = 0.0
        var targetSeverity: DiseaseSeverity = .mild

        for (severity, weight) in weights.sorted(by: { $0.value > $1.value }) {
            cumulative += weight
            if roll <= cumulative {
                targetSeverity = severity
                break
            }
        }

        let candidates = all.filter { $0.severity == targetSeverity }
        return candidates.randomElement() ?? all[0]
    }
}
