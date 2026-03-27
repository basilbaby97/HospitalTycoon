import Foundation

// MARK: - Equipment Template (catalog definition)

struct EquipmentTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let category: EquipmentCategory
    let purchaseCost: Int
    let installationCost: Int
    let annualMaintenance: Int
    let requiredRoomTypes: [RoomType]
    let diagnosticCapabilities: [DiagnosticTestType]
    let description: String
    let tier: EquipmentTier

    var totalAcquisitionCost: Int {
        purchaseCost + installationCost
    }

    var monthlyMaintenance: Double {
        Double(annualMaintenance) / 12.0
    }
}

// MARK: - Installed Equipment (in-game instance)

struct InstalledEquipment: Codable, Identifiable {
    let id: UUID
    let templateId: String
    let roomId: UUID
    let position: GridPosition
    var condition: Double // 0-100%
    var installDay: Int
    var lastMaintenanceDay: Int?
    var isOperational: Bool { condition > 10.0 }

    var template: EquipmentTemplate? {
        EquipmentCatalog.find(id: templateId)
    }
}

// MARK: - Equipment Categories

enum EquipmentCategory: String, Codable, CaseIterable {
    case mri
    case ctScanner
    case xRay
    case ultrasound
    case patientMonitor
    case ventilator
    case surgicalRobot
    case chemistryAnalyzer
    case hematologyAnalyzer
    case ecgMachine
    case defibrillator
    case anesthesiaSystem
    case surgicalTable
    case endoscopySystem
    case infusionPump
    case examinationBed
    case bloodGasAnalyzer
    case microscope
    case dispensingSystem
    case basicFurniture

    var displayName: String {
        switch self {
        case .mri: return "MRI Scanner"
        case .ctScanner: return "CT Scanner"
        case .xRay: return "X-Ray System"
        case .ultrasound: return "Ultrasound"
        case .patientMonitor: return "Patient Monitor"
        case .ventilator: return "Ventilator"
        case .surgicalRobot: return "Surgical Robot"
        case .chemistryAnalyzer: return "Chemistry Analyzer"
        case .hematologyAnalyzer: return "Hematology Analyzer"
        case .ecgMachine: return "ECG Machine"
        case .defibrillator: return "Defibrillator"
        case .anesthesiaSystem: return "Anesthesia System"
        case .surgicalTable: return "Surgical Table"
        case .endoscopySystem: return "Endoscopy System"
        case .infusionPump: return "Infusion Pump"
        case .examinationBed: return "Examination Bed"
        case .bloodGasAnalyzer: return "Blood Gas Analyzer"
        case .microscope: return "Microscope"
        case .dispensingSystem: return "Dispensing System"
        case .basicFurniture: return "Basic Furniture"
        }
    }

    var spriteLabel: String {
        switch self {
        case .mri: return "MRI"
        case .ctScanner: return "CT"
        case .xRay: return "XR"
        case .ultrasound: return "US"
        case .patientMonitor: return "PM"
        case .ventilator: return "VT"
        case .surgicalRobot: return "SR"
        case .chemistryAnalyzer: return "CA"
        case .hematologyAnalyzer: return "HA"
        case .ecgMachine: return "EC"
        case .defibrillator: return "DF"
        case .anesthesiaSystem: return "AN"
        case .surgicalTable: return "ST"
        case .endoscopySystem: return "EN"
        case .infusionPump: return "IP"
        case .examinationBed: return "EB"
        case .bloodGasAnalyzer: return "BG"
        case .microscope: return "MS"
        case .dispensingSystem: return "DS"
        case .basicFurniture: return "BF"
        }
    }
}

enum EquipmentTier: String, Codable {
    case basic
    case standard
    case premium

    var qualityMultiplier: Double {
        switch self {
        case .basic: return 0.8
        case .standard: return 1.0
        case .premium: return 1.2
        }
    }
}

// MARK: - Diagnostic Test Types

enum DiagnosticTestType: String, Codable, CaseIterable {
    case physicalExam
    case completeBloodCount
    case basicMetabolicPanel
    case comprehensiveMetabolicPanel
    case chestXRay
    case ctScanChest
    case ctScanAbdomen
    case ctScanHead
    case mriBrain
    case mriSpine
    case mriAbdomen
    case ecg
    case urinalysis
    case ultrasoundAbdomen
    case ultrasoundCardiac
    case bloodCulture
    case troponinLevel
    case dDimer
    case arterialBloodGas
    case lumbarPuncture
    case endoscopy
    case colonoscopy
    case biopsy

    var displayName: String {
        switch self {
        case .physicalExam: return "Physical Examination"
        case .completeBloodCount: return "Complete Blood Count (CBC)"
        case .basicMetabolicPanel: return "Basic Metabolic Panel (BMP)"
        case .comprehensiveMetabolicPanel: return "Comprehensive Metabolic Panel (CMP)"
        case .chestXRay: return "Chest X-Ray"
        case .ctScanChest: return "CT Scan - Chest"
        case .ctScanAbdomen: return "CT Scan - Abdomen"
        case .ctScanHead: return "CT Scan - Head"
        case .mriBrain: return "MRI - Brain"
        case .mriSpine: return "MRI - Spine"
        case .mriAbdomen: return "MRI - Abdomen"
        case .ecg: return "ECG/EKG"
        case .urinalysis: return "Urinalysis"
        case .ultrasoundAbdomen: return "Ultrasound - Abdomen"
        case .ultrasoundCardiac: return "Echocardiogram"
        case .bloodCulture: return "Blood Culture"
        case .troponinLevel: return "Troponin Level"
        case .dDimer: return "D-Dimer"
        case .arterialBloodGas: return "Arterial Blood Gas (ABG)"
        case .lumbarPuncture: return "Lumbar Puncture"
        case .endoscopy: return "Endoscopy"
        case .colonoscopy: return "Colonoscopy"
        case .biopsy: return "Biopsy"
        }
    }

    var cptCode: String {
        switch self {
        case .physicalExam: return "99213"
        case .completeBloodCount: return "85025"
        case .basicMetabolicPanel: return "80048"
        case .comprehensiveMetabolicPanel: return "80053"
        case .chestXRay: return "71046"
        case .ctScanChest: return "71260"
        case .ctScanAbdomen: return "74178"
        case .ctScanHead: return "70553"
        case .mriBrain: return "70553"
        case .mriSpine: return "72148"
        case .mriAbdomen: return "74183"
        case .ecg: return "93000"
        case .urinalysis: return "81001"
        case .ultrasoundAbdomen: return "76700"
        case .ultrasoundCardiac: return "93306"
        case .bloodCulture: return "87040"
        case .troponinLevel: return "84484"
        case .dDimer: return "85379"
        case .arterialBloodGas: return "82803"
        case .lumbarPuncture: return "62270"
        case .endoscopy: return "43239"
        case .colonoscopy: return "45378"
        case .biopsy: return "88305"
        }
    }

    var hospitalCost: Int {
        switch self {
        case .physicalExam: return 50
        case .completeBloodCount: return 15
        case .basicMetabolicPanel: return 20
        case .comprehensiveMetabolicPanel: return 25
        case .chestXRay: return 55
        case .ctScanChest: return 51
        case .ctScanAbdomen: return 60
        case .ctScanHead: return 55
        case .mriBrain: return 165
        case .mriSpine: return 170
        case .mriAbdomen: return 175
        case .ecg: return 25
        case .urinalysis: return 10
        case .ultrasoundAbdomen: return 100
        case .ultrasoundCardiac: return 120
        case .bloodCulture: return 30
        case .troponinLevel: return 20
        case .dDimer: return 15
        case .arterialBloodGas: return 25
        case .lumbarPuncture: return 200
        case .endoscopy: return 500
        case .colonoscopy: return 600
        case .biopsy: return 300
        }
    }

    var chargeAmount: Int {
        switch self {
        case .physicalExam: return 150
        case .completeBloodCount: return 100
        case .basicMetabolicPanel: return 200
        case .comprehensiveMetabolicPanel: return 250
        case .chestXRay: return 410
        case .ctScanChest: return 1565
        case .ctScanAbdomen: return 1800
        case .ctScanHead: return 1600
        case .mriBrain: return 2048
        case .mriSpine: return 2200
        case .mriAbdomen: return 2100
        case .ecg: return 300
        case .urinalysis: return 80
        case .ultrasoundAbdomen: return 800
        case .ultrasoundCardiac: return 1200
        case .bloodCulture: return 250
        case .troponinLevel: return 200
        case .dDimer: return 150
        case .arterialBloodGas: return 250
        case .lumbarPuncture: return 2500
        case .endoscopy: return 5000
        case .colonoscopy: return 6000
        case .biopsy: return 3000
        }
    }

    var ticksRequired: Int {
        switch self {
        case .physicalExam: return 1
        case .completeBloodCount: return 2
        case .basicMetabolicPanel: return 2
        case .comprehensiveMetabolicPanel: return 2
        case .chestXRay: return 2
        case .ctScanChest, .ctScanAbdomen, .ctScanHead: return 4
        case .mriBrain, .mriSpine, .mriAbdomen: return 5
        case .ecg: return 2
        case .urinalysis: return 1
        case .ultrasoundAbdomen: return 3
        case .ultrasoundCardiac: return 3
        case .bloodCulture: return 3
        case .troponinLevel: return 2
        case .dDimer: return 2
        case .arterialBloodGas: return 2
        case .lumbarPuncture: return 4
        case .endoscopy: return 6
        case .colonoscopy: return 6
        case .biopsy: return 5
        }
    }

    var requiredRoomType: RoomType {
        switch self {
        case .physicalExam: return .gpOffice
        case .completeBloodCount, .basicMetabolicPanel, .comprehensiveMetabolicPanel,
             .bloodCulture, .troponinLevel, .dDimer, .arterialBloodGas: return .bloodLab
        case .chestXRay: return .xRayRoom
        case .ctScanChest, .ctScanAbdomen, .ctScanHead: return .ctScanRoom
        case .mriBrain, .mriSpine, .mriAbdomen: return .mriRoom
        case .ecg: return .examinationRoom
        case .urinalysis: return .bloodLab
        case .ultrasoundAbdomen: return .ultrasoundRoom
        case .ultrasoundCardiac: return .ultrasoundRoom
        case .lumbarPuncture: return .examinationRoom
        case .endoscopy, .colonoscopy: return .operatingTheater
        case .biopsy: return .pathologyLab
        }
    }

    var requiredEquipment: EquipmentCategory {
        switch self {
        case .physicalExam: return .examinationBed
        case .completeBloodCount, .basicMetabolicPanel, .comprehensiveMetabolicPanel,
             .troponinLevel, .dDimer: return .chemistryAnalyzer
        case .bloodCulture: return .chemistryAnalyzer
        case .arterialBloodGas: return .bloodGasAnalyzer
        case .chestXRay: return .xRay
        case .ctScanChest, .ctScanAbdomen, .ctScanHead: return .ctScanner
        case .mriBrain, .mriSpine, .mriAbdomen: return .mri
        case .ecg: return .ecgMachine
        case .urinalysis: return .chemistryAnalyzer
        case .ultrasoundAbdomen, .ultrasoundCardiac: return .ultrasound
        case .lumbarPuncture: return .examinationBed
        case .endoscopy, .colonoscopy: return .endoscopySystem
        case .biopsy: return .microscope
        }
    }
}
