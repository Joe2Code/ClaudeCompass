import Foundation

/// View-ready computed data derived from StatsCache
struct UsageSnapshot: Sendable {
    let lastUpdated: Date
    let todayActivity: DailyActivity?
    let todayTokens: DailyModelTokens?
    let weeklyActivity: [DailyActivity]
    let weeklyTokens: [DailyModelTokens]
    let modelBreakdown: [ModelBreakdownItem]
    let todayModelBreakdown: [ModelBreakdownItem]
    let hourlyDistribution: [HourlyBucket]
    let pacingPercent: Double
    let weeklyPacingPercent: Double
    let weeklyTimePercent: Double
    let totalMessages: Int
    let totalSessions: Int
    let longestSessionDuration: TimeInterval?
    let daysSinceFirstSession: Int

    static let empty = UsageSnapshot(
        lastUpdated: .now,
        todayActivity: nil,
        todayTokens: nil,
        weeklyActivity: [],
        weeklyTokens: [],
        modelBreakdown: [],
        todayModelBreakdown: [],
        hourlyDistribution: [],
        pacingPercent: 0,
        weeklyPacingPercent: 0,
        weeklyTimePercent: 0,
        totalMessages: 0,
        totalSessions: 0,
        longestSessionDuration: nil,
        daysSinceFirstSession: 0
    )
}

struct ModelBreakdownItem: Identifiable, Sendable {
    let id: String  // model identifier
    let friendlyName: String
    let totalTokens: Int
    let inputTokens: Int
    let outputTokens: Int
    let cacheTokens: Int
    let fraction: Double  // 0..1 share of total
}

struct HourlyBucket: Identifiable, Sendable {
    let hour: Int
    let count: Int
    var id: Int { hour }

    var label: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "a" : "p"
        return "\(h)\(ampm)"
    }
}

// MARK: - Building a snapshot from StatsCache

extension UsageSnapshot {
    init(from cache: StatsCache, resetDay: Int = 6, resetHour: Int = 19, weeklyBudget: Int = 0) {
        let now = Date()
        let calendar = Calendar.current
        let todayString = Self.dateString(from: now)

        // Today's activity
        let today = cache.dailyActivity.first { $0.date == todayString }
        let todayTok = cache.dailyModelTokens.first { $0.date == todayString }

        // Last 7 days (calendar)
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)!.startOfDay
        let weekly = cache.dailyActivity.filter {
            guard let d = $0.parsedDate else { return false }
            return d >= sevenDaysAgo
        }.sorted { $0.date < $1.date }

        let weeklyTok = cache.dailyModelTokens.filter {
            guard let d = Date.fromDateString($0.date) else { return false }
            return d >= sevenDaysAgo
        }.sorted { $0.date < $1.date }

        // Model breakdown
        let totalAllModels = cache.modelUsage.values.reduce(0) { $0 + $1.totalTokens }
        let breakdown = cache.modelUsage.map { (model, stats) in
            ModelBreakdownItem(
                id: model,
                friendlyName: model.friendlyModelName,
                totalTokens: stats.totalTokens,
                inputTokens: stats.inputTokens,
                outputTokens: stats.outputTokens,
                cacheTokens: stats.cacheReadInputTokens + stats.cacheCreationInputTokens,
                fraction: totalAllModels > 0 ? Double(stats.totalTokens) / Double(totalAllModels) : 0
            )
        }.sorted { $0.totalTokens > $1.totalTokens }

        // Today's model breakdown (from dailyModelTokens)
        let todayBreakdown: [ModelBreakdownItem] = {
            guard let todayTokensByModel = todayTok?.tokensByModel else { return [] }
            let todayTotal = todayTokensByModel.values.reduce(0, +)
            guard todayTotal > 0 else { return [] }
            return todayTokensByModel.map { (model, tokens) in
                ModelBreakdownItem(
                    id: "today-\(model)",
                    friendlyName: model.friendlyModelName,
                    totalTokens: tokens,
                    inputTokens: 0,
                    outputTokens: 0,
                    cacheTokens: 0,
                    fraction: Double(tokens) / Double(todayTotal)
                )
            }.sorted { $0.totalTokens > $1.totalTokens }
        }()

        // Hourly distribution
        let hourly = (0..<24).map { hour in
            HourlyBucket(hour: hour, count: cache.hourCounts["\(hour)"] ?? 0)
        }

        // Daily pacing: today's messages / average daily messages
        let avgDaily: Double = {
            guard !cache.dailyActivity.isEmpty else { return 1 }
            let total = cache.dailyActivity.reduce(0) { $0 + $1.messageCount }
            return Double(total) / Double(cache.dailyActivity.count)
        }()
        let todayCount = Double(today?.messageCount ?? 0)
        let pacing = min((todayCount / max(avgDaily, 1)) * 100, 100)

        // Billing period calculations
        let lastReset = Self.lastResetDate(resetDay: resetDay, resetHour: resetHour)
        let resetDateString = Self.dateString(from: lastReset)

        // Messages in billing period (days >= reset date)
        let billingMessages = cache.dailyActivity.filter { $0.date >= resetDateString }
            .reduce(0) { $0 + $1.messageCount }

        // Weekly budget: user-configured or auto-estimate
        let weeklyCapacity: Double
        if weeklyBudget > 0 {
            weeklyCapacity = Double(weeklyBudget)
        } else {
            // Auto-estimate: use the highest daily count × 7 as a rough capacity
            let peakDaily = Double(cache.dailyActivity.map(\.messageCount).max() ?? 1)
            weeklyCapacity = max(peakDaily * 7, avgDaily * 14)
        }
        let weeklyPacing = min((Double(billingMessages) / max(weeklyCapacity, 1)) * 100, 100)

        // Weekly time percent
        let elapsed = now.timeIntervalSince(lastReset)
        let totalPeriod: TimeInterval = 7 * 24 * 3600
        let timePct = min(max(elapsed / totalPeriod * 100, 0), 100)

        // Days since first session
        let firstDate = cache.firstSessionDate.flatMap(Date.fromISO) ?? now
        let daysSince = max(calendar.dateComponents([.day], from: firstDate, to: now).day ?? 0, 0)

        // Longest session
        let longestDuration = cache.longestSession?.durationSeconds

        self.init(
            lastUpdated: now,
            todayActivity: today,
            todayTokens: todayTok,
            weeklyActivity: weekly,
            weeklyTokens: weeklyTok,
            modelBreakdown: breakdown,
            todayModelBreakdown: todayBreakdown,
            hourlyDistribution: hourly,
            pacingPercent: pacing,
            weeklyPacingPercent: weeklyPacing,
            weeklyTimePercent: timePct,
            totalMessages: cache.totalMessages,
            totalSessions: cache.totalSessions,
            longestSessionDuration: longestDuration,
            daysSinceFirstSession: daysSince
        )
    }

    // MARK: - Helpers

    static func lastResetDate(resetDay: Int, resetHour: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        var daysDiff = currentWeekday - resetDay
        if daysDiff < 0 { daysDiff += 7 }
        // If it's the reset day but before the reset hour, go back a full week
        if daysDiff == 0 && (currentHour < resetHour || (currentHour == resetHour && currentMinute == 0)) {
            daysDiff = 7
        }

        let resetDayDate = calendar.date(byAdding: .day, value: -daysDiff, to: calendar.startOfDay(for: now))!
        return calendar.date(bySettingHour: resetHour, minute: 0, second: 0, of: resetDayDate)!
    }

    private static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
