import Foundation

extension Notification.Name {
    static let settingsDidChange = Notification.Name("com.claudecompass.settingsDidChange")
}

enum Constants {
    static let statsCachePath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.claude/stats-cache.json"
    }()

    static let defaultRefreshInterval: TimeInterval = 60
    static let minimumRefreshInterval: TimeInterval = 10
    static let maximumRefreshInterval: TimeInterval = 600

    enum Keychain {
        static let service = "com.claudecompass.app"
        static let sessionKeyAccount = "anthropic-session-key"
        static let orgIdAccount = "anthropic-org-id"
    }

    enum UserDefaultsKeys {
        static let refreshInterval = "refreshInterval"
        static let displayMode = "displayMode"
        static let notificationThreshold = "notificationThreshold"
        static let notificationsEnabled = "notificationsEnabled"
        static let launchAtLogin = "launchAtLogin"
        static let showTokenCounts = "showTokenCounts"
        static let weeklyResetDay = "weeklyResetDay"
        static let weeklyResetHour = "weeklyResetHour"
        static let weeklyMessageBudget = "weeklyMessageBudget"
        static let showStatusIcon = "showStatusIcon"
    }

    enum NotificationThresholds {
        static let defaultWarning: Double = 80
        static let defaultCritical: Double = 95
    }
}
