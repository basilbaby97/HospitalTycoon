import Foundation
import Combine

class GameEngine {
    private weak var gameState: GameState?
    private var tickObserver: AnyCancellable?

    init(gameState: GameState) {
        self.gameState = gameState
        setupTickListener()
    }

    private func setupTickListener() {
        tickObserver = NotificationCenter.default.publisher(for: .gameTickRequested)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func tick() {
        guard let state = gameState, !state.isPaused else { return }

        // 1. Advance time (1 tick = 1 game-hour)
        TimeManager.advanceHour(state)

        // 2. Generate patients
        PatientGenerator.maybeSpawnPatient(state)

        // 3. Process diagnosis pipeline
        DiagnosisEngine.processPatients(state)

        // 4. Staff AI - assign tasks
        StaffAI.assignTasks(state)

        // 5. Staff fatigue
        processStaffFatigue(state)

        // 6. Check for events
        if state.currentHour == 12 && state.currentDay % GameConstants.eventCheckFrequencyDays == 0 {
            EventSystem.checkForEvents(state)
        }

        // 7. Update room operational status
        updateRoomOperationalStatus(state)
    }

    private func processStaffFatigue(_ state: GameState) {
        for i in state.staff.indices where state.staff[i].isOnDuty {
            state.staff[i].fatigue = min(
                GameConstants.maxStaffFatigue,
                state.staff[i].fatigue + GameConstants.fatiguePerHour
            )

            // Auto-rest if exhausted
            if state.staff[i].fatigue >= GameConstants.maxStaffFatigue {
                state.staff[i].isOnDuty = false
            }
        }
    }

    private func updateRoomOperationalStatus(_ state: GameState) {
        for i in state.hospital.rooms.indices {
            let room = state.hospital.rooms[i]
            let def = RoomDefinitions.definition(for: room.type)

            // Check if required staff are assigned and on duty
            let assignedStaff = state.staff.filter { $0.assignedRoomId == room.id && $0.isOnDuty }
            let hasRequiredStaff = def.requiredStaff.allSatisfy { requiredRole in
                assignedStaff.contains { $0.role == requiredRole }
            }

            // Check if required equipment is installed and operational
            let roomEquipment = state.hospital.equipmentInRoom(room.id)
            let hasRequiredEquipment = def.requiredEquipmentCategories.allSatisfy { requiredCat in
                roomEquipment.contains { equip in
                    equip.template?.category == requiredCat && equip.isOperational
                }
            }

            state.hospital.rooms[i].isOperational = hasRequiredStaff && hasRequiredEquipment
        }
    }

    deinit {
        tickObserver?.cancel()
    }
}
