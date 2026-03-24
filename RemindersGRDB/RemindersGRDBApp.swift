import SwiftUI

@main
struct RemindersGRDBApp: App {
    init () {
        let _ = try! appDatabase()
    }
    var body: some Scene {
        WindowGroup {
            RemindersListsView(model: .init())
        }
    }
}
