import SpriteKit

class AnimationManager {
    private let entityLayer: SKNode
    private let spriteFactory: SpriteFactory
    private var staffSprites: [UUID: SKNode] = [:]
    private var patientSprites: [UUID: SKNode] = [:]

    init(entityLayer: SKNode, spriteFactory: SpriteFactory) {
        self.entityLayer = entityLayer
        self.spriteFactory = spriteFactory
    }

    // MARK: - Entity Updates

    func updateEntities(staff: [StaffMember], patients: [Patient], hospital: Hospital) {
        updateStaffSprites(staff: staff, hospital: hospital)
        updatePatientSprites(patients: patients, hospital: hospital)
    }

    private func updateStaffSprites(staff: [StaffMember], hospital: Hospital) {
        // Remove sprites for staff no longer present
        let currentStaffIds = Set(staff.map { $0.id })
        for (id, node) in staffSprites where !currentStaffIds.contains(id) {
            node.removeFromParent()
            staffSprites.removeValue(forKey: id)
        }

        for member in staff {
            let sprite: SKNode
            if let existing = staffSprites[member.id] {
                sprite = existing
            } else {
                sprite = spriteFactory.createStaffSprite(role: member.role)
                sprite.zPosition = 20
                entityLayer.addChild(sprite)
                staffSprites[member.id] = sprite
            }

            // Position staff in their assigned room or at a default position
            let targetPosition: CGPoint
            if let roomId = member.assignedRoomId, let room = hospital.rooms.first(where: { $0.id == roomId }) {
                targetPosition = CGPoint(
                    x: CGFloat(room.center.x) * GameConstants.tileSize + CGFloat.random(in: -8...8),
                    y: CGFloat(room.center.y) * GameConstants.tileSize + CGFloat.random(in: -8...8)
                )
            } else {
                // Off-duty or unassigned - place at entrance area
                targetPosition = CGPoint(
                    x: CGFloat(Hospital.defaultWidth / 2) * GameConstants.tileSize,
                    y: 2 * GameConstants.tileSize
                )
            }

            if sprite.position == .zero {
                sprite.position = targetPosition
            } else {
                let moveAction = SKAction.move(to: targetPosition, duration: 0.5)
                moveAction.timingMode = .easeInEaseOut
                sprite.run(moveAction, withKey: "move")
            }
        }
    }

    private func updatePatientSprites(patients: [Patient], hospital: Hospital) {
        let currentPatientIds = Set(patients.map { $0.id })
        for (id, node) in patientSprites where !currentPatientIds.contains(id) {
            // Fade out discharged patients
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
            patientSprites.removeValue(forKey: id)
        }

        for patient in patients {
            guard patient.state != .discharged && patient.state != .deceased else {
                if let node = patientSprites[patient.id] {
                    node.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))
                    patientSprites.removeValue(forKey: patient.id)
                }
                continue
            }

            let sprite: SKNode
            if let existing = patientSprites[patient.id] {
                sprite = existing
            } else {
                sprite = spriteFactory.createPatientSprite(state: patient.state)
                sprite.zPosition = 15
                entityLayer.addChild(sprite)
                patientSprites[patient.id] = sprite
            }

            let targetPosition = patientPosition(patient, hospital: hospital)

            if sprite.position == .zero {
                sprite.position = targetPosition
            } else {
                let moveAction = SKAction.move(to: targetPosition, duration: 0.8)
                moveAction.timingMode = .easeInEaseOut
                sprite.run(moveAction, withKey: "move")
            }
        }
    }

    private func patientPosition(_ patient: Patient, hospital: Hospital) -> CGPoint {
        let tileSize = GameConstants.tileSize

        // If patient has an assigned room, go there
        if let roomId = patient.currentRoomId, let room = hospital.rooms.first(where: { $0.id == roomId }) {
            return CGPoint(
                x: CGFloat(room.center.x) * tileSize + CGFloat.random(in: -6...6),
                y: CGFloat(room.center.y) * tileSize + CGFloat.random(in: -6...6)
            )
        }

        // Waiting patients go to waiting area or reception
        if let waitingRoom = hospital.roomsOfType(.waitingArea).first {
            return CGPoint(
                x: CGFloat(waitingRoom.center.x) * tileSize + CGFloat.random(in: -10...10),
                y: CGFloat(waitingRoom.center.y) * tileSize + CGFloat.random(in: -10...10)
            )
        }

        // Default: entrance area
        return CGPoint(
            x: CGFloat(Hospital.defaultWidth / 2) * tileSize,
            y: 1 * tileSize
        )
    }

    // MARK: - Animation Update

    func update(deltaTime: TimeInterval) {
        // Additional per-frame animation logic if needed
    }
}
