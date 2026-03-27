import SwiftUI

struct HUDView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        HStack(spacing: 12) {
            // Cash
            hudItem(icon: "dollarsign.circle.fill", color: .green,
                    value: formatCurrency(gameState.finance.cashBalance))

            Divider().frame(height: 20)

            // Accounts Receivable
            hudItem(icon: "doc.plaintext.fill", color: .orange,
                    value: "AR: \(formatCurrency(gameState.finance.accountsReceivable))")

            Divider().frame(height: 20)

            // Date
            hudItem(icon: "calendar", color: .blue,
                    value: gameState.formattedDate)

            Divider().frame(height: 20)

            // Reputation
            hudItem(icon: "star.fill", color: reputationColor,
                    value: String(format: "%.0f", gameState.reputation))

            Divider().frame(height: 20)

            // Patient count
            hudItem(icon: "person.fill", color: .white,
                    value: "\(gameState.patients.count)")

            Divider().frame(height: 20)

            // Staff count
            hudItem(icon: "person.2.fill", color: .cyan,
                    value: "\(gameState.staff.count)")

            Spacer()

            // Speed controls
            speedControls
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func hudItem(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(value)
                .font(.caption.monospacedDigit())
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var speedControls: some View {
        @Bindable var state = gameState
        HStack(spacing: 4) {
            Button(action: { state.isPaused.toggle() }) {
                Image(systemName: state.isPaused ? "play.fill" : "pause.fill")
                    .foregroundColor(state.isPaused ? .yellow : .white)
                    .frame(width: 30, height: 30)
            }

            ForEach(GameSpeed.allCases, id: \.self) { speed in
                Button(action: { state.gameSpeed = speed; state.isPaused = false }) {
                    Text(speed.rawValue)
                        .font(.caption2.bold())
                        .foregroundColor(state.gameSpeed == speed && !state.isPaused ? .blue : .gray)
                        .frame(width: 28, height: 28)
                        .background(
                            state.gameSpeed == speed && !state.isPaused
                            ? Color.blue.opacity(0.2)
                            : Color.clear
                        )
                        .cornerRadius(6)
                }
            }
        }
    }

    private var reputationColor: Color {
        if gameState.reputation >= 75 { return .green }
        if gameState.reputation >= 50 { return .yellow }
        if gameState.reputation >= 25 { return .orange }
        return .red
    }

    private func formatCurrency(_ amount: Double) -> String {
        if abs(amount) >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if abs(amount) >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        }
        return String(format: "$%.0f", amount)
    }
}
