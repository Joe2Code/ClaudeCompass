import Foundation
import ServiceManagement

@Observable
@MainActor
final class SettingsViewModel {
    var refreshInterval: Double
    var displayMode: DisplayMode
    var notificationThreshold: Double
    var notificationsEnabled: Bool
    var launchAtLogin: Bool
    var showTokenCounts: Bool
    var weeklyResetDay: Int
    var weeklyResetHour: Int
    var weeklyMessageBudget: Int
    var showStatusIcon: Bool

    var sessionKey: String
    var orgId: String
    var hasCredentials: Bool

    var statusMessage: String?
    var notificationPermissionStatus: String = "Checking…"

    private let settingsManager = SettingsManager.shared

    static let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    init() {
        let settings = SettingsManager.shared.loadSettings()
        self.refreshInterval = settings.refreshInterval
        self.displayMode = settings.displayMode
        self.notificationThreshold = settings.notificationThreshold
        self.notificationsEnabled = settings.notificationsEnabled
        self.showTokenCounts = settings.showTokenCounts
        self.weeklyResetDay = settings.weeklyResetDay
        self.weeklyResetHour = settings.weeklyResetHour
        self.weeklyMessageBudget = settings.weeklyMessageBudget
        self.showStatusIcon = settings.showStatusIcon

        self.sessionKey = SettingsManager.shared.sessionKey ?? ""
        self.orgId = SettingsManager.shared.orgId ?? ""
        self.hasCredentials = SettingsManager.shared.sessionKey != nil

        // Sync launch at login with actual system state
        let status = SMAppService.mainApp.status
        self.launchAtLogin = (status == .enabled)
    }

    func save() {
        let settings = AppSettings(
            refreshInterval: refreshInterval,
            displayMode: displayMode,
            notificationThreshold: notificationThreshold,
            notificationsEnabled: notificationsEnabled,
            launchAtLogin: launchAtLogin,
            showTokenCounts: showTokenCounts,
            weeklyResetDay: weeklyResetDay,
            weeklyResetHour: weeklyResetHour,
            weeklyMessageBudget: weeklyMessageBudget,
            showStatusIcon: showStatusIcon
        )
        settingsManager.save(settings)
        updateLaunchAtLogin()
        statusMessage = "Settings saved"
    }

    func saveCredentials() {
        if sessionKey.isEmpty {
            settingsManager.deleteSessionKey()
        } else {
            settingsManager.saveSessionKey(sessionKey)
        }

        if orgId.isEmpty {
            settingsManager.deleteOrgId()
        } else {
            settingsManager.saveOrgId(orgId)
        }

        hasCredentials = !sessionKey.isEmpty
        statusMessage = "Credentials saved"
    }

    func clearCredentials() {
        sessionKey = ""
        orgId = ""
        settingsManager.deleteSessionKey()
        settingsManager.deleteOrgId()
        hasCredentials = false
        statusMessage = "Credentials cleared"
    }

    var resetDayName: String {
        let index = weeklyResetDay - 1  // 1-based to 0-based
        guard (0..<7).contains(index) else { return "?" }
        return Self.dayNames[index]
    }

    var resetTimeFormatted: String {
        let hour12 = weeklyResetHour % 12 == 0 ? 12 : weeklyResetHour % 12
        let ampm = weeklyResetHour < 12 ? "AM" : "PM"
        return "\(hour12) \(ampm)"
    }

    // MARK: - Launch at Login

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
            statusMessage = "Launch at login failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Notification Permission

    func checkNotificationPermission() {
        Task {
            await NotificationService.shared.refreshPermissionState()
            let state = await NotificationService.shared.permissionState
            switch state {
            case .granted:
                notificationPermissionStatus = "Granted"
            case .denied:
                notificationPermissionStatus = "Denied"
            case .notDetermined:
                notificationPermissionStatus = "Not Requested"
            case .unknown:
                notificationPermissionStatus = "Unknown"
            }
        }
    }
}
