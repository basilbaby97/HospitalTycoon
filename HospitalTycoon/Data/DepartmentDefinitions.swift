import Foundation

struct DepartmentDefinitions {
    struct DepartmentInfo {
        let department: Department
        let marginProfile: MarginProfile
        let description: String
        let availableRoomTypes: [RoomType]
        let unlockCost: Int // cost to unlock this department

        enum MarginProfile: String {
            case costCenter = "Cost Center"
            case revenueCenter = "Revenue Center"
            case profitCenter = "Profit Center"
            case mixed = "Mixed"
        }
    }

    static let all: [DepartmentInfo] = [
        DepartmentInfo(
            department: .general,
            marginProfile: .revenueCenter,
            description: "Reception, waiting areas, and general administration",
            availableRoomTypes: [.reception, .waitingArea, .administrativeOffice],
            unlockCost: 0
        ),
        DepartmentInfo(
            department: .emergencyDepartment,
            marginProfile: .revenueCenter,
            description: "High volume emergency and trauma care. Mixed payer population.",
            availableRoomTypes: [.emergencyBay, .triageRoom, .traumaBay],
            unlockCost: 500_000
        ),
        DepartmentInfo(
            department: .internalMedicine,
            marginProfile: .revenueCenter,
            description: "General practice and internal medicine. First point of diagnosis.",
            availableRoomTypes: [.gpOffice, .examinationRoom, .generalWard, .privateRoom],
            unlockCost: 0
        ),
        DepartmentInfo(
            department: .surgery,
            marginProfile: .profitCenter,
            description: "General and specialized surgery. High margin procedures.",
            availableRoomTypes: [.operatingTheater, .preOpRoom, .postOpRecovery],
            unlockCost: 1_000_000
        ),
        DepartmentInfo(
            department: .orthopedics,
            marginProfile: .profitCenter,
            description: "Joint replacement, fracture repair, sports medicine. Very high margins.",
            availableRoomTypes: [.operatingTheater, .examinationRoom, .generalWard],
            unlockCost: 1_500_000
        ),
        DepartmentInfo(
            department: .cardiology,
            marginProfile: .profitCenter,
            description: "Heart disease diagnosis and treatment. Cath lab procedures are highly profitable.",
            availableRoomTypes: [.cathLab, .cardiacMonitoringUnit, .examinationRoom],
            unlockCost: 2_000_000
        ),
        DepartmentInfo(
            department: .neurology,
            marginProfile: .revenueCenter,
            description: "Neurological conditions including stroke care.",
            availableRoomTypes: [.examinationRoom, .generalWard, .privateRoom],
            unlockCost: 1_500_000
        ),
        DepartmentInfo(
            department: .pediatrics,
            marginProfile: .revenueCenter,
            description: "Children's care from infants to adolescents.",
            availableRoomTypes: [.examinationRoom, .generalWard, .nicu],
            unlockCost: 1_000_000
        ),
        DepartmentInfo(
            department: .obgyn,
            marginProfile: .revenueCenter,
            description: "Obstetrics and gynecology. Childbirth and women's health.",
            availableRoomTypes: [.examinationRoom, .operatingTheater, .generalWard, .privateRoom],
            unlockCost: 1_200_000
        ),
        DepartmentInfo(
            department: .oncology,
            marginProfile: .profitCenter,
            description: "Cancer diagnosis and treatment. Growing high-margin service line.",
            availableRoomTypes: [.chemotherapyRoom, .radiationTherapyRoom, .examinationRoom, .privateRoom],
            unlockCost: 2_500_000
        ),
        DepartmentInfo(
            department: .radiology,
            marginProfile: .costCenter,
            description: "Diagnostic imaging support. Charges per scan but primarily supports other departments.",
            availableRoomTypes: [.xRayRoom, .ctScanRoom, .mriRoom, .ultrasoundRoom],
            unlockCost: 0
        ),
        DepartmentInfo(
            department: .pathologyLab,
            marginProfile: .costCenter,
            description: "Laboratory testing and pathology. Essential for diagnosis.",
            availableRoomTypes: [.bloodLab, .microbiologyLab, .pathologyLab],
            unlockCost: 0
        ),
        DepartmentInfo(
            department: .pharmacy,
            marginProfile: .mixed,
            description: "Medication dispensing and pharmaceutical services.",
            availableRoomTypes: [.pharmacyDispensary],
            unlockCost: 200_000
        ),
        DepartmentInfo(
            department: .intensiveCare,
            marginProfile: .costCenter,
            description: "Critical care. High cost but essential for complex cases. 1:1-2 nurse ratio.",
            availableRoomTypes: [.icuBay, .nicu],
            unlockCost: 1_500_000
        ),
        DepartmentInfo(
            department: .support,
            marginProfile: .costCenter,
            description: "Cafeteria, restrooms, staff lounges, and supply storage.",
            availableRoomTypes: [.cafeteria, .restroom, .staffLounge, .supplyRoom],
            unlockCost: 0
        ),
    ]

    static func info(for department: Department) -> DepartmentInfo {
        all.first { $0.department == department }!
    }

    static var unlockedByDefault: [Department] {
        all.filter { $0.unlockCost == 0 }.map { $0.department }
    }
}
