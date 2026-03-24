import Foundation
import SQLiteData

@Table
struct RemindersList {
    let id: Int
    var color = 0x4a99ef_ff
    var title = ""
}

@Table
struct Tag {
    let id: Int
    var title = ""
}

@Table
struct Reminder {
    let id: Int
    var dueDate: Date?
    var isCompleted = false
    var isFlagging = false
    var notes = ""
    var title = ""
}
