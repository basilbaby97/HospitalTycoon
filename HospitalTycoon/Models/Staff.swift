import Foundation

struct StaffMember: Codable, Identifiable {
    let id: UUID
    var name: String
    var role: StaffRole
    var skillLevel: Double // 0.0 to 1.0
    var annualSalary: Double
    var assignedRoomId: UUID?
    var assignedDepartment: Department?
    var fatigue: Double = 0.0 // 0-100
    var satisfaction: Double = 75.0 // 0-100
    var hireDay: Int
    var isOnDuty: Bool = true
    var currentTaskId: UUID?

    var isExhausted: Bool { fatigue >= GameConstants.burnoutThreshold }
    var effectiveSkill: Double {
        isExhausted ? skillLevel * GameConstants.burnoutSkillPenalty : skillLevel
    }
    var dailySalary: Double { annualSalary / 365.0 }
    var hourlySalary: Double { dailySalary / 8.0 } // 8-hour shifts

    init(name: String, role: StaffRole, skillLevel: Double, salary: Double, hireDay: Int) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.skillLevel = skillLevel
        self.annualSalary = salary
        self.hireDay = hireDay
    }
}

// MARK: - Staff Roles

enum StaffRole: String, Codable, CaseIterable, Identifiable {
    // Physicians
    case generalPractitioner
    case emergencyPhysician
    case surgeon
    case cardiologist
    case orthopedicSurgeon
    case neurologist
    case oncologist
    case anesthesiologist
    case radiologist
    case pathologist

    // Nursing
    case registeredNurse
    case licensedPracticalNurse
    case nurseAssistant
    case nursePractitioner

    // Other clinical
    case pharmacist
    case labTechnician

    // Non-clinical
    case receptionist
    case administrator
    case janitor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .generalPractitioner: return "General Practitioner"
        case .emergencyPhysician: return "Emergency Physician"
        case .surgeon: return "Surgeon"
        case .cardiologist: return "Cardiologist"
        case .orthopedicSurgeon: return "Orthopedic Surgeon"
        case .neurologist: return "Neurologist"
        case .oncologist: return "Oncologist"
        case .anesthesiologist: return "Anesthesiologist"
        case .radiologist: return "Radiologist"
        case .pathologist: return "Pathologist"
        case .registeredNurse: return "Registered Nurse"
        case .licensedPracticalNurse: return "Licensed Practical Nurse"
        case .nurseAssistant: return "Certified Nursing Assistant"
        case .nursePractitioner: return "Nurse Practitioner"
        case .pharmacist: return "Pharmacist"
        case .labTechnician: return "Lab Technician"
        case .receptionist: return "Receptionist"
        case .administrator: return "Administrator"
        case .janitor: return "Janitor"
        }
    }

    var shortName: String {
        switch self {
        case .generalPractitioner: return "GP"
        case .emergencyPhysician: return "ER Doc"
        case .surgeon: return "Surgeon"
        case .cardiologist: return "Cardio"
        case .orthopedicSurgeon: return "Ortho"
        case .neurologist: return "Neuro"
        case .oncologist: return "Onco"
        case .anesthesiologist: return "Anesth"
        case .radiologist: return "Rad"
        case .pathologist: return "Path"
        case .registeredNurse: return "RN"
        case .licensedPracticalNurse: return "LPN"
        case .nurseAssistant: return "CNA"
        case .nursePractitioner: return "NP"
        case .pharmacist: return "PharmD"
        case .labTechnician: return "Lab Tech"
        case .receptionist: return "Recept"
        case .administrator: return "Admin"
        case .janitor: return "Janitor"
        }
    }

    var spriteLabel: String {
        switch self {
        case .generalPractitioner: return "GP"
        case .emergencyPhysician: return "ER"
        case .surgeon: return "SG"
        case .cardiologist: return "CD"
        case .orthopedicSurgeon: return "OR"
        case .neurologist: return "NR"
        case .oncologist: return "ON"
        case .anesthesiologist: return "AN"
        case .radiologist: return "RD"
        case .pathologist: return "PT"
        case .registeredNurse: return "RN"
        case .licensedPracticalNurse: return "LP"
        case .nurseAssistant: return "CA"
        case .nursePractitioner: return "NP"
        case .pharmacist: return "PH"
        case .labTechnician: return "LT"
        case .receptionist: return "RC"
        case .administrator: return "AD"
        case .janitor: return "JN"
        }
    }

    var isPhysician: Bool {
        switch self {
        case .generalPractitioner, .emergencyPhysician, .surgeon, .cardiologist,
             .orthopedicSurgeon, .neurologist, .oncologist, .anesthesiologist,
             .radiologist, .pathologist:
            return true
        default:
            return false
        }
    }

    var isNurse: Bool {
        switch self {
        case .registeredNurse, .licensedPracticalNurse, .nurseAssistant, .nursePractitioner:
            return true
        default:
            return false
        }
    }

    var category: StaffCategory {
        if isPhysician { return .physician }
        if isNurse { return .nursing }
        switch self {
        case .pharmacist, .labTechnician: return .clinical
        case .receptionist, .administrator: return .administrative
        case .janitor: return .support
        default: return .clinical
        }
    }
}

enum StaffCategory: String, Codable {
    case physician
    case nursing
    case clinical
    case administrative
    case support
}
