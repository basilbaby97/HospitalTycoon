import SwiftUI

struct InsuranceContractView: View {
    @Environment(GameState.self) private var gameState
    @State private var showNewContract = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Insurance Contracts")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showNewContract = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Active contracts
                    Text("ACTIVE CONTRACTS")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    let active = gameState.insuranceContracts.filter { $0.isActive }
                    if active.isEmpty {
                        Text("No active contracts. Negotiate with payers to receive patients.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(active) { contract in
                            contractCard(contract)
                        }
                    }

                    // Available payers
                    Text("AVAILABLE PAYERS")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    let contractedPayers = Set(gameState.insuranceContracts.filter { $0.isActive }.map { $0.payerType })
                    let available = PayerType.allCases.filter { !contractedPayers.contains($0) && $0 != .selfPay }

                    ForEach(available) { payer in
                        availablePayerCard(payer)
                    }
                }
                .padding(.bottom)
            }
        }
    }

    private func contractCard(_ contract: InsuranceContract) -> some View {
        let profile = InsuranceData.profile(for: contract.payerType)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(contract.payerType.displayName)
                    .font(.subheadline.bold())
                Spacer()
                if contract.payerType.isGovernment {
                    Text("GOV")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Rate vs Medicare")
                        .font(.system(size: 9)).foregroundColor(.gray)
                    Text(String(format: "%.0f%%", contract.negotiatedRate * 100))
                        .font(.caption.bold()).foregroundColor(.green)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Denial Rate")
                        .font(.system(size: 9)).foregroundColor(.gray)
                    Text(String(format: "%.0f%%", profile.denialRate * 100))
                        .font(.caption.bold()).foregroundColor(profile.denialRate > 0.15 ? .red : .orange)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Processing")
                        .font(.system(size: 9)).foregroundColor(.gray)
                    Text("\(profile.avgClaimProcessingDays) days")
                        .font(.caption.bold())
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Volume")
                        .font(.system(size: 9)).foregroundColor(.gray)
                    Text("\(contract.patientVolume)/mo")
                        .font(.caption.bold())
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private func availablePayerCard(_ payer: PayerType) -> some View {
        let profile = InsuranceData.profile(for: payer)
        return Button(action: { negotiateContract(payer) }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(payer.displayName)
                        .font(.subheadline.bold())
                    Text(profile.description)
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.0f%% of Medicare", payer.baseReimbursementRate * 100))
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("Negotiate")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }
        .foregroundColor(.white)
        .padding(.horizontal)
    }

    private func negotiateContract(_ payer: PayerType) {
        // Negotiation: rate depends on hospital reputation
        let reputationBonus = (gameState.reputation - 50) / 100 * 0.1 // up to +/-5%
        let negotiatedRate = payer.baseReimbursementRate + reputationBonus
        let contract = InsuranceContract(
            payerType: payer,
            negotiatedRate: max(payer.baseReimbursementRate * 0.9, negotiatedRate),
            startDay: TimeManager.totalDays(for: gameState),
            durationDays: 365,
            patientVolume: Int(InsuranceData.profile(for: payer).patientPercentage * 100)
        )
        gameState.insuranceContracts.append(contract)
    }
}
