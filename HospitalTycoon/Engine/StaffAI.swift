import Foundation

struct StaffAI {
    /// Assign idle staff to rooms and tasks
    static func assignTasks(_ state: GameState) {
        assignStaffToRooms(state)
        manageShifts(state)
    }

    /// Auto-assign unassigned staff to rooms that need them
    private static func assignStaffToRooms(_ state: GameState) {
        for i in state.hospital.rooms.indices {
            let room = state.hospital.rooms[i]
            let def = RoomDefinitions.definition(for: room.type)

            // Check what staff roles are needed but not assigned
            let assignedStaff = state.staff.filter { $0.assignedRoomId == room.id }
            let assignedRoles = assignedStaff.map { $0.role }

            for requiredRole in def.requiredStaff {
                let alreadyHave = assignedRoles.filter { $0 == requiredRole }.count
                let needed = def.requiredStaff.filter { $0 == requiredRole }.count

                if alreadyHave < needed {
                    // Find an unassigned staff member with this role
                    if let staffIdx = state.staff.firstIndex(where: {
                        $0.role == requiredRole && $0.assignedRoomId == nil && $0.isOnDuty
                    }) {
                        state.staff[staffIdx].assignedRoomId = room.id
                        state.staff[staffIdx].assignedDepartment = room.department
                    }
                }
            }
        }
    }

    /// Manage shift changes - rest exhausted staff, bring back rested staff
    private static func manageShifts(_ state: GameState) {
        for i in state.staff.indices {
            // Rest exhausted staff
            if state.staff[i].isOnDuty && state.staff[i].fatigue >= GameConstants.maxStaffFatigue {
                state.staff[i].isOnDuty = false
                state.staff[i].currentTaskId = nil
            }

            // Bring back rested staff
            if !state.staff[i].isOnDuty && state.staff[i].fatigue <= 20 {
                state.staff[i].isOnDuty = true
            }
        }
    }

    /// Check if a specific room has enough operational staff
    static func isRoomAdequatelyStaffed(_ room: Room, state: GameState) -> Bool {
        let def = RoomDefinitions.definition(for: room.type)
        let assignedStaff = state.staff.filter { $0.assignedRoomId == room.id && $0.isOnDuty }

        return def.requiredStaff.allSatisfy { requiredRole in
            assignedStaff.contains { $0.role == requiredRole }
        }
    }

    /// Get the best available doctor for a patient
    static func findBestDoctor(for department: Department, state: GameState) -> StaffMember? {
        state.staff
            .filter { $0.role.isPhysician && $0.isOnDuty && $0.currentTaskId == nil }
            .filter { $0.assignedDepartment == department || $0.assignedDepartment == nil }
            .max(by: { $0.effectiveSkill < $1.effectiveSkill })
    }
}
