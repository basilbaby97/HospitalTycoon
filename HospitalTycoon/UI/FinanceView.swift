import SwiftUI

struct FinanceView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Financial Dashboard")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Key Metrics
                    metricsSection

                    Divider()

                    // Revenue Cycle
                    revenueCycleSection

                    Divider()

                    // Claims Overview
                    claimsSection

                    Divider()

                    // Recent Transactions
                    transactionsSection
                }
                .padding()
            }
        }
    }

    private var metricsSection: some View {
        VStack(spacing: 8) {
            Text("KEY METRICS")
                .font(.caption.bold())
                .foregroundColor(.gray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                metricCard("Cash Balance", value: formatCurrency(gameState.finance.cashBalance), color: .green)
                metricCard("Accounts Receivable", value: formatCurrency(gameState.finance.accountsReceivable), color: .orange)
                metricCard("Total Revenue", value: formatCurrency(gameState.finance.totalRevenue), color: .blue)
                metricCard("Total Expenses", value: formatCurrency(gameState.finance.totalExpenses), color: .red)
                metricCard("Net Income", value: formatCurrency(gameState.finance.netIncome),
                          color: gameState.finance.netIncome >= 0 ? .green : .red)
                metricCard("Operating Margin",
                          value: String(format: "%.1f%%", gameState.finance.operatingMargin * 100),
                          color: gameState.finance.operatingMargin >= 0.03 ? .green : .orange)
            }
        }
    }

    private var revenueCycleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REVENUE CYCLE")
                .font(.caption.bold())
                .foregroundColor(.gray)

            let pendingClaims = gameState.claims.filter { $0.status == .submitted || $0.status == .adjudicating }
            let deniedClaims = gameState.claims.filter { $0.status == .denied }
            let appealedClaims = gameState.claims.filter { $0.status == .appealed }
            let paidClaims = gameState.claims.filter { $0.status == .paid }

            HStack(spacing: 12) {
                pipelineStage("Pending", count: pendingClaims.count, color: .yellow)
                Image(systemName: "arrow.right").foregroundColor(.gray).font(.caption)
                pipelineStage("Denied", count: deniedClaims.count, color: .red)
                Image(systemName: "arrow.right").foregroundColor(.gray).font(.caption)
                pipelineStage("Appeals", count: appealedClaims.count, color: .orange)
                Image(systemName: "arrow.right").foregroundColor(.gray).font(.caption)
                pipelineStage("Paid", count: paidClaims.count, color: .green)
            }

            // Denial rate
            if !gameState.claims.isEmpty {
                let denialCount = gameState.claims.filter { $0.status == .denied || $0.status == .deniedFinal }.count
                let totalProcessed = gameState.claims.filter { $0.status != .submitted }.count
                if totalProcessed > 0 {
                    let denialRate = Double(denialCount) / Double(totalProcessed)
                    Text("Denial Rate: \(String(format: "%.1f%%", denialRate * 100))")
                        .font(.caption)
                        .foregroundColor(denialRate > 0.15 ? .red : .green)
                }
            }
        }
    }

    private var claimsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT CLAIMS")
                .font(.caption.bold())
                .foregroundColor(.gray)

            let recentClaims = Array(gameState.claims.suffix(10).reversed())
            if recentClaims.isEmpty {
                Text("No claims yet")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(recentClaims) { claim in
                    claimRow(claim)
                }
            }
        }
    }

    private func claimRow(_ claim: InsuranceClaim) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(claim.drgDescription)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text("\(claim.payerType.displayName) - \(claim.drgCode)")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(claim.expectedReimbursement))
                    .font(.caption)
                claimStatusBadge(claim.status)
            }
        }
        .padding(.vertical, 4)
    }

    private func claimStatusBadge(_ status: ClaimStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .submitted: return ("Submitted", .yellow)
            case .adjudicating: return ("Processing", .yellow)
            case .paid: return ("Paid", .green)
            case .denied: return ("Denied", .red)
            case .appealed: return ("Appealed", .orange)
            case .appealApproved: return ("Appeal Won", .green)
            case .deniedFinal: return ("Denied Final", .red)
            case .writtenOff: return ("Written Off", .gray)
            }
        }()
        return Text(text)
            .font(.system(size: 9, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT TRANSACTIONS")
                .font(.caption.bold())
                .foregroundColor(.gray)

            ForEach(gameState.finance.recentTransactions.prefix(15)) { txn in
                HStack {
                    Text(txn.description)
                        .font(.system(size: 10))
                        .lineLimit(1)
                    Spacer()
                    Text(formatCurrency(txn.amount))
                        .font(.system(size: 10).monospacedDigit())
                        .foregroundColor(txn.amount >= 0 ? .green : .red)
                }
            }
        }
    }

    private func metricCard(_ title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.gray)
            Text(value)
                .font(.caption.bold().monospacedDigit())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }

    private func pipelineStage(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.caption.bold())
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let sign = amount < 0 ? "-" : ""
        let abs = abs(amount)
        if abs >= 1_000_000 { return "\(sign)$\(String(format: "%.1fM", abs / 1_000_000))" }
        if abs >= 1_000 { return "\(sign)$\(String(format: "%.0fK", abs / 1_000))" }
        return "\(sign)$\(String(format: "%.0f", abs))"
    }
}
