import Foundation

struct TimeManager {
    static func advanceHour(_ state: GameState) {
        state.currentHour += 1

        if state.currentHour >= GameConstants.hoursPerDay {
            state.currentHour = 0
            advanceDay(state)
        }
    }

    private static func advanceDay(_ state: GameState) {
        state.currentDay += 1

        if state.currentDay > GameConstants.daysPerMonth {
            state.currentDay = 1
            advanceMonth(state)
        }

        // Daily tasks
        onNewDay(state)
    }

    private static func advanceMonth(_ state: GameState) {
        state.currentMonth += 1

        if state.currentMonth > GameConstants.monthsPerYear {
            state.currentMonth = 1
            state.currentYear += 1
        }

        // Monthly tasks
        onNewMonth(state)
    }

    private static func onNewDay(_ state: GameState) {
        // Pay daily salaries
        ExpenseEngine.processDailySalaries(state)

        // Degrade equipment
        ExpenseEngine.degradeEquipment(state)

        // Process claims
        RevenueEngine.processClaimsForDay(state)

        // Reputation decay
        state.reputation = max(
            GameConstants.minReputation,
            state.reputation - GameConstants.reputationDecayPerDay
        )

        // Staff fatigue recovery for off-duty staff
        for i in state.staff.indices {
            if !state.staff[i].isOnDuty {
                state.staff[i].fatigue = max(0, state.staff[i].fatigue - GameConstants.restRecoveryPerHour * 8)
            }
        }

        // Auto-save check
        if state.currentDay % GameConstants.autoSaveIntervalDays == 0 {
            SaveManager.shared.saveGame(state)
        }
    }

    private static func onNewMonth(_ state: GameState) {
        // Monthly equipment maintenance costs
        ExpenseEngine.processMonthlyMaintenance(state)

        // Monthly supply costs
        ExpenseEngine.processMonthlySupplies(state)

        // Record monthly financials
        let monthKey = state.currentYear * 100 + state.currentMonth
        state.finance.monthlyRevenue[monthKey] = state.finance.totalRevenue
        state.finance.monthlyExpenses[monthKey] = state.finance.totalExpenses

        // Check insurance contract expirations
        for i in state.insuranceContracts.indices {
            if state.insuranceContracts[i].isActive {
                let totalDays = (state.currentYear - 2026) * 360 + (state.currentMonth - 1) * 30 + state.currentDay
                if totalDays >= state.insuranceContracts[i].expirationDay {
                    state.insuranceContracts[i].isActive = false
                }
            }
        }
    }

    static var isOperatingHours: Bool {
        true // simplified: always operating for now
    }

    static func totalDays(for state: GameState) -> Int {
        (state.currentYear - 2026) * 360 + (state.currentMonth - 1) * 30 + state.currentDay
    }
}
