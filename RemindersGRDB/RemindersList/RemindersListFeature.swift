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
            },
        animation: .default
    )
    var remindersListRows: [RemindersListRow]

    var remindersListForm: RemindersList.Draft?

    @Selection
    struct RemindersListRow {
        let incompleteRemindersCount: Int
        let remindersList: RemindersList
    }

    func  deleteButtonTapped(_ remindersList: RemindersList) {
        withErrorReporting {
            try database.write { db in
                try RemindersList
                    .delete(remindersList)
                    .execute(db)
            }
        }
    }

    func editButtonTapped(_ remindersList: RemindersList) {
        remindersListForm = .init(remindersList)
    }

    func addListButtonTapped() {
        remindersListForm = .init()
    }
}

struct RemindersListsView: View {
    @Bindable var model: RemindersListModel

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
                    .swipeActions {
                        Button(role: .destructive) {
                            model.deleteButtonTapped(row.remindersList)
                        } label: {
                            Image(systemName: "trash")
                        }

                        Button {
                            model.editButtonTapped(row.remindersList)
                        } label: {
                            Image(systemName: "info")
                        }
                    }
                }
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
                        model.addListButtonTapped()
                    }  label: {
                        Text("Add List")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(item: $model.remindersListForm) { list in
            NavigationStack {
                RemindersListForm(remindersList: list)
                    .navigationTitle("New List")
            }
            .presentationDetents([.medium])
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
