import SQLiteData
import Sharing
import SwiftUI

enum DetailType {
    case remindersList(RemindersList)

    var navigationTitle: String {
        switch self {
            case let .remindersList(remindersList):
                "\(remindersList.title) Reminders"
        }
    }

    var color: Color {
        switch self {
            case let .remindersList(remindersList):
                remindersList.color.swiftUIColor
        }
    }

    var appStorageKeySuffix: String {
        switch self {
            case let .remindersList(remindersList):
                "remindersList_\(remindersList.id)"
        }
    }
}

@MainActor
@Observable
class RemindersDetailModel {
    let detailType: DetailType

    @ObservationIgnored
    @FetchAll var reminders: [Reminder]

    @ObservationIgnored
    @Shared var showCompleted: Bool

    init(detailType: DetailType) {
        self.detailType = detailType
        _showCompleted = Shared(
            wrappedValue: false,
            .appStorage("showCompleted_\(detailType.appStorageKeySuffix)")
        )
        _reminders = FetchAll(remindersQuery)
    }

    var remindersQuery: some SelectStatementOf<Reminder> {
        Reminder
            .where {
                if !showCompleted {
                    !$0.isCompleted
                }
            }
            .where {
                switch detailType {
                    case let .remindersList(remindersList):
                        $0.remindersListID.eq(remindersList.id)
                }
            }
    }

    func toggleShowCompletedButtonTapped() async {
        $showCompleted.withLock {
            $0.toggle()
        }
        await updateQuery()
    }

    func updateQuery() async {
        await withErrorReporting {
            try await $reminders.load(remindersQuery)
        }
    }
}

struct RemindersDetailView: View {
    @Bindable var model: RemindersDetailModel

    var body: some View {
        List {
            ForEach(model.reminders) { reminder in
                ReminderRow(
                    color: model.detailType.color,
                    isPastDue: false,
                    reminder: reminder,
                    tags: ["weekend", "fun"]
                ) {
                    // Details button tapped in row
                }
            }
        }
        .navigationTitle(Text(model.detailType.navigationTitle))
        .listStyle(.plain)
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
                }
                .tint(model.detailType.color)
            }

            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Group {
                        Menu {
                            ForEach(["Due date", "Priority", "Title"], id: \.self) { ordering in
                                Button {
                                    // Order action
                                } label: {
                                    Label {
                                        Text(ordering)
                                    } icon: {
                                        // Ordering icon
                                    }
                                }
                            }
                        } label: {
                            Text("Sort By")
                            Label {
                                Text("Current order") // TODO: - get the current order
                            } icon: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        Button {
                            Task {
                                await model.toggleShowCompletedButtonTapped()
                            }
                        } label: {
                            Label {
                                Text(
                                    model.showCompleted
                                    ? "Hide completed" : "Show completed"
                                )
                            } icon: {
                                Image(
                                    systemName: model.showCompleted
                                    ? "eye.slash.fill" : "eye"
                                )
                            }
                        }
                    }
                    .tint(model.detailType.color)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .tint(model.detailType.color)
                }
            }
        }
    }
}

struct RemindersDetailPreview: PreviewProvider {
    static var previews: some View {
        let remindersList = try! prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
            return try $0.defaultDatabase.read { db in
                try RemindersList.find(1).fetchOne(db)!
            }
        }

        NavigationStack {
            RemindersDetailView(
                model: .init(detailType: .remindersList(remindersList))
            )
        }
    }
}
