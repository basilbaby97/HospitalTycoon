import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @Environment(GameState.self) private var gameState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Room info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ROOM INFORMATION")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)

                        LabeledContent("Type", value: room.type.displayName)
                        LabeledContent("Department", value: room.department.displayName)
                        LabeledContent("Size", value: "\(room.width)x\(room.height) tiles")
                        LabeledContent("Position", value: "(\(room.origin.x), \(room.origin.y))")
                        LabeledContent("Capacity", value: "\(room.patientCapacity) patients")
                        LabeledContent("Operational", value: room.isOperational ? "Yes" : "No")
                    }

                    Divider()

                    // Assigned staff
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ASSIGNED STAFF")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)

                        let staff = gameState.staff.filter { $0.assignedRoomId == room.id }
                        if staff.isEmpty {
                            Text("No staff assigned")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(staff) { member in
                                HStack {
                                    Text(member.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(member.role.shortName)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("Skill: \(Int(member.effectiveSkill * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.cyan)
                                }
                            }
                        }

                        // Required staff
                        let def = RoomDefinitions.definition(for: room.type)
                        if !def.requiredStaff.isEmpty {
                            Text("Required: \(def.requiredStaff.map { $0.displayName }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Divider()

                    // Equipment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("INSTALLED EQUIPMENT")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)

                        let equipment = gameState.hospital.equipmentInRoom(room.id)
                        if equipment.isEmpty {
                            Text("No equipment installed")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(equipment) { item in
                                if let template = item.template {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(template.name)
                                                .font(.subheadline)
                                            Text(template.brand)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(String(format: "%.0f%%", item.condition))
                                                .font(.caption.bold())
                                                .foregroundColor(item.condition > 50 ? .green : .orange)
                                            Text(item.isOperational ? "Operational" : "Down")
                                                .font(.system(size: 9))
                                                .foregroundColor(item.isOperational ? .green : .red)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Divider()

                    // Patients in room
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PATIENTS IN ROOM")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)

                        let patients = gameState.patients.filter { $0.currentRoomId == room.id }
                        if patients.isEmpty {
                            Text("No patients")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(patients) { patient in
                                HStack {
                                    Text(patient.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(patient.state.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(room.type.displayName)
        }
    }
}
