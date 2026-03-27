import Foundation

struct Room: Codable, Identifiable, Equatable {
    let id: UUID
    let type: RoomType
    let origin: GridPosition
    let width: Int
    let height: Int
    let department: Department
    var assignedStaffIds: [UUID] = []
    var patientCapacity: Int = 1
    var isOperational: Bool = false // needs required staff + equipment

    var center: GridPosition {
        GridPosition(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    var allPositions: [GridPosition] {
        var positions: [GridPosition] = []
        for y in origin.y..<(origin.y + height) {
            for x in origin.x..<(origin.x + width) {
                positions.append(GridPosition(x: x, y: y))
            }
        }
        return positions
    }
}

// MARK: - Room Types

enum RoomType: String, Codable, CaseIterable, Identifiable {
    // General
    case reception
    case waitingArea

    // Internal Medicine / GP
    case gpOffice
    case examinationRoom

    // Emergency
    case emergencyBay
    case triageRoom
    case traumaBay

    // Surgery
    case operatingTheater
    case preOpRoom
    case postOpRecovery

    // Wards
    case generalWard
    case privateRoom

    // Cardiology
    case cathLab
    case cardiacMonitoringUnit

    // Radiology / Imaging
    case xRayRoom
    case ctScanRoom
    case mriRoom
    case ultrasoundRoom

    // Laboratory
    case bloodLab
    case microbiologyLab
    case pathologyLab

    // Pharmacy
    case pharmacyDispensary

    // ICU
    case icuBay
    case nicu

    // Oncology
    case chemotherapyRoom
    case radiationTherapyRoom

    // Support
    case cafeteria
    case restroom
    case staffLounge
    case supplyRoom
    case administrativeOffice

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .reception: return "Reception"
        case .waitingArea: return "Waiting Area"
        case .gpOffice: return "GP Office"
        case .examinationRoom: return "Examination Room"
        case .emergencyBay: return "Emergency Bay"
        case .triageRoom: return "Triage Room"
        case .traumaBay: return "Trauma Bay"
        case .operatingTheater: return "Operating Theater"
        case .preOpRoom: return "Pre-Op Room"
        case .postOpRecovery: return "Post-Op Recovery"
        case .generalWard: return "General Ward"
        case .privateRoom: return "Private Room"
        case .cathLab: return "Cath Lab"
        case .cardiacMonitoringUnit: return "Cardiac Monitoring Unit"
        case .xRayRoom: return "X-Ray Room"
        case .ctScanRoom: return "CT Scan Room"
        case .mriRoom: return "MRI Room"
        case .ultrasoundRoom: return "Ultrasound Room"
        case .bloodLab: return "Blood Lab"
        case .microbiologyLab: return "Microbiology Lab"
        case .pathologyLab: return "Pathology Lab"
        case .pharmacyDispensary: return "Pharmacy"
        case .icuBay: return "ICU Bay"
        case .nicu: return "NICU"
        case .chemotherapyRoom: return "Chemotherapy Room"
        case .radiationTherapyRoom: return "Radiation Therapy"
        case .cafeteria: return "Cafeteria"
        case .restroom: return "Restroom"
        case .staffLounge: return "Staff Lounge"
        case .supplyRoom: return "Supply Room"
        case .administrativeOffice: return "Admin Office"
        }
    }
}

// MARK: - Department

enum Department: String, Codable, CaseIterable, Identifiable {
    case general
    case emergencyDepartment
    case internalMedicine
    case surgery
    case orthopedics
    case cardiology
    case neurology
    case pediatrics
    case obgyn
    case oncology
    case radiology
    case pathologyLab
    case pharmacy
    case intensiveCare
    case support

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .general: return "General"
        case .emergencyDepartment: return "Emergency Department"
        case .internalMedicine: return "Internal Medicine"
        case .surgery: return "Surgery"
        case .orthopedics: return "Orthopedics"
        case .cardiology: return "Cardiology"
        case .neurology: return "Neurology"
        case .pediatrics: return "Pediatrics"
        case .obgyn: return "OB/GYN"
        case .oncology: return "Oncology"
        case .radiology: return "Radiology"
        case .pathologyLab: return "Pathology & Lab"
        case .pharmacy: return "Pharmacy"
        case .intensiveCare: return "Intensive Care"
        case .support: return "Support Services"
        }
    }

    var color: RoomColor {
        switch self {
        case .general: return .gray
        case .emergencyDepartment: return .red
        case .internalMedicine: return .blue
        case .surgery: return .green
        case .orthopedics: return .teal
        case .cardiology: return .purple
        case .neurology: return .indigo
        case .pediatrics: return .pink
        case .obgyn: return .rose
        case .oncology: return .orange
        case .radiology: return .cyan
        case .pathologyLab: return .yellow
        case .pharmacy: return .mint
        case .intensiveCare: return .darkRed
        case .support: return .brown
        }
    }
}

enum RoomColor: String, Codable {
    case gray, red, blue, green, teal, purple, indigo, pink, rose
    case orange, cyan, yellow, mint, darkRed, brown
}

// MARK: - Room Definition (static data)

struct RoomDefinition {
    let type: RoomType
    let department: Department
    let width: Int
    let height: Int
    let baseCost: Int
    let requiredStaff: [StaffRole]
    let requiredEquipmentCategories: [EquipmentCategory]
    let patientCapacity: Int
    let description: String
}
