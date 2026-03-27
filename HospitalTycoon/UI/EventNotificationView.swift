import SwiftUI

struct EventNotificationView: View {
    let event: GameEvent
    let onDismiss: () -> Void

    @State private var isExpanded = false
    @State private var opacity: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.type.iconName)
                    .font(.title3)
                    .foregroundColor(event.type.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    if !isExpanded {
                        Text("Tap for details")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if event.financialImpact != 0 {
                    Text(financialImpactText)
                        .font(.caption.bold())
                        .foregroundColor(event.financialImpact > 0 ? .green : .red)
                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            if isExpanded {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 16) {
                    if event.durationDays > 0 {
                        Label("\(event.durationDays) days", systemImage: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    if event.reputationImpact != 0 {
                        Label("\(event.reputationImpact > 0 ? "+" : "")\(Int(event.reputationImpact)) rep",
                              systemImage: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(event.reputationImpact > 0 ? .yellow : .red)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(event.type.accentColor.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: event.type.accentColor.opacity(0.3), radius: 8)
        .opacity(opacity)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
            HapticManager.shared.eventOccurred()
            AudioManager.shared.playSFX(.eventNotification)
        }
    }

    private var financialImpactText: String {
        let amount = abs(event.financialImpact)
        let prefix = event.financialImpact > 0 ? "+" : "-"
        if amount >= 1_000_000 {
            return "\(prefix)$\(String(format: "%.1fM", amount / 1_000_000))"
        } else if amount >= 1000 {
            return "\(prefix)$\(String(format: "%.0fK", amount / 1000))"
        } else {
            return "\(prefix)$\(Int(amount))"
        }
    }
}

// MARK: - Event Banner Stack

struct EventBannerStack: View {
    @Environment(GameState.self) private var gameState
    @State private var dismissedEventIds: Set<UUID> = []

    var body: some View {
        VStack(spacing: 8) {
            ForEach(visibleEvents) { event in
                EventNotificationView(event: event) {
                    withAnimation {
                        dismissedEventIds.insert(event.id)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var visibleEvents: [GameEvent] {
        gameState.activeEvents.filter { !dismissedEventIds.contains($0.id) }
    }
}

// MARK: - GameEventType UI Extensions

extension GameEventType {
    var iconName: String {
        switch self {
        case .fluSeason: return "allergens"
        case .equipmentFailure: return "wrench.and.screwdriver.fill"
        case .cmsAudit: return "doc.text.magnifyingglass"
        case .staffBurnout: return "person.crop.circle.badge.exclamationmark"
        case .vipPatient: return "star.circle.fill"
        case .malpracticeLawsuit: return "exclamationmark.shield.fill"
        case .insuranceRateChange: return "chart.line.uptrend.xyaxis"
        case .jointCommissionInspection: return "checklist.checked"
        case .communityOutreach: return "heart.circle.fill"
        case .technologyGrant: return "laptopcomputer"
        case .naturalDisaster: return "cloud.bolt.rain.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .fluSeason: return .orange
        case .equipmentFailure: return .red
        case .cmsAudit: return .yellow
        case .staffBurnout: return .purple
        case .vipPatient: return .blue
        case .malpracticeLawsuit: return .red
        case .insuranceRateChange: return .cyan
        case .jointCommissionInspection: return .yellow
        case .communityOutreach: return .green
        case .technologyGrant: return .green
        case .naturalDisaster: return .red
        }
    }
}
