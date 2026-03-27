import Foundation

enum GameConstants {
    // MARK: - Grid
    static let gridWidth = 60
    static let gridHeight = 60
    static let tileSize: CGFloat = 32.0

    // MARK: - Starting Values
    static let startingCash: Double = 5_000_000
    static let startingReputation: Double = 50.0

    // MARK: - Financial
    static let targetOperatingMargin = 0.04 // 4%
    static let laborCostPercentage = 0.45
    static let supplyCostPercentage = 0.15
    static let facilityCostPercentage = 0.10
    static let revenuePerOccupiedBedPerDay: Double = 2_500

    // MARK: - Revenue Cycle
    static let claimSubmissionDelay = 1 // days after discharge
    static let defaultDenialRate = 0.14 // 14%
    static let appealSuccessRate = 0.75 // 75%
    static let appealStaffTimeCost: Double = 500 // cost to process an appeal
    static let averageDaysInAR = 35

    // MARK: - Patients
    static let basePatientArrivalRate = 2.0 // patients per game-day at 50 reputation
    static let maxPatientArrivalRate = 20.0
    static let diagnosisConfidenceThreshold = 0.85 // 85% confidence to confirm diagnosis
    static let misdiagnosisPenalty: Double = -5.0 // reputation hit
    static let successfulTreatmentBonus: Double = 1.0 // reputation gain

    // MARK: - Staff
    static let maxStaffFatigue: Double = 100.0
    static let fatiguePerHour: Double = 4.0 // per working hour
    static let restRecoveryPerHour: Double = 10.0
    static let burnoutThreshold: Double = 80.0
    static let burnoutSkillPenalty: Double = 0.7 // 30% skill reduction when burnt out

    // MARK: - Equipment
    static let equipmentDegradationPerDay: Double = 0.1 // 0.1% condition loss per day
    static let maintenanceRestoreAmount: Double = 30.0
    static let equipmentFailureThreshold: Double = 10.0 // below this, equipment breaks

    // MARK: - Reputation
    static let minReputation: Double = 0.0
    static let maxReputation: Double = 100.0
    static let reputationDecayPerDay: Double = 0.1 // slow natural decay
    static let waitTimePenaltyPerHour: Double = -0.5

    // MARK: - Time
    static let hoursPerDay = 24
    static let daysPerMonth = 30
    static let monthsPerYear = 12
    static let operatingHoursStart = 6 // 6 AM
    static let operatingHoursEnd = 22 // 10 PM
    static let emergencyHours = true // ED always open

    // MARK: - Events
    static let eventCheckFrequencyDays = 3
    static let baseEventProbability = 0.15 // 15% chance per check

    // MARK: - Auto-save
    static let autoSaveIntervalDays = 5

    // MARK: - Payer Mix (% of patients by default)
    static let defaultPayerMix: [(PayerType, Double)] = [
        (.medicare, 0.30),
        (.medicaid, 0.15),
        (.medicareAdvantage, 0.10),
        (.unitedHealthcare, 0.12),
        (.anthem, 0.08),
        (.aetna, 0.07),
        (.cigna, 0.05),
        (.humana, 0.03),
        (.blueCrossBlueshield, 0.05),
        (.selfPay, 0.05),
    ]
}
