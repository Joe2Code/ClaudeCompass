import Foundation

enum DisplayMode: String, CaseIterable, Sendable {
    case weekly = "weekly"
    case daily = "daily"
    case dual = "dual"
    case iconOnly = "iconOnly"

    var label: String {
        switch self {
        case .weekly: return "Weekly (Usage / Time)"
        case .daily: return "Daily Pacing"
        case .dual: return "Daily / Weekly"
        case .iconOnly: return "Icon Only"
        }
    }
}

struct AppSettings: Sendable {
    var refreshInterval: TimeInterval
    var displayMode: DisplayMode
    var notificationThreshold: Double
    var notificationsEnabled: Bool
    var launchAtLogin: Bool
    var showTokenCounts: Bool
    var weeklyResetDay: Int        // 1=Sun, 2=Mon, ..., 6=Fri, 7=Sat
    var weeklyResetHour: Int       // 0–23
    var weeklyMessageBudget: Int   // 0 = auto-estimate
    var showStatusIcon: Bool       // colored circle in menu bar

    static let defaults = AppSettings(
        refreshInterval: Constants.defaultRefreshInterval,
        displayMode: .weekly,
        notificationThreshold: Constants.NotificationThresholds.defaultWarning,
        notificationsEnabled: true,
        launchAtLogin: false,
        showTokenCounts: true,
        weeklyResetDay: 6,     // Friday
        weeklyResetHour: 19,   // 7 PM
        weeklyMessageBudget: 0,
        showStatusIcon: true
    )
}
