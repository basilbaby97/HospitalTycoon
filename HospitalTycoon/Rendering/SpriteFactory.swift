import SpriteKit

class SpriteFactory {
    // MARK: - Lines

    func createLine(from start: CGPoint, to end: CGPoint, color: SKColor, width: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = width
        return node
    }

    // MARK: - Department Colors

    func colorForDepartment(_ department: Department) -> SKColor {
        switch department.color {
        case .gray: return SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6)
        case .red: return SKColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.6)
        case .blue: return SKColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 0.6)
        case .green: return SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 0.6)
        case .teal: return SKColor(red: 0.2, green: 0.6, blue: 0.6, alpha: 0.6)
        case .purple: return SKColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 0.6)
        case .indigo: return SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 0.6)
        case .pink: return SKColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 0.6)
        case .rose: return SKColor(red: 0.7, green: 0.3, blue: 0.5, alpha: 0.6)
        case .orange: return SKColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.6)
        case .cyan: return SKColor(red: 0.2, green: 0.7, blue: 0.8, alpha: 0.6)
        case .yellow: return SKColor(red: 0.7, green: 0.7, blue: 0.2, alpha: 0.6)
        case .mint: return SKColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 0.6)
        case .darkRed: return SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.6)
        case .brown: return SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 0.6)
        }
    }

    // MARK: - Equipment Sprites

    func createEquipmentSprite(label: String, color: SKColor, size: CGSize) -> SKNode {
        let container = SKNode()

        let background = SKSpriteNode(color: SKColor(white: 0.2, alpha: 0.8), size: size)
        background.zPosition = 0
        container.addChild(background)

        let border = SKShapeNode(rectOf: size, cornerRadius: 2)
        border.strokeColor = color
        border.fillColor = .clear
        border.lineWidth = 1
        border.zPosition = 1
        container.addChild(border)

        let text = SKLabelNode(text: label)
        text.fontSize = min(8, size.width * 0.4)
        text.fontName = "Helvetica-Bold"
        text.fontColor = color
        text.horizontalAlignmentMode = .center
        text.verticalAlignmentMode = .center
        text.zPosition = 2
        container.addChild(text)

        return container
    }

    // MARK: - Entity Sprites (Staff / Patients)

    func createStaffSprite(role: StaffRole) -> SKNode {
        let container = SKNode()
        let radius: CGFloat = 6.0

        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = colorForStaffRole(role)
        circle.strokeColor = .white
        circle.lineWidth = 1
        circle.zPosition = 0
        container.addChild(circle)

        let label = SKLabelNode(text: role.spriteLabel)
        label.fontSize = 6
        label.fontName = "Helvetica-Bold"
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        container.addChild(label)

        return container
    }

    func createPatientSprite(state: PatientState) -> SKNode {
        let container = SKNode()
        let radius: CGFloat = 5.0

        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = colorForPatientState(state)
        circle.strokeColor = SKColor(white: 0.8, alpha: 1.0)
        circle.lineWidth = 0.5
        circle.zPosition = 0
        container.addChild(circle)

        return container
    }

    private func colorForStaffRole(_ role: StaffRole) -> SKColor {
        switch role {
        case .generalPractitioner, .emergencyPhysician, .surgeon, .cardiologist,
             .orthopedicSurgeon, .neurologist, .oncologist, .anesthesiologist:
            return SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0) // Blue for doctors
        case .registeredNurse, .licensedPracticalNurse, .nurseAssistant, .nursePractitioner:
            return SKColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0) // Green for nurses
        case .radiologist, .pathologist:
            return SKColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0) // Purple for specialists
        case .pharmacist:
            return SKColor(red: 0.3, green: 0.7, blue: 0.7, alpha: 1.0) // Teal
        case .labTechnician:
            return SKColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1.0) // Yellow
        case .receptionist, .administrator:
            return SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Gray
        case .janitor:
            return SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0) // Brown
        }
    }

    private func colorForPatientState(_ state: PatientState) -> SKColor {
        switch state {
        case .arriving, .waitingForRegistration:
            return SKColor(white: 0.9, alpha: 1.0) // White
        case .registered, .waitingForExam:
            return SKColor(red: 0.9, green: 0.9, blue: 0.5, alpha: 1.0) // Light yellow
        case .inExamination, .awaitingTestResults:
            return SKColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0) // Orange
        case .diagnosed, .waitingForTreatment:
            return SKColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0) // Dark orange
        case .inTreatment, .admitted:
            return SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0) // Red
        case .recovering:
            return SKColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0) // Light green
        case .discharged:
            return SKColor(red: 0.3, green: 0.9, blue: 0.3, alpha: 1.0) // Green
        case .deceased:
            return SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Dark gray
        }
    }
}
