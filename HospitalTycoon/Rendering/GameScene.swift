import SpriteKit
import GameplayKit

class GameScene: SKScene {
    weak var gameState: GameState?

    private var hospitalRenderer: HospitalRenderer!
    private var cameraController: CameraController!
    private var animationManager: AnimationManager!
    private let spriteFactory = SpriteFactory()

    private var cameraNode: SKCameraNode!
    private var hospitalLayer: SKNode!
    private var entityLayer: SKNode!
    private var uiLayer: SKNode!

    private var lastUpdateTime: TimeInterval = 0
    private var tickAccumulator: TimeInterval = 0

    // Build mode state
    var buildModeRoomType: RoomType?
    var buildPreviewNode: SKNode?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1.0)

        setupLayers()
        setupCamera(view: view)
        setupRendering()
        renderHospital()
    }

    private func setupLayers() {
        hospitalLayer = SKNode()
        hospitalLayer.name = "hospitalLayer"
        addChild(hospitalLayer)

        entityLayer = SKNode()
        entityLayer.name = "entityLayer"
        addChild(entityLayer)

        uiLayer = SKNode()
        uiLayer.name = "uiLayer"
        addChild(uiLayer)
    }

    private func setupCamera(view: SKView) {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)

        cameraController = CameraController(
            camera: cameraNode,
            scene: self,
            gridWidth: GameConstants.gridWidth,
            gridHeight: GameConstants.gridHeight,
            tileSize: GameConstants.tileSize
        )

        let panGesture = UIPanGestureRecognizer(target: cameraController!, action: #selector(CameraController.handlePan(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: cameraController!, action: #selector(CameraController.handlePinch(_:)))
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)

        // Center camera on grid
        let centerX = CGFloat(GameConstants.gridWidth) * GameConstants.tileSize / 2
        let centerY = CGFloat(GameConstants.gridHeight) * GameConstants.tileSize / 2
        cameraNode.position = CGPoint(x: centerX, y: centerY)
    }

    private func setupRendering() {
        hospitalRenderer = HospitalRenderer(spriteFactory: spriteFactory, hospitalLayer: hospitalLayer)
        animationManager = AnimationManager(entityLayer: entityLayer, spriteFactory: spriteFactory)
    }

    // MARK: - Rendering

    func renderHospital() {
        guard let state = gameState else { return }
        hospitalRenderer.renderGrid(hospital: state.hospital)
        hospitalRenderer.renderRooms(hospital: state.hospital)
        hospitalRenderer.renderEquipment(hospital: state.hospital)
        animationManager.updateEntities(staff: state.staff, patients: state.patients, hospital: state.hospital)
    }

    func refreshRendering() {
        hospitalRenderer.clear()
        renderHospital()
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = gameState else { return }

        let location = touch.location(in: hospitalLayer)
        let gridPos = gridPosition(from: location)

        if state.isInBuildMode, let buildItem = state.selectedBuildItem {
            handleBuildTouch(buildItem: buildItem, at: gridPos)
        } else {
            handleSelectionTouch(at: gridPos)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = gameState else { return }
        if state.isInBuildMode {
            let location = touch.location(in: hospitalLayer)
            let gridPos = gridPosition(from: location)
            updateBuildPreview(at: gridPos)
        }
    }

    private func handleBuildTouch(buildItem: BuildItem, at gridPos: GridPosition) {
        guard let state = gameState else { return }

        switch buildItem {
        case .room(let roomType):
            let def = RoomDefinitions.definition(for: roomType)
            if state.hospital.canPlaceRoom(type: roomType, at: gridPos) {
                if state.finance.cashBalance >= Double(def.baseCost) {
                    state.hospital.placeRoom(type: roomType, at: gridPos)
                    state.finance.cashBalance -= Double(def.baseCost)
                    state.finance.addTransaction(
                        type: .construction,
                        amount: -Double(def.baseCost),
                        description: "Built \(roomType.displayName)",
                        day: state.currentDay
                    )
                    refreshRendering()
                }
            }
        case .equipment(let templateId):
            if let room = state.hospital.room(at: gridPos) {
                if let template = EquipmentCatalog.find(id: templateId) {
                    let cost = Double(template.totalAcquisitionCost)
                    if state.finance.cashBalance >= cost {
                        state.hospital.installEquipment(templateId: templateId, in: room.id, at: gridPos)
                        state.finance.cashBalance -= cost
                        state.finance.addTransaction(
                            type: .equipmentPurchase,
                            amount: -cost,
                            description: "Installed \(template.brand) \(template.name)",
                            day: state.currentDay
                        )
                        refreshRendering()
                    }
                }
            }
        }
    }

    private func handleSelectionTouch(at gridPos: GridPosition) {
        // Selection handled via SwiftUI overlay
    }

    private func updateBuildPreview(at gridPos: GridPosition) {
        buildPreviewNode?.removeFromParent()
        guard let state = gameState, let buildItem = state.selectedBuildItem else { return }

        if case .room(let type) = buildItem {
            let def = RoomDefinitions.definition(for: type)
            let canPlace = state.hospital.canPlaceRoom(type: type, at: gridPos)
            let previewColor = canPlace ? SKColor.green.withAlphaComponent(0.3) : SKColor.red.withAlphaComponent(0.3)
            let width = CGFloat(def.width) * GameConstants.tileSize
            let height = CGFloat(def.height) * GameConstants.tileSize
            let node = SKSpriteNode(color: previewColor, size: CGSize(width: width, height: height))
            node.anchorPoint = .zero
            node.position = CGPoint(
                x: CGFloat(gridPos.x) * GameConstants.tileSize,
                y: CGFloat(gridPos.y) * GameConstants.tileSize
            )
            node.zPosition = 100
            hospitalLayer.addChild(node)
            buildPreviewNode = node
        }
    }

    // MARK: - Coordinate Conversion

    func gridPosition(from scenePoint: CGPoint) -> GridPosition {
        GridPosition(
            x: Int(scenePoint.x / GameConstants.tileSize),
            y: Int(scenePoint.y / GameConstants.tileSize)
        )
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard let state = gameState else { return }

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if !state.isPaused {
            tickAccumulator += dt
            if tickAccumulator >= state.gameSpeed.tickInterval {
                tickAccumulator -= state.gameSpeed.tickInterval
                // Game tick handled by GameEngine in SwiftUI
                NotificationCenter.default.post(name: .gameTickRequested, object: nil)
            }
        }

        animationManager.update(deltaTime: dt)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let gameTickRequested = Notification.Name("gameTickRequested")
}
