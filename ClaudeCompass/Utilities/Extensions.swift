import Foundation

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var compactFormatted: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", Double(self) / 1_000)
        }
        return "\(self)"
    }
}

extension Double {
    var percentFormatted: String {
        String(format: "%.0f%%", self)
    }

    var oneDecimalFormatted: String {
        String(format: "%.1f", self)
    }
}

extension String {
    var friendlyModelName: String {
        if contains("opus-4-6") { return "Opus 4.6" }
        if contains("opus-4-5") { return "Opus 4.5" }
        if contains("sonnet-4-5") { return "Sonnet 4.5" }
        if contains("sonnet-4") { return "Sonnet 4" }
        if contains("haiku-4-5") { return "Haiku 4.5" }
        if contains("haiku") { return "Haiku" }
        return self
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    static func fromISO(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }

    static func fromDateString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}

extension TimeInterval {
    var friendlyDuration: String {
        let hours = Int(self / 3600)
        let minutes = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
