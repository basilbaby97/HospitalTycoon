import Foundation

struct DiagnosisEngine {
    /// Process all patients through the diagnosis pipeline
    static func processPatients(_ state: GameState) {
        for i in state.patients.indices {
            processPatient(index: i, state: state)
        }

        // Clean up discharged patients (keep last 50 for history)
        let discharged = state.patients.filter { $0.state == .discharged || $0.state == .deceased }
        if discharged.count > 50 {
            state.patients.removeAll { $0.state == .discharged || $0.state == .deceased }
        }
    }

    private static func processPatient(index i: Int, state: GameState) {
        guard i < state.patients.count else { return }
        let patient = state.patients[i]

        switch patient.state {
        case .arriving:
            // Move to registration queue
            if let reception = state.hospital.roomsOfType(.reception).first(where: { $0.isOperational }) {
                state.patients[i].state = .waitingForRegistration
                state.patients[i].currentRoomId = reception.id
            }

        case .waitingForRegistration:
            // Check if receptionist is available
            if let reception = state.hospital.roomsOfType(.reception).first(where: { $0.isOperational }) {
                let receptionist = state.staff.first {
                    $0.role == .receptionist && $0.assignedRoomId == reception.id && $0.isOnDuty
                }
                if receptionist != nil {
                    state.patients[i].state = .registered
                }
            }
            state.patients[i].waitTimeHours += 1
            state.patients[i].satisfaction -= GameConstants.waitTimePenaltyPerHour

        case .registered:
            // Find available GP office or exam room
            let examRooms = state.hospital.rooms.filter {
                ($0.type == .gpOffice || $0.type == .examinationRoom) && $0.isOperational
            }
            if let room = examRooms.first(where: { room in
                !state.patients.contains { $0.currentRoomId == room.id && $0.state == .inExamination }
            }) {
                state.patients[i].state = .waitingForExam
                state.patients[i].currentRoomId = room.id
            }

        case .waitingForExam:
            // Find available doctor
            guard let roomId = patient.currentRoomId else { break }
            let availableDoctor = state.staff.first {
                $0.role.isPhysician && $0.assignedRoomId == roomId && $0.isOnDuty && $0.currentTaskId == nil
            }
            if let doctor = availableDoctor {
                state.patients[i].state = .inExamination
                state.patients[i].assignedDoctorId = doctor.id

                // Generate initial differential diagnosis
                let differential = SymptomDatabase.initialDifferential(for: patient.presentingSymptoms)
                state.patients[i].differentialDiagnosis = differential

                // Determine which tests to order
                let testsToOrder = determineTests(for: state.patients[i])
                state.patients[i].orderedTests = testsToOrder

                // Mark doctor as busy
                if let docIdx = state.staff.firstIndex(where: { $0.id == doctor.id }) {
                    state.staff[docIdx].currentTaskId = patient.id
                }
            }
            state.patients[i].waitTimeHours += 1
            state.patients[i].satisfaction -= GameConstants.waitTimePenaltyPerHour

        case .inExamination:
            // Physical exam takes 1 tick, then move to tests
            state.patients[i].performedTests.append(.physicalExam)
            if state.patients[i].orderedTests.isEmpty {
                // No tests needed (simple case) - try to confirm diagnosis
                if state.patients[i].canConfirmDiagnosis {
                    confirmDiagnosis(patientIndex: i, state: state)
                } else {
                    // Order basic tests
                    state.patients[i].orderedTests = [.completeBloodCount]
                    state.patients[i].state = .awaitingTestResults
                }
            } else {
                state.patients[i].state = .awaitingTestResults
            }

        case .awaitingTestResults:
            // Process test in progress
            if let currentTest = patient.currentTestInProgress {
                state.patients[i].testProgressTicks += 1
                if state.patients[i].testProgressTicks >= currentTest.ticksRequired {
                    // Test complete
                    completeTest(patientIndex: i, testType: currentTest, state: state)
                    state.patients[i].currentTestInProgress = nil
                    state.patients[i].testProgressTicks = 0
                }
            } else if !state.patients[i].orderedTests.isEmpty {
                // Start next test if room/equipment available
                let nextTest = state.patients[i].orderedTests[0]
                if canPerformTest(nextTest, state: state) {
                    state.patients[i].orderedTests.removeFirst()
                    state.patients[i].currentTestInProgress = nextTest
                    state.patients[i].testProgressTicks = 0

                    // Move patient to appropriate room
                    if let testRoom = findRoomForTest(nextTest, state: state) {
                        state.patients[i].currentRoomId = testRoom.id
                    }
                }
            } else {
                // All tests done - check if we can diagnose
                if state.patients[i].canConfirmDiagnosis {
                    confirmDiagnosis(patientIndex: i, state: state)
                } else {
                    // Need more tests - order additional based on top differential
                    let additionalTests = suggestAdditionalTests(for: state.patients[i])
                    if additionalTests.isEmpty {
                        // Force diagnosis with what we have
                        confirmDiagnosis(patientIndex: i, state: state)
                    } else {
                        state.patients[i].orderedTests = additionalTests
                    }
                }
            }

        case .diagnosed:
            state.patients[i].state = .waitingForTreatment

        case .waitingForTreatment:
            // Find treatment room
            guard let disease = patient.confirmedDisease else { break }
            let treatmentRooms = state.hospital.roomsOfType(disease.treatmentRoom).filter { $0.isOperational }
            if let room = treatmentRooms.first(where: { room in
                let occupancy = state.patients.filter { $0.currentRoomId == room.id && $0.state == .inTreatment }.count
                return occupancy < room.patientCapacity
            }) {
                state.patients[i].state = .inTreatment
                state.patients[i].currentRoomId = room.id
                state.patients[i].treatmentTotalTicks = disease.treatmentTicks
                state.patients[i].treatmentProgressTicks = 0
            }
            state.patients[i].waitTimeHours += 1

        case .inTreatment:
            state.patients[i].treatmentProgressTicks += 1
            if state.patients[i].treatmentProgressTicks >= state.patients[i].treatmentTotalTicks {
                // Treatment complete
                completeTreatment(patientIndex: i, state: state)
            }

        case .admitted:
            // Long-stay patients
            state.patients[i].treatmentProgressTicks += 1
            if state.patients[i].treatmentProgressTicks >= state.patients[i].treatmentTotalTicks {
                completeTreatment(patientIndex: i, state: state)
            }

        case .recovering:
            // Recovery takes 12-24 ticks
            state.patients[i].treatmentProgressTicks += 1
            if state.patients[i].treatmentProgressTicks >= 12 {
                dischargePatient(patientIndex: i, state: state)
            }

        case .discharged, .deceased:
            break
        }
    }

    // MARK: - Test Logic

    private static func determineTests(for patient: Patient) -> [DiagnosticTestType] {
        // Look at top differential diagnoses and collect their required tests
        var tests: Set<DiagnosticTestType> = []

        for entry in patient.differentialDiagnosis.prefix(3) {
            if let disease = DiseaseDatabase.find(id: entry.diseaseId) {
                for test in disease.requiredTests {
                    tests.insert(test)
                }
            }
        }

        // Remove physical exam (already done)
        tests.remove(.physicalExam)

        // Sort by cost (cheapest first) to be efficient
        return tests.sorted { $0.hospitalCost < $1.hospitalCost }
    }

    private static func canPerformTest(_ test: DiagnosticTestType, state: GameState) -> Bool {
        let requiredRoom = test.requiredRoomType
        return state.hospital.roomsOfType(requiredRoom).contains { $0.isOperational }
    }

    private static func findRoomForTest(_ test: DiagnosticTestType, state: GameState) -> Room? {
        state.hospital.roomsOfType(test.requiredRoomType).first { $0.isOperational }
    }

    private static func completeTest(patientIndex: Int, testType: DiagnosticTestType, state: GameState) {
        let patient = state.patients[patientIndex]
        let doctorSkill = state.staff.first(where: { $0.id == patient.assignedDoctorId })?.effectiveSkill ?? 0.5

        // Record test as performed
        state.patients[patientIndex].performedTests.append(testType)

        // Generate test result
        let isRelevant = patient.actualDisease.requiredTests.contains(testType)
        let result = TestResult(
            testType: testType,
            findings: isRelevant ? "Abnormal findings consistent with pathology" : "Within normal limits",
            isAbnormal: isRelevant,
            affectedDiseases: isRelevant ? [patient.actualDisease.id] : [],
            completedDay: state.currentDay,
            completedHour: state.currentHour
        )
        state.patients[patientIndex].testResults.append(result)

        // Update differential diagnosis using Bayesian update
        let updatedDiff = SymptomDatabase.updateDifferential(
            current: patient.differentialDiagnosis,
            testType: testType,
            actualDisease: patient.actualDisease,
            doctorSkill: doctorSkill
        )
        state.patients[patientIndex].differentialDiagnosis = updatedDiff
    }

    private static func suggestAdditionalTests(for patient: Patient) -> [DiagnosticTestType] {
        guard let topDisease = patient.topDifferential,
              let disease = DiseaseDatabase.find(id: topDisease.diseaseId) else { return [] }

        let performedSet = Set(patient.performedTests)
        return disease.requiredTests.filter { !performedSet.contains($0) }
    }

    // MARK: - Diagnosis Confirmation

    private static func confirmDiagnosis(patientIndex: Int, state: GameState) {
        guard let top = state.patients[patientIndex].topDifferential else { return }

        let diagnosedDisease = DiseaseDatabase.find(id: top.diseaseId)
        state.patients[patientIndex].confirmedDisease = diagnosedDisease
        state.patients[patientIndex].state = .diagnosed

        // Check for misdiagnosis
        if top.diseaseId != state.patients[patientIndex].actualDisease.id {
            state.totalMisdiagnoses += 1
            state.reputation += GameConstants.misdiagnosisPenalty
        }

        // Release doctor
        if let docId = state.patients[patientIndex].assignedDoctorId,
           let docIdx = state.staff.firstIndex(where: { $0.id == docId }) {
            state.staff[docIdx].currentTaskId = nil
        }
    }

    // MARK: - Treatment Completion

    private static func completeTreatment(patientIndex: Int, state: GameState) {
        let patient = state.patients[patientIndex]
        let isCorrectDiagnosis = patient.confirmedDisease?.id == patient.actualDisease.id

        // Treatment success based on diagnosis accuracy and staff skill
        let baseSuccessRate = isCorrectDiagnosis ? 0.90 : 0.40
        let doctorSkill = state.staff.first(where: { $0.id == patient.assignedDoctorId })?.effectiveSkill ?? 0.5
        let successRate = baseSuccessRate * (0.7 + doctorSkill * 0.3)

        let isSuccessful = Double.random(in: 0...1) < successRate

        if isSuccessful {
            state.patients[patientIndex].state = .recovering
            state.patients[patientIndex].isTreatmentSuccessful = true
            state.patients[patientIndex].treatmentProgressTicks = 0

            let severity = patient.confirmedDisease?.severity ?? .mild
            state.reputation = min(GameConstants.maxReputation,
                                   state.reputation + GameConstants.successfulTreatmentBonus * severity.reputationImpact)
        } else {
            // Treatment failed
            let mortalityRisk = patient.actualDisease.mortalityRisk * (isCorrectDiagnosis ? 0.5 : 1.5)
            if Double.random(in: 0...1) < mortalityRisk {
                state.patients[patientIndex].state = .deceased
                state.patients[patientIndex].isTreatmentSuccessful = false
                state.reputation += GameConstants.misdiagnosisPenalty * 2
            } else {
                // Patient needs more treatment - re-admit
                state.patients[patientIndex].state = .admitted
                state.patients[patientIndex].treatmentProgressTicks = 0
                state.patients[patientIndex].treatmentTotalTicks *= 2
            }
        }
    }

    private static func dischargePatient(patientIndex: Int, state: GameState) {
        state.patients[patientIndex].state = .discharged
        state.patients[patientIndex].currentRoomId = nil
        state.totalPatientsDischarged += 1

        // Submit claim
        RevenueEngine.submitClaim(for: state.patients[patientIndex], state: state)
    }
}
