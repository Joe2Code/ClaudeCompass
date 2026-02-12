import SwiftUI

enum Theme {
    // MARK: - Colors

    enum Colors {
        static let primary = Color(red: 0.847, green: 0.584, blue: 0.839)     // Claude purple
        static let secondary = Color(red: 0.925, green: 0.733, blue: 0.506)   // Warm amber

        // Softer, easier-on-the-eyes status colors
        static let usageLow = Color(red: 0.35, green: 0.75, blue: 0.55)       // Calm green
        static let usageMedium = Color(red: 0.90, green: 0.72, blue: 0.30)    // Warm amber
        static let usageHigh = Color(red: 0.90, green: 0.55, blue: 0.30)      // Muted orange
        static let usageCritical = Color(red: 0.85, green: 0.35, blue: 0.35)  // Soft red

        static let cardBackground = Color(nsColor: .controlBackgroundColor)
        static let textPrimary = Color(nsColor: .labelColor)
        static let textSecondary = Color(nsColor: .secondaryLabelColor)
        static let textTertiary = Color(nsColor: .tertiaryLabelColor)
        static let separator = Color(nsColor: .separatorColor)

        static func forUsagePercent(_ percent: Double) -> Color {
            switch percent {
            case ...50: return usageLow
            case ...80: return usageMedium
            default: return usageCritical
            }
        }

        static func nsColorForUsagePercent(_ percent: Double) -> NSColor {
            switch percent {
            case ...50: return NSColor(red: 0.35, green: 0.75, blue: 0.55, alpha: 1)
            case ...80: return NSColor(red: 0.90, green: 0.72, blue: 0.30, alpha: 1)
            default:    return NSColor(red: 0.85, green: 0.35, blue: 0.35, alpha: 1)
            }
        }
    }

    // MARK: - Layout

    enum Layout {
        static let popoverWidth: CGFloat = 420
        static let popoverMaxHeight: CGFloat = 860
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 10
        static let sectionSpacing: CGFloat = 16
        static let itemSpacing: CGFloat = 8
    }

    // MARK: - Fonts

    enum Fonts {
        static let title = Font.system(size: 15, weight: .semibold)
        static let headline = Font.system(size: 13, weight: .medium)
        static let body = Font.system(size: 12)
        static let caption = Font.system(size: 11, weight: .regular)
        static let stat = Font.system(size: 24, weight: .bold, design: .rounded)
        static let statSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let menuBar = Font.system(size: 12, weight: .medium, design: .rounded)
    }
}
