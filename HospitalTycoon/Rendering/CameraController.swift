import SpriteKit

class CameraController: NSObject {
    private weak var camera: SKCameraNode?
    private weak var scene: SKScene?
    private let gridWidth: Int
    private let gridHeight: Int
    private let tileSize: CGFloat

    private var minZoom: CGFloat = 0.3
    private var maxZoom: CGFloat = 3.0
    private var currentScale: CGFloat = 1.0
    private var lastPanLocation: CGPoint = .zero

    init(camera: SKCameraNode, scene: SKScene, gridWidth: Int, gridHeight: Int, tileSize: CGFloat) {
        self.camera = camera
        self.scene = scene
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.tileSize = tileSize
        super.init()
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let camera = camera, let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            lastPanLocation = gesture.location(in: view)

        case .changed:
            let currentLocation = gesture.location(in: view)
            let dx = (currentLocation.x - lastPanLocation.x) * currentScale
            let dy = (currentLocation.y - lastPanLocation.y) * currentScale

            camera.position.x -= dx
            camera.position.y += dy // Invert Y for SpriteKit coordinate system

            lastPanLocation = currentLocation
            clampCameraPosition()

        default:
            break
        }
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let camera = camera else { return }

        switch gesture.state {
        case .changed:
            let newScale = currentScale / gesture.scale
            let clampedScale = max(minZoom, min(maxZoom, newScale))
            camera.setScale(clampedScale)
            currentScale = clampedScale
            gesture.scale = 1.0
            clampCameraPosition()

        case .ended:
            currentScale = camera.xScale

        default:
            break
        }
    }

    private func clampCameraPosition() {
        guard let camera = camera else { return }

        let worldWidth = CGFloat(gridWidth) * tileSize
        let worldHeight = CGFloat(gridHeight) * tileSize
        let margin: CGFloat = tileSize * 5

        let minX = -margin
        let maxX = worldWidth + margin
        let minY = -margin
        let maxY = worldHeight + margin

        camera.position.x = max(minX, min(maxX, camera.position.x))
        camera.position.y = max(minY, min(maxY, camera.position.y))
    }

    func centerOn(position: GridPosition) {
        guard let camera = camera else { return }
        camera.position = CGPoint(
            x: CGFloat(position.x) * tileSize,
            y: CGFloat(position.y) * tileSize
        )
    }

    func zoomToFit() {
        guard let camera = camera, let scene = scene, let view = scene.view else { return }
        let worldWidth = CGFloat(gridWidth) * tileSize
        let worldHeight = CGFloat(gridHeight) * tileSize
        let scaleX = worldWidth / view.bounds.width
        let scaleY = worldHeight / view.bounds.height
        let fitScale = max(scaleX, scaleY) * 1.1
        camera.setScale(fitScale)
        currentScale = fitScale

        camera.position = CGPoint(x: worldWidth / 2, y: worldHeight / 2)
    }
}
