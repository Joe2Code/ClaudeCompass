import Foundation

final class SettingsManager: @unchecked Sendable {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    private init() {
        registerDefaults()
        migrateIfNeeded()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Constants.UserDefaultsKeys.refreshInterval: Constants.defaultRefreshInterval,
            Constants.UserDefaultsKeys.displayMode: DisplayMode.weekly.rawValue,
            Constants.UserDefaultsKeys.notificationThreshold: Constants.NotificationThresholds.defaultWarning,
            Constants.UserDefaultsKeys.notificationsEnabled: true,
            Constants.UserDefaultsKeys.launchAtLogin: false,
            Constants.UserDefaultsKeys.showTokenCounts: true,
            Constants.UserDefaultsKeys.weeklyResetDay: 6,
            Constants.UserDefaultsKeys.weeklyResetHour: 19,
            Constants.UserDefaultsKeys.weeklyMessageBudget: 0,
            Constants.UserDefaultsKeys.showStatusIcon: true,
        ])
    }

    private func migrateIfNeeded() {
        let migrationKey = "com.claudecompass.migrated.v2"
        guard !defaults.bool(forKey: migrationKey) else { return }

        // Migrate old display modes ("percentage", "dual") to new default "weekly"
        let current = defaults.string(forKey: Constants.UserDefaultsKeys.displayMode) ?? ""
        if current == "percentage" || current == "dual" {
            defaults.set(DisplayMode.weekly.rawValue, forKey: Constants.UserDefaultsKeys.displayMode)
        }
        defaults.set(true, forKey: migrationKey)
    }

    // MARK: - Read

    func loadSettings() -> AppSettings {
        AppSettings(
            refreshInterval: defaults.double(forKey: Constants.UserDefaultsKeys.refreshInterval),
            displayMode: DisplayMode(rawValue: defaults.string(forKey: Constants.UserDefaultsKeys.displayMode) ?? "") ?? .weekly,
            notificationThreshold: defaults.double(forKey: Constants.UserDefaultsKeys.notificationThreshold),
            notificationsEnabled: defaults.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled),
            launchAtLogin: defaults.bool(forKey: Constants.UserDefaultsKeys.launchAtLogin),
            showTokenCounts: defaults.bool(forKey: Constants.UserDefaultsKeys.showTokenCounts),
            weeklyResetDay: {
                let val = defaults.integer(forKey: Constants.UserDefaultsKeys.weeklyResetDay)
                return (1...7).contains(val) ? val : 6
            }(),
            weeklyResetHour: {
                let val = defaults.integer(forKey: Constants.UserDefaultsKeys.weeklyResetHour)
                return (0...23).contains(val) ? val : 19
            }(),
            weeklyMessageBudget: defaults.integer(forKey: Constants.UserDefaultsKeys.weeklyMessageBudget),
            showStatusIcon: defaults.bool(forKey: Constants.UserDefaultsKeys.showStatusIcon)
        )
    }

    // MARK: - Write

    func save(_ settings: AppSettings) {
        defaults.set(settings.refreshInterval, forKey: Constants.UserDefaultsKeys.refreshInterval)
        defaults.set(settings.displayMode.rawValue, forKey: Constants.UserDefaultsKeys.displayMode)
        defaults.set(settings.notificationThreshold, forKey: Constants.UserDefaultsKeys.notificationThreshold)
        defaults.set(settings.notificationsEnabled, forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        defaults.set(settings.launchAtLogin, forKey: Constants.UserDefaultsKeys.launchAtLogin)
        defaults.set(settings.showTokenCounts, forKey: Constants.UserDefaultsKeys.showTokenCounts)
        defaults.set(settings.weeklyResetDay, forKey: Constants.UserDefaultsKeys.weeklyResetDay)
        defaults.set(settings.weeklyResetHour, forKey: Constants.UserDefaultsKeys.weeklyResetHour)
        defaults.set(settings.weeklyMessageBudget, forKey: Constants.UserDefaultsKeys.weeklyMessageBudget)
        defaults.set(settings.showStatusIcon, forKey: Constants.UserDefaultsKeys.showStatusIcon)
    }

    // MARK: - Credentials

    var sessionKey: String? {
        KeychainHelper.load(key: Constants.Keychain.sessionKeyAccount)
    }

    func saveSessionKey(_ key: String) {
        KeychainHelper.save(key: Constants.Keychain.sessionKeyAccount, value: key)
    }

    func deleteSessionKey() {
        KeychainHelper.delete(key: Constants.Keychain.sessionKeyAccount)
    }

    var orgId: String? {
        KeychainHelper.load(key: Constants.Keychain.orgIdAccount)
    }

    func saveOrgId(_ id: String) {
        KeychainHelper.save(key: Constants.Keychain.orgIdAccount, value: id)
    }

    func deleteOrgId() {
        KeychainHelper.delete(key: Constants.Keychain.orgIdAccount)
    }
}
