//
//  LaunchView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchView: View {
    let store: Store<LaunchState, LaunchAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "paperplane.fill")
                VStack(alignment: .leading) {
                    Text("Mission:")
                    Text("Date/time:")
                    Text("Rocket:")
                    Text("Days \(viewStore.days < 0 ? "since" : "from") now:")
                }
                VStack(alignment: .leading) {
                    Text(viewStore.missionName)
                    Text(viewStore.dateTime)
                    Text(viewStore.rocketInfo)
                    Text("\(viewStore.days < 0 ? "-" : "+")\(viewStore.days)")
                }
                Spacer()
                switch viewStore.successful {
                case .success:
                    Image(systemName: "checkmark")
                case .failure:
                    Image(systemName: "xmark")
                case .unknown:
                    Image(systemName: "questionmark")
                }
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                viewStore.send(.launchTapped)
            }
        }
    }
}
