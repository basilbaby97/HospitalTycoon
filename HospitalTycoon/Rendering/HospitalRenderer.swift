import SpriteKit

class HospitalRenderer {
    private let spriteFactory: SpriteFactory
    private let hospitalLayer: SKNode
    private var gridNodes: [SKNode] = []
    private var roomNodes: [UUID: SKNode] = [:]
    private var equipmentNodes: [UUID: SKNode] = []

    init(spriteFactory: SpriteFactory, hospitalLayer: SKNode) {
        self.spriteFactory = spriteFactory
        self.hospitalLayer = hospitalLayer
    }

    func clear() {
        hospitalLayer.removeAllChildren()
        gridNodes.removeAll()
        roomNodes.removeAll()
        equipmentNodes.removeAll()
    }

    // MARK: - Grid

    func renderGrid(hospital: Hospital) {
        let gridNode = SKNode()
        gridNode.name = "grid"

        let tileSize = GameConstants.tileSize

        // Draw grid background
        let bgWidth = CGFloat(hospital.width) * tileSize
        let bgHeight = CGFloat(hospital.height) * tileSize
        let background = SKSpriteNode(
            color: SKColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0),
            size: CGSize(width: bgWidth, height: bgHeight)
        )
        background.anchorPoint = .zero
        background.position = .zero
        background.zPosition = -10
        gridNode.addChild(background)

        // Draw grid lines
        let gridLineColor = SKColor(white: 0.25, alpha: 0.3)
        for x in 0...hospital.width {
            let line = spriteFactory.createLine(
                from: CGPoint(x: CGFloat(x) * tileSize, y: 0),
                to: CGPoint(x: CGFloat(x) * tileSize, y: bgHeight),
                color: gridLineColor,
                width: 0.5
            )
            gridNode.addChild(line)
        }
        for y in 0...hospital.height {
            let line = spriteFactory.createLine(
                from: CGPoint(x: 0, y: CGFloat(y) * tileSize),
                to: CGPoint(x: bgWidth, y: CGFloat(y) * tileSize),
                color: gridLineColor,
                width: 0.5
            )
            gridNode.addChild(line)
        }

        hospitalLayer.addChild(gridNode)
        gridNodes.append(gridNode)
    }

    // MARK: - Rooms

    func renderRooms(hospital: Hospital) {
        for room in hospital.rooms {
            renderRoom(room, hospital: hospital)
        }
    }

    private func renderRoom(_ room: Room, hospital: Hospital) {
        let tileSize = GameConstants.tileSize
        let roomNode = SKNode()
        roomNode.name = "room-\(room.id)"

        let width = CGFloat(room.width) * tileSize
        let height = CGFloat(room.height) * tileSize
        let position = CGPoint(
            x: CGFloat(room.origin.x) * tileSize,
            y: CGFloat(room.origin.y) * tileSize
        )

        // Room floor
        let color = spriteFactory.colorForDepartment(room.department)
        let floor = SKSpriteNode(color: color, size: CGSize(width: width, height: height))
        floor.anchorPoint = .zero
        floor.position = position
        floor.zPosition = 0
        roomNode.addChild(floor)

        // Room border/walls
        let wallColor = SKColor(white: 0.3, alpha: 1.0)
        let wallWidth: CGFloat = 2.0

        // Top wall
        let topWall = spriteFactory.createLine(
            from: CGPoint(x: position.x, y: position.y + height),
            to: CGPoint(x: position.x + width, y: position.y + height),
            color: wallColor, width: wallWidth
        )
        topWall.zPosition = 5
        roomNode.addChild(topWall)

        // Bottom wall
        let bottomWall = spriteFactory.createLine(
            from: CGPoint(x: position.x, y: position.y),
            to: CGPoint(x: position.x + width, y: position.y),
            color: wallColor, width: wallWidth
        )
        bottomWall.zPosition = 5
        roomNode.addChild(bottomWall)

        // Left wall
        let leftWall = spriteFactory.createLine(
            from: CGPoint(x: position.x, y: position.y),
            to: CGPoint(x: position.x, y: position.y + height),
            color: wallColor, width: wallWidth
        )
        leftWall.zPosition = 5
        roomNode.addChild(leftWall)

        // Right wall
        let rightWall = spriteFactory.createLine(
            from: CGPoint(x: position.x + width, y: position.y),
            to: CGPoint(x: position.x + width, y: position.y + height),
            color: wallColor, width: wallWidth
        )
        rightWall.zPosition = 5
        roomNode.addChild(rightWall)

        // Door indicator (gap in bottom wall)
        let doorX = position.x + CGFloat(room.width / 2) * tileSize
        let doorNode = SKSpriteNode(
            color: SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0),
            size: CGSize(width: tileSize * 0.6, height: wallWidth * 2)
        )
        doorNode.position = CGPoint(x: doorX + tileSize * 0.3, y: position.y)
        doorNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        doorNode.zPosition = 6
        roomNode.addChild(doorNode)

        // Room label
        let label = SKLabelNode(text: room.type.displayName)
        label.fontSize = min(10, tileSize * 0.4)
        label.fontName = "Helvetica-Bold"
        label.fontColor = .white
        label.position = CGPoint(x: position.x + width / 2, y: position.y + height / 2 + 4)
        label.zPosition = 8
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        roomNode.addChild(label)

        // Department label (smaller, below room name)
        let deptLabel = SKLabelNode(text: room.department.displayName)
        deptLabel.fontSize = min(7, tileSize * 0.25)
        deptLabel.fontName = "Helvetica"
        deptLabel.fontColor = SKColor(white: 0.9, alpha: 0.7)
        deptLabel.position = CGPoint(x: position.x + width / 2, y: position.y + height / 2 - 8)
        deptLabel.zPosition = 8
        deptLabel.horizontalAlignmentMode = .center
        deptLabel.verticalAlignmentMode = .center
        roomNode.addChild(deptLabel)

        hospitalLayer.addChild(roomNode)
        roomNodes[room.id] = roomNode
    }

    // MARK: - Equipment

    func renderEquipment(hospital: Hospital) {
        for equipment in hospital.installedEquipment {
            renderEquipmentItem(equipment)
        }
    }

    private func renderEquipmentItem(_ equipment: InstalledEquipment) {
        guard let template = equipment.template else { return }
        let tileSize = GameConstants.tileSize

        let node = spriteFactory.createEquipmentSprite(
            label: template.category.spriteLabel,
            color: equipment.isOperational ? .white : .red,
            size: CGSize(width: tileSize * 0.6, height: tileSize * 0.6)
        )
        node.position = CGPoint(
            x: CGFloat(equipment.position.x) * tileSize + tileSize / 2,
            y: CGFloat(equipment.position.y) * tileSize + tileSize / 2
        )
        node.zPosition = 10
        hospitalLayer.addChild(node)
        equipmentNodes[equipment.id] = node
    }
}
