import SwiftUI

struct EquipmentCatalogView: View {
    @Environment(GameState.self) private var gameState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: EquipmentCategory?
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                // Category filter
                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            categoryChip(nil, label: "All")
                            ForEach(EquipmentCategory.allCases, id: \.self) { cat in
                                categoryChip(cat, label: cat.displayName)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Equipment list
                Section("Equipment (\(filteredEquipment.count))") {
                    ForEach(filteredEquipment) { equipment in
                        equipmentRow(equipment)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search equipment...")
            .navigationTitle("Equipment Catalog")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var filteredEquipment: [EquipmentTemplate] {
        EquipmentCatalog.all.filter { eq in
            let matchesCategory = selectedCategory == nil || eq.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                eq.name.localizedCaseInsensitiveContains(searchText) ||
                eq.brand.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    private func categoryChip(_ category: EquipmentCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: { selectedCategory = category }) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }

    private func equipmentRow(_ equipment: EquipmentTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(equipment.name)
                        .font(.subheadline.bold())
                    Text(equipment.brand)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
                tierBadge(equipment.tier)
            }

            HStack(spacing: 16) {
                costLabel("Purchase", amount: equipment.purchaseCost)
                costLabel("Install", amount: equipment.installationCost)
                costLabel("Maint/yr", amount: equipment.annualMaintenance)
            }

            if !equipment.diagnosticCapabilities.isEmpty {
                Text("Enables: \(equipment.diagnosticCapabilities.map { $0.displayName }.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundColor(.green)
            }

            Text(equipment.description)
                .font(.caption2)
                .foregroundColor(.secondary)

            // Buy button
            Button(action: {
                buyEquipment(equipment)
            }) {
                HStack {
                    Text("Purchase")
                    Spacer()
                    Text(formatCurrency(equipment.totalAcquisitionCost))
                }
                .font(.caption.bold())
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    gameState.finance.cashBalance >= Double(equipment.totalAcquisitionCost)
                    ? Color.green.opacity(0.2)
                    : Color.red.opacity(0.2)
                )
                .cornerRadius(6)
            }
            .disabled(gameState.finance.cashBalance < Double(equipment.totalAcquisitionCost))
        }
        .padding(.vertical, 4)
    }

    private func tierBadge(_ tier: EquipmentTier) -> some View {
        Text(tier.rawValue.capitalized)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tierColor(tier).opacity(0.2))
            .foregroundColor(tierColor(tier))
            .cornerRadius(10)
    }

    private func tierColor(_ tier: EquipmentTier) -> Color {
        switch tier {
        case .basic: return .gray
        case .standard: return .blue
        case .premium: return .purple
        }
    }

    private func costLabel(_ label: String, amount: Int) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text(formatCurrency(amount))
                .font(.caption2.bold())
        }
    }

    private func buyEquipment(_ equipment: EquipmentTemplate) {
        gameState.isInBuildMode = true
        gameState.selectedBuildItem = .equipment(equipment.id)
        dismiss()
    }

    private func formatCurrency(_ amount: Int) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", Double(amount) / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%dK", amount / 1_000)
        }
        return "$\(amount)"
    }
}
