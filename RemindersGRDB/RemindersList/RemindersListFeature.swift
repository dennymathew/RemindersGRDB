import SwiftUI
import SQLiteData

@Observable
class RemindersListsModel {
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

    @ObservationIgnored
    @FetchOne(
        Reminder.select {
            Stats.Columns(
                allCount: $0.count(filter: !$0.isCompleted),
                flaggedCount: $0.count(filter: !$0.isCompleted && $0.isFlagged),
                scheduledCount: $0.count(filter: !$0.isCompleted && $0.isScheduled),
                todayCount: $0.count(filter: !$0.isCompleted && $0.isToday)
            )
        }
    )
    var stats = Stats()

    @Selection
    struct Stats {
        var allCount = 0
        var flaggedCount = 0
        var scheduledCount = 0
        var todayCount = 0
    }

    var remindersListForm: RemindersList.Draft?

    var remindersDetail: RemindersDetailModel?

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

    func detailButtonTapped(_ detailType: DetailType) {
        remindersDetail = RemindersDetailModel(detailType: detailType)
    }
}

struct RemindersListsView: View {
    @Bindable var model: RemindersListsModel

    @State private var searchText: String = ""

    var body: some View {
        List {
            Section {
                Grid(
                    alignment: .leading,
                    horizontalSpacing: 16,
                    verticalSpacing: 16
                ) {
                    GridRow {
                        ReminderGridCell(
                            color: .blue,
                            count: model.stats.todayCount,
                            iconName: "calendar.circle.fill",
                            title: "Today"
                        ) {
                            model.detailButtonTapped(.today)
                        }

                        ReminderGridCell(
                            color: .red,
                            count: model.stats.scheduledCount,
                            iconName: "calendar.circle.fill",
                            title: "Scheduled"
                        ) {
                            model.detailButtonTapped(.scheduled)
                        }
                    }

                    GridRow {
                        ReminderGridCell(
                            color: .gray,
                            count: model.stats.allCount,
                            iconName: "tray.circle.fill",
                            title: "All"
                        ) {
                            model.detailButtonTapped(.all)
                        }

                        ReminderGridCell(
                            color: .orange,
                            count: model.stats.flaggedCount,
                            iconName: "flag.circle.fill",
                            title: "Flagged"
                        ) {
                            model.detailButtonTapped(.flagged)
                        }
                    }

                    GridRow {
                        ReminderGridCell(
                            color: .gray,
                            count: model.stats.allCount,
                            iconName: "checkmark.circle.fill",
                            title: "Completed"
                        ) {
                            model.detailButtonTapped(.completed)
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .padding([.leading, .trailing], -16)
            }

            Section {
                ForEach(
                    model.remindersListRows,
                    id: \.remindersList.id
                ) { row in
                    Button {
                        model.detailButtonTapped(.remindersList(row.remindersList))
                    } label: {
                        RemindersListRow(
                            incompleteRemindersCount: row.incompleteRemindersCount,
                            remindersList: row.remindersList
                        )
                        .foregroundColor(.primary)
                    }
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
//                        model.newReminderButtonTapped()
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
        .navigationDestination(item: $model.remindersDetail) { details in
            RemindersDetailView(model: details)
        }
    }

    private struct ReminderGridCell: View {
        let color: Color
        let count: Int?
        let iconName: String
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: iconName)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(color)
                            .background(
                                Color
                                    .white
                                    .clipShape(Circle())
                                    .padding(4)
                            )

                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .bold()
                            .padding(.leading, 4)

                        Spacer()

                        if let count {
                            Text("\(count)")
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .bold()
                                .foregroundStyle(Color(.label))
                        }
                    }

                    Spacer()
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
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
