import Foundation

@MainActor
final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published var selectedHabitID: UUID?

    private let fileURL: URL

    init() {
        let fileManager = FileManager.default
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = support.appendingPathComponent("HabitWidget", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("habits.json")
        load()
    }

    var selectedHabit: Habit? {
        guard let id = selectedHabitID else { return habits.first }
        return habits.first { $0.id == id } ?? habits.first
    }

    func toggle(date: Date, habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        let key = DateKey.key(date)
        if habits[index].completedDates.contains(key) {
            habits[index].completedDates.remove(key)
        } else {
            habits[index].completedDates.insert(key)
        }
        save()
    }

    func addHabit(name: String, colorHex: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let habit = Habit(name: trimmed, colorHex: colorHex)
        habits.append(habit)
        selectedHabitID = habit.id
        save()
    }

    func update(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
        save()
    }

    func delete(_ id: UUID) {
        habits.removeAll { $0.id == id }
        if selectedHabitID == id { selectedHabitID = habits.first?.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
            selectedHabitID = decoded.first?.id
        } else {
            habits = [Habit(name: "Habit", colorHex: HabitPalette.colors[0])]
            selectedHabitID = habits.first?.id
            save()
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(habits)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            NSLog("HabitWidget: failed to save habits - \(error)")
        }
    }
}
