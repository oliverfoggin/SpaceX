//
//  AppState.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var company: Company?
    var launches: IdentifiedArrayOf<Launch> = []
    var rockets: [String: Rocket] = [:]
    
    var sortedFilteredLaunches: IdentifiedArrayOf<LaunchState> {
        let sortedArray = self.launches
            .map { launch -> LaunchState in
                var launchViewState = LaunchState(id: launch.id, launch: launch, rocket: nil)

                if let rocketId = launch.rocketId {
                    launchViewState.rocket = self.rockets[rocketId]
                }

                return launchViewState
            }
        
        return IdentifiedArray(sortedArray)
    }
}

enum AppAction {
    case fetchCompany
    case companyResponse(Result<Company, SpaceXClient.Failure>)
    case fetchLaunches
    case launchesResponse(Result<[Launch], SpaceXClient.Failure>)
    case launchAction(id: LaunchState.ID, action: LaunchAction)
}

struct AppEnvironment {
    var spaceXClient: SpaceXClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension AppEnvironment {
    static let live = AppEnvironment(
        spaceXClient: .live,
        mainQueue: .main
    )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
//    launchStateReducer.forEach(
//        state: \AppState.sortedFilteredLaunches,
//        action: /AppAction.launchAction(id:action:),
//        environment: { _ in LaunchEnvironment() }
//    ),
    Reducer {
        state, action, environment in
        switch action {
        case .fetchCompany:
            struct FetchCompanyId: Hashable {}
            
            return environment.spaceXClient
                .fetchCompanyInfo()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.companyResponse)
                .cancellable(id: FetchCompanyId())
                
        case .companyResponse(.failure):
            return .none
            
        case let .companyResponse(.success(response)):
            state.company = response
            return .none
            
        case .fetchLaunches:
            struct FetchLaunchesId: Hashable {}
            
            return environment.spaceXClient
                .fetchLaunches()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.launchesResponse)
                .cancellable(id: FetchLaunchesId())
            
        case .launchesResponse(.failure):
            return .none
            
        case let .launchesResponse(.success(response)):
            state.launches = IdentifiedArray(response)
            return .none
            
        case .launchAction:
            return .none
        }
    }
)
.debug()
