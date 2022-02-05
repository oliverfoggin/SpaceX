import ComposableArchitecture
import SwiftUI
import FilterFeature
import LaunchFeature
import CompanyFeature
import ReusableViews

public struct AppView: View {
  let store: Store<AppState, AppAction>
  @ObservedObject var viewStore: ViewStore<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }

  public var body: some View {
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
      .confirmationDialog(
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
      .alert(
        self.store.scope(state: \.downloadErrorAlert),
        dismiss: .downloadAlertCancelTapped
      )
      .navigationTitle("SpaceX")
      .navigationBarItems(
        trailing: Button { self.viewStore.send(.setFilterSheet(isPresented: true)) }
        label: { Image(systemName: "line.horizontal.3.decrease.circle") }
      )
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
              LaunchView(store: launchStore)
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
