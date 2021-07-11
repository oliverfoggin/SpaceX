//
//  LaunchView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchView: View {
    let store: Store<Launch, LaunchAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                
            }
        }
    }
}


struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(
            store: Store(
                initialState: Launch(
                    id: "12345678",
                    missionName: "Mission",
                    launchDate: Date(),
                    rocketId: "09876kljh",
                    patchImageURL: URL(string: "http://placekitten.com/200/300")!,
                    success: true,
                    wikipediaURL: URL(string: "https://wikipedia.com")!,
                    youtubeID: "234567"
                ),
                reducer: launchReducer,
                environment: .init()
            )
        )
    }
}
