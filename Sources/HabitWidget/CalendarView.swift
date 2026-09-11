import SwiftUI

struct CalendarView: View {
    let habit: Habit
    @Binding var month: Date
    let onToggle: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            header
            weekdayRow
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    dayCell(date)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left").font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 14, weight: .semibold))

            Spacer()

            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
    }

    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(Array(orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {
        if let date {
            let done = habit.completedDates.contains(DateKey.key(date))
            let isToday = calendar.isDateInToday(date)
            let color = Color(hex: habit.colorHex)

            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 12, weight: done ? .semibold : .regular))
                .foregroundStyle(done ? Color.white : Color.primary.opacity(isToday ? 1 : 0.85))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    Circle()
                        .fill(done ? color : Color.primary.opacity(0.06))
                        .padding(3)
                )
                .overlay(
                    Circle()
                        .strokeBorder(isToday ? color : .clear, lineWidth: 1.5)
                        .padding(3)
                )
                .contentShape(Circle())
                .onTapGesture { onToggle(date) }
                .help(done ? "Mark as not done" : "Mark as done")
        } else {
            Color.clear.frame(height: 32)
        }
    }

    private var days: [Date?] {
        guard let firstOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: month)
        ), let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            result.append(calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    private func shiftMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: month) {
            month = newMonth
        }
    }
}
