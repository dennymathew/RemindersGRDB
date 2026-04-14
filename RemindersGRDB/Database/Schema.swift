import Foundation
import SQLiteData

@Table
struct RemindersList: Equatable, Identifiable {
    let id: Int
    var color = 0x4a99ef_ff
    var title = ""
}

extension RemindersList.Draft: Identifiable {}

@Table
struct Tag: Identifiable {
    let id: Int
    var title = ""
}

extension Tag?.TableColumns {
    var jsonTitles: some QueryExpression<[String].JSONRepresentation> {
        (self.title ?? "").jsonGroupArray(filter: self.id.isNot(nil))
    }
}

@Table
struct Reminder: Identifiable {
    let id: Int
    var dueDate: Date?
    var isCompleted = false
    var isFlagged = false
    var notes = ""
    var priority: Priority?
    var remindersListID: RemindersList.ID
    var title = ""

    enum Priority: Int, QueryBindable {
        case low = 1
        case medium
        case high
    }
}

extension Reminder.TableColumns {
    var isPastDue: some QueryExpression<Bool> {
        !isCompleted && (dueDate ?? Date.distantFuture) < Date()
    }

    var isScheduled: some QueryExpression<Bool> {
        dueDate.isNot(nil)
    }

    var isToday: some QueryExpression<Bool> {
        #sql("date(\(dueDate)) == date()")
    }
}

@Table
struct ReminderTag {
    let reminderID: Reminder.ID
    let tagID: Tag.ID
}


