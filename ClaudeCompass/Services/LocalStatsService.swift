import Foundation

actor LocalStatsService {
    static let shared = LocalStatsService()

    private let filePath: String

    init(filePath: String = Constants.statsCachePath) {
        self.filePath = filePath
    }

    func loadStats() throws -> StatsCache {
        let url = URL(fileURLWithPath: filePath)

        guard FileManager.default.fileExists(atPath: filePath) else {
            throw StatsError.fileNotFound(filePath)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(StatsCache.self, from: data)
    }

    func loadSnapshot(resetDay: Int = 6, resetHour: Int = 19, weeklyBudget: Int = 0) throws -> UsageSnapshot {
        let cache = try loadStats()
        return UsageSnapshot(from: cache, resetDay: resetDay, resetHour: resetHour, weeklyBudget: weeklyBudget)
    }
}

enum StatsError: LocalizedError {
    case fileNotFound(String)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Stats file not found at \(path)"
        case .parseError(let detail):
            return "Failed to parse stats: \(detail)"
        }
    }
}
