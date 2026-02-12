import SwiftUI

struct UsageMeter: View {
    let percent: Double
    var label: String = "Today's Pacing"
    var showLabel: Bool = true

    private var clampedPercent: Double {
        min(max(percent, 0), 100)
    }

    private var meterColor: Color {
        Theme.Colors.forUsagePercent(percent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showLabel {
                HStack {
                    Text(label)
                        .font(Theme.Fonts.headline)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Spacer()
                    Text(percent.percentFormatted)
                        .font(Theme.Fonts.headline)
                        .foregroundStyle(meterColor)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.separator.opacity(0.3))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(meterColor)
                        .frame(width: geometry.size.width * clampedPercent / 100, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: clampedPercent)
                }
            }
            .frame(height: 8)
        }
    }
}
