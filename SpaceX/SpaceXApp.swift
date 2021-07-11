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
            AppView(
                store: Store(
                    initialState: .init(),
                    reducer: appReducer,
                    environment: .live
                )
            )
        }
    }
}
