import Foundation

actor SaveManager {
    static let shared = SaveManager()

    private let fileManager = FileManager.default
    private let saveDirectoryName = "HospitalTycoonSaves"

    private var saveDirectoryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(saveDirectoryName)
    }

    private init() {
        ensureSaveDirectory()
    }

    private func ensureSaveDirectory() {
        if !fileManager.fileExists(atPath: saveDirectoryURL.path) {
            try? fileManager.createDirectory(at: saveDirectoryURL, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save

    func save(_ state: GameState, name: String? = nil) async throws {
        let saveName = name ?? state.hospitalName
        let sanitized = sanitizeFileName(saveName)
        let fileURL = saveDirectoryURL.appendingPathComponent("\(sanitized).json")

        let saveData = SaveData(
            version: SaveData.currentVersion,
            savedAt: Date(),
            hospitalName: state.hospitalName,
            gameState: state
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(saveData)
        try data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Load

    func load(name: String) async throws -> GameState {
        let sanitized = sanitizeFileName(name)
        let fileURL = saveDirectoryURL.appendingPathComponent("\(sanitized).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw SaveError.fileNotFound
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let saveData = try decoder.decode(SaveData.self, from: data)

        guard saveData.version == SaveData.currentVersion else {
            throw SaveError.incompatibleVersion(saveData.version)
        }

        return saveData.gameState
    }

    // MARK: - List Saves

    func listSaves() async -> [SaveInfo] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: saveDirectoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: .skipsHiddenFiles
        ) else { return [] }

        var saves: [SaveInfo] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let saveData = try? decoder.decode(SaveData.self, from: data) else { continue }

            let attributes = try? fileManager.attributesOfItem(atPath: file.path)
            let fileSize = attributes?[.size] as? Int ?? 0

            saves.append(SaveInfo(
                name: file.deletingPathExtension().lastPathComponent,
                hospitalName: saveData.hospitalName,
                savedAt: saveData.savedAt,
                day: saveData.gameState.currentDay,
                cash: saveData.gameState.finance.cashBalance,
                fileSize: fileSize
            ))
        }

        return saves.sorted { $0.savedAt > $1.savedAt }
    }

    // MARK: - Delete

    func deleteSave(name: String) async throws {
        let sanitized = sanitizeFileName(name)
        let fileURL = saveDirectoryURL.appendingPathComponent("\(sanitized).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw SaveError.fileNotFound
        }

        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Auto-save

    func autoSave(_ state: GameState) async {
        try? await save(state, name: "autosave")
    }

    func loadAutoSave() async throws -> GameState {
        try await load(name: "autosave")
    }

    func hasAutoSave() async -> Bool {
        let fileURL = saveDirectoryURL.appendingPathComponent("autosave.json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    // MARK: - Helpers

    private func sanitizeFileName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        return name.unicodeScalars
            .filter { allowed.contains($0) }
            .map { String($0) }
            .joined()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "_")
    }
}

// MARK: - Save Data Structures

struct SaveData: Codable {
    static let currentVersion = 1

    let version: Int
    let savedAt: Date
    let hospitalName: String
    let gameState: GameState
}

struct SaveInfo: Identifiable {
    let id = UUID()
    let name: String
    let hospitalName: String
    let savedAt: Date
    let day: Int
    let cash: Double
    let fileSize: Int

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: savedAt)
    }

    var formattedSize: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(fileSize))
    }
}

// MARK: - Errors

enum SaveError: LocalizedError {
    case fileNotFound
    case incompatibleVersion(Int)
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Save file not found"
        case .incompatibleVersion(let version):
            return "Incompatible save version: \(version)"
        case .encodingFailed:
            return "Failed to encode game state"
        case .decodingFailed:
            return "Failed to decode save file"
        }
    }
}
