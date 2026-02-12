import SwiftUI

struct PacingIndicator: View {
    let pacingPercent: Double

    private var status: PacingStatus {
        switch pacingPercent {
        case ..<30: return .light
        case ..<60: return .moderate
        case ..<85: return .heavy
        case ..<100: return .nearLimit
        default: return .overLimit
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(status.label)
                    .font(Theme.Fonts.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text(status.description)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer()

            Text(pacingPercent.percentFormatted)
                .font(Theme.Fonts.statSmall)
                .foregroundStyle(status.color)
        }
        .padding(Theme.Layout.cardPadding)
        .background(status.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius))
    }
}

private enum PacingStatus {
    case light, moderate, heavy, nearLimit, overLimit

    var label: String {
        switch self {
        case .light: return "Light Usage"
        case .moderate: return "Moderate Usage"
        case .heavy: return "Heavy Usage"
        case .nearLimit: return "Near Limit"
        case .overLimit: return "Over Limit"
        }
    }

    var description: String {
        switch self {
        case .light: return "Well below your daily average"
        case .moderate: return "On track with your daily average"
        case .heavy: return "Above your daily average"
        case .nearLimit: return "Approaching your typical daily limit"
        case .overLimit: return "Exceeded your daily average"
        }
    }

    var color: Color {
        switch self {
        case .light: return Theme.Colors.usageLow
        case .moderate: return Theme.Colors.usageMedium
        case .heavy: return Theme.Colors.usageHigh
        case .nearLimit: return Theme.Colors.usageCritical
        case .overLimit: return Theme.Colors.usageCritical
        }
    }
}
