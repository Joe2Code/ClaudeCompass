import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            VStack(spacing: Theme.Layout.sectionSpacing) {
                pacingSection
                todayStatsSection
                webUsageSection
                modelSection
                weeklySection
                hourlySection
            }
            .padding(Theme.Layout.cardPadding)
        }
        .frame(width: Theme.Layout.popoverWidth)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "gauge.medium")
                .foregroundStyle(Theme.Colors.primary)
            Text("Claude Compass")
                .font(Theme.Fonts.title)

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
            }

            Button(action: { viewModel.refresh() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)

            Button(action: { AppDelegate.shared.openSettings() }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.Layout.cardPadding)
    }

    // MARK: - Sections

    private var pacingSection: some View {
        VStack(spacing: Theme.Layout.itemSpacing) {
            PacingIndicator(pacingPercent: viewModel.snapshot.pacingPercent)
            UsageMeter(percent: viewModel.snapshot.pacingPercent, label: "Today's Pacing")
            UsageMeter(percent: viewModel.snapshot.weeklyPacingPercent, label: "Weekly Usage (estimate)")
            UsageMeter(percent: viewModel.snapshot.weeklyTimePercent, label: "Week Elapsed")
        }
    }

    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("Today")
                .font(Theme.Fonts.headline)
                .foregroundStyle(Theme.Colors.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: Theme.Layout.itemSpacing) {
                StatCard(
                    title: "Messages",
                    value: viewModel.todayMessages.formattedWithCommas,
                    icon: "message.fill"
                )
                StatCard(
                    title: "Sessions",
                    value: "\(viewModel.todaySessions)",
                    icon: "terminal.fill"
                )
                StatCard(
                    title: "Tool Calls",
                    value: viewModel.todayToolCalls.formattedWithCommas,
                    icon: "wrench.fill"
                )
                StatCard(
                    title: "Tokens",
                    value: viewModel.todayTokens.compactFormatted,
                    icon: "number"
                )
            }
        }
    }

    @ViewBuilder
    private var webUsageSection: some View {
        if let webData = viewModel.webUsageData {
            VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
                Text("Web Usage")
                    .font(Theme.Fonts.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)

                if let remaining = webData.remainingMessages, let max = webData.maxMessages {
                    UsageMeter(
                        percent: Double(max - remaining) / Double(max) * 100,
                        label: "API Messages",
                        showLabel: true
                    )

                    HStack {
                        Text("\(remaining) of \(max) messages remaining")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Spacer()
                        if let reset = webData.resetTime {
                            Text("Resets \(reset, style: .relative)")
                                .font(Theme.Fonts.caption)
                                .foregroundStyle(Theme.Colors.textTertiary)
                        }
                    }
                }

                if let dailyPct = webData.dailyUsagePercent {
                    UsageMeter(
                        percent: dailyPct,
                        label: "Daily API Usage",
                        showLabel: true
                    )
                }
            }
        } else if let webError = viewModel.webUsageError {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 10))
                Text("Web: \(webError)")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }

    private var modelSection: some View {
        ModelBreakdown(
            models: viewModel.snapshot.modelBreakdown,
            todayModels: viewModel.snapshot.todayModelBreakdown,
            showTokenCounts: viewModel.showTokenCounts
        )
    }

    private var weeklySection: some View {
        WeeklyTrend(activity: viewModel.snapshot.weeklyActivity)
    }

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            HourlyDistribution(buckets: viewModel.snapshot.hourlyDistribution)

            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: 10))
                    Text(errorMessage)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }

            if let lastRefresh = viewModel.lastRefresh {
                Text("Updated \(lastRefresh, style: .relative) ago")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
