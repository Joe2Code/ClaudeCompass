import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(Theme.Fonts.title)
                Spacer()
                Button("Done") {
                    viewModel.save()
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(Theme.Layout.cardPadding)

            Divider()

            TabView {
                generalTab
                    .tabItem { Label("General", systemImage: "gearshape") }
                credentialsTab
                    .tabItem { Label("API", systemImage: "key") }
                notificationsTab
                    .tabItem { Label("Alerts", systemImage: "bell") }
            }
            .padding(Theme.Layout.cardPadding)

            if let status = viewModel.statusMessage {
                Text(status)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.primary)
                    .padding(.bottom, 8)
                    .task(id: status) {
                        try? await Task.sleep(for: .seconds(2))
                        viewModel.statusMessage = nil
                    }
            }
        }
        .frame(width: 400, height: 420)
    }

    // MARK: - General

    private var generalTab: some View {
        Form {
            Picker("Display Mode", selection: $viewModel.displayMode) {
                ForEach(DisplayMode.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }

            Section("Weekly Reset") {
                Picker("Reset Day", selection: $viewModel.weeklyResetDay) {
                    ForEach(1...7, id: \.self) { day in
                        Text(SettingsViewModel.dayNames[day - 1]).tag(day)
                    }
                }

                Picker("Reset Hour", selection: $viewModel.weeklyResetHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        let h12 = hour % 12 == 0 ? 12 : hour % 12
                        let ampm = hour < 12 ? "AM" : "PM"
                        Text("\(h12) \(ampm)").tag(hour)
                    }
                }

                Text("Set this to match your Claude plan's weekly reset time.")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }

            Section("Weekly Budget") {
                HStack {
                    Text("Message Budget")
                    Spacer()
                    TextField("Auto", value: $viewModel.weeklyMessageBudget, format: .number)
                        .frame(width: 80)
                        .textFieldStyle(.roundedBorder)
                    Text("msgs")
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Text("Set to 0 for auto-estimate. To calibrate: check your usage % on claude.ai, then adjust until the numbers roughly match.")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }

            HStack {
                Text("Refresh Interval")
                Spacer()
                TextField("", value: $viewModel.refreshInterval, format: .number)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                Text("seconds")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Toggle("Show Status Icon", isOn: $viewModel.showStatusIcon)
            Toggle("Show Token Counts", isOn: $viewModel.showTokenCounts)
            Toggle("Launch at Login", isOn: $viewModel.launchAtLogin)
        }
        .formStyle(.grouped)
    }

    // MARK: - Credentials

    private var credentialsTab: some View {
        Form {
            Section {
                SecureField("Session Key", text: $viewModel.sessionKey)
                    .textFieldStyle(.roundedBorder)
                TextField("Organization ID (optional)", text: $viewModel.orgId)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("Anthropic API Credentials")
            } footer: {
                Text("Stored securely in macOS Keychain. Used for web usage data (optional).")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }

            HStack {
                Button("Save Credentials") {
                    viewModel.saveCredentials()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                if viewModel.hasCredentials {
                    Button("Clear") {
                        viewModel.clearCredentials()
                    }
                    .controlSize(.small)
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Notifications

    private var notificationsTab: some View {
        Form {
            Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)

            if viewModel.notificationsEnabled {
                HStack {
                    Text("Warning Threshold")
                    Spacer()
                    TextField("", value: $viewModel.notificationThreshold, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                    Text("%")
                        .font(Theme.Fonts.caption)
                }

                Text("You'll be notified when your pacing reaches this percentage of your daily average.")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)

                Section("System Permission") {
                    HStack {
                        Text("Notification Access")
                            .font(Theme.Fonts.body)
                        Spacer()
                        Text(viewModel.notificationPermissionStatus)
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(
                                viewModel.notificationPermissionStatus == "Granted"
                                    ? Color.green
                                    : Theme.Colors.textSecondary
                            )
                    }

                    if viewModel.notificationPermissionStatus == "Denied" {
                        Button("Open System Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .task {
            viewModel.checkNotificationPermission()
        }
    }
}
