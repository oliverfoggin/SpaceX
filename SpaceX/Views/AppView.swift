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

struct AppView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                if viewStore.company == nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            viewStore.send(.fetchCompany)
                            viewStore.send(.fetchRockets)
                        }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                            Section(header: HeaderView(title: "COMPANY")) {
                                CompanyView(company: viewStore.company!)
                            }
                            Section(header: HeaderView(title: "LAUNCHES")) {
                                if viewStore.launches.isEmpty {
                                    ProgressView()
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .onAppear {
                                            viewStore.send(.fetchLaunches)
                                        }
                                } else {
                                    ForEachStore(
                                        self.store.scope(state: \.compiledLaunchViewModels, action: AppAction.launchAction(id:action:))
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
                trailing: NavigationLink(destination: FilterView(store: self.store.scope(state: \.filterState, action: AppAction.filterAction(action:)))) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: .init(),
                reducer: appReducer,
                environment: .live
            )
        )
    }
}
