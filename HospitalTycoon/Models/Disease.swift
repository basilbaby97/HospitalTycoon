import Foundation

struct Disease: Codable, Identifiable {
    let id: String // unique identifier
    let name: String
    let drgCode: String
    let icdCode: String
    let department: Department
    let severity: DiseaseSeverity
    let symptoms: [DiseaseSymptom] // symptoms and their probability of presenting
    let requiredTests: [DiagnosticTestType] // tests needed to diagnose
    let treatmentRoom: RoomType
    let treatmentTicks: Int // how long treatment takes
    let baseMedicarePayment: Double // DRG base payment
    let description: String
    let mortalityRisk: Double // 0-1, chance of death if untreated or misdiagnosed
}

struct DiseaseSymptom: Codable {
    let symptom: Symptom
    let probability: Double // 0-1, chance this symptom presents
    let weight: Double // how strongly this symptom indicates this disease
}

enum DiseaseSeverity: String, Codable {
    case mild
    case moderate
    case severe
    case critical

    var treatmentTimeMultiplier: Double {
        switch self {
        case .mild: return 1.0
        case .moderate: return 1.5
        case .severe: return 2.0
        case .critical: return 3.0
        }
    }

    var reputationImpact: Double {
        switch self {
        case .mild: return 0.5
        case .moderate: return 1.0
        case .severe: return 2.0
        case .critical: return 3.0
        }
    }
}
