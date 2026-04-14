import SQLiteData
import Sharing
import SwiftUI

@MainActor
@Observable
class RemindersDetailModel {
    let detailType: DetailType

    @ObservationIgnored
    @FetchAll var rows: [Row]

    @ObservationIgnored
    @Shared var showCompleted: Bool

    @ObservationIgnored
    @Shared var ordering: Ordering

    var reminderForm: Reminder.Draft?

    init(detailType: DetailType) {
        self.detailType = detailType
        _showCompleted = Shared(
            wrappedValue: false,
            .appStorage("showCompleted_\(detailType.appStorageKeySuffix)")
        )
        _ordering = Shared(
            wrappedValue: .dueDate,
            .appStorage("ordering_\(detailType.appStorageKeySuffix)")
        )
        _rows = FetchAll(query)
    }

    var query: some StructuredQueries.Statement<Row> {
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
                    case .all:
                        true
                    case .completed:
                        $0.isCompleted
                    case .flagged:
                        $0.isFlagged
                    case .scheduled:
                        $0.isScheduled
                    case .today:
                        $0.isToday
                }
            }
            .order { $0.isCompleted }
            .order {
                switch ordering {
                    case .dueDate:
                        $0.dueDate.asc(nulls: .last)
                    case .priority:
                        ($0.priority.desc(), $0.isFlagged.desc())
                    case .title:
                        $0.title
                }
            }
            .leftJoin(ReminderTag.all) { $0.id.eq($1.reminderID) }
            .leftJoin(Tag.all) { $1.tagID.eq($2.id) }
            .select {
                Row.Columns(
                    isPastDue: $0.isPastDue,
                    reminder: $0,
                    tags: $2.jsonTitles
                )
            }
    }

    func toggleShowCompletedButtonTapped() async {
        $showCompleted.withLock {
            $0.toggle()
        }
        await updateQuery()
    }

    func orderingButtonTapped(_ ordering: Ordering) async {
        $ordering.withLock { $0 = ordering }
        await updateQuery()
    }

    func reminderDetailsButtonTapped(_ reminder: Reminder) {
        reminderForm = .init(reminder)
    }

    func newReminderButtonTapped() {
        switch detailType {
            case let .remindersList(remindersList):
                reminderForm = .init(remindersListID: remindersList.id)
            case .all:
                break
            case .completed:
                break
            case .flagged:
                break
            case .scheduled:
                break
            case .today:
                break
        }
    }

    func updateQuery() async {
        await withErrorReporting {
            try await $rows.load(query, animation: .default)
        }
    }

    @Selection
    struct Row {
        var isPastDue: Bool
        var reminder: Reminder
        @Column(as: [String].JSONRepresentation.self)
        var tags: [String]
    }
}

enum Ordering: String, CaseIterable {
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"

    var icon: Image {
        switch self {
            case .dueDate:
                .init(systemName: "calendar")
            case .priority:
                .init(systemName: "chart.bar.fill")
            case .title:
                .init(systemName: "textformat.characters")
        }
    }
}

enum DetailType {
    case remindersList(RemindersList)
    case all
    case completed
    case flagged
    case scheduled
    case today

    var navigationTitle: String {
        switch self {
            case let .remindersList(remindersList):
                "\(remindersList.title) Reminders"
            case .all:
                "All"
            case .completed:
                "Completed"
            case .flagged:
                "Flagged"
            case .scheduled:
                "Scheduled"
            case .today:
                "Today"
        }
    }

    var color: Color {
        switch self {
            case let .remindersList(remindersList):
                remindersList.color.swiftUIColor
            case .all:
                .black
            case .completed:
                .gray
            case .flagged:
                .orange
            case .scheduled:
                .red
            case .today:
                .blue
        }
    }

    var appStorageKeySuffix: String {
        switch self {
            case let .remindersList(remindersList):
                "remindersList_\(remindersList.id)"
            case .all:
                "all"
            case .completed:
                "completed"
            case .flagged:
                "flagged"
            case .scheduled:
                "scheduled"
            case .today:
                "today"
        }
    }
}

struct RemindersDetailView: View {
    @Bindable var model: RemindersDetailModel

    var body: some View {
        List {
            ForEach(model.rows, id: \.reminder.id) { row in
                ReminderRow(
                    color: model.detailType.color,
                    isPastDue: row.isPastDue,
                    reminder: row.reminder,
                    tags: row.tags
                ) {
                    model.reminderDetailsButtonTapped(row.reminder)
                }
            }
        }
        .navigationTitle(Text(model.detailType.navigationTitle))
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        model.newReminderButtonTapped()
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
                            ForEach(Ordering.allCases, id: \.self) { ordering in
                                Button {
                                    Task {
                                        await model.orderingButtonTapped(ordering)
                                    }
                                } label: {
                                    Label {
                                        Text(ordering.rawValue)
                                    } icon: {
                                        ordering.icon
                                    }
                                }
                            }
                        } label: {
                            Text("Sort By")
                            Label {
                                Text(model.ordering.rawValue)
                            } icon: {
                                model.ordering.icon
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
