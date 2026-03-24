//
//  RemindersGRDBApp.swift
//  RemindersGRDB
//
//  Created by Denny Mathew on 24.03.26.
//

import SwiftUI

@main
struct RemindersGRDBApp: App {
    init () {
        let _ = try! appDatabase()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
