import Foundation

struct StaffTemplates {
    struct Template {
        let role: StaffRole
        let salaryRange: ClosedRange<Double>
        let baseSkillRange: ClosedRange<Double>
    }

    static let all: [Template] = [
        // Physicians
        Template(role: .generalPractitioner, salaryRange: 200_000...280_000, baseSkillRange: 0.5...0.9),
        Template(role: .emergencyPhysician, salaryRange: 265_000...420_000, baseSkillRange: 0.6...0.95),
        Template(role: .surgeon, salaryRange: 300_000...450_000, baseSkillRange: 0.5...0.95),
        Template(role: .cardiologist, salaryRange: 350_000...550_000, baseSkillRange: 0.6...0.95),
        Template(role: .orthopedicSurgeon, salaryRange: 400_000...650_000, baseSkillRange: 0.6...0.95),
        Template(role: .neurologist, salaryRange: 280_000...450_000, baseSkillRange: 0.5...0.9),
        Template(role: .oncologist, salaryRange: 300_000...500_000, baseSkillRange: 0.6...0.95),
        Template(role: .anesthesiologist, salaryRange: 350_000...500_000, baseSkillRange: 0.6...0.95),
        Template(role: .radiologist, salaryRange: 300_000...500_000, baseSkillRange: 0.5...0.9),
        Template(role: .pathologist, salaryRange: 250_000...400_000, baseSkillRange: 0.5...0.9),

        // Nursing
        Template(role: .registeredNurse, salaryRange: 70_000...120_000, baseSkillRange: 0.4...0.9),
        Template(role: .licensedPracticalNurse, salaryRange: 48_000...64_000, baseSkillRange: 0.4...0.8),
        Template(role: .nurseAssistant, salaryRange: 30_000...38_000, baseSkillRange: 0.3...0.7),
        Template(role: .nursePractitioner, salaryRange: 110_000...140_000, baseSkillRange: 0.6...0.95),

        // Other clinical
        Template(role: .pharmacist, salaryRange: 100_000...150_000, baseSkillRange: 0.5...0.9),
        Template(role: .labTechnician, salaryRange: 45_000...65_000, baseSkillRange: 0.4...0.85),

        // Non-clinical
        Template(role: .receptionist, salaryRange: 28_000...38_000, baseSkillRange: 0.4...0.8),
        Template(role: .administrator, salaryRange: 150_000...300_000, baseSkillRange: 0.5...0.9),
        Template(role: .janitor, salaryRange: 25_000...35_000, baseSkillRange: 0.3...0.7),
    ]

    static func template(for role: StaffRole) -> Template {
        all.first { $0.role == role }!
    }

    // MARK: - Name Generation

    private static let firstNames = [
        "James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
        "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
        "Thomas", "Sarah", "Christopher", "Karen", "Daniel", "Lisa", "Matthew", "Nancy",
        "Anthony", "Betty", "Mark", "Margaret", "Donald", "Sandra", "Steven", "Ashley",
        "Andrew", "Kimberly", "Paul", "Emily", "Joshua", "Donna", "Kenneth", "Michelle",
        "Carlos", "Maria", "Wei", "Aisha", "Raj", "Priya", "Ahmed", "Fatima",
        "Hiroshi", "Yuki", "Diego", "Sofia", "Omar", "Leila", "Andrei", "Elena",
    ]

    private static let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
        "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
        "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
        "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
        "Chen", "Wang", "Kim", "Patel", "Shah", "Singh", "Nguyen", "Tanaka",
        "Mueller", "Johansson", "O'Brien", "Kowalski", "Rossi", "Santos", "Kumar",
    ]

    static func generateCandidate(role: StaffRole, currentDay: Int) -> StaffMember {
        let template = self.template(for: role)
        let name = "\(firstNames.randomElement()!) \(lastNames.randomElement()!)"
        let skill = Double.random(in: template.baseSkillRange)
        let salary = Double.random(in: template.salaryRange)

        // Higher skill = higher salary expectation
        let adjustedSalary = salary * (0.8 + skill * 0.4) // skill modifies salary +-20%

        return StaffMember(
            name: name,
            role: role,
            skillLevel: skill,
            salary: adjustedSalary.rounded(),
            hireDay: currentDay
        )
    }

    static func generateCandidates(role: StaffRole, count: Int, currentDay: Int) -> [StaffMember] {
        (0..<count).map { _ in generateCandidate(role: role, currentDay: currentDay) }
    }
}
