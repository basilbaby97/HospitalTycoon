import SwiftUI

struct MainMenuView: View {
    let onStartGame: () -> Void
    let onLoadGame: () -> Void

    @State private var hospitalName = "General Hospital"
    @State private var showNewGameSheet = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("HOSPITAL")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(red: 0.7, green: 0.85, blue: 1.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("TYCOON")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                    Text("Real Healthcare Management Simulation")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    Button(action: { showNewGameSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Hospital")
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: 280)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: onLoadGame) {
                        HStack {
                            Image(systemName: "folder.fill")
                            Text("Load Game")
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: 280)
                        .padding(.vertical, 16)
                        .background(Color(white: 0.25))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }

                Spacer()

                Text("v1.0 - Powered by real healthcare economics")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
        }
        .sheet(isPresented: $showNewGameSheet) {
            newGameSheet
        }
    }

    private var newGameSheet: some View {
        NavigationStack {
            Form {
                Section("Hospital Name") {
                    TextField("Enter name", text: $hospitalName)
                }

                Section("Starting Conditions") {
                    LabeledContent("Starting Capital", value: "$5,000,000")
                    LabeledContent("Location", value: "Suburban")
                    LabeledContent("Starting Reputation", value: "50/100")
                }

                Section("Payer Mix") {
                    LabeledContent("Medicare", value: "30%")
                    LabeledContent("Medicaid", value: "15%")
                    LabeledContent("Private Insurance", value: "50%")
                    LabeledContent("Self-Pay", value: "5%")
                }
            }
            .navigationTitle("New Hospital")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewGameSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        showNewGameSheet = false
                        onStartGame()
                    }
                    .bold()
                }
            }
        }
    }
}
