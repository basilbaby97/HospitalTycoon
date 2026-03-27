import SwiftUI

struct StaffMenuView: View {
    @Environment(GameState.self) private var gameState
    @State private var selectedRole: StaffRole?
    @State private var candidates: [StaffMember] = []
    @State private var showHiring = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Staff Management")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(gameState.staff.count) total")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                statBadge("Physicians", count: gameState.staff.filter { $0.role.isPhysician }.count, color: .blue)
                statBadge("Nurses", count: gameState.staff.filter { $0.role.isNurse }.count, color: .green)
                statBadge("Other", count: gameState.staff.filter { !$0.role.isPhysician && !$0.role.isNurse }.count, color: .gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Annual cost
            Text("Annual Labor Cost: \(formatCurrency(gameState.totalStaffCostPerYear))")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.bottom, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    // Hire button
                    Button(action: { showHiring = true }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Hire New Staff")
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Current staff list
                    ForEach(StaffCategory.allCases, id: \.self) { category in
                        let categoryStaff = gameState.staff.filter { $0.role.category == category }
                        if !categoryStaff.isEmpty {
                            staffSection(title: category.rawValue.capitalized, staff: categoryStaff)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showHiring) {
            hiringSheet
        }
    }

    private func staffSection(title: String, staff: [StaffMember]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundColor(.gray)
                .padding(.horizontal)

            ForEach(staff) { member in
                staffRow(member)
            }
        }
    }

    private func staffRow(_ member: StaffMember) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline.bold())
                Text(member.role.displayName)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(member.annualSalary) + "/yr")
                    .font(.caption)
                    .foregroundColor(.green)
                HStack(spacing: 4) {
                    // Skill
                    Text("Skill: \(Int(member.skillLevel * 100))%")
                        .font(.system(size: 9))
                        .foregroundColor(.cyan)
                    // Fatigue
                    if member.fatigue > 50 {
                        Text("Tired")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
            }
            // Fire button
            Button(action: { fireStaff(member) }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red.opacity(0.6))
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.03))
    }

    private var hiringSheet: some View {
        NavigationStack {
            List {
                Section("Select Role") {
                    ForEach(StaffRole.allCases) { role in
                        Button(action: {
                            selectedRole = role
                            candidates = StaffTemplates.generateCandidates(
                                role: role, count: 3, currentDay: gameState.currentDay
                            )
                        }) {
                            HStack {
                                Text(role.displayName)
                                Spacer()
                                let template = StaffTemplates.template(for: role)
                                Text(formatSalaryRange(template.salaryRange))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

                if let role = selectedRole {
                    Section("Candidates for \(role.displayName)") {
                        ForEach(candidates) { candidate in
                            candidateRow(candidate)
                        }

                        Button("Refresh Candidates") {
                            candidates = StaffTemplates.generateCandidates(
                                role: role, count: 3, currentDay: gameState.currentDay
                            )
                        }
                    }
                }
            }
            .navigationTitle("Hire Staff")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showHiring = false }
                }
            }
        }
    }

    private func candidateRow(_ candidate: StaffMember) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(candidate.name).font(.subheadline.bold())
                Text("Skill: \(Int(candidate.skillLevel * 100))%")
                    .font(.caption).foregroundColor(.cyan)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(formatCurrency(candidate.annualSalary) + "/yr")
                    .font(.caption).foregroundColor(.green)
                Text(formatCurrency(candidate.dailySalary) + "/day")
                    .font(.system(size: 10)).foregroundColor(.gray)
            }
            Button("Hire") { hireStaff(candidate) }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
    }

    private func hireStaff(_ candidate: StaffMember) {
        gameState.staff.append(candidate)
    }

    private func fireStaff(_ member: StaffMember) {
        gameState.staff.removeAll { $0.id == member.id }
    }

    private func statBadge(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3.bold())
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 { return String(format: "$%.1fM", amount / 1_000_000) }
        if amount >= 1_000 { return String(format: "$%.0fK", amount / 1_000) }
        return String(format: "$%.0f", amount)
    }

    private func formatSalaryRange(_ range: ClosedRange<Double>) -> String {
        "\(formatCurrency(range.lowerBound))-\(formatCurrency(range.upperBound))"
    }
}

extension StaffCategory: CaseIterable {
    static var allCases: [StaffCategory] = [.physician, .nursing, .clinical, .administrative, .support]
}
