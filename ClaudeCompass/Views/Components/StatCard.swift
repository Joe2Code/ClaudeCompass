import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var subtitle: String? = nil
    var color: Color = Theme.Colors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Text(value)
                .font(Theme.Fonts.statSmall)
                .foregroundStyle(Theme.Colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Layout.cardPadding)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius))
    }
}
