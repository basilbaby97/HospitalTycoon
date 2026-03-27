import XCTest
@testable import HospitalTycoon

final class HospitalTycoonTests: XCTestCase {

    func testGameStateInitialization() {
        let state = GameState()
        XCTAssertEqual(state.hospitalName, "General Hospital")
        XCTAssertEqual(state.currentDay, 1)
        XCTAssertEqual(state.currentHour, 8)
        XCTAssertTrue(state.patients.isEmpty)
        XCTAssertTrue(state.staff.isEmpty)
        XCTAssertEqual(state.finance.cashBalance, Double(GameConstants.startingCash))
    }

    func testHospitalGridSetup() {
        let hospital = Hospital()
        XCTAssertEqual(hospital.gridWidth, GameConstants.gridWidth)
        XCTAssertEqual(hospital.gridHeight, GameConstants.gridHeight)
    }

    func testRoomPlacement() {
        let hospital = Hospital()
        let def = RoomDefinitions.definition(for: .gpOffice)
        let room = Room(
            type: .gpOffice,
            origin: GridPosition(x: 5, y: 5),
            width: def.width,
            height: def.height,
            department: .internalMedicine
        )

        XCTAssertTrue(hospital.canPlaceRoom(room))
        var mutableHospital = hospital
        mutableHospital.placeRoom(room)
        XCTAssertEqual(mutableHospital.rooms.count, 1)
    }

    func testEquipmentCatalog() {
        let allEquipment = EquipmentCatalog.allEquipment
        XCTAssertFalse(allEquipment.isEmpty)
        XCTAssertTrue(allEquipment.count >= 40)

        // Verify real brands exist
        let brands = EquipmentCatalog.allBrands
        XCTAssertTrue(brands.contains("GE Healthcare"))
        XCTAssertTrue(brands.contains("Siemens Healthineers"))
        XCTAssertTrue(brands.contains("Philips"))
    }

    func testDiseaseDatabase() {
        let diseases = DiseaseDatabase.allDiseases
        XCTAssertEqual(diseases.count, 25)

        // Verify DRG codes exist
        for disease in diseases {
            XCTAssertFalse(disease.drgCode.isEmpty)
            XCTAssertFalse(disease.icdCode.isEmpty)
            XCTAssertGreaterThan(disease.baseMedicarePayment, 0)
        }
    }

    func testInsurancePayerRates() {
        for payer in PayerType.allCases {
            XCTAssertGreaterThan(payer.reimbursementRate, 0)
            if payer != .selfPay {
                XCTAssertGreaterThan(payer.averageProcessingDays, 0)
            }
        }
    }

    func testStaffSalaryRanges() {
        for role in StaffRole.allCases {
            let range = StaffTemplates.salaryRange(for: role)
            XCTAssertGreaterThan(range.min, 0)
            XCTAssertGreaterThanOrEqual(range.max, range.min)
        }
    }

    func testSymptomDifferentialGeneration() {
        let symptoms: [SymptomPresentation] = [
            SymptomPresentation(symptom: .fever, severity: 0.8),
            SymptomPresentation(symptom: .cough, severity: 0.7),
            SymptomPresentation(symptom: .shortnessOfBreath, severity: 0.6)
        ]

        let differential = SymptomDatabase.initialDifferential(for: symptoms)
        XCTAssertFalse(differential.isEmpty)

        // Probabilities should sum to approximately 1.0
        let totalProb = differential.map(\.probability).reduce(0, +)
        XCTAssertEqual(totalProb, 1.0, accuracy: 0.01)
    }

    func testCPTCodes() {
        let codes = CPTCodeDatabase.allCodes
        XCTAssertFalse(codes.isEmpty)

        for code in codes {
            XCTAssertFalse(code.code.isEmpty)
            XCTAssertGreaterThan(code.hospitalCost, 0)
            XCTAssertGreaterThan(code.chargeAmount, code.hospitalCost)
        }
    }

    func testRevenueCalculation() {
        // Medicare baseline
        let medicareRate = PayerType.medicare.reimbursementRate
        XCTAssertEqual(medicareRate, 1.0)

        // Commercial should be higher than Medicare
        XCTAssertGreaterThan(PayerType.unitedHealthcare.reimbursementRate, medicareRate)
        XCTAssertGreaterThan(PayerType.blueCrossBlueshield.reimbursementRate, medicareRate)

        // Medicaid should be lower
        XCTAssertLessThan(PayerType.medicaid.reimbursementRate, medicareRate)
    }
}
