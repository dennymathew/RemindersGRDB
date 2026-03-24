import SwiftUI
import SQLiteData

@Observable
class RemindersListModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase)
    var database

    @ObservationIgnored
    @FetchAll(
        RemindersList
            .order(by: \.title)
            .group(by: \.id)
            .leftJoin(Reminder.all) {
                $0.id.eq($1.remindersListID) &&
                !$1.isCompleted
            }
            .select {
                RemindersListRow.Columns(
                    incompleteRemindersCount: $1.count(),
                    remindersList: $0
                )
            }
    )
    var remindersListRows: [RemindersListRow]

    @Selection
    struct RemindersListRow {
        let incompleteRemindersCount: Int
        let remindersList: RemindersList
    }

    func  deleteButtonTapped(indexSet: IndexSet) {
        withErrorReporting {
            try database.write { db in
                let ids = indexSet.map { remindersListRows[$0].remindersList.id }
                try RemindersList
                    .where { $0.id.in(ids) }
                    .delete()
                    .execute(db)
            }
        }
    }
}

struct RemindersListsView: View {
    let model: RemindersListModel

    @State private var searchText: String = ""

    var body: some View {
        List {
            Section {
                    //Top-level stats
            }

            Section {
                ForEach(
                    model.remindersListRows,
                    id: \.remindersList.id
                ) { row in
                    RemindersListRow(
                        incompleteRemindersCount: row.incompleteRemindersCount,
                        remindersList: row.remindersList
                    )
                }
                .onDelete(perform: model.deleteButtonTapped(indexSet:))
            } header: {
                Text("My lists")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }

            Section {
                    // Tags
            } header: {
                Text("Tags")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                            // New reminder action
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New reminder")
                        }
                        .bold()
                        .font(.title3)
                    }
                    Spacer()
                    Button {
                            // Add list action
                    }  label: {
                        Text("Add List")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    NavigationStack {
        RemindersListsView(model: .init())
    }
}
