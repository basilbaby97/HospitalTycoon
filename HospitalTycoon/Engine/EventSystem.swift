import Foundation

struct EventSystem {
    /// Roll for random events each tick
    static func checkForEvents(_ state: GameState) {
        // Only check once per day (at hour 8)
        guard state.currentHour == 8 else { return }

        let roll = Double.random(in: 0...1)
        if roll < GameConstants.eventProbabilityPerDay {
            let event = generateEvent(state)
            applyEvent(event, state: state)
            state.activeEvents.append(event)
        }

        // Expire old events
        expireEvents(state)
    }

    private static func generateEvent(_ state: GameState) -> GameEvent {
        let eventType = weightedRandomEvent(state)
        let event: GameEvent

        switch eventType {
        case .fluSeason:
            event = GameEvent(
                type: .fluSeason,
                title: "Flu Season Outbreak",
                description: "A severe flu strain is spreading in the community. Expect a 50% increase in respiratory patients for the next 30 days.",
                startDay: state.currentDay,
                durationDays: 30,
                financialImpact: 0,
                reputationImpact: 0
            )

        case .equipmentFailure:
            let equipment = state.hospital.installedEquipment.filter { $0.isOperational }.randomElement()
            let name = equipment?.template?.name ?? "Equipment"
            let repairCost = Int(Double(equipment?.template?.purchaseCost ?? 50000) * 0.15)
            event = GameEvent(
                type: .equipmentFailure,
                title: "Equipment Malfunction",
                description: "\(name) has experienced a critical failure. Emergency repair cost: $\(repairCost.formatted()). The unit will be offline for 3 days.",
                startDay: state.currentDay,
                durationDays: 3,
                financialImpact: -Double(repairCost),
                reputationImpact: -2.0,
                affectedEquipmentId: equipment?.id
            )

        case .cmsAudit:
            let claimsUnderReview = min(5, state.claims.filter { $0.status == .paid }.count)
            event = GameEvent(
                type: .cmsAudit,
                title: "CMS Compliance Audit",
                description: "The Centers for Medicare & Medicaid Services is auditing \(claimsUnderReview) recent claims. Potential clawbacks if documentation is insufficient.",
                startDay: state.currentDay,
                durationDays: 14,
                financialImpact: 0,
                reputationImpact: -3.0
            )

        case .staffBurnout:
            let overworked = state.staff.filter { $0.isOnDuty && $0.fatigue > 70 }
            let affected = overworked.first
            let name = affected?.name ?? "A staff member"
            event = GameEvent(
                type: .staffBurnout,
                title: "Staff Burnout",
                description: "\(name) is experiencing severe burnout and will need extended time off. Consider hiring additional staff to reduce workload.",
                startDay: state.currentDay,
                durationDays: 7,
                financialImpact: 0,
                reputationImpact: -1.0,
                affectedStaffId: affected?.id
            )

        case .vipPatient:
            event = GameEvent(
                type: .vipPatient,
                title: "VIP Patient Arrival",
                description: "A high-profile patient is arriving at your hospital. Excellent care will significantly boost your reputation. Poor care will make headlines.",
                startDay: state.currentDay,
                durationDays: 5,
                financialImpact: 25000,
                reputationImpact: 0
            )

        case .malpracticeLawsuit:
            let settlementCost = Int.random(in: 100_000...500_000)
            event = GameEvent(
                type: .malpracticeLawsuit,
                title: "Malpractice Lawsuit Filed",
                description: "A former patient has filed a malpractice claim. Legal fees and potential settlement: $\(settlementCost.formatted()). Case will take 30 days to resolve.",
                startDay: state.currentDay,
                durationDays: 30,
                financialImpact: -Double(settlementCost),
                reputationImpact: -8.0
            )

        case .insuranceRateChange:
            let payer = PayerType.allCases.filter { $0 != .selfPay }.randomElement() ?? .medicare
            let changePercent = Int.random(in: -8...5)
            let direction = changePercent >= 0 ? "increase" : "decrease"
            event = GameEvent(
                type: .insuranceRateChange,
                title: "\(payer.displayName) Rate Change",
                description: "\(payer.displayName) has announced a \(abs(changePercent))% \(direction) in reimbursement rates effective immediately.",
                startDay: state.currentDay,
                durationDays: 90,
                financialImpact: 0,
                reputationImpact: 0,
                rateChangePercent: Double(changePercent) / 100.0,
                affectedPayer: payer
            )

        case .jointCommissionInspection:
            event = GameEvent(
                type: .jointCommissionInspection,
                title: "Joint Commission Inspection",
                description: "The Joint Commission is conducting an unannounced survey. Hospitals with good staffing ratios and equipment maintenance will pass. Failure results in reputation loss.",
                startDay: state.currentDay,
                durationDays: 3,
                financialImpact: -15000,
                reputationImpact: 0
            )

        case .communityOutreach:
            event = GameEvent(
                type: .communityOutreach,
                title: "Community Health Fair",
                description: "Your hospital has been invited to sponsor a community health fair. This will boost your visibility and attract new patients.",
                startDay: state.currentDay,
                durationDays: 1,
                financialImpact: -5000,
                reputationImpact: 5.0
            )

        case .technologyGrant:
            let grantAmount = Int.random(in: 50_000...250_000)
            event = GameEvent(
                type: .technologyGrant,
                title: "Technology Innovation Grant",
                description: "Your hospital has been awarded a $\(grantAmount.formatted()) federal grant for healthcare technology improvement.",
                startDay: state.currentDay,
                durationDays: 1,
                financialImpact: Double(grantAmount),
                reputationImpact: 3.0
            )

        case .naturalDisaster:
            event = GameEvent(
                type: .naturalDisaster,
                title: "Severe Weather Emergency",
                description: "A major storm has caused mass casualties in the area. Expect a surge of trauma patients over the next 3 days. Emergency services are at full capacity.",
                startDay: state.currentDay,
                durationDays: 3,
                financialImpact: -20000,
                reputationImpact: 0
            )
        }

        return event
    }

    private static func weightedRandomEvent(_ state: GameState) -> GameEventType {
        var weights: [(GameEventType, Double)] = [
            (.fluSeason, 0.12),
            (.equipmentFailure, 0.18),
            (.cmsAudit, 0.08),
            (.staffBurnout, 0.15),
            (.vipPatient, 0.10),
            (.malpracticeLawsuit, 0.05),
            (.insuranceRateChange, 0.10),
            (.jointCommissionInspection, 0.05),
            (.communityOutreach, 0.08),
            (.technologyGrant, 0.04),
            (.naturalDisaster, 0.05),
        ]

        // Increase flu season chance in winter months
        if state.currentMonth >= 11 || state.currentMonth <= 2 {
            if let idx = weights.firstIndex(where: { $0.0 == .fluSeason }) {
                weights[idx].1 *= 2.0
            }
        }

        // Increase equipment failure if equipment is old/worn
        let avgCondition = state.hospital.installedEquipment.isEmpty ? 100.0 :
            state.hospital.installedEquipment.map(\.condition).reduce(0, +) / Double(state.hospital.installedEquipment.count)
        if avgCondition < 60 {
            if let idx = weights.firstIndex(where: { $0.0 == .equipmentFailure }) {
                weights[idx].1 *= 1.5
            }
        }

        // Increase burnout if staff is overworked
        let avgFatigue = state.staff.isEmpty ? 0.0 :
            state.staff.map(\.fatigue).reduce(0, +) / Double(state.staff.count)
        if avgFatigue > 60 {
            if let idx = weights.firstIndex(where: { $0.0 == .staffBurnout }) {
                weights[idx].1 *= 1.5
            }
        }

        // Increase malpractice risk if misdiagnosis rate is high
        if state.totalMisdiagnoses > 5 {
            if let idx = weights.firstIndex(where: { $0.0 == .malpracticeLawsuit }) {
                weights[idx].1 *= 2.0
            }
        }

        let totalWeight = weights.map(\.1).reduce(0, +)
        var roll = Double.random(in: 0..<totalWeight)

        for (eventType, weight) in weights {
            roll -= weight
            if roll <= 0 {
                return eventType
            }
        }

        return .equipmentFailure
    }

    static func applyEvent(_ event: GameEvent, state: GameState) {
        // Immediate financial impact
        if event.financialImpact != 0 {
            if event.financialImpact > 0 {
                state.finance.recordPayment(amount: event.financialImpact, type: .otherRevenue,
                                            description: event.title, day: state.currentDay)
            } else {
                state.finance.recordExpense(amount: abs(event.financialImpact), type: .otherExpense,
                                            description: event.title, day: state.currentDay)
            }
        }

        // Reputation impact
        if event.reputationImpact != 0 {
            state.reputation = max(0, min(GameConstants.maxReputation,
                                          state.reputation + event.reputationImpact))
        }

        // Type-specific effects
        switch event.type {
        case .equipmentFailure:
            if let eqId = event.affectedEquipmentId,
               let idx = state.hospital.installedEquipment.firstIndex(where: { $0.id == eqId }) {
                state.hospital.installedEquipment[idx].condition = 0
            }

        case .staffBurnout:
            if let staffId = event.affectedStaffId,
               let idx = state.staff.firstIndex(where: { $0.id == staffId }) {
                state.staff[idx].isOnDuty = false
                state.staff[idx].fatigue = GameConstants.maxStaffFatigue
                state.staff[idx].satisfaction -= 20
            }

        case .cmsAudit:
            // Review recent paid claims - chance of clawback
            let paidClaims = state.claims.filter { $0.status == .paid }.suffix(5)
            for claim in paidClaims {
                if Double.random(in: 0...1) < 0.2 {
                    // Clawback
                    let clawback = (claim.actualPayment ?? 0) * 0.5
                    state.finance.recordExpense(amount: clawback, type: .otherExpense,
                                                description: "CMS Audit Clawback", day: state.currentDay)
                }
            }

        case .jointCommissionInspection:
            // Evaluate hospital quality
            let staffRatio = Double(state.staff.filter(\.isOnDuty).count) / max(1, Double(state.hospital.rooms.count))
            let equipmentHealth = state.hospital.installedEquipment.isEmpty ? 100.0 :
                state.hospital.installedEquipment.map(\.condition).reduce(0, +) / Double(state.hospital.installedEquipment.count)

            if staffRatio >= 1.0 && equipmentHealth >= 70 {
                state.reputation = min(GameConstants.maxReputation, state.reputation + 10)
                state.activeEvents[state.activeEvents.count - 1].description += " PASSED - Excellent rating!"
            } else {
                state.reputation = max(0, state.reputation - 10)
                state.activeEvents[state.activeEvents.count - 1].description += " FAILED - Deficiencies noted."
            }

        case .insuranceRateChange:
            if let payer = event.affectedPayer, let rateChange = event.rateChangePercent {
                if let idx = state.insuranceContracts.firstIndex(where: { $0.payerType == payer }) {
                    state.insuranceContracts[idx].negotiatedRate *= (1.0 + rateChange)
                }
            }

        default:
            break
        }
    }

    private static func expireEvents(_ state: GameState) {
        state.activeEvents.removeAll { event in
            state.currentDay >= event.startDay + event.durationDays
        }
    }

    /// Check if flu season event is active (used by PatientGenerator)
    static func isFluSeasonActive(_ state: GameState) -> Bool {
        state.activeEvents.contains { $0.type == .fluSeason }
    }

    /// Check if natural disaster is active (used by PatientGenerator)
    static func isEmergencySurge(_ state: GameState) -> Bool {
        state.activeEvents.contains { $0.type == .naturalDisaster }
    }
}
