import Foundation

/// Root structure matching ~/.claude/stats-cache.json
struct StatsCache: Codable, Sendable {
    let version: Int
    let lastComputedDate: String
    let dailyActivity: [DailyActivity]
    let dailyModelTokens: [DailyModelTokens]
    let modelUsage: [String: ModelUsageStats]
    let totalSessions: Int
    let totalMessages: Int
    let longestSession: LongestSession?
    let firstSessionDate: String?
    let hourCounts: [String: Int]
    let totalSpeculationTimeSavedMs: Int?
}

struct DailyActivity: Codable, Sendable, Identifiable {
    let date: String
    let messageCount: Int
    let sessionCount: Int
    let toolCallCount: Int

    var id: String { date }

    var parsedDate: Date? {
        Date.fromDateString(date)
    }
}

struct DailyModelTokens: Codable, Sendable, Identifiable {
    let date: String
    let tokensByModel: [String: Int]

    var id: String { date }

    var totalTokens: Int {
        tokensByModel.values.reduce(0, +)
    }
}

struct ModelUsageStats: Codable, Sendable {
    let inputTokens: Int
    let outputTokens: Int
    let cacheReadInputTokens: Int
    let cacheCreationInputTokens: Int
    let webSearchRequests: Int
    let costUSD: Double
    let contextWindow: Int
    let maxOutputTokens: Int

    var totalTokens: Int {
        inputTokens + outputTokens + cacheReadInputTokens + cacheCreationInputTokens
    }
}

struct LongestSession: Codable, Sendable {
    let sessionId: String
    let duration: Int  // milliseconds
    let messageCount: Int
    let timestamp: String

    var durationSeconds: TimeInterval {
        TimeInterval(duration) / 1000.0
    }
}
