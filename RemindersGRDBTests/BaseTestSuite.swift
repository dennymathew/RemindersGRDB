import InlineSnapshotTesting
import Foundation
import SQLiteData
import Testing
@testable import RemindersGRDB
import DependenciesTestSupport

@MainActor
@Suite(
    .dependency(\.date.now, Date(timeIntervalSince1970: 1_700_000_000)),
    .dependency(\.defaultDatabase, try appDatabase()),
    .snapshots(record: .failed)
)
struct BaseTestSuite {}
