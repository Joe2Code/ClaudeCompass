import SwiftUI

struct ModelBreakdown: View {
    let models: [ModelBreakdownItem]
    let todayModels: [ModelBreakdownItem]
    var showTokenCounts: Bool = true
    @State private var showChart = true
    @State private var showToday = false

    private var activeModels: [ModelBreakdownItem] {
        showToday ? todayModels : models
    }

    private var periodLabel: String {
        showToday ? "Today" : "All Time"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            HStack {
                Text("Model Breakdown")
                    .font(Theme.Fonts.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Picker("", selection: $showToday) {
                    Text("All").tag(false)
                    Text("Today").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 90)

                Picker("", selection: $showChart) {
                    Image(systemName: "chart.pie").tag(true)
                    Image(systemName: "list.bullet").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 60)
            }

            if showChart {
                ModelPieChart(models: activeModels)
            } else {
                modelList
            }
        }
    }

    private var modelList: some View {
        Group {
            if activeModels.isEmpty {
                Text("No model data available")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            } else {
                ForEach(activeModels) { model in
                    ModelRow(model: model, showTokens: showTokenCounts && !showToday)
                }
            }
        }
    }
}

private struct ModelRow: View {
    let model: ModelBreakdownItem
    let showTokens: Bool

    private var barColor: Color {
        if model.friendlyName.contains("Opus") { return Theme.Colors.primary }
        if model.friendlyName.contains("Sonnet") { return Theme.Colors.secondary }
        return .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(model.friendlyName)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Text((model.fraction * 100).percentFormatted)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor.opacity(0.7))
                    .frame(width: geometry.size.width * model.fraction, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: model.fraction)
            }
            .frame(height: 6)

            if showTokens {
                HStack(spacing: 12) {
                    TokenLabel(label: "In", count: model.inputTokens)
                    TokenLabel(label: "Out", count: model.outputTokens)
                    TokenLabel(label: "Cache", count: model.cacheTokens)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

private struct TokenLabel: View {
    let label: String
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textTertiary)
            Text(count.compactFormatted)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}
