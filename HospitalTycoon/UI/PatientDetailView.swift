import SwiftUI

struct PatientDetailView: View {
    let patient: Patient
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Patient Info
                    patientInfoSection

                    Divider()

                    // Presenting Symptoms
                    symptomsSection

                    Divider()

                    // Differential Diagnosis
                    differentialSection

                    Divider()

                    // Test Results
                    testResultsSection

                    Divider()

                    // Treatment Status
                    treatmentSection
                }
                .padding()
            }
            .navigationTitle(patient.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var patientInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PATIENT INFORMATION")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                infoItem("Age", value: "\(patient.age)")
                infoItem("Insurance", value: patient.payerType.displayName)
                infoItem("Satisfaction", value: "\(Int(patient.satisfaction))%")
                infoItem("Wait Time", value: "\(patient.waitTimeHours)h")
                infoItem("Status", value: patient.state.rawValue)
                infoItem("Arrival", value: "Day \(patient.arrivalDay) \(patient.arrivalHour):00")
            }
        }
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRESENTING SYMPTOMS")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            ForEach(patient.presentingSymptoms, id: \.symptom) { presentation in
                HStack {
                    Text(presentation.symptom.displayName)
                        .font(.subheadline)
                    Spacer()
                    // Severity bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)
                            Rectangle()
                                .fill(severityColor(presentation.severity))
                                .frame(width: geo.size.width * presentation.severity, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(width: 80, height: 6)
                    Text(severityLabel(presentation.severity))
                        .font(.system(size: 9))
                        .foregroundColor(severityColor(presentation.severity))
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
    }

    private var differentialSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DIFFERENTIAL DIAGNOSIS")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            if patient.differentialDiagnosis.isEmpty {
                Text("Awaiting examination")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(patient.differentialDiagnosis) { entry in
                    HStack {
                        if entry.ruledOut {
                            Text(entry.diseaseName)
                                .font(.subheadline)
                                .strikethrough()
                                .foregroundColor(.gray)
                        } else {
                            Text(entry.diseaseName)
                                .font(.subheadline)
                                .foregroundColor(entry.probability > 0.5 ? .primary : .secondary)
                        }
                        Spacer()
                        if !entry.ruledOut {
                            // Probability bar
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 8)
                                    .cornerRadius(4)
                                Rectangle()
                                    .fill(probabilityColor(entry.probability))
                                    .frame(width: 100 * entry.probability, height: 8)
                                    .cornerRadius(4)
                            }
                            Text("\(Int(entry.probability * 100))%")
                                .font(.caption.bold().monospacedDigit())
                                .foregroundColor(probabilityColor(entry.probability))
                                .frame(width: 35, alignment: .trailing)
                        } else {
                            Text("Ruled Out")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                }

                if let confirmed = patient.confirmedDisease {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Confirmed: \(confirmed.name)")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)

                    Text("DRG: \(confirmed.drgCode) | ICD-10: \(confirmed.icdCode)")
                        .font(.caption)
                        .foregroundColor(.blue)

                    // Check for misdiagnosis
                    if confirmed.id != patient.actualDisease.id {
                        Text("Warning: Diagnosis may be incorrect")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private var testResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DIAGNOSTIC TESTS (\(patient.testResults.count) completed)")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            if patient.testResults.isEmpty && patient.orderedTests.isEmpty {
                Text("No tests ordered yet")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Completed tests
            ForEach(patient.testResults, id: \.testType) { result in
                HStack {
                    Image(systemName: result.isAbnormal ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundColor(result.isAbnormal ? .orange : .green)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(result.testType.displayName)
                            .font(.caption.bold())
                        Text(result.findings)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("CPT: \(result.testType.cptCode)")
                        .font(.system(size: 9))
                        .foregroundColor(.blue)
                }
            }

            // In-progress test
            if let current = patient.currentTestInProgress {
                HStack {
                    ProgressView()
                        .controlSize(.mini)
                    Text(current.displayName)
                        .font(.caption)
                    Text("(\(patient.testProgressTicks)/\(current.ticksRequired) ticks)")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
            }

            // Pending tests
            if !patient.orderedTests.isEmpty {
                Text("Pending: \(patient.orderedTests.map { $0.displayName }.joined(separator: ", "))")
                    .font(.system(size: 9))
                    .foregroundColor(.yellow)
            }
        }
    }

    private var treatmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TREATMENT")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            if let disease = patient.confirmedDisease {
                Text("Treatment room: \(disease.treatmentRoom.displayName)")
                    .font(.caption)

                if patient.treatmentTotalTicks > 0 {
                    ProgressView(value: Double(patient.treatmentProgressTicks),
                                total: Double(patient.treatmentTotalTicks))
                    Text("\(patient.treatmentProgressTicks)/\(patient.treatmentTotalTicks) ticks")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }

                if let success = patient.isTreatmentSuccessful {
                    Text(success ? "Treatment successful" : "Treatment unsuccessful")
                        .font(.caption.bold())
                        .foregroundColor(success ? .green : .red)
                }
            } else {
                Text("Awaiting diagnosis")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helpers

    private func infoItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption.bold())
        }
    }

    private func severityColor(_ severity: Double) -> Color {
        if severity > 0.7 { return .red }
        if severity > 0.4 { return .orange }
        return .yellow
    }

    private func severityLabel(_ severity: Double) -> String {
        if severity > 0.7 { return "Severe" }
        if severity > 0.4 { return "Moderate" }
        return "Mild"
    }

    private func probabilityColor(_ probability: Double) -> Color {
        if probability >= 0.85 { return .green }
        if probability >= 0.5 { return .yellow }
        if probability >= 0.25 { return .orange }
        return .red
    }
}
