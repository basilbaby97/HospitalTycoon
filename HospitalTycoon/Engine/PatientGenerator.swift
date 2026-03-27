import Foundation

struct PatientGenerator {
    private static let firstNames = [
        "Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason",
        "Isabella", "William", "Mia", "James", "Charlotte", "Benjamin", "Amelia",
        "Lucas", "Harper", "Henry", "Evelyn", "Alexander", "Abigail", "Daniel",
        "Emily", "Michael", "Elizabeth", "Sebastian", "Sofia", "Jack", "Avery",
        "Maria", "Jose", "Carmen", "Wei", "Min", "Arun", "Priya", "Fatima",
        "Ahmed", "Yuki", "Hiroshi", "Olga", "Boris", "Pierre", "Ingrid",
    ]

    private static let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
        "Davis", "Rodriguez", "Martinez", "Anderson", "Taylor", "Thomas", "Moore",
        "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Clark",
        "Lewis", "Robinson", "Walker", "Young", "King", "Wright", "Hill",
        "Chen", "Wang", "Patel", "Kim", "Nguyen", "Singh", "Santos",
        "Mueller", "Johansson", "O'Brien", "Kowalski", "Rossi", "Kumar",
    ]

    /// Maybe spawn a new patient this tick (called every game-hour)
    static func maybeSpawnPatient(_ state: GameState) {
        // Only spawn during operating hours (or ED always open)
        let hasED = !state.hospital.roomsOfType(.emergencyBay).isEmpty
        let isOperatingHours = state.currentHour >= GameConstants.operatingHoursStart &&
                               state.currentHour < GameConstants.operatingHoursEnd
        guard isOperatingHours || hasED else { return }

        // Must have a reception
        guard !state.hospital.roomsOfType(.reception).isEmpty else { return }

        // Calculate arrival rate based on reputation, contracts, and hospital size
        let baseRate = GameConstants.basePatientArrivalRate
        let reputationMultiplier = state.reputation / 50.0 // 1.0 at 50 reputation
        let contractMultiplier = Double(state.insuranceContracts.filter { $0.isActive }.count) / 4.0
        let hourlyRate = baseRate * reputationMultiplier * max(0.5, contractMultiplier) / Double(GameConstants.hoursPerDay)

        // Poisson-style: probability of at least one patient this hour
        let probability = min(0.8, hourlyRate)
        guard Double.random(in: 0...1) < probability else { return }

        // Generate patient
        let patient = generatePatient(state: state)
        state.patients.append(patient)
        state.totalPatientsServed += 1
    }

    static func generatePatient(state: GameState) -> Patient {
        let name = "\(firstNames.randomElement()!) \(lastNames.randomElement()!)"
        let age = Int.random(in: 18...85)
        let payerType = selectPayerType(state: state)
        let disease = selectDisease(state: state)
        let symptoms = SymptomDatabase.generatePresentingSymptoms(for: disease)

        return Patient(
            name: name,
            age: age,
            payerType: payerType,
            disease: disease,
            symptoms: symptoms,
            arrivalDay: state.currentDay,
            arrivalHour: state.currentHour
        )
    }

    private static func selectPayerType(state: GameState) -> PayerType {
        // Weight by active contracts + default payer mix
        let activeContracts = state.insuranceContracts.filter { $0.isActive }
        if !activeContracts.isEmpty {
            // Weighted by patient volume
            let totalVolume = activeContracts.reduce(0) { $0 + $1.patientVolume }
            let roll = Int.random(in: 0..<max(1, totalVolume))
            var cumulative = 0
            for contract in activeContracts {
                cumulative += contract.patientVolume
                if roll < cumulative {
                    return contract.payerType
                }
            }
        }

        // Fallback to default mix
        let roll = Double.random(in: 0...1)
        var cumulative = 0.0
        for (payer, weight) in GameConstants.defaultPayerMix {
            cumulative += weight
            if roll <= cumulative {
                return payer
            }
        }
        return .selfPay
    }

    private static func selectDisease(state: GameState) -> Disease {
        // Check for active events that affect disease distribution
        let hasFluSeason = state.activeEvents.contains { $0.type == .fluSeason && $0.isActive }

        if hasFluSeason && Double.random(in: 0...1) < 0.4 {
            // During flu season, 40% chance of respiratory illness
            let respiratory = DiseaseDatabase.all.filter {
                $0.department == .internalMedicine &&
                $0.symptoms.contains(where: { $0.symptom == .cough || $0.symptom == .fever })
            }
            if let disease = respiratory.randomElement() {
                return disease
            }
        }

        return DiseaseDatabase.randomDisease()
    }
}
