//
//  ContentView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                if viewStore.company == nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            viewStore.send(AppAction.fetchCompany)
                        }
                } else {
                    List {
                        Section(header: Text("COMPANY")) {
                            CompanyView(company: viewStore.company!)
                        }
                        Section(header: Text("LAUNCHES")) {
                            ForEach(viewStore.sortedFilteredLaunches) { launch in
                                Text(launch.launch.missionName)
                            }
//                            ForEachStore(<#T##store: Store<Array<_>, (Array<_>.Index, _)>##Store<Array<_>, (Array<_>.Index, _)>#>, content: <#T##(Store<_, _>) -> View#>)
                            if viewStore.launches.isEmpty {
                                ProgressView()
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .onAppear {
                                        viewStore.send(AppAction.fetchLaunches)
                                    }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("SpaceX")
            .navigationBarItems(
                trailing: Button(
                    action: {}, label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: .init(),
                reducer: appReducer,
                environment: .live
            )
        )
    }
}
