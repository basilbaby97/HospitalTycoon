import SwiftUI

struct BuildMenuView: View {
    @Environment(GameState.self) private var gameState
    let onDismiss: () -> Void
    weak var gameScene: GameScene?

    @State private var selectedDepartment: Department?
    @State private var selectedRoomType: RoomType?
    @State private var showEquipmentCatalog = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Build")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if gameState.isInBuildMode {
                    Button("Cancel") {
                        cancelBuildMode()
                    }
                    .foregroundColor(.red)
                }
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Department selector
                    Text("DEPARTMENTS")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Department.allCases) { dept in
                            departmentButton(dept)
                        }
                    }
                    .padding(.horizontal)

                    if let dept = selectedDepartment {
                        Divider()

                        // Room list for selected department
                        Text("ROOMS - \(dept.displayName.uppercased())")
                            .font(.caption.bold())
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        let rooms = RoomDefinitions.rooms(for: dept)
                        ForEach(rooms, id: \.type) { roomDef in
                            roomButton(roomDef)
                        }

                        Divider()

                        // Equipment button
                        Button(action: { showEquipmentCatalog = true }) {
                            HStack {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                Text("Equipment Catalog")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showEquipmentCatalog) {
            EquipmentCatalogView()
        }
    }

    private func departmentButton(_ dept: Department) -> some View {
        let info = DepartmentDefinitions.info(for: dept)
        let isSelected = selectedDepartment == dept
        return Button(action: { selectedDepartment = dept }) {
            VStack(spacing: 4) {
                Text(dept.displayName)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if info.unlockCost > 0 {
                    Text(formatCost(info.unlockCost))
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .foregroundColor(.white)
    }

    private func roomButton(_ def: RoomDefinition) -> some View {
        let isSelected = selectedRoomType == def.type
        return Button(action: {
            selectedRoomType = def.type
            enterBuildMode(roomType: def.type)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(def.type.displayName)
                        .font(.subheadline.bold())
                    Text("\(def.width)x\(def.height) tiles")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(def.description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(formatCost(def.baseCost))
                        .font(.caption.bold())
                        .foregroundColor(gameState.finance.cashBalance >= Double(def.baseCost) ? .green : .red)
                    if !def.requiredStaff.isEmpty {
                        Text(def.requiredStaff.map { $0.shortName }.joined(separator: ", "))
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .foregroundColor(.white)
        .padding(.horizontal)
    }

    private func enterBuildMode(roomType: RoomType) {
        gameState.isInBuildMode = true
        gameState.selectedBuildItem = .room(roomType)
        gameScene?.buildModeRoomType = roomType
    }

    private func cancelBuildMode() {
        gameState.isInBuildMode = false
        gameState.selectedBuildItem = nil
        gameScene?.buildModeRoomType = nil
        gameScene?.buildPreviewNode?.removeFromParent()
    }

    private func formatCost(_ cost: Int) -> String {
        if cost >= 1_000_000 {
            return String(format: "$%.1fM", Double(cost) / 1_000_000)
        } else if cost >= 1_000 {
            return String(format: "$%dK", cost / 1_000)
        }
        return "$\(cost)"
    }
}
