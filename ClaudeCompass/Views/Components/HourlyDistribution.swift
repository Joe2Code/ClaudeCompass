import SwiftUI

struct HourlyDistribution: View {
    let buckets: [HourlyBucket]

    private var maxCount: Int {
        buckets.map(\.count).max() ?? 1
    }

    // Show every 3rd hour label to avoid crowding
    private let labelHours: Set<Int> = [0, 3, 6, 9, 12, 15, 18, 21]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("Activity by Hour")
                .font(Theme.Fonts.headline)
                .foregroundStyle(Theme.Colors.textPrimary)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(buckets) { bucket in
                    VStack(spacing: 2) {
                        Spacer()

                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor(for: bucket))
                            .frame(height: barHeight(for: bucket))

                        if labelHours.contains(bucket.hour) {
                            Text(bucket.label)
                                .font(.system(size: 8))
                                .foregroundStyle(Theme.Colors.textTertiary)
                        } else {
                            Text("")
                                .font(.system(size: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)
        }
    }

    private func barHeight(for bucket: HourlyBucket) -> CGFloat {
        guard maxCount > 0, bucket.count > 0 else { return 1 }
        return CGFloat(bucket.count) / CGFloat(maxCount) * 40
    }

    private func barColor(for bucket: HourlyBucket) -> Color {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if bucket.hour == currentHour {
            return Theme.Colors.primary
        }
        return Theme.Colors.primary.opacity(0.35)
    }
}
