import Foundation

struct ExpenseEngine {
    /// Process daily salary expenses
    static func processDailySalaries(_ state: GameState) {
        let dailyTotal = state.staff.reduce(0.0) { $0 + $1.dailySalary }
        guard dailyTotal > 0 else { return }

        state.finance.paySalaries(amount: dailyTotal, day: state.currentDay)
    }

    /// Monthly equipment maintenance costs
    static func processMonthlyMaintenance(_ state: GameState) {
        var totalMaintenance = 0.0

        for equipment in state.hospital.installedEquipment {
            if let template = equipment.template {
                totalMaintenance += template.monthlyMaintenance
            }
        }

        guard totalMaintenance > 0 else { return }
        state.finance.payMaintenance(
            amount: totalMaintenance,
            description: "Equipment maintenance (\(state.hospital.installedEquipment.count) items)",
            day: state.currentDay
        )
    }

    /// Monthly supply costs (based on patient volume and rooms)
    static func processMonthlySupplies(_ state: GameState) {
        let baseSupplyCost = Double(state.hospital.rooms.count) * 500 // $500/room/month base
        let patientSupplyCost = Double(state.totalPatientsServed) * 50 // $50 per patient served

        let totalSupplies = baseSupplyCost + patientSupplyCost
        guard totalSupplies > 0 else { return }

        // Supply room discount
        let hasSupplyRoom = state.hospital.roomsOfType(.supplyRoom).count > 0
        let discount = hasSupplyRoom ? 0.95 : 1.0

        let finalCost = totalSupplies * discount
        state.finance.cashBalance -= finalCost
        state.finance.addTransaction(
            type: .supplies,
            amount: -finalCost,
            description: "Monthly medical supplies",
            day: state.currentDay
        )
    }

    /// Degrade equipment condition daily
    static func degradeEquipment(_ state: GameState) {
        for i in state.hospital.installedEquipment.indices {
            state.hospital.installedEquipment[i].condition -= GameConstants.equipmentDegradationPerDay

            // Equipment failure
            if state.hospital.installedEquipment[i].condition <= GameConstants.equipmentFailureThreshold {
                if let template = state.hospital.installedEquipment[i].template {
                    let repairCost = template.monthlyMaintenance // Emergency repair = 1 month maintenance
                    state.finance.cashBalance -= Double(repairCost)
                    state.finance.addTransaction(
                        type: .maintenance,
                        amount: -Double(repairCost),
                        description: "Emergency repair: \(template.brand) \(template.name)",
                        day: state.currentDay
                    )
                    state.hospital.installedEquipment[i].condition = 50.0 // Partial restore
                    state.hospital.installedEquipment[i].lastMaintenanceDay = TimeManager.totalDays(for: state)
                }
            }
        }
    }

    /// Calculate current operating margin
    static func currentOperatingMargin(_ state: GameState) -> Double {
        state.finance.operatingMargin
    }

    /// Calculate labor cost as percentage of total expenses
    static func laborCostPercentage(_ state: GameState) -> Double {
        guard state.finance.totalExpenses > 0 else { return 0 }
        let annualLabor = state.totalStaffCostPerYear
        let dailyLabor = annualLabor / 365.0
        let totalDays = max(1, TimeManager.totalDays(for: state))
        let totalLaborToDate = dailyLabor * Double(totalDays)
        return totalLaborToDate / state.finance.totalExpenses
    }
}
