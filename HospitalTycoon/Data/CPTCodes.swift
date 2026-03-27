import Foundation

struct CPTCodeEntry: Codable {
    let code: String
    let description: String
    let category: CPTCategory
    let hospitalCost: Double
    let chargeAmount: Double
    let medicareReimbursement: Double
}

enum CPTCategory: String, Codable {
    case evaluationManagement = "E&M"
    case surgery = "Surgery"
    case radiology = "Radiology"
    case pathologyLab = "Pathology/Lab"
    case medicine = "Medicine"
    case anesthesia = "Anesthesia"
}

struct CPTCodes {
    static let all: [CPTCodeEntry] = [
        // Evaluation & Management
        CPTCodeEntry(code: "99213", description: "Office visit, established patient, low complexity",
                     category: .evaluationManagement, hospitalCost: 50, chargeAmount: 150, medicareReimbursement: 92),
        CPTCodeEntry(code: "99214", description: "Office visit, established patient, moderate complexity",
                     category: .evaluationManagement, hospitalCost: 70, chargeAmount: 220, medicareReimbursement: 130),
        CPTCodeEntry(code: "99215", description: "Office visit, established patient, high complexity",
                     category: .evaluationManagement, hospitalCost: 100, chargeAmount: 350, medicareReimbursement: 185),
        CPTCodeEntry(code: "99281", description: "ED visit, self-limited problem",
                     category: .evaluationManagement, hospitalCost: 80, chargeAmount: 300, medicareReimbursement: 150),
        CPTCodeEntry(code: "99285", description: "ED visit, high severity with threat to life",
                     category: .evaluationManagement, hospitalCost: 300, chargeAmount: 1500, medicareReimbursement: 750),

        // Radiology
        CPTCodeEntry(code: "71046", description: "Chest X-ray, 2 views",
                     category: .radiology, hospitalCost: 55, chargeAmount: 410, medicareReimbursement: 45),
        CPTCodeEntry(code: "71260", description: "CT chest with contrast",
                     category: .radiology, hospitalCost: 51, chargeAmount: 1565, medicareReimbursement: 250),
        CPTCodeEntry(code: "74178", description: "CT abdomen/pelvis with contrast",
                     category: .radiology, hospitalCost: 60, chargeAmount: 1800, medicareReimbursement: 280),
        CPTCodeEntry(code: "70553", description: "MRI brain with/without contrast",
                     category: .radiology, hospitalCost: 165, chargeAmount: 2048, medicareReimbursement: 400),
        CPTCodeEntry(code: "72148", description: "MRI lumbar spine without contrast",
                     category: .radiology, hospitalCost: 170, chargeAmount: 2200, medicareReimbursement: 380),
        CPTCodeEntry(code: "76700", description: "Ultrasound abdomen complete",
                     category: .radiology, hospitalCost: 100, chargeAmount: 800, medicareReimbursement: 150),
        CPTCodeEntry(code: "93306", description: "Echocardiography, complete",
                     category: .radiology, hospitalCost: 120, chargeAmount: 1200, medicareReimbursement: 250),

        // Pathology/Lab
        CPTCodeEntry(code: "85025", description: "Complete blood count (CBC) with differential",
                     category: .pathologyLab, hospitalCost: 15, chargeAmount: 100, medicareReimbursement: 11),
        CPTCodeEntry(code: "80048", description: "Basic metabolic panel",
                     category: .pathologyLab, hospitalCost: 20, chargeAmount: 200, medicareReimbursement: 15),
        CPTCodeEntry(code: "80053", description: "Comprehensive metabolic panel",
                     category: .pathologyLab, hospitalCost: 25, chargeAmount: 250, medicareReimbursement: 18),
        CPTCodeEntry(code: "87040", description: "Blood culture",
                     category: .pathologyLab, hospitalCost: 30, chargeAmount: 250, medicareReimbursement: 20),
        CPTCodeEntry(code: "84484", description: "Troponin, quantitative",
                     category: .pathologyLab, hospitalCost: 20, chargeAmount: 200, medicareReimbursement: 25),
        CPTCodeEntry(code: "85379", description: "D-Dimer, quantitative",
                     category: .pathologyLab, hospitalCost: 15, chargeAmount: 150, medicareReimbursement: 18),
        CPTCodeEntry(code: "82803", description: "Arterial blood gas",
                     category: .pathologyLab, hospitalCost: 25, chargeAmount: 250, medicareReimbursement: 30),
        CPTCodeEntry(code: "81001", description: "Urinalysis with microscopy",
                     category: .pathologyLab, hospitalCost: 10, chargeAmount: 80, medicareReimbursement: 8),
        CPTCodeEntry(code: "88305", description: "Surgical pathology (biopsy)",
                     category: .pathologyLab, hospitalCost: 300, chargeAmount: 3000, medicareReimbursement: 120),

        // Medicine
        CPTCodeEntry(code: "93000", description: "Electrocardiogram (ECG), complete",
                     category: .medicine, hospitalCost: 25, chargeAmount: 300, medicareReimbursement: 35),

        // Surgery
        CPTCodeEntry(code: "47562", description: "Laparoscopic cholecystectomy",
                     category: .surgery, hospitalCost: 2000, chargeAmount: 15000, medicareReimbursement: 5200),
        CPTCodeEntry(code: "44970", description: "Laparoscopic appendectomy",
                     category: .surgery, hospitalCost: 1800, chargeAmount: 12000, medicareReimbursement: 4500),
        CPTCodeEntry(code: "27447", description: "Total knee replacement",
                     category: .surgery, hospitalCost: 5000, chargeAmount: 35000, medicareReimbursement: 12000),
        CPTCodeEntry(code: "27130", description: "Total hip replacement",
                     category: .surgery, hospitalCost: 5500, chargeAmount: 38000, medicareReimbursement: 13000),
        CPTCodeEntry(code: "33533", description: "Coronary artery bypass (CABG), single",
                     category: .surgery, hospitalCost: 15000, chargeAmount: 80000, medicareReimbursement: 30000),
        CPTCodeEntry(code: "43239", description: "Upper GI endoscopy with biopsy",
                     category: .surgery, hospitalCost: 500, chargeAmount: 5000, medicareReimbursement: 1500),
        CPTCodeEntry(code: "45378", description: "Colonoscopy, diagnostic",
                     category: .surgery, hospitalCost: 600, chargeAmount: 6000, medicareReimbursement: 1800),
        CPTCodeEntry(code: "62270", description: "Lumbar puncture",
                     category: .surgery, hospitalCost: 200, chargeAmount: 2500, medicareReimbursement: 800),
    ]

    static func find(code: String) -> CPTCodeEntry? {
        all.first { $0.code == code }
    }

    static func entries(for category: CPTCategory) -> [CPTCodeEntry] {
        all.filter { $0.category == category }
    }
}
