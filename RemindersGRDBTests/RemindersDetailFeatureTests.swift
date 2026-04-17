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

            try await model.$rows.load()
            assertInlineSnapshot(of: model.$rows, as: .customDump) {
                """
                [
                  [0]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 6,
                      createdAt: nil,
                      dueDate: Date(2023-11-16T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: true,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Pick up kids from school",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  ),
                  [1]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 8,
                      createdAt: nil,
                      dueDate: Date(2023-11-18T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: false,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Take out trash",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  )
                ]
                """
            }

            await model.toggleShowCompletedButtonTapped()
            try await model.$rows.load()
            assertInlineSnapshot(of: model.rows, as: .customDump) {
                """
                [
                  [0]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 6,
                      createdAt: nil,
                      dueDate: Date(2023-11-16T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: true,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Pick up kids from school",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  ),
                  [1]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 8,
                      createdAt: nil,
                      dueDate: Date(2023-11-18T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: false,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Take out trash",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  ),
                  [2]: RemindersDetailModel.Row(
                    isPastDue: false,
                    reminder: Reminder(
                      id: 7,
                      createdAt: nil,
                      dueDate: Date(2023-11-12T22:13:20.000Z),
                      isCompleted: true,
                      isFlagged: false,
                      notes: "",
                      priority: .low,
                      remindersListID: 2,
                      title: "Get laundry",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  )
                ]
                """
            }

            await model.orderingButtonTapped(.priority)
            try await model.$rows.load()
            assertInlineSnapshot(of: model.rows, as: .customDump) {
                """
                [
                  [0]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 6,
                      createdAt: nil,
                      dueDate: Date(2023-11-16T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: true,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Pick up kids from school",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  ),
                  [1]: RemindersDetailModel.Row(
                    isPastDue: true,
                    reminder: Reminder(
                      id: 8,
                      createdAt: nil,
                      dueDate: Date(2023-11-18T22:13:20.000Z),
                      isCompleted: false,
                      isFlagged: false,
                      notes: "",
                      priority: .high,
                      remindersListID: 2,
                      title: "Take out trash",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  ),
                  [2]: RemindersDetailModel.Row(
                    isPastDue: false,
                    reminder: Reminder(
                      id: 7,
                      createdAt: nil,
                      dueDate: Date(2023-11-12T22:13:20.000Z),
                      isCompleted: true,
                      isFlagged: false,
                      notes: "",
                      priority: .low,
                      remindersListID: 2,
                      title: "Get laundry",
                      updatedAt: nil
                    ),
                    tags: [
                      [0]: "easy-win"
                    ]
                  )
                ]
                """
            }
        }
    }
}
