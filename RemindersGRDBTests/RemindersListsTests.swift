import DependenciesTestSupport
import Testing
import SQLiteData
@testable import RemindersGRDB

@Suite(.dependency(\.defaultDatabase, try appDatabase()))
struct RemindersListsTests {
    @Test func deletion() async throws {
        let model = await RemindersListModel()
        try await model.$remindersLists.load()
        #expect(model.remindersLists.count == 3)
        #expect(model.remindersLists.map(\.id) == [3, 1, 2])

        await model.deleteButtonTapped(indexSet: [1])
        try await model.$remindersLists.load()

        #expect(model.remindersLists.count == 2)
        #expect(model.remindersLists.map(\.id) == [3, 2])
    }
}
