import Foundation
import SwiftUI
import Combine

@Observable
@MainActor
final class DashboardViewModel {
    // MARK: - Published State

    var snapshot: UsageSnapshot = .empty
    var isLoading = false
    var errorMessage: String?
    var lastRefresh: Date?

    // MARK: - Web Usage State

    var webUsageData: WebUsageService.WebUsageData?
    var webUsageError: String?

    // MARK: - Cached Settings

    var displayMode: DisplayMode = .weekly
    var showTokenCounts: Bool = true
    var notificationsEnabled: Bool = true
    var notificationThreshold: Double = 80
    var weeklyResetDay: Int = 6
    var weeklyResetHour: Int = 19
    var weeklyMessageBudget: Int = 0
    var showStatusIcon: Bool = true

    // MARK: - Menu Bar Display

    var menuBarText: String {
        switch displayMode {
        case .weekly:
            let usage = Int(snapshot.weeklyPacingPercent)
            let time = Int(snapshot.weeklyTimePercent)
            return "\(usage)% · \(time)%"
        case .daily:
            return "\(Int(snapshot.pacingPercent))%"
        case .dual:
            let daily = Int(snapshot.pacingPercent)
            let weekly = Int(snapshot.weeklyPacingPercent)
            return "\(daily)% · \(weekly)%"
        case .iconOnly:
            return ""
        }
    }

    var menuBarColor: Color {
        switch displayMode {
        case .weekly:
            return Theme.Colors.forUsagePercent(snapshot.weeklyPacingPercent)
        default:
            return Theme.Colors.forUsagePercent(snapshot.pacingPercent)
        }
    }

    var menuBarIcon: String {
        "circle.fill"
    }

    // MARK: - Computed

    var todayMessages: Int {
        snapshot.todayActivity?.messageCount ?? 0
    }

    var todaySessions: Int {
        snapshot.todayActivity?.sessionCount ?? 0
    }

    var todayToolCalls: Int {
        snapshot.todayActivity?.toolCallCount ?? 0
    }

    var todayTokens: Int {
        snapshot.todayTokens?.totalTokens ?? 0
    }

    // MARK: - Services

    private let localService = LocalStatsService.shared
    private let webService = WebUsageService.shared
    private let notificationService = NotificationService.shared
    private var refreshTimer: Timer?
    private var settingsObserver: Any?

    // MARK: - Lifecycle

    func start() {
        reloadSettings()
        refresh()
        startTimer()
        Task {
            await notificationService.requestPermission()
        }

        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.reloadSettings()
                self?.startTimer()
                self?.refresh()
            }
        }
    }

    func stop() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func startTimer() {
        refreshTimer?.invalidate()
        reloadSettings()
        let interval = SettingsManager.shared.loadSettings().refreshInterval
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func reloadSettings() {
        let settings = SettingsManager.shared.loadSettings()
        displayMode = settings.displayMode
        showTokenCounts = settings.showTokenCounts
        notificationsEnabled = settings.notificationsEnabled
        notificationThreshold = settings.notificationThreshold
        weeklyResetDay = settings.weeklyResetDay
        weeklyResetHour = settings.weeklyResetHour
        weeklyMessageBudget = settings.weeklyMessageBudget
        showStatusIcon = settings.showStatusIcon
    }

    func refresh() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let snap = try await localService.loadSnapshot(
                    resetDay: weeklyResetDay,
                    resetHour: weeklyResetHour,
                    weeklyBudget: weeklyMessageBudget
                )
                self.snapshot = snap
                self.lastRefresh = Date()

                // Check notifications
                if notificationsEnabled {
                    await notificationService.checkAndNotifyIfPermitted(
                        pacingPercent: snap.pacingPercent,
                        threshold: notificationThreshold
                    )
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }

        fetchWebUsageIfConfigured()
    }

    func fetchWebUsageIfConfigured() {
        let sessionKey = SettingsManager.shared.sessionKey
        let orgId = SettingsManager.shared.orgId

        guard let key = sessionKey, !key.isEmpty else {
            webUsageData = nil
            webUsageError = nil
            return
        }

        Task {
            do {
                let data = try await webService.fetchUsage(sessionKey: key, orgId: orgId)
                self.webUsageData = data
                self.webUsageError = nil
            } catch {
                self.webUsageError = error.localizedDescription
                self.webUsageData = nil
            }
        }
    }
}
