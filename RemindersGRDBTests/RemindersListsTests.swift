import CustomDump
import DependenciesTestSupport
import Testing
import SQLiteData
@testable import RemindersGRDB
import InlineSnapshotTesting
import SnapshotTestingCustomDump

@Suite(
    .dependency(\.defaultDatabase, try appDatabase()),
    .snapshots(record: .failed)
)
@MainActor
struct RemindersListsTests {
    @Test func deletion() async throws {
        let model = RemindersListModel()
        try await model.$remindersListRows.load()
        assertInlineSnapshot(of: model.remindersListRows, as: .customDump) {
            """
            [
              [0]: RemindersListModel.RemindersListRow(
                incompleteRemindersCount: 1,
                remindersList: RemindersList(
                  id: 3,
                  color: 2128628479,
                  title: "Business"
                )
              ),
              [1]: RemindersListModel.RemindersListRow(
                incompleteRemindersCount: 4,
                remindersList: RemindersList(
                  id: 1,
                  color: 61381144575,
                  title: "Family"
                )
              ),
              [2]: RemindersListModel.RemindersListRow(
                incompleteRemindersCount: 2,
                remindersList: RemindersList(
                  id: 2,
                  color: 4017310463,
                  title: "Personal"
                )
              )
            ]
            """
        }

        model.deleteButtonTapped(indexSet: [1])
        try await model.$remindersListRows.load()

        assertInlineSnapshot(of: model.remindersListRows, as: .customDump) {
            """
            [
              [0]: RemindersListModel.RemindersListRow(
                incompleteRemindersCount: 1,
                remindersList: RemindersList(
                  id: 3,
                  color: 2128628479,
                  title: "Business"
                )
              ),
              [1]: RemindersListModel.RemindersListRow(
                incompleteRemindersCount: 2,
                remindersList: RemindersList(
                  id: 2,
                  color: 4017310463,
                  title: "Personal"
                )
              )
            ]
            """
        }
    }
}
