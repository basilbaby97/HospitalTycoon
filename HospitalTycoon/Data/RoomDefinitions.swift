import Foundation

struct RoomDefinitions {
    static let all: [RoomDefinition] = [
        // General
        RoomDefinition(type: .reception, department: .general, width: 4, height: 3, baseCost: 50_000,
                       requiredStaff: [.receptionist], requiredEquipmentCategories: [.basicFurniture],
                       patientCapacity: 1, description: "Patient check-in and registration desk"),
        RoomDefinition(type: .waitingArea, department: .general, width: 5, height: 4, baseCost: 30_000,
                       requiredStaff: [], requiredEquipmentCategories: [.basicFurniture],
                       patientCapacity: 10, description: "Seating area for patients awaiting care"),
        RoomDefinition(type: .administrativeOffice, department: .general, width: 3, height: 3, baseCost: 40_000,
                       requiredStaff: [.administrator], requiredEquipmentCategories: [.basicFurniture],
                       patientCapacity: 0, description: "Hospital management and billing office"),

        // Emergency Department
        RoomDefinition(type: .emergencyBay, department: .emergencyDepartment, width: 4, height: 4, baseCost: 150_000,
                       requiredStaff: [.emergencyPhysician, .registeredNurse], requiredEquipmentCategories: [.patientMonitor, .defibrillator],
                       patientCapacity: 2, description: "Emergency treatment bay with monitoring equipment"),
        RoomDefinition(type: .triageRoom, department: .emergencyDepartment, width: 3, height: 3, baseCost: 80_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor, .examinationBed],
                       patientCapacity: 1, description: "Initial patient assessment and prioritization"),
        RoomDefinition(type: .traumaBay, department: .emergencyDepartment, width: 5, height: 5, baseCost: 300_000,
                       requiredStaff: [.emergencyPhysician, .registeredNurse, .registeredNurse], requiredEquipmentCategories: [.patientMonitor, .ventilator, .defibrillator],
                       patientCapacity: 1, description: "Advanced trauma care with full life support capabilities"),

        // Internal Medicine
        RoomDefinition(type: .gpOffice, department: .internalMedicine, width: 3, height: 3, baseCost: 80_000,
                       requiredStaff: [.generalPractitioner], requiredEquipmentCategories: [.examinationBed],
                       patientCapacity: 1, description: "General practitioner consultation and examination"),
        RoomDefinition(type: .examinationRoom, department: .internalMedicine, width: 3, height: 3, baseCost: 60_000,
                       requiredStaff: [.generalPractitioner], requiredEquipmentCategories: [.examinationBed, .patientMonitor],
                       patientCapacity: 1, description: "Detailed patient examination room"),
        RoomDefinition(type: .generalWard, department: .internalMedicine, width: 5, height: 4, baseCost: 120_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor],
                       patientCapacity: 4, description: "Multi-bed ward for patient recovery and observation"),
        RoomDefinition(type: .privateRoom, department: .internalMedicine, width: 4, height: 3, baseCost: 100_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor],
                       patientCapacity: 1, description: "Single-patient room for enhanced privacy and comfort"),

        // Surgery
        RoomDefinition(type: .operatingTheater, department: .surgery, width: 6, height: 5, baseCost: 500_000,
                       requiredStaff: [.surgeon, .anesthesiologist, .registeredNurse], requiredEquipmentCategories: [.surgicalTable, .anesthesiaSystem, .patientMonitor],
                       patientCapacity: 1, description: "Full surgical suite with anesthesia and monitoring"),
        RoomDefinition(type: .preOpRoom, department: .surgery, width: 3, height: 3, baseCost: 60_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor, .examinationBed],
                       patientCapacity: 2, description: "Pre-operative preparation and assessment"),
        RoomDefinition(type: .postOpRecovery, department: .surgery, width: 5, height: 4, baseCost: 100_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor],
                       patientCapacity: 4, description: "Post-surgical recovery and monitoring"),

        // Cardiology
        RoomDefinition(type: .cathLab, department: .cardiology, width: 6, height: 5, baseCost: 800_000,
                       requiredStaff: [.cardiologist, .registeredNurse], requiredEquipmentCategories: [.patientMonitor, .ecgMachine],
                       patientCapacity: 1, description: "Cardiac catheterization laboratory for diagnostic and interventional procedures"),
        RoomDefinition(type: .cardiacMonitoringUnit, department: .cardiology, width: 5, height: 4, baseCost: 200_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.patientMonitor, .ecgMachine],
                       patientCapacity: 4, description: "Continuous cardiac rhythm monitoring unit"),

        // Radiology
        RoomDefinition(type: .xRayRoom, department: .radiology, width: 4, height: 3, baseCost: 150_000,
                       requiredStaff: [.radiologist], requiredEquipmentCategories: [.xRay],
                       patientCapacity: 1, description: "Standard X-ray imaging room"),
        RoomDefinition(type: .ctScanRoom, department: .radiology, width: 5, height: 4, baseCost: 300_000,
                       requiredStaff: [.radiologist], requiredEquipmentCategories: [.ctScanner],
                       patientCapacity: 1, description: "CT scanning room with radiation shielding"),
        RoomDefinition(type: .mriRoom, department: .radiology, width: 6, height: 5, baseCost: 500_000,
                       requiredStaff: [.radiologist], requiredEquipmentCategories: [.mri],
                       patientCapacity: 1, description: "MRI suite with magnetic shielding"),
        RoomDefinition(type: .ultrasoundRoom, department: .radiology, width: 3, height: 3, baseCost: 100_000,
                       requiredStaff: [.radiologist], requiredEquipmentCategories: [.ultrasound],
                       patientCapacity: 1, description: "Ultrasound imaging room"),

        // Laboratory
        RoomDefinition(type: .bloodLab, department: .pathologyLab, width: 4, height: 3, baseCost: 200_000,
                       requiredStaff: [.labTechnician], requiredEquipmentCategories: [.chemistryAnalyzer, .hematologyAnalyzer],
                       patientCapacity: 0, description: "Blood testing and chemistry analysis laboratory"),
        RoomDefinition(type: .microbiologyLab, department: .pathologyLab, width: 4, height: 3, baseCost: 180_000,
                       requiredStaff: [.labTechnician], requiredEquipmentCategories: [.chemistryAnalyzer],
                       patientCapacity: 0, description: "Microbiology and culture testing laboratory"),
        RoomDefinition(type: .pathologyLab, department: .pathologyLab, width: 4, height: 4, baseCost: 250_000,
                       requiredStaff: [.pathologist], requiredEquipmentCategories: [.microscope],
                       patientCapacity: 0, description: "Tissue analysis and pathology laboratory"),

        // Pharmacy
        RoomDefinition(type: .pharmacyDispensary, department: .pharmacy, width: 4, height: 3, baseCost: 150_000,
                       requiredStaff: [.pharmacist], requiredEquipmentCategories: [.dispensingSystem],
                       patientCapacity: 1, description: "Medication dispensing and pharmaceutical services"),

        // ICU
        RoomDefinition(type: .icuBay, department: .intensiveCare, width: 4, height: 4, baseCost: 300_000,
                       requiredStaff: [.generalPractitioner, .registeredNurse], requiredEquipmentCategories: [.patientMonitor, .ventilator, .infusionPump],
                       patientCapacity: 1, description: "Intensive care bay with full life support. 1:1-2 nurse-to-patient ratio."),
        RoomDefinition(type: .nicu, department: .intensiveCare, width: 4, height: 4, baseCost: 350_000,
                       requiredStaff: [.registeredNurse, .registeredNurse], requiredEquipmentCategories: [.patientMonitor, .ventilator, .infusionPump],
                       patientCapacity: 1, description: "Neonatal intensive care for premature and critically ill newborns"),

        // Oncology
        RoomDefinition(type: .chemotherapyRoom, department: .oncology, width: 4, height: 4, baseCost: 200_000,
                       requiredStaff: [.registeredNurse], requiredEquipmentCategories: [.infusionPump, .patientMonitor],
                       patientCapacity: 3, description: "Chemotherapy infusion bay with patient monitoring"),
        RoomDefinition(type: .radiationTherapyRoom, department: .oncology, width: 6, height: 5, baseCost: 1_000_000,
                       requiredStaff: [.radiologist], requiredEquipmentCategories: [],
                       patientCapacity: 1, description: "Linear accelerator-based radiation therapy suite"),

        // Support
        RoomDefinition(type: .cafeteria, department: .support, width: 5, height: 4, baseCost: 100_000,
                       requiredStaff: [], requiredEquipmentCategories: [.basicFurniture],
                       patientCapacity: 0, description: "Dining area for staff and visitors. Improves staff satisfaction."),
        RoomDefinition(type: .restroom, department: .support, width: 2, height: 2, baseCost: 20_000,
                       requiredStaff: [.janitor], requiredEquipmentCategories: [],
                       patientCapacity: 0, description: "Restroom facilities. Required for hygiene rating."),
        RoomDefinition(type: .staffLounge, department: .support, width: 4, height: 3, baseCost: 60_000,
                       requiredStaff: [], requiredEquipmentCategories: [.basicFurniture],
                       patientCapacity: 0, description: "Staff break room. Reduces burnout and improves morale."),
        RoomDefinition(type: .supplyRoom, department: .support, width: 3, height: 3, baseCost: 40_000,
                       requiredStaff: [], requiredEquipmentCategories: [],
                       patientCapacity: 0, description: "Medical supply storage. Reduces supply costs by 5%."),
    ]

    static func definition(for type: RoomType) -> RoomDefinition {
        all.first { $0.type == type } ?? all[0]
    }

    static func rooms(for department: Department) -> [RoomDefinition] {
        all.filter { $0.department == department }
    }
}
