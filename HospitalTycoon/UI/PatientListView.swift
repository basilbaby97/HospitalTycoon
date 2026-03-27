import SwiftUI

struct PatientListView: View {
    @Environment(GameState.self) private var gameState
    @State private var selectedPatient: Patient?
    @State private var filterState: PatientState?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Patients")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(activePatients.count) active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()

            // Status summary
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    statusChip(nil, label: "All", count: activePatients.count)
                    statusChip(.waitingForRegistration, label: "Waiting", count: patientCount(for: [.waitingForRegistration, .waitingForExam, .waitingForTreatment]))
                    statusChip(.inExamination, label: "Exam", count: patientCount(for: [.inExamination, .awaitingTestResults]))
                    statusChip(.inTreatment, label: "Treatment", count: patientCount(for: [.inTreatment, .admitted]))
                    statusChip(.recovering, label: "Recovery", count: patientCount(for: [.recovering]))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            Divider()

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredPatients) { patient in
                        Button(action: { selectedPatient = patient }) {
                            patientRow(patient)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .sheet(item: $selectedPatient) { patient in
            PatientDetailView(patient: patient)
        }
    }

    private var activePatients: [Patient] {
        gameState.patients.filter { $0.state != .discharged && $0.state != .deceased }
    }

    private var filteredPatients: [Patient] {
        if filterState == nil { return activePatients }
        return activePatients // simplified - show all for now
    }

    private func patientCount(for states: [PatientState]) -> Int {
        gameState.patients.filter { states.contains($0.state) }.count
    }

    private func statusChip(_ state: PatientState?, label: String, count: Int) -> some View {
        Button(action: { filterState = state }) {
            VStack(spacing: 2) {
                Text("\(count)")
                    .font(.caption.bold())
                Text(label)
                    .font(.system(size: 9))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(filterState == state ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .foregroundColor(.white)
    }

    private func patientRow(_ patient: Patient) -> some View {
        HStack {
            // Status indicator
            Circle()
                .fill(stateColor(patient.state))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(patient.name)
                        .font(.subheadline.bold())
                    Text("(\(patient.age))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text(patient.payerType.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(.blue)
                Text(patient.presentingSymptoms.map { $0.symptom.displayName }.prefix(3).joined(separator: ", "))
                    .font(.system(size: 9))
                    .foregroundColor(.orange)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(patient.state.rawValue.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression).capitalized)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(stateColor(patient.state))

                if let top = patient.topDifferential {
                    Text("\(Int(top.probability * 100))% \(top.diseaseName)")
                        .font(.system(size: 8))
                        .foregroundColor(.cyan)
                        .lineLimit(1)
                }

                if patient.satisfaction < 60 {
                    Text("Dissatisfied")
                        .font(.system(size: 8))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.03))
        .foregroundColor(.white)
    }

    private func stateColor(_ state: PatientState) -> Color {
        switch state {
        case .arriving, .waitingForRegistration: return .white
        case .registered, .waitingForExam: return .yellow
        case .inExamination, .awaitingTestResults: return .orange
        case .diagnosed, .waitingForTreatment: return .orange
        case .inTreatment, .admitted: return .red
        case .recovering: return .green
        case .discharged: return .green
        case .deceased: return .gray
        }
    }
}
