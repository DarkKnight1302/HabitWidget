import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var month = Date()
    @State private var showingAdd = false
    @State private var editingHabit: Habit?
    @State private var today = Date()

    var body: some View {
        VStack(spacing: 14) {
            habitBar

            if let habit = store.selectedHabit {
                CalendarView(habit: habit, month: $month) { date in
                    store.toggle(date: date, habitID: habit.id)
                }
                stats(for: habit)
            } else {
                Text("Add a habit to get started")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .padding(16)
        .frame(width: 340)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .background(WindowConfigurator())
        .sheet(isPresented: $showingAdd) { HabitEditor(existing: nil) }
        .sheet(item: $editingHabit) { habit in HabitEditor(existing: habit) }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            today = Date()
        }
    }

    private var habitBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.habits) { habit in
                    habitChip(habit)
                }
                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.primary.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .help("Add a habit")
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }

    private func habitChip(_ habit: Habit) -> some View {
        let selected = store.selectedHabit?.id == habit.id
        return Button {
            store.selectedHabitID = habit.id
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(selected ? Color.white : Color(hex: habit.colorHex))
                    .frame(width: 8, height: 8)
                Text(habit.name)
                    .font(.system(size: 12, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(selected ? Color(hex: habit.colorHex) : Color.primary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename / Edit") { editingHabit = habit }
            Button("Delete", role: .destructive) { store.delete(habit.id) }
        }
    }

    private func stats(for habit: Habit) -> some View {
        let total = Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 0
        let done = habit.completedDates.filter { $0.hasPrefix(DateKey.monthPrefix(month)) }.count
        return HStack {
            Label("\(done)/\(total) this month", systemImage: "calendar")
            Spacer()
            Label("\(streak(for: habit)) day streak", systemImage: "flame.fill")
                .foregroundStyle(Color(hex: habit.colorHex))
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .id(today)
    }

    private func streak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        var day = Date()
        if !habit.completedDates.contains(DateKey.key(day)) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while habit.completedDates.contains(DateKey.key(day)) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }
}

struct HabitEditor: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.dismiss) private var dismiss
    let existing: Habit?

    @State private var name = ""
    @State private var colorHex = HabitPalette.colors[0]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(existing == nil ? "New Habit" : "Edit Habit")
                .font(.headline)

            TextField("Habit name", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 260)

            HStack(spacing: 10) {
                ForEach(HabitPalette.colors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.primary, lineWidth: colorHex == hex ? 2 : 0)
                                .padding(-3)
                        )
                        .onTapGesture { colorHex = hex }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
        .onAppear {
            if let existing {
                name = existing.name
                colorHex = existing.colorHex
            }
        }
    }

    private func save() {
        if var habit = existing {
            habit.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            habit.colorHex = colorHex
            store.update(habit)
        } else {
            store.addHabit(name: name, colorHex: colorHex)
        }
        dismiss()
    }
}
