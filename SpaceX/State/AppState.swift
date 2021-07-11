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
    
    var sortedFilteredLaunches: IdentifiedArrayOf<LaunchViewState> {
        let sortedArray = self.launches
            .sorted(by: \Launch.launchDate)
            .map { launch -> LaunchViewState in
                LaunchViewState(
                    launch: launch,
                    rocket: self.rockets[launch.rocketId]
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
    launchReducer.forEach(
        state: \AppState.launches,
        action: /AppAction.launchAction(id:action:),
        environment: { _ in LaunchEnvironment() }
    ),
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
            state.launches = response
            return .none
            
        case .fetchRockets:
            struct FetchRocketsId: Hashable {}
            
            return environment.spaceXClient
                .fetchRockets()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.rocketsResponse)
                .cancellable(id: FetchRocketsId())
            
        case .rocketsResponse(.failure):
            return .none
            
        case let .rocketsResponse(.success(response)):
            state.rockets = response
            return .none
            
        case .launchAction:
            return .none
        }
    }
)
.debug()
