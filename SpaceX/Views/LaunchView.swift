//
//  LaunchView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchView: View {
    let store: Store<LaunchViewModel, LaunchAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(alignment: .firstTextBaseline) {
                viewStore.patchImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                VStack(alignment: .leading) {
                    Text("Mission:")
                    Text("Date/time:")
                    Text("Rocket:")
                    Text(viewStore.daysTitle)
                }
                VStack(alignment: .leading) {
                    Text(viewStore.missionName)
                    Text(viewStore.dateTime)
                    Text(viewStore.rocketInfo)
                    Text("\(viewStore.days)")
                }
                Spacer()
                viewStore.successImage
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                viewStore.send(.launchTapped(launch: viewStore.launch))
            }
            .onAppear {
                if case .none = viewStore.launch.patchImage {
                    viewStore.send(.requestImage)
                }
            }
        }
    }
}
