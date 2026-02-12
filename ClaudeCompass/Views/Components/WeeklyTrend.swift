import SwiftUI

struct WeeklyTrend: View {
    let activity: [DailyActivity]

    private var maxCount: Int {
        activity.map(\.messageCount).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("Weekly Trend")
                .font(Theme.Fonts.headline)
                .foregroundStyle(Theme.Colors.textPrimary)

            if activity.isEmpty {
                Text("No data for this week")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            } else {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(activity) { day in
                        DayBar(day: day, maxCount: maxCount)
                    }
                }
                .frame(height: 80)
            }
        }
    }
}

private struct DayBar: View {
    let day: DailyActivity
    let maxCount: Int

    private var barHeight: CGFloat {
        guard maxCount > 0 else { return 0 }
        return CGFloat(day.messageCount) / CGFloat(maxCount)
    }

    private var isToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return day.date == formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 4) {
            Spacer()

            Text(day.messageCount.compactFormatted)
                .font(.system(size: 9))
                .foregroundStyle(Theme.Colors.textTertiary)

            RoundedRectangle(cornerRadius: 3)
                .fill(isToday ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.4))
                .frame(height: max(barHeight * 60, 2))

            Text(dayLabel)
                .font(.system(size: 9))
                .foregroundStyle(isToday ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var dayLabel: String {
        guard let date = Date.fromDateString(day.date) else { return "?" }
        return date.shortWeekday
    }
}
