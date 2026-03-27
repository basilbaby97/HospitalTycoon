import Foundation

struct Hospital: Codable {
    static let defaultWidth = 60
    static let defaultHeight = 60

    var width: Int
    var height: Int
    var tiles: [[Tile]]
    var rooms: [Room]
    var installedEquipment: [InstalledEquipment]

    init(width: Int = Hospital.defaultWidth, height: Int = Hospital.defaultHeight) {
        self.width = width
        self.height = height
        self.tiles = Array(repeating: Array(repeating: Tile(), count: width), count: height)
        self.rooms = []
        self.installedEquipment = []
    }

    // MARK: - Room Placement

    mutating func canPlaceRoom(type: RoomType, at origin: GridPosition) -> Bool {
        let def = RoomDefinitions.definition(for: type)
        let endX = origin.x + def.width - 1
        let endY = origin.y + def.height - 1

        guard endX < width, endY < height, origin.x >= 0, origin.y >= 0 else { return false }

        for y in origin.y...endY {
            for x in origin.x...endX {
                if tiles[y][x].roomId != nil { return false }
            }
        }
        return true
    }

    @discardableResult
    mutating func placeRoom(type: RoomType, at origin: GridPosition) -> Room? {
        guard canPlaceRoom(type: type, at: origin) else { return nil }

        let def = RoomDefinitions.definition(for: type)
        let room = Room(
            id: UUID(),
            type: type,
            origin: origin,
            width: def.width,
            height: def.height,
            department: def.department
        )

        for y in origin.y..<(origin.y + def.height) {
            for x in origin.x..<(origin.x + def.width) {
                tiles[y][x].roomId = room.id
                tiles[y][x].tileType = .room
            }
        }

        // Set wall tiles on boundary
        for y in origin.y..<(origin.y + def.height) {
            tiles[y][origin.x].hasWallLeft = true
            tiles[y][origin.x + def.width - 1].hasWallRight = true
        }
        for x in origin.x..<(origin.x + def.width) {
            tiles[origin.y][x].hasWallTop = true
            tiles[origin.y + def.height - 1][x].hasWallBottom = true
        }

        // Place door at bottom-center
        let doorX = origin.x + def.width / 2
        let doorY = origin.y + def.height - 1
        tiles[doorY][doorX].hasDoor = true
        tiles[doorY][doorX].hasWallBottom = false

        rooms.append(room)
        return room
    }

    mutating func removeRoom(id: UUID) {
        guard let room = rooms.first(where: { $0.id == id }) else { return }

        for y in room.origin.y..<(room.origin.y + room.height) {
            for x in room.origin.x..<(room.origin.x + room.width) {
                tiles[y][x] = Tile()
            }
        }

        installedEquipment.removeAll { $0.roomId == id }
        rooms.removeAll { $0.id == id }
    }

    // MARK: - Equipment

    mutating func installEquipment(templateId: String, in roomId: UUID, at position: GridPosition) -> InstalledEquipment? {
        guard let template = EquipmentCatalog.find(id: templateId) else { return nil }
        guard rooms.contains(where: { $0.id == roomId }) else { return nil }

        let equipment = InstalledEquipment(
            id: UUID(),
            templateId: templateId,
            roomId: roomId,
            position: position,
            condition: 100.0,
            installDay: 0
        )
        installedEquipment.append(equipment)
        return equipment
    }

    func room(at position: GridPosition) -> Room? {
        guard position.y >= 0, position.y < height, position.x >= 0, position.x < width else { return nil }
        guard let roomId = tiles[position.y][position.x].roomId else { return nil }
        return rooms.first { $0.id == roomId }
    }

    func equipmentInRoom(_ roomId: UUID) -> [InstalledEquipment] {
        installedEquipment.filter { $0.roomId == roomId }
    }

    func roomsOfType(_ type: RoomType) -> [Room] {
        rooms.filter { $0.type == type }
    }

    func roomsInDepartment(_ department: Department) -> [Room] {
        rooms.filter { $0.department == department }
    }
}

// MARK: - Grid & Tile Types

struct GridPosition: Codable, Equatable, Hashable {
    var x: Int
    var y: Int
}

struct Tile: Codable {
    var tileType: TileType = .empty
    var roomId: UUID?
    var hasWallLeft: Bool = false
    var hasWallRight: Bool = false
    var hasWallTop: Bool = false
    var hasWallBottom: Bool = false
    var hasDoor: Bool = false
}

enum TileType: String, Codable {
    case empty
    case room
    case hallway
    case entrance
}
