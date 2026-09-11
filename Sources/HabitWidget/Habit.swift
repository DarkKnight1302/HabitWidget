import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var colorHex: String
    var completedDates: Set<String> = []

    init(id: UUID = UUID(), name: String, colorHex: String, completedDates: Set<String> = []) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.completedDates = completedDates
    }
}
