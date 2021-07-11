//
//  ContentView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct HeaderView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.white)
                .font(.title)
                .padding(4)
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .background(Color.init(white: 0.2))
    }
}

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
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                            Section(header: HeaderView(title: "COMPANY")) {
                                CompanyView(company: viewStore.company!)
                            }
                            Section(header: HeaderView(title: "LAUNCHES")) {
                                if viewStore.launches.isEmpty {
                                    ProgressView()
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .onAppear {
                                            viewStore.send(AppAction.fetchLaunches)
                                        }
                                } else {
                                    ForEachStore(
                                        self.store.scope(state: \.sortedFilteredLaunches, action: AppAction.launchAction(id:action:))
                                    ) { launchStore in
                                        VStack {
                                            LaunchView.init(store: launchStore)
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    }
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
