//
//  SpaceXApp.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

@main
struct SpaceXApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: .init(),
                    reducer: appReducer,
                    environment: .live
                )
            )
        }
    }
}
