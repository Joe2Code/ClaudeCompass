import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()

    private var lastNotifiedThreshold: Double = 0
    private(set) var permissionState: PermissionState = .unknown

    enum PermissionState: Sendable {
        case unknown
        case granted
        case denied
        case notDetermined
    }

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            permissionState = granted ? .granted : .denied
        } catch {
            print("Notification permission error: \(error)")
            permissionState = .denied
        }
    }

    func refreshPermissionState() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            permissionState = .granted
        case .denied:
            permissionState = .denied
        case .notDetermined:
            permissionState = .notDetermined
        @unknown default:
            permissionState = .unknown
        }
    }

    func checkAndNotifyIfPermitted(pacingPercent: Double, threshold: Double) {
        guard permissionState == .granted else { return }

        guard pacingPercent >= threshold else {
            // Reset if usage drops below threshold
            if pacingPercent < threshold - 10 {
                lastNotifiedThreshold = 0
            }
            return
        }

        // Don't re-notify for the same threshold crossing
        let bucket = (pacingPercent / 10).rounded(.down) * 10
        guard bucket > lastNotifiedThreshold else { return }
        lastNotifiedThreshold = bucket

        let content = UNMutableNotificationContent()
        content.title = "Claude Compass"

        if pacingPercent >= 95 {
            content.body = "Usage at \(Int(pacingPercent))% of your daily average — you're near your typical limit."
            content.sound = .default
        } else {
            content.body = "Usage at \(Int(pacingPercent))% of your daily average."
            content.sound = nil
        }

        let request = UNNotificationRequest(
            identifier: "usage-\(Int(bucket))",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
