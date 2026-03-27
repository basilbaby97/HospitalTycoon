import Foundation

// MARK: - Payer Type

enum PayerType: String, Codable, CaseIterable, Identifiable {
    case medicare
    case medicaid
    case medicareAdvantage
    case unitedHealthcare
    case anthem
    case aetna
    case cigna
    case humana
    case blueCrossBlueshield
    case selfPay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .medicare: return "Medicare"
        case .medicaid: return "Medicaid"
        case .medicareAdvantage: return "Medicare Advantage"
        case .unitedHealthcare: return "UnitedHealthcare"
        case .anthem: return "Anthem/Elevance"
        case .aetna: return "Aetna"
        case .cigna: return "Cigna"
        case .humana: return "Humana"
        case .blueCrossBlueshield: return "Blue Cross Blue Shield"
        case .selfPay: return "Self-Pay"
        }
    }

    /// Reimbursement rate relative to Medicare baseline (1.0 = 100%)
    var baseReimbursementRate: Double {
        switch self {
        case .medicare: return 1.00
        case .medicaid: return 0.90
        case .medicareAdvantage: return 1.10
        case .unitedHealthcare: return 1.37
        case .anthem: return 1.35
        case .aetna: return 1.30
        case .cigna: return 1.33
        case .humana: return 1.25
        case .blueCrossBlueshield: return 1.40
        case .selfPay: return 2.50 // Full charges but low collection
        }
    }

    /// Expected collection rate (% of billed amount actually collected)
    var collectionRate: Double {
        switch self {
        case .selfPay: return 0.20
        default: return 0.95
        }
    }

    /// Average days to process a claim
    var avgProcessingDays: Int {
        switch self {
        case .medicare: return 21
        case .medicaid: return 38
        case .medicareAdvantage: return 17
        case .unitedHealthcare: return 25
        case .anthem: return 25
        case .aetna: return 17
        case .cigna: return 25
        case .humana: return 17
        case .blueCrossBlueshield: return 22
        case .selfPay: return 0 // Collected at time of service or billed
        }
    }

    /// Base denial rate
    var denialRate: Double {
        switch self {
        case .medicare: return 0.10
        case .medicaid: return 0.18
        case .medicareAdvantage: return 0.15
        case .unitedHealthcare: return 0.16
        case .anthem: return 0.14
        case .aetna: return 0.12
        case .cigna: return 0.15
        case .humana: return 0.13
        case .blueCrossBlueshield: return 0.11
        case .selfPay: return 0.0
        }
    }

    var isGovernment: Bool {
        switch self {
        case .medicare, .medicaid, .medicareAdvantage: return true
        default: return false
        }
    }
}

// MARK: - Insurance Contract

struct InsuranceContract: Codable, Identifiable {
    let id: UUID
    let payerType: PayerType
    var negotiatedRate: Double // Multiplier on Medicare baseline
    var contractStartDay: Int
    var contractDurationDays: Int
    var isActive: Bool
    var patientVolume: Int // Expected patients per month

    init(payerType: PayerType, negotiatedRate: Double? = nil, startDay: Int, durationDays: Int = 365, patientVolume: Int = 10) {
        self.id = UUID()
        self.payerType = payerType
        self.negotiatedRate = negotiatedRate ?? payerType.baseReimbursementRate
        self.contractStartDay = startDay
        self.contractDurationDays = durationDays
        self.isActive = true
        self.patientVolume = patientVolume
    }

    var expirationDay: Int {
        contractStartDay + contractDurationDays
    }

    func reimbursementForMedicareBase(_ medicareAmount: Double) -> Double {
        medicareAmount * negotiatedRate
    }
}
