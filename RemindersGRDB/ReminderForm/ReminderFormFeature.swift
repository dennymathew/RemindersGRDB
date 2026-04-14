import IssueReporting
import SQLiteData
import SwiftUI

struct ReminderFormFeatureView: View {
    @State var reminder: Reminder.Draft

    @FetchOne var selectedRemindersList = RemindersList.Draft()
    @FetchAll var remindersLists: [RemindersList]

    @State private var isPresentingTagsPopover = false
    @State private var isPresentingDatePopover = false

    var body: some View {
        Form {
            TextField("Title", text: $reminder.title)

            TextEditor(text: $reminder.notes)
                .lineLimit(4)

            Section {
                Button {
                    isPresentingTagsPopover.toggle()
                } label: {
                    HStack {
                        Image(systemName: "number.square.fill")
                            .font(.title)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text("weekend #fun") // TODO: - Get tags
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.callout)
                            .foregroundStyle(.gray)
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .popover(isPresented: $isPresentingTagsPopover) {
                NavigationStack {
                    Text("Tags")
                }
            }

            Section {
                Toggle(isOn: $reminder.dueDate.isNotNil) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("Date")
                    }
                }
                if reminder.dueDate != nil {
                    DatePicker(
                        "",
                        selection: $reminder.dueDate[coalesce: .now],
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            Section {
                Toggle(isOn: $reminder.isFlagged) {
                    HStack {
                        Image(systemName: "flag.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("Flag")
                    }
                }

                Picker(selection: $reminder.priority) {
                    Text("None").tag(Reminder.Priority?.none)
                    Divider()
                    Text("High").tag(Reminder.Priority.high)
                    Text("Medium").tag(Reminder.Priority.medium)
                    Text("low").tag(Reminder.Priority.low)
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("Priority")
                    }
                }

                Picker(selection: $reminder.remindersListID) {
                    ForEach(remindersLists) { list in
                        Text(list.title)
                            .tag(list.id)
                            .buttonStyle(.plain)
                    }
                } label: {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.title)
                            .foregroundStyle(selectedRemindersList.color.swiftUIColor)
                        Text("List")
                    }
                }

            }
        }
        .task(id: reminder.remindersListID) {
            await withErrorReporting {
                try await $selectedRemindersList.load(
                    try await RemindersList.Draft
                        .where { $0.id.eq(reminder.remindersListID) }
                )
            }
        }
        .toolbar {
            ToolbarItem {
                Button {

                } label: {
                    Text("Save")
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button {

                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

struct ReminderFormFeature_Previews: PreviewProvider {
    static var previews: some View {
        let _ = try! prepareDependencies {
            $0.defaultDatabase = try appDatabase()
        }
        NavigationStack {
            ReminderFormFeatureView(
                reminder: .init(
                    dueDate: Date(),
                    isFlagged: true,
                    notes: "* Milk\n* Eggs\n * Cheese",
                    priority: .medium,
                    remindersListID: 1,
                    title: "Get groceries"
                )
            )
            .navigationTitle("Reminder")
        }
    }
}

extension Date? {
    var isNotNil: Bool {
        get { self != nil }
        set { self = newValue ? Date() : nil }
    }
}

extension Optional {
    fileprivate subscript(coalesce coalesce: Wrapped) -> Wrapped {
        get  { self ?? coalesce }
        set { self = newValue }
    }
}
