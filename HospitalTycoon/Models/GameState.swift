import Foundation
import Observation

@Observable
final class GameState: Codable {
    // MARK: - Hospital
    var hospital: Hospital
    var hospitalName: String

    // MARK: - Staff
    var staff: [StaffMember] = []

    // MARK: - Patients
    var patients: [Patient] = []
    var patientQueue: [UUID] = []

    // MARK: - Finance
    var finance: Finance
    var claims: [InsuranceClaim] = []
    var insuranceContracts: [InsuranceContract] = []

    // MARK: - Time
    var currentDay: Int = 1
    var currentHour: Int = 8
    var currentMonth: Int = 1
    var currentYear: Int = 2026
    var isPaused: Bool = true
    var gameSpeed: GameSpeed = .normal

    // MARK: - Reputation
    var reputation: Double = 50.0
    var totalPatientsServed: Int = 0
    var totalPatientsDischarged: Int = 0
    var totalMisdiagnoses: Int = 0

    // MARK: - Events
    var activeEvents: [GameEvent] = []
    var eventLog: [GameEvent] = []

    // MARK: - Build Mode
    var selectedBuildItem: BuildItem?
    var isInBuildMode: Bool = false

    init(hospitalName: String = "General Hospital") {
        self.hospitalName = hospitalName
        self.hospital = Hospital()
        self.finance = Finance(cashBalance: 5_000_000)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case hospital, hospitalName, staff, patients, patientQueue
        case finance, claims, insuranceContracts
        case currentDay, currentHour, currentMonth, currentYear
        case isPaused, gameSpeed, reputation
        case totalPatientsServed, totalPatientsDischarged, totalMisdiagnoses
        case activeEvents, eventLog
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hospital = try c.decode(Hospital.self, forKey: .hospital)
        hospitalName = try c.decode(String.self, forKey: .hospitalName)
        staff = try c.decode([StaffMember].self, forKey: .staff)
        patients = try c.decode([Patient].self, forKey: .patients)
        patientQueue = try c.decode([UUID].self, forKey: .patientQueue)
        finance = try c.decode(Finance.self, forKey: .finance)
        claims = try c.decode([InsuranceClaim].self, forKey: .claims)
        insuranceContracts = try c.decode([InsuranceContract].self, forKey: .insuranceContracts)
        currentDay = try c.decode(Int.self, forKey: .currentDay)
        currentHour = try c.decode(Int.self, forKey: .currentHour)
        currentMonth = try c.decode(Int.self, forKey: .currentMonth)
        currentYear = try c.decode(Int.self, forKey: .currentYear)
        isPaused = try c.decode(Bool.self, forKey: .isPaused)
        gameSpeed = try c.decode(GameSpeed.self, forKey: .gameSpeed)
        reputation = try c.decode(Double.self, forKey: .reputation)
        totalPatientsServed = try c.decode(Int.self, forKey: .totalPatientsServed)
        totalPatientsDischarged = try c.decode(Int.self, forKey: .totalPatientsDischarged)
        totalMisdiagnoses = try c.decode(Int.self, forKey: .totalMisdiagnoses)
        activeEvents = try c.decode([GameEvent].self, forKey: .activeEvents)
        eventLog = try c.decode([GameEvent].self, forKey: .eventLog)
        selectedBuildItem = nil
        isInBuildMode = false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(hospital, forKey: .hospital)
        try c.encode(hospitalName, forKey: .hospitalName)
        try c.encode(staff, forKey: .staff)
        try c.encode(patients, forKey: .patients)
        try c.encode(patientQueue, forKey: .patientQueue)
        try c.encode(finance, forKey: .finance)
        try c.encode(claims, forKey: .claims)
        try c.encode(insuranceContracts, forKey: .insuranceContracts)
        try c.encode(currentDay, forKey: .currentDay)
        try c.encode(currentHour, forKey: .currentHour)
        try c.encode(currentMonth, forKey: .currentMonth)
        try c.encode(currentYear, forKey: .currentYear)
        try c.encode(isPaused, forKey: .isPaused)
        try c.encode(gameSpeed, forKey: .gameSpeed)
        try c.encode(reputation, forKey: .reputation)
        try c.encode(totalPatientsServed, forKey: .totalPatientsServed)
        try c.encode(totalPatientsDischarged, forKey: .totalPatientsDischarged)
        try c.encode(totalMisdiagnoses, forKey: .totalMisdiagnoses)
        try c.encode(activeEvents, forKey: .activeEvents)
        try c.encode(eventLog, forKey: .eventLog)
    }

    // MARK: - Computed

    var formattedDate: String {
        String(format: "%02d/%02d/%04d %02d:00", currentMonth, currentDay, currentYear, currentHour)
    }

    var totalStaffCostPerYear: Double {
        staff.reduce(0) { $0 + $1.annualSalary }
    }

    var occupiedBeds: Int {
        patients.filter { $0.state == .admitted || $0.state == .inTreatment }.count
    }
}

// MARK: - Supporting Types

enum GameSpeed: String, Codable, CaseIterable {
    case normal = "1x"
    case fast = "2x"
    case veryFast = "3x"

    var tickInterval: TimeInterval {
        switch self {
        case .normal: return 1.0
        case .fast: return 0.5
        case .veryFast: return 0.25
        }
    }
}

enum BuildItem: Codable, Equatable {
    case room(RoomType)
    case equipment(String) // equipment template ID
}

struct GameEvent: Codable, Identifiable {
    let id: UUID
    let type: GameEventType
    let title: String
    let description: String
    let dayOccurred: Int
    var isActive: Bool
    var durationDays: Int

    init(type: GameEventType, title: String, description: String, dayOccurred: Int, durationDays: Int = 0) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.dayOccurred = dayOccurred
        self.isActive = true
        self.durationDays = durationDays
    }
}

enum GameEventType: String, Codable {
    case fluSeason
    case equipmentFailure
    case cmsAudit
    case staffBurnout
    case vipPatient
    case malpracticeLawsuit
    case insuranceRenegotiation
    case jointCommissionInspection
    case communityOutbreak
    case donation
}
