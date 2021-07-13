//
//  ContentView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<AppState, AppAction>
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let company = self.viewStore.company {
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        CompanyView(companyViewModel: CompanyViewModel(company: company))
                        LaunchListView(store: self.store)
                    }
                } else {
                    LoadingView(store: self.store)
                }
            }
            .actionSheet(
                self.store.scope(state: \.launchActionSheet),
                dismiss: .cancelTapped
            )
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showFilterSheet,
                    send: AppAction.setFilterSheet(isPresented:)
                )
            ) {
                FilterView(
                    store: self.store.scope(
                        state: \.filterState,
                        action: AppAction.filterAction(action:)
                    )
                )
            }
            .navigationTitle("SpaceX")
            .navigationBarItems(
                trailing: Button(action: { self.viewStore.send(.setFilterSheet(isPresented: true)) }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            )
        }
    }
}

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

struct LoadingView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear {
                    viewStore.send(.fetchCompany)
                    viewStore.send(.fetchRockets)
                }
        }
    }
}

struct LaunchListView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
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
