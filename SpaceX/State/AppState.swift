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
    var launches: [Launch] = []
//    var rockets: [String: Rocket] = [:]
}

enum AppAction {
    case fetchCompany
    case companyResponse(Result<Company, SpaceXClient.Failure>)
    case fetchLaunches
    case launchesResponse(Result<[Launch], SpaceXClient.Failure>)
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

let appReducer = Reducer<AppState, AppAction, AppEnvironment> {
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
    }
}
.debug()
