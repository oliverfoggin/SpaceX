//
//  AppState.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import Foundation
import ComposableArchitecture

enum FetchStatus {
    case none, fetching, complete
}

struct AppState: Equatable {
    var company: Company?
    var companyFetchStatus: FetchStatus = .none
    
    var launches: IdentifiedArrayOf<Launch> = []
    var launchesFetchStatus: FetchStatus = .none
    
    var rockets: [String: Rocket] = [:]
    var rocketsFetchStatus: FetchStatus = .none
    
    var filterState: FilterState = FilterState()
    
    var compiledLaunchViewModels: IdentifiedArrayOf<LaunchViewModel> = []
}

extension AppState {
    func compileLaunchViewModels(now: Date, calendar: Calendar) -> IdentifiedArrayOf<LaunchViewModel> {
        let sortedArray = filterState.sort(items: self.launches, by: \.launchDate)
            .map { launch -> LaunchViewModel in
                LaunchViewModel(
                    launch: launch,
                    rocket: self.rockets[launch.rocketId],
                    now: now,
                    calendar: calendar
                )
            }

        return IdentifiedArray(sortedArray)
    }
}

enum AppAction {
    case fetchCompany
    case companyResponse(Result<Company, SpaceXClient.Failure>)
    
    case fetchLaunches
    case launchesResponse(Result<IdentifiedArrayOf<Launch>, SpaceXClient.Failure>)
    
    case fetchRockets
    case rocketsResponse(Result<[String: Rocket], SpaceXClient.Failure>)
    
    case launchAction(id: Launch.ID, action: LaunchAction)
    
    case compileLaunches
}

struct AppEnvironment {
    var spaceXClient: SpaceXClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var now: () -> Date
    var calendar: Calendar
}

extension AppEnvironment {
    static let live = AppEnvironment(
        spaceXClient: .live,
        mainQueue: .main,
        now: Date.init,
        calendar: .current
    )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    launchReducer.forEach(
        state: \AppState.launches,
        action: /AppAction.launchAction(id:action:),
        environment: { _ in LaunchEnvironment() }
    ),
    Reducer {
        state, action, environment in
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
            return .none
            
        case let .launchesResponse(.success(response)):
            state.launchesFetchStatus = .complete
            state.launches = response
            return Effect(value: AppAction.compileLaunches)
                .eraseToEffect()
            
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
                .eraseToEffect()
            
        case .launchAction:
            return .none
            
        case .compileLaunches:
            state.compiledLaunchViewModels = state.compileLaunchViewModels(now: environment.now(), calendar: environment.calendar)
            return .none
        }
    }
)
.debug()
