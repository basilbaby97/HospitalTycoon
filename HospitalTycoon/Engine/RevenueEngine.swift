import Foundation

struct RevenueEngine {
    /// Submit a claim after patient discharge
    static func submitClaim(for patient: Patient, state: GameState) {
        guard let disease = patient.confirmedDisease else { return }

        let totalCharges = calculateTotalCharges(patient: patient)
        let medicareBase = disease.baseMedicarePayment
        let contract = state.insuranceContracts.first { $0.payerType == patient.payerType && $0.isActive }
        let rate = contract?.negotiatedRate ?? patient.payerType.baseReimbursementRate
        let expectedReimbursement = medicareBase * rate

        let claim = InsuranceClaim(
            patientId: patient.id,
            patientName: patient.name,
            payerType: patient.payerType,
            drgCode: disease.drgCode,
            drgDescription: disease.name,
            cptCodes: patient.performedTests.map { $0.cptCode },
            totalCharges: totalCharges,
            expectedReimbursement: expectedReimbursement,
            submittedDay: TimeManager.totalDays(for: state)
        )

        state.claims.append(claim)
        state.finance.submitClaim(
            amount: expectedReimbursement,
            description: "Claim submitted: \(disease.name) [\(patient.payerType.displayName)]",
            day: state.currentDay
        )

        // Collect copay immediately (if applicable)
        let profile = InsuranceData.profile(for: patient.payerType)
        if profile.copayRange.upperBound > 0 {
            let copay = Double(Int.random(in: profile.copayRange))
            state.finance.cashBalance += copay
            state.finance.addTransaction(
                type: .patientCopay,
                amount: copay,
                description: "Copay from \(patient.name)",
                day: state.currentDay
            )
        }
    }

    /// Process claims for the current day (adjudication, payment, denial)
    static func processClaimsForDay(_ state: GameState) {
        let currentTotalDay = TimeManager.totalDays(for: state)

        for i in state.claims.indices {
            var claim = state.claims[i]
            guard !claim.isResolved else { continue }

            switch claim.status {
            case .submitted:
                let daysElapsed = currentTotalDay - claim.submittedDay
                let processingDays = claim.payerType.avgProcessingDays
                if daysElapsed >= processingDays {
                    // Adjudication decision
                    let isDenied = Double.random(in: 0...1) < claim.payerType.denialRate
                    if isDenied {
                        claim.status = .denied
                        claim.adjudicationDay = currentTotalDay
                        claim.denialReason = DenialReason.allCases.randomElement()
                        state.finance.accountsReceivable -= claim.expectedReimbursement
                        state.finance.addTransaction(
                            type: .claimDenied,
                            amount: 0,
                            description: "DENIED: \(claim.drgDescription) - \(claim.denialReason?.rawValue ?? "")",
                            day: state.currentDay
                        )
                    } else {
                        // Paid!
                        claim.status = .paid
                        claim.adjudicationDay = currentTotalDay
                        claim.paidDay = currentTotalDay
                        let payment = claim.expectedReimbursement * claim.payerType.collectionRate
                        claim.actualPayment = payment
                        state.finance.receivePayment(
                            amount: payment,
                            fromAR: true,
                            description: "Payment: \(claim.drgDescription) [\(claim.payerType.displayName)]",
                            day: state.currentDay
                        )
                    }
                }

            case .denied:
                // Auto-appeal high-value claims
                if claim.expectedReimbursement > 2000 {
                    claim.status = .appealed
                    claim.appealStatus = .submitted
                    state.finance.cashBalance -= GameConstants.appealStaffTimeCost
                    state.finance.addTransaction(
                        type: .miscExpense,
                        amount: -GameConstants.appealStaffTimeCost,
                        description: "Appeal filed: \(claim.drgDescription)",
                        day: state.currentDay
                    )
                } else {
                    claim.status = .writtenOff
                }

            case .appealed:
                if let adjDay = claim.adjudicationDay {
                    let daysSinceAppeal = currentTotalDay - adjDay
                    if daysSinceAppeal >= 30 { // Appeals take ~30 days
                        let successRate = claim.denialReason?.appealSuccessRate ?? GameConstants.appealSuccessRate
                        let appealWon = Double.random(in: 0...1) < successRate
                        if appealWon {
                            claim.status = .paid
                            claim.appealStatus = .approved
                            claim.paidDay = currentTotalDay
                            let payment = claim.expectedReimbursement * claim.payerType.collectionRate
                            claim.actualPayment = payment
                            state.finance.accountsReceivable += claim.expectedReimbursement
                            state.finance.receivePayment(
                                amount: payment,
                                fromAR: true,
                                description: "Appeal won: \(claim.drgDescription)",
                                day: state.currentDay
                            )
                        } else {
                            claim.status = .deniedFinal
                            claim.appealStatus = .denied
                        }
                    }
                }

            default:
                break
            }

            state.claims[i] = claim
        }
    }

    private static func calculateTotalCharges(patient: Patient) -> Double {
        var total = 0.0
        for test in patient.performedTests {
            total += Double(test.chargeAmount)
        }
        // Add treatment charges
        if let disease = patient.confirmedDisease {
            total += disease.baseMedicarePayment * 1.5 // Hospitals charge ~150% of Medicare
        }
        return total
    }
}
