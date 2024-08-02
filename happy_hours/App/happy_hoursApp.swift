//
//  happy_hoursApp.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct happy_hoursApp: App {
    var body: some Scene {
        WindowGroup {
            BookListView(store: Store(initialState: BookListReducer.State()) {
                BookListReducer()
            })
        }
    }
}
