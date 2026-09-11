import SwiftUI

extension Color {
    init(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)
        if value.count == 6 {
            self.init(
                red: Double((rgb >> 16) & 0xFF) / 255.0,
                green: Double((rgb >> 8) & 0xFF) / 255.0,
                blue: Double(rgb & 0xFF) / 255.0
            )
        } else {
            self.init(red: 0.31, green: 0.55, blue: 0.97)
        }
    }
}

enum HabitPalette {
    static let colors = [
        "#4F8DF7", "#F75C7E", "#F7A54F", "#4FCB8D",
        "#9B6DF7", "#F7D24F", "#4FD8F7", "#F75C5C"
    ]
}

enum DateKey {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func key(_ date: Date) -> String { formatter.string(from: date) }
    static func date(_ key: String) -> Date? { formatter.date(from: key) }
    static func monthPrefix(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d-", comps.year ?? 0, comps.month ?? 0)
    }
}
