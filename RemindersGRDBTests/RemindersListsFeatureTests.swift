import CustomDump
import DependenciesTestSupport
import Testing
import SQLiteData
@testable import RemindersGRDB
import InlineSnapshotTesting
import SnapshotTestingCustomDump

extension BaseTestSuite {
    @MainActor
    struct RemindersListsTests {
        @Test func deletion() async throws {
            let model = RemindersListsModel()
            try await model.$remindersListRows.load()
            assertInlineSnapshot(of: model.remindersListRows, as: .customDump) {
            """
            [
              [0]: RemindersListsModel.RemindersListRow(
                incompleteRemindersCount: 1,
                remindersList: RemindersList(
                  id: 3,
                  color: 2128628479,
                  title: "Business"
                )
              ),
              [1]: RemindersListsModel.RemindersListRow(
                incompleteRemindersCount: 4,
                remindersList: RemindersList(
                  id: 1,
                  color: 61381144575,
                  title: "Family"
                )
              ),
              [2]: RemindersListsModel.RemindersListRow(
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

            model.deleteButtonTapped(model.remindersListRows[1].remindersList)
            try await model.$remindersListRows.load()

            assertInlineSnapshot(of: model.remindersListRows, as: .customDump) {
            """
            [
              [0]: RemindersListsModel.RemindersListRow(
                incompleteRemindersCount: 1,
                remindersList: RemindersList(
                  id: 3,
                  color: 2128628479,
                  title: "Business"
                )
              ),
              [1]: RemindersListsModel.RemindersListRow(
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
}
