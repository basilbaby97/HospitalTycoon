import Foundation

struct Finance: Codable {
    var cashBalance: Double
    var accountsReceivable: Double = 0
    var totalRevenue: Double = 0
    var totalExpenses: Double = 0
    var transactions: [FinancialTransaction] = []
    var monthlyRevenue: [Int: Double] = [:] // month -> revenue
    var monthlyExpenses: [Int: Double] = [:] // month -> expenses

    init(cashBalance: Double) {
        self.cashBalance = cashBalance
    }

    var operatingMargin: Double {
        guard totalRevenue > 0 else { return 0 }
        return (totalRevenue - totalExpenses) / totalRevenue
    }

    var netIncome: Double {
        totalRevenue - totalExpenses
    }

    mutating func addTransaction(type: TransactionType, amount: Double, description: String, day: Int) {
        let transaction = FinancialTransaction(
            id: UUID(),
            type: type,
            amount: amount,
            description: description,
            day: day
        )
        transactions.append(transaction)

        if amount > 0 {
            totalRevenue += amount
        } else {
            totalExpenses += abs(amount)
        }
    }

    mutating func receivePayment(amount: Double, fromAR: Bool, description: String, day: Int) {
        cashBalance += amount
        if fromAR {
            accountsReceivable -= amount
        }
        addTransaction(type: .claimPayment, amount: amount, description: description, day: day)
    }

    mutating func submitClaim(amount: Double, description: String, day: Int) {
        accountsReceivable += amount
        addTransaction(type: .claimSubmitted, amount: 0, description: description, day: day)
    }

    mutating func paySalaries(amount: Double, day: Int) {
        cashBalance -= amount
        addTransaction(type: .salary, amount: -amount, description: "Staff salaries", day: day)
    }

    mutating func payMaintenance(amount: Double, description: String, day: Int) {
        cashBalance -= amount
        addTransaction(type: .maintenance, amount: -amount, description: description, day: day)
    }

    // Recent transactions (last 50)
    var recentTransactions: [FinancialTransaction] {
        Array(transactions.suffix(50).reversed())
    }
}

// MARK: - Transaction

struct FinancialTransaction: Codable, Identifiable {
    let id: UUID
    let type: TransactionType
    let amount: Double // positive = income, negative = expense
    let description: String
    let day: Int
}

enum TransactionType: String, Codable {
    case claimPayment     // Insurance payment received
    case claimSubmitted   // Claim submitted to payer
    case claimDenied      // Claim denied
    case salary           // Staff salary
    case construction     // Room building
    case equipmentPurchase // Equipment purchase
    case maintenance      // Equipment maintenance
    case supplies         // Medical supplies
    case patientCopay     // Patient copay collected
    case loanPayment      // Loan repayment
    case loanReceived     // Loan received
    case eventCost        // Cost from game event
    case miscIncome       // Other income
    case miscExpense      // Other expense
}
