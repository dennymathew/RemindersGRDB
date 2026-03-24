import SwiftUI

struct RemindersListsView: View {

    @State private var searchText: String = ""

    var body: some View {
        List {
            Section {
                    //Top-level stats
            }

            Section {
                RemindersListRow(
                    incompleteRemindersCount: 5,
                    remindersList: .init(
                        id: 1,
                        color: 0x4a99ef_ff,
                        title: "Family"
                    )
                )
                RemindersListRow(
                    incompleteRemindersCount: 3,
                    remindersList: .init(
                        id: 2,
                        color: 0xef734a_ff,
                        title: "Personal"
                    )
                )
                RemindersListRow(
                    incompleteRemindersCount: 2,
                    remindersList: .init(
                        id: 3,
                        color: 0x7ee04a_ff,
                        title: "Business"
                    )
                )
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
    RemindersListsView()
}
