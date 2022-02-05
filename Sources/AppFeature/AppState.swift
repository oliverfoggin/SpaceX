import ComposableArchitecture
import SwiftUI
import Models
import FoundationHelpers
import FilterFeature
import LaunchFeature
import Services

enum FetchStatus {
  case none, fetching, complete
}

public struct AppState: Equatable {
  var company: Company?
  var companyFetchStatus: FetchStatus = .none

  var downloadErrorAlert: AlertState<AppAction>?

  var launches: IdentifiedArrayOf<Launch> = []
  var launchesFetchStatus: FetchStatus = .none
  var launchActionSheet: ConfirmationDialogState<AppAction>?

  var rockets: [String: Rocket] = [:]
  var rocketsFetchStatus: FetchStatus = .none

  var filterState = FilterState()
  var showFilterSheet = false

  var compiledLaunchViewModels: IdentifiedArrayOf<LaunchViewModel> = []

	public init() {}
}

extension AppState {
  func compileLaunchViewModels(now: Date, calendar: Calendar) -> IdentifiedArrayOf<LaunchViewModel> {
    let sortedArray = launches.sorted(by: \.launchDate, using: filterState.ascending ? (<) : (>))
      .filter { launch in
        switch self.filterState.successFilter {
        case .all:
          return true
        case .successful:
          return launch.success ?? false
        case .unsuccessful:
          return !(launch.success ?? true)
        }
      }
      .filter { launch in
        switch self.filterState.year {
        case "All":
          return true
        case let year:
          guard let yearInt = Int(year),
                calendar.component(.year, from: launch.launchDate) == yearInt
          else {
            return false
          }
          return true
        }
      }
      .map { launch -> LaunchViewModel in
        LaunchViewModel(
          launch: launch,
          rocket: self.rockets[launch.rocketId],
          now: now,
          calendar: calendar
        )
      }

    return IdentifiedArray(uniqueElements: sortedArray)
  }
}

public enum AppAction: Equatable {
  case fetchCompany
  case companyResponse(Result<Company, SpaceXClient.Failure>)
  case companyAlertReloadTapped

  case downloadAlertCancelTapped

  case fetchLaunches
  case launchesResponse(Result<IdentifiedArrayOf<Launch>, SpaceXClient.Failure>)
  case launchAlertReloadTapped

  case fetchRockets
  case rocketsResponse(Result<[String: Rocket], SpaceXClient.Failure>)

  case compileLaunches

  case launchAction(id: Launch.ID, action: LaunchAction)

  case filterAction(action: FilterAction)
  case setFilterSheet(isPresented: Bool)

  case cancelTapped
  case openURLTapped(url: URL)
}

public struct AppEnvironment {
  var spaceXClient: SpaceXClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var now: () -> Date
  var calendar: Calendar
  var application: UIApplication
  var launchEnvironment: LaunchEnvironment
}

extension AppEnvironment {
	public static let live = AppEnvironment(
    spaceXClient: .live,
    mainQueue: .main,
    now: Date.init,
    calendar: .current,
    application: .shared,
    launchEnvironment: .live
  )
}

public let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
  launchReducer.forEach(
    state: \AppState.launches,
    action: /AppAction.launchAction(id:action:),
    environment: { $0.launchEnvironment }
  ),
  filterReducer.pullback(
    state: \AppState.filterState,
    action: /AppAction.filterAction(action:),
    environment: { _ in FilterEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
    case .fetchCompany:
      guard case .none = state.companyFetchStatus else {
        return .none
      }

      struct FetchCompanyId: Hashable {}

      state.companyFetchStatus = .fetching
      return environment.spaceXClient
        .fetchCompanyInfo()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AppAction.companyResponse)
        .cancellable(id: FetchCompanyId())

    case .companyResponse(.failure):
      state.companyFetchStatus = .complete
      state.downloadErrorAlert = AlertState(
        title: TextState("Compnay Info failed to download"),
        primaryButton: .default(
          TextState("Retry"),
          action: .send(.companyAlertReloadTapped)
        ),
        secondaryButton: .cancel(
          TextState("Cancel"),
          action: .send(.downloadAlertCancelTapped)
        )
      )
      return .none

    case let .companyResponse(.success(response)):
      state.companyFetchStatus = .complete
      state.company = response
      return .none

    case .fetchLaunches:
      guard case .none = state.launchesFetchStatus else {
        return .none
      }

      struct FetchLaunchesId: Hashable {}

      state.launchesFetchStatus = .fetching
      return environment.spaceXClient
        .fetchLaunches()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AppAction.launchesResponse)
        .cancellable(id: FetchLaunchesId())

    case .launchesResponse(.failure):
      state.launchesFetchStatus = .complete
      state.downloadErrorAlert = AlertState(
        title: TextState("Launches failed to download"),
        primaryButton: .default(
          TextState("Retry"),
          action: .send(AppAction.launchAlertReloadTapped)
        ),
        secondaryButton: .cancel(
          TextState("Cancel"),
          action: .send(.downloadAlertCancelTapped)
        )
      )
      return .none

    case let .launchesResponse(.success(response)):
      state.launchesFetchStatus = .complete
      state.launches = response
      state.filterState.years = ["All"] + response.map { launch in
        let year = environment.calendar.component(.year, from: launch.launchDate)
        return FilterState.yearFormatter.string(from: NSNumber(value: year))!
      }
      .unique()
      return Effect(value: AppAction.compileLaunches)

    case .fetchRockets:
      guard case .none = state.rocketsFetchStatus else {
        return .none
      }

      struct FetchRocketsId: Hashable {}

      state.rocketsFetchStatus = .fetching
      return environment.spaceXClient
        .fetchRockets()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AppAction.rocketsResponse)
        .cancellable(id: FetchRocketsId())

    case .rocketsResponse(.failure):
      state.rocketsFetchStatus = .complete
      return .none

    case let .rocketsResponse(.success(response)):
      state.rocketsFetchStatus = .complete
      state.rockets = response
      return Effect(value: AppAction.compileLaunches)

    case .launchAction(id: _, action: .launchTapped(let launch)):
      state.launchActionSheet = ConfirmationDialogState(
        title: TextState("Which info would you like to see?"),
        buttons: launch.actionSheetButtons
      )
      return .none

    case .launchAction(id: _, action: .imageResponse(.success(.some))):
      return Effect(value: AppAction.compileLaunches)

    case .launchAction:
      return .none

    case .compileLaunches:
      state.compiledLaunchViewModels = state.compileLaunchViewModels(now: environment.now(), calendar: environment.calendar)
      return .none

    case let .filterAction(action: action):
      return Effect(value: AppAction.compileLaunches)

    case let .setFilterSheet(isPresented: isPresented):
      state.showFilterSheet = isPresented
      return .none

    case .cancelTapped:
      state.launchActionSheet = nil
      return .none

    case let .openURLTapped(url: url):
      state.launchActionSheet = nil
      environment.application.open(url)
      return .none

    case .launchAlertReloadTapped:
      state.downloadErrorAlert = nil
      state.launchesFetchStatus = .none
      return Effect(value: .fetchLaunches)

    case .downloadAlertCancelTapped:
      state.downloadErrorAlert = nil
      return .none

    case .companyAlertReloadTapped:
      state.downloadErrorAlert = nil
      state.companyFetchStatus = .none
      return Effect(value: .fetchCompany)
    }
  }
)
  .debugActions()
