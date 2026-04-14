import InlineSnapshotTesting
import SQLiteData
import Testing
@testable import RemindersGRDB
import SnapshotTestingCustomDump

extension BaseTestSuite {
    @MainActor
    struct RemindersDetailTests {
        @Dependency(\.defaultDatabase) var database
        @Test func querying() async throws {
            let remindersList = try await database.read { db in
                try RemindersList.find(2).fetchOne(db)!
            }
            let model = RemindersDetailModel(detailType: .remindersList(remindersList))

            try await model.$reminders.load()
            assertInlineSnapshot(of: model.reminders, as: .customDump) {
                """
                [
                  [0]: Reminder(
                    id: 6,
                    dueDate: Date(2023-11-16T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: true,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Pick up kids from school"
                  ),
                  [1]: Reminder(
                    id: 8,
                    dueDate: Date(2023-11-18T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: false,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Take out trash"
                  )
                ]
                """
            }

            await model.toggleShowCompletedButtonTapped()
            try await model.$reminders.load()
            assertInlineSnapshot(of: model.reminders, as: .customDump) {
                """
                [
                  [0]: Reminder(
                    id: 6,
                    dueDate: Date(2023-11-16T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: true,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Pick up kids from school"
                  ),
                  [1]: Reminder(
                    id: 8,
                    dueDate: Date(2023-11-18T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: false,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Take out trash"
                  ),
                  [2]: Reminder(
                    id: 7,
                    dueDate: Date(2023-11-12T22:13:20.000Z),
                    isCompleted: true,
                    isFlagged: false,
                    notes: "",
                    priority: .low,
                    remindersListID: 2,
                    title: "Get laundry"
                  )
                ]
                """
            }

            await model.orderingButtonTapped(.priority)
            try await model.$reminders.load()
            assertInlineSnapshot(of: model.reminders, as: .customDump) {
                """
                [
                  [0]: Reminder(
                    id: 6,
                    dueDate: Date(2023-11-16T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: true,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Pick up kids from school"
                  ),
                  [1]: Reminder(
                    id: 8,
                    dueDate: Date(2023-11-18T22:13:20.000Z),
                    isCompleted: false,
                    isFlagged: false,
                    notes: "",
                    priority: .high,
                    remindersListID: 2,
                    title: "Take out trash"
                  ),
                  [2]: Reminder(
                    id: 7,
                    dueDate: Date(2023-11-12T22:13:20.000Z),
                    isCompleted: true,
                    isFlagged: false,
                    notes: "",
                    priority: .low,
                    remindersListID: 2,
                    title: "Get laundry"
                  )
                ]
                """
            }
        }
    }
}
