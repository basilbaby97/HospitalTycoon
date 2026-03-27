import Foundation

struct InsuranceClaim: Codable, Identifiable {
    let id: UUID
    let patientId: UUID
    let patientName: String
    let payerType: PayerType
    let drgCode: String
    let drgDescription: String
    let cptCodes: [String]
    let totalCharges: Double
    let expectedReimbursement: Double
    var status: ClaimStatus
    let submittedDay: Int
    var adjudicationDay: Int? // day when decision is made
    var paidDay: Int?
    var actualPayment: Double?
    var denialReason: DenialReason?
    var appealStatus: AppealStatus?

    init(
        patientId: UUID,
        patientName: String,
        payerType: PayerType,
        drgCode: String,
        drgDescription: String,
        cptCodes: [String],
        totalCharges: Double,
        expectedReimbursement: Double,
        submittedDay: Int
    ) {
        self.id = UUID()
        self.patientId = patientId
        self.patientName = patientName
        self.payerType = payerType
        self.drgCode = drgCode
        self.drgDescription = drgDescription
        self.cptCodes = cptCodes
        self.totalCharges = totalCharges
        self.expectedReimbursement = expectedReimbursement
        self.status = .submitted
        self.submittedDay = submittedDay
    }

    var daysOutstanding: Int? {
        guard let adjDay = adjudicationDay else { return nil }
        return adjDay - submittedDay
    }

    var isResolved: Bool {
        status == .paid || status == .deniedFinal || status == .writtenOff
    }
}

enum ClaimStatus: String, Codable {
    case submitted       // Sent to payer
    case adjudicating    // Under review
    case paid            // Payment received
    case denied          // Denied - can appeal
    case appealed        // Under appeal
    case appealApproved  // Appeal successful - awaiting payment
    case deniedFinal     // Denied after appeal
    case writtenOff      // Bad debt write-off
}

enum DenialReason: String, Codable, CaseIterable {
    case missingDocumentation = "Missing Documentation"
    case priorAuthRequired = "Prior Authorization Required"
    case medicalNecessity = "Medical Necessity Not Established"
    case codingError = "Coding Error"
    case duplicateClaim = "Duplicate Claim"
    case timeLimitExceeded = "Filing Time Limit Exceeded"
    case outOfNetwork = "Out of Network"
    case benefitExhausted = "Benefits Exhausted"

    var appealSuccessRate: Double {
        switch self {
        case .missingDocumentation: return 0.85
        case .priorAuthRequired: return 0.70
        case .medicalNecessity: return 0.60
        case .codingError: return 0.90
        case .duplicateClaim: return 0.50
        case .timeLimitExceeded: return 0.30
        case .outOfNetwork: return 0.40
        case .benefitExhausted: return 0.20
        }
    }
}

enum AppealStatus: String, Codable {
    case preparing
    case submitted
    case underReview
    case approved
    case denied
}
