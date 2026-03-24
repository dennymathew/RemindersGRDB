import SwiftUI
import SQLiteData

struct RemindersListsView: View {
    @FetchAll(RemindersList.order(by: \.title)) var remindersLists

    @State private var searchText: String = ""

    var body: some View {
        List {
            Section {
                    //Top-level stats
            }

            Section {
                ForEach(remindersLists) { list in
                    RemindersListRow(
                        incompleteRemindersCount: 0,
                        remindersList: list
                    )
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
        RemindersListsView()
    }
}
