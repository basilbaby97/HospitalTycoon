import Foundation

struct EquipmentCatalog {
    static let all: [EquipmentTemplate] = [
        // === MRI Scanners ===
        EquipmentTemplate(
            id: "mri-ge-signa-explorer", name: "SIGNA Explorer 1.5T", brand: "GE Healthcare",
            category: .mri, purchaseCost: 1_200_000, installationCost: 200_000, annualMaintenance: 100_000,
            requiredRoomTypes: [.mriRoom], diagnosticCapabilities: [.mriBrain, .mriSpine, .mriAbdomen],
            description: "Reliable 1.5T MRI system for routine diagnostic imaging", tier: .standard
        ),
        EquipmentTemplate(
            id: "mri-siemens-magnetom-sola", name: "MAGNETOM Sola 1.5T", brand: "Siemens Healthineers",
            category: .mri, purchaseCost: 1_400_000, installationCost: 250_000, annualMaintenance: 110_000,
            requiredRoomTypes: [.mriRoom], diagnosticCapabilities: [.mriBrain, .mriSpine, .mriAbdomen],
            description: "Advanced 1.5T MRI with BioMatrix technology for consistent results", tier: .standard
        ),
        EquipmentTemplate(
            id: "mri-ge-signa-premier", name: "SIGNA Premier 3T", brand: "GE Healthcare",
            category: .mri, purchaseCost: 2_500_000, installationCost: 350_000, annualMaintenance: 150_000,
            requiredRoomTypes: [.mriRoom], diagnosticCapabilities: [.mriBrain, .mriSpine, .mriAbdomen],
            description: "Premium 3T MRI with AIR Recon DL for enhanced image quality", tier: .premium
        ),
        EquipmentTemplate(
            id: "mri-siemens-magnetom-vida", name: "MAGNETOM Vida 3T", brand: "Siemens Healthineers",
            category: .mri, purchaseCost: 2_800_000, installationCost: 400_000, annualMaintenance: 160_000,
            requiredRoomTypes: [.mriRoom], diagnosticCapabilities: [.mriBrain, .mriSpine, .mriAbdomen],
            description: "Top-tier 3T MRI with BioMatrix for personalized scanning", tier: .premium
        ),
        EquipmentTemplate(
            id: "mri-philips-ingenia-ambition", name: "Ingenia Ambition 1.5T", brand: "Philips",
            category: .mri, purchaseCost: 1_300_000, installationCost: 200_000, annualMaintenance: 95_000,
            requiredRoomTypes: [.mriRoom], diagnosticCapabilities: [.mriBrain, .mriSpine, .mriAbdomen],
            description: "Helium-free 1.5T MRI with lower operating costs", tier: .standard
        ),

        // === CT Scanners ===
        EquipmentTemplate(
            id: "ct-ge-revolution", name: "Revolution CT", brand: "GE Healthcare",
            category: .ctScanner, purchaseCost: 450_000, installationCost: 80_000, annualMaintenance: 40_000,
            requiredRoomTypes: [.ctScanRoom], diagnosticCapabilities: [.ctScanChest, .ctScanAbdomen, .ctScanHead],
            description: "256-slice CT scanner for rapid whole-body imaging", tier: .premium
        ),
        EquipmentTemplate(
            id: "ct-siemens-somatom", name: "SOMATOM go.Top", brand: "Siemens Healthineers",
            category: .ctScanner, purchaseCost: 350_000, installationCost: 60_000, annualMaintenance: 35_000,
            requiredRoomTypes: [.ctScanRoom], diagnosticCapabilities: [.ctScanChest, .ctScanAbdomen, .ctScanHead],
            description: "64-slice CT with tablet-based workflow for streamlined operation", tier: .standard
        ),
        EquipmentTemplate(
            id: "ct-canon-aquilion", name: "Aquilion ONE PRISM", brand: "Canon Medical",
            category: .ctScanner, purchaseCost: 500_000, installationCost: 90_000, annualMaintenance: 45_000,
            requiredRoomTypes: [.ctScanRoom], diagnosticCapabilities: [.ctScanChest, .ctScanAbdomen, .ctScanHead],
            description: "320-row area detector CT for advanced cardiac and neuro imaging", tier: .premium
        ),
        EquipmentTemplate(
            id: "ct-basic-64", name: "Optima CT540", brand: "GE Healthcare",
            category: .ctScanner, purchaseCost: 150_000, installationCost: 40_000, annualMaintenance: 25_000,
            requiredRoomTypes: [.ctScanRoom], diagnosticCapabilities: [.ctScanChest, .ctScanAbdomen, .ctScanHead],
            description: "Entry-level 64-slice CT scanner for routine imaging", tier: .basic
        ),

        // === X-Ray Systems ===
        EquipmentTemplate(
            id: "xray-ge-optima", name: "Optima XR240amx", brand: "GE Healthcare",
            category: .xRay, purchaseCost: 120_000, installationCost: 20_000, annualMaintenance: 10_000,
            requiredRoomTypes: [.xRayRoom], diagnosticCapabilities: [.chestXRay],
            description: "Digital radiography system for general X-ray imaging", tier: .standard
        ),
        EquipmentTemplate(
            id: "xray-siemens-ysio", name: "Ysio Max", brand: "Siemens Healthineers",
            category: .xRay, purchaseCost: 180_000, installationCost: 25_000, annualMaintenance: 12_000,
            requiredRoomTypes: [.xRayRoom], diagnosticCapabilities: [.chestXRay],
            description: "Ceiling-mounted digital X-ray with auto-positioning", tier: .premium
        ),
        EquipmentTemplate(
            id: "xray-philips-digital", name: "DigitalDiagnost C90", brand: "Philips",
            category: .xRay, purchaseCost: 150_000, installationCost: 22_000, annualMaintenance: 11_000,
            requiredRoomTypes: [.xRayRoom], diagnosticCapabilities: [.chestXRay],
            description: "Advanced digital X-ray with AI-powered image enhancement", tier: .standard
        ),

        // === Ultrasound ===
        EquipmentTemplate(
            id: "us-philips-epiq", name: "EPIQ Elite", brand: "Philips",
            category: .ultrasound, purchaseCost: 250_000, installationCost: 5_000, annualMaintenance: 8_000,
            requiredRoomTypes: [.ultrasoundRoom], diagnosticCapabilities: [.ultrasoundAbdomen, .ultrasoundCardiac],
            description: "Premium ultrasound with 3D/4D imaging and cardiac capabilities", tier: .premium
        ),
        EquipmentTemplate(
            id: "us-ge-logiq", name: "LOGIQ E10s", brand: "GE Healthcare",
            category: .ultrasound, purchaseCost: 150_000, installationCost: 3_000, annualMaintenance: 6_000,
            requiredRoomTypes: [.ultrasoundRoom], diagnosticCapabilities: [.ultrasoundAbdomen, .ultrasoundCardiac],
            description: "Versatile diagnostic ultrasound for general and cardiac imaging", tier: .standard
        ),
        EquipmentTemplate(
            id: "us-siemens-acuson", name: "ACUSON Redwood", brand: "Siemens Healthineers",
            category: .ultrasound, purchaseCost: 80_000, installationCost: 2_000, annualMaintenance: 5_000,
            requiredRoomTypes: [.ultrasoundRoom], diagnosticCapabilities: [.ultrasoundAbdomen],
            description: "Compact ultrasound for routine abdominal and OB imaging", tier: .basic
        ),

        // === Patient Monitors ===
        EquipmentTemplate(
            id: "monitor-philips-intellivue", name: "IntelliVue MX800", brand: "Philips",
            category: .patientMonitor, purchaseCost: 18_000, installationCost: 1_000, annualMaintenance: 1_000,
            requiredRoomTypes: [.emergencyBay, .triageRoom, .traumaBay, .generalWard, .privateRoom, .icuBay, .nicu, .operatingTheater, .cathLab, .cardiacMonitoringUnit, .postOpRecovery, .preOpRoom, .examinationRoom, .chemotherapyRoom],
            diagnosticCapabilities: [], description: "Advanced bedside monitor with multi-parameter tracking", tier: .premium
        ),
        EquipmentTemplate(
            id: "monitor-ge-carescape", name: "CARESCAPE B650", brand: "GE Healthcare",
            category: .patientMonitor, purchaseCost: 15_000, installationCost: 800, annualMaintenance: 900,
            requiredRoomTypes: [.emergencyBay, .triageRoom, .traumaBay, .generalWard, .privateRoom, .icuBay, .nicu, .operatingTheater, .cathLab, .cardiacMonitoringUnit, .postOpRecovery, .preOpRoom, .examinationRoom, .chemotherapyRoom],
            diagnosticCapabilities: [], description: "Modular patient monitor for critical and acute care", tier: .standard
        ),
        EquipmentTemplate(
            id: "monitor-mindray-epm", name: "ePM 15M", brand: "Mindray",
            category: .patientMonitor, purchaseCost: 7_000, installationCost: 500, annualMaintenance: 600,
            requiredRoomTypes: [.emergencyBay, .triageRoom, .traumaBay, .generalWard, .privateRoom, .icuBay, .nicu, .operatingTheater, .cathLab, .cardiacMonitoringUnit, .postOpRecovery, .preOpRoom, .examinationRoom, .chemotherapyRoom],
            diagnosticCapabilities: [], description: "Cost-effective patient monitor for general ward use", tier: .basic
        ),

        // === Ventilators ===
        EquipmentTemplate(
            id: "vent-hamilton-c6", name: "Hamilton C6", brand: "Hamilton Medical",
            category: .ventilator, purchaseCost: 60_000, installationCost: 2_000, annualMaintenance: 3_000,
            requiredRoomTypes: [.icuBay, .nicu, .traumaBay, .operatingTheater],
            diagnosticCapabilities: [], description: "Intelligent ventilator with adaptive support ventilation", tier: .premium
        ),
        EquipmentTemplate(
            id: "vent-drager-evita", name: "Evita V800", brand: "Draeger",
            category: .ventilator, purchaseCost: 50_000, installationCost: 1_500, annualMaintenance: 2_500,
            requiredRoomTypes: [.icuBay, .nicu, .traumaBay, .operatingTheater],
            diagnosticCapabilities: [], description: "ICU ventilator with comprehensive ventilation modes", tier: .standard
        ),

        // === Surgical Robots ===
        EquipmentTemplate(
            id: "robot-davinci-5", name: "da Vinci 5", brand: "Intuitive Surgical",
            category: .surgicalRobot, purchaseCost: 2_200_000, installationCost: 200_000, annualMaintenance: 190_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Latest generation surgical robot with force feedback and 10,000+ lux visualization", tier: .premium
        ),
        EquipmentTemplate(
            id: "robot-medtronic-hugo", name: "Hugo RAS", brand: "Medtronic",
            category: .surgicalRobot, purchaseCost: 1_800_000, installationCost: 150_000, annualMaintenance: 160_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Modular robotic-assisted surgery system with open architecture", tier: .standard
        ),

        // === Lab Equipment ===
        EquipmentTemplate(
            id: "chem-roche-cobas", name: "Cobas 8000", brand: "Roche Diagnostics",
            category: .chemistryAnalyzer, purchaseCost: 180_000, installationCost: 15_000, annualMaintenance: 15_000,
            requiredRoomTypes: [.bloodLab, .microbiologyLab], diagnosticCapabilities: [.completeBloodCount, .basicMetabolicPanel, .comprehensiveMetabolicPanel, .troponinLevel, .dDimer, .bloodCulture],
            description: "High-throughput modular analyzer for clinical chemistry and immunoassay", tier: .premium
        ),
        EquipmentTemplate(
            id: "chem-abbott-architect", name: "Architect c8000", brand: "Abbott",
            category: .chemistryAnalyzer, purchaseCost: 130_000, installationCost: 10_000, annualMaintenance: 12_000,
            requiredRoomTypes: [.bloodLab, .microbiologyLab], diagnosticCapabilities: [.completeBloodCount, .basicMetabolicPanel, .comprehensiveMetabolicPanel, .troponinLevel, .dDimer, .bloodCulture],
            description: "Integrated clinical chemistry analyzer with broad test menu", tier: .standard
        ),
        EquipmentTemplate(
            id: "chem-beckman-au5800", name: "AU5800", brand: "Beckman Coulter",
            category: .chemistryAnalyzer, purchaseCost: 100_000, installationCost: 8_000, annualMaintenance: 10_000,
            requiredRoomTypes: [.bloodLab, .microbiologyLab], diagnosticCapabilities: [.completeBloodCount, .basicMetabolicPanel, .comprehensiveMetabolicPanel, .troponinLevel],
            description: "Reliable chemistry analyzer for mid-volume laboratories", tier: .basic
        ),
        EquipmentTemplate(
            id: "hema-sysmex-xn", name: "XN-Series", brand: "Sysmex",
            category: .hematologyAnalyzer, purchaseCost: 80_000, installationCost: 5_000, annualMaintenance: 10_000,
            requiredRoomTypes: [.bloodLab], diagnosticCapabilities: [.completeBloodCount],
            description: "Automated hematology analyzer for CBC and differential", tier: .standard
        ),
        EquipmentTemplate(
            id: "abg-radiometer-abl", name: "ABL90 FLEX PLUS", brand: "Radiometer",
            category: .bloodGasAnalyzer, purchaseCost: 25_000, installationCost: 2_000, annualMaintenance: 5_000,
            requiredRoomTypes: [.bloodLab, .icuBay], diagnosticCapabilities: [.arterialBloodGas],
            description: "Point-of-care blood gas analyzer with 35-second results", tier: .standard
        ),
        EquipmentTemplate(
            id: "microscope-olympus-bx", name: "BX53", brand: "Olympus",
            category: .microscope, purchaseCost: 15_000, installationCost: 500, annualMaintenance: 1_000,
            requiredRoomTypes: [.pathologyLab, .microbiologyLab], diagnosticCapabilities: [.biopsy],
            description: "Research-grade microscope for pathology and microbiology", tier: .standard
        ),

        // === ECG ===
        EquipmentTemplate(
            id: "ecg-ge-mac5500", name: "MAC 5500 HD", brand: "GE Healthcare",
            category: .ecgMachine, purchaseCost: 12_000, installationCost: 500, annualMaintenance: 1_000,
            requiredRoomTypes: [.examinationRoom, .emergencyBay, .cathLab, .cardiacMonitoringUnit],
            diagnosticCapabilities: [.ecg], description: "12-lead diagnostic ECG with advanced algorithm", tier: .premium
        ),
        EquipmentTemplate(
            id: "ecg-philips-pagewriter", name: "PageWriter TC70", brand: "Philips",
            category: .ecgMachine, purchaseCost: 8_000, installationCost: 300, annualMaintenance: 800,
            requiredRoomTypes: [.examinationRoom, .emergencyBay, .cathLab, .cardiacMonitoringUnit],
            diagnosticCapabilities: [.ecg], description: "Touchscreen ECG cardiograph with wireless connectivity", tier: .standard
        ),

        // === Defibrillators ===
        EquipmentTemplate(
            id: "defib-philips-heartstart", name: "HeartStart MRx", brand: "Philips",
            category: .defibrillator, purchaseCost: 20_000, installationCost: 500, annualMaintenance: 2_000,
            requiredRoomTypes: [.emergencyBay, .traumaBay, .icuBay, .operatingTheater],
            diagnosticCapabilities: [], description: "Professional defibrillator/monitor for emergency and critical care", tier: .standard
        ),
        EquipmentTemplate(
            id: "defib-stryker-lifepak", name: "LIFEPAK 15", brand: "Stryker",
            category: .defibrillator, purchaseCost: 28_000, installationCost: 500, annualMaintenance: 2_500,
            requiredRoomTypes: [.emergencyBay, .traumaBay, .icuBay, .operatingTheater],
            diagnosticCapabilities: [], description: "Advanced monitor/defibrillator with 12-lead ECG and SpO2", tier: .premium
        ),

        // === Anesthesia ===
        EquipmentTemplate(
            id: "anes-ge-aisys", name: "Aisys CS2", brand: "GE Healthcare",
            category: .anesthesiaSystem, purchaseCost: 80_000, installationCost: 5_000, annualMaintenance: 8_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Advanced anesthesia delivery system with electronic gas mixing", tier: .premium
        ),
        EquipmentTemplate(
            id: "anes-drager-perseus", name: "Perseus A500", brand: "Draeger",
            category: .anesthesiaSystem, purchaseCost: 60_000, installationCost: 4_000, annualMaintenance: 6_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Turbine-driven anesthesia workstation with hot-swappable ventilation", tier: .standard
        ),

        // === Surgical Tables ===
        EquipmentTemplate(
            id: "table-stryker-altus", name: "Altus Surgical Table", brand: "Stryker",
            category: .surgicalTable, purchaseCost: 60_000, installationCost: 2_000, annualMaintenance: 3_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Versatile surgical table with bariatric capability", tier: .standard
        ),
        EquipmentTemplate(
            id: "table-maquet-magnus", name: "Magnus Surgical Table", brand: "Maquet/Getinge",
            category: .surgicalTable, purchaseCost: 75_000, installationCost: 3_000, annualMaintenance: 3_500,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [],
            description: "Premium operating table with carbon fiber top for full radiolucency", tier: .premium
        ),

        // === Endoscopy ===
        EquipmentTemplate(
            id: "endo-olympus-evis", name: "EVIS X1", brand: "Olympus",
            category: .endoscopySystem, purchaseCost: 120_000, installationCost: 10_000, annualMaintenance: 10_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [.endoscopy, .colonoscopy],
            description: "Next-generation endoscopy system with AI-assisted detection", tier: .premium
        ),
        EquipmentTemplate(
            id: "endo-stryker-1688", name: "1688 AIM Platform", brand: "Stryker",
            category: .endoscopySystem, purchaseCost: 80_000, installationCost: 8_000, annualMaintenance: 8_000,
            requiredRoomTypes: [.operatingTheater], diagnosticCapabilities: [.endoscopy, .colonoscopy],
            description: "4K endoscopy visualization with fluorescence imaging", tier: .standard
        ),

        // === Infusion Pumps ===
        EquipmentTemplate(
            id: "pump-bd-alaris", name: "Alaris System", brand: "BD (Becton Dickinson)",
            category: .infusionPump, purchaseCost: 5_000, installationCost: 200, annualMaintenance: 500,
            requiredRoomTypes: [.icuBay, .nicu, .generalWard, .chemotherapyRoom, .privateRoom],
            diagnosticCapabilities: [], description: "Smart infusion pump with dose error reduction", tier: .standard
        ),

        // === Examination Beds ===
        EquipmentTemplate(
            id: "bed-hill-rom-centrella", name: "Centrella Smart+ Bed", brand: "Hillrom/Baxter",
            category: .examinationBed, purchaseCost: 15_000, installationCost: 500, annualMaintenance: 800,
            requiredRoomTypes: [.gpOffice, .examinationRoom, .triageRoom, .generalWard, .privateRoom, .preOpRoom],
            diagnosticCapabilities: [.physicalExam], description: "Smart hospital bed with fall prevention and patient monitoring", tier: .standard
        ),
        EquipmentTemplate(
            id: "bed-stryker-procuity", name: "ProCuity Bed", brand: "Stryker",
            category: .examinationBed, purchaseCost: 18_000, installationCost: 500, annualMaintenance: 900,
            requiredRoomTypes: [.gpOffice, .examinationRoom, .triageRoom, .generalWard, .privateRoom, .preOpRoom],
            diagnosticCapabilities: [.physicalExam], description: "Advanced med-surg bed with integrated scale and position alerts", tier: .premium
        ),

        // === Pharmacy ===
        EquipmentTemplate(
            id: "disp-bd-pyxis", name: "Pyxis MedStation ES", brand: "BD (Becton Dickinson)",
            category: .dispensingSystem, purchaseCost: 50_000, installationCost: 5_000, annualMaintenance: 8_000,
            requiredRoomTypes: [.pharmacyDispensary], diagnosticCapabilities: [],
            description: "Automated medication dispensing cabinet with barcode verification", tier: .standard
        ),
        EquipmentTemplate(
            id: "disp-omnicell-xt", name: "XT Automated Dispensing", brand: "Omnicell",
            category: .dispensingSystem, purchaseCost: 55_000, installationCost: 5_500, annualMaintenance: 8_500,
            requiredRoomTypes: [.pharmacyDispensary], diagnosticCapabilities: [],
            description: "Advanced automated dispensing with predictive analytics", tier: .premium
        ),

        // === Basic Furniture ===
        EquipmentTemplate(
            id: "furniture-basic", name: "Standard Furnishing Set", brand: "Various",
            category: .basicFurniture, purchaseCost: 5_000, installationCost: 500, annualMaintenance: 200,
            requiredRoomTypes: [.reception, .waitingArea, .administrativeOffice, .cafeteria, .staffLounge],
            diagnosticCapabilities: [], description: "Desks, chairs, and basic room furnishings", tier: .basic
        ),
    ]

    static func find(id: String) -> EquipmentTemplate? {
        all.first { $0.id == id }
    }

    static func equipment(for category: EquipmentCategory) -> [EquipmentTemplate] {
        all.filter { $0.category == category }
    }

    static func equipment(forRoom roomType: RoomType) -> [EquipmentTemplate] {
        all.filter { $0.requiredRoomTypes.contains(roomType) }
    }

    static func equipmentByBrand(_ brand: String) -> [EquipmentTemplate] {
        all.filter { $0.brand == brand }
    }

    static var allBrands: [String] {
        Array(Set(all.map { $0.brand })).sorted()
    }
}
