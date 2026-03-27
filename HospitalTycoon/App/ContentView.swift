import SwiftUI

struct ContentView: View {
    @Environment(GameState.self) private var gameState
    @State private var isPlaying = false

    var body: some View {
        if isPlaying {
            GameView()
        } else {
            MainMenuView(onStartGame: {
                isPlaying = true
            }, onLoadGame: {
                if let loaded = SaveManager.shared.loadGame() {
                    // Copy loaded state
                    gameState.hospital = loaded.hospital
                    gameState.hospitalName = loaded.hospitalName
                    gameState.staff = loaded.staff
                    gameState.patients = loaded.patients
                    gameState.finance = loaded.finance
                    gameState.claims = loaded.claims
                    gameState.insuranceContracts = loaded.insuranceContracts
                    gameState.currentDay = loaded.currentDay
                    gameState.currentHour = loaded.currentHour
                    gameState.currentMonth = loaded.currentMonth
                    gameState.currentYear = loaded.currentYear
                    gameState.reputation = loaded.reputation
                    gameState.totalPatientsServed = loaded.totalPatientsServed
                    gameState.totalPatientsDischarged = loaded.totalPatientsDischarged
                    gameState.totalMisdiagnoses = loaded.totalMisdiagnoses
                    isPlaying = true
                }
            })
        }
    }
}
