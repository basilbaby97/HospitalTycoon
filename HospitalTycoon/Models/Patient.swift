import Foundation

struct Patient: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int
    var payerType: PayerType
    var state: PatientState

    // Clinical
    var presentingSymptoms: [SymptomPresentation] // what brought them in
    var actualDisease: Disease // hidden from player until diagnosed
    var differentialDiagnosis: [DifferentialEntry] = [] // Bayesian probability list
    var confirmedDisease: Disease? // set when confidence > threshold
    var performedTests: [DiagnosticTestType] = []
    var testResults: [TestResult] = []
    var orderedTests: [DiagnosticTestType] = [] // tests queued but not yet done
    var currentTestInProgress: DiagnosticTestType?
    var testProgressTicks: Int = 0

    // Routing
    var currentRoomId: UUID?
    var assignedDoctorId: UUID?
    var arrivalDay: Int
    var arrivalHour: Int

    // Satisfaction
    var satisfaction: Double = 80.0 // 0-100
    var waitTimeHours: Int = 0

    // Treatment
    var treatmentProgressTicks: Int = 0
    var treatmentTotalTicks: Int = 0
    var isTreatmentSuccessful: Bool?

    init(name: String, age: Int, payerType: PayerType, disease: Disease, symptoms: [SymptomPresentation], arrivalDay: Int, arrivalHour: Int) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.payerType = payerType
        self.state = .arriving
        self.actualDisease = disease
        self.presentingSymptoms = symptoms
        self.arrivalDay = arrivalDay
        self.arrivalHour = arrivalHour
    }

    var hasConfirmedDiagnosis: Bool { confirmedDisease != nil }

    var topDifferential: DifferentialEntry? {
        differentialDiagnosis.max(by: { $0.probability < $1.probability })
    }

    var canConfirmDiagnosis: Bool {
        guard let top = topDifferential else { return false }
        return top.probability >= GameConstants.diagnosisConfidenceThreshold
    }
}

// MARK: - Patient State

enum PatientState: String, Codable {
    case arriving
    case waitingForRegistration
    case registered
    case waitingForExam
    case inExamination
    case awaitingTestResults
    case diagnosed
    case waitingForTreatment
    case inTreatment
    case admitted
    case recovering
    case discharged
    case deceased
}

// MARK: - Symptom Presentation

struct SymptomPresentation: Codable {
    let symptom: Symptom
    let severity: Double // 0-1 (how strongly presented)
}

// MARK: - Differential Diagnosis Entry

struct DifferentialEntry: Codable, Identifiable {
    var id: String { diseaseId }
    let diseaseId: String
    let diseaseName: String
    var probability: Double // 0.0 to 1.0
    var ruledOut: Bool = false
}

// MARK: - Test Result

struct TestResult: Codable {
    let testType: DiagnosticTestType
    let findings: String
    let isAbnormal: Bool
    let affectedDiseases: [String] // disease IDs whose probability changes
    let completedDay: Int
    let completedHour: Int
}

// MARK: - Symptom

enum Symptom: String, Codable, CaseIterable {
    case fever
    case cough
    case chestPain
    case headache
    case nausea
    case vomiting
    case fatigue
    case shortnessOfBreath
    case abdominalPain
    case dizziness
    case rash
    case jointPain
    case backPain
    case soreThroat
    case blurredVision
    case swelling
    case bruising
    case numbness
    case weightLoss
    case anxiety
    case insomnia
    case sweating
    case palpitations
    case urinarySymptoms
    case diarrhea
    case constipation
    case hipPain
    case inabilityToWalk

    var displayName: String {
        switch self {
        case .fever: return "Fever"
        case .cough: return "Cough"
        case .chestPain: return "Chest Pain"
        case .headache: return "Headache"
        case .nausea: return "Nausea"
        case .vomiting: return "Vomiting"
        case .fatigue: return "Fatigue"
        case .shortnessOfBreath: return "Shortness of Breath"
        case .abdominalPain: return "Abdominal Pain"
        case .dizziness: return "Dizziness"
        case .rash: return "Rash"
        case .jointPain: return "Joint Pain"
        case .backPain: return "Back Pain"
        case .soreThroat: return "Sore Throat"
        case .blurredVision: return "Blurred Vision"
        case .swelling: return "Swelling"
        case .bruising: return "Bruising"
        case .numbness: return "Numbness/Tingling"
        case .weightLoss: return "Weight Loss"
        case .anxiety: return "Anxiety"
        case .insomnia: return "Insomnia"
        case .sweating: return "Excessive Sweating"
        case .palpitations: return "Palpitations"
        case .urinarySymptoms: return "Urinary Symptoms"
        case .diarrhea: return "Diarrhea"
        case .constipation: return "Constipation"
        case .hipPain: return "Hip Pain"
        case .inabilityToWalk: return "Inability to Walk"
        }
    }
}
