//
//  SpaceXTests.swift
//  SpaceXTests
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import XCTest
import ComposableArchitecture

@testable import SpaceX

private let now = Date(timeIntervalSince1970: 1626215596)

class SpaceXTests: XCTestCase {
    let scheduler = DispatchQueue.test
    let calendar = Calendar.init(identifier: .gregorian)

    func testDownloadData() {
        var spaceXClient = SpaceXClient.failing;
        spaceXClient.fetchCompanyInfo = { Effect(value: mockCompanyInfo) }
        spaceXClient.fetchRockets = { Effect(value: mockRockets) }
        spaceXClient.fetchLaunches = { Effect(value: mockLaunches) }
        
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: AppEnvironment(
                spaceXClient: spaceXClient,
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                now: { now },
                calendar: calendar,
                application: .shared,
                launchEnvironment: LaunchEnvironment(
                    imageClient: .failing,
                    mainQueue: self.scheduler.eraseToAnyScheduler()
                )
            )
        )
        
        store.send(.fetchCompany) {
            $0.companyFetchStatus = .fetching
        }
        self.scheduler.advance()
        store.receive(.companyResponse(.success(mockCompanyInfo))) {
            $0.companyFetchStatus = .complete
            $0.company = mockCompanyInfo
        }
        
        store.send(.fetchRockets) {
            $0.rocketsFetchStatus = .fetching
        }
        self.scheduler.advance()
        store.receive(.rocketsResponse(.success(mockRockets))) {
            $0.rocketsFetchStatus = .complete
            $0.rockets = mockRockets
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = []
        }
        
        store.send(.fetchLaunches) {
            $0.launchesFetchStatus = .fetching
        }
        self.scheduler.advance()
        store.receive(.launchesResponse(.success(mockLaunches))) {
            $0.launchesFetchStatus = .complete
            $0.launches = mockLaunches
            $0.filterState.years = ["All", "2021"]
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(
                    launch: mockLaunches[0],
                    rocket: Rocket(id: "a", name: "Dave", type: "Car"),
                    now: now,
                    calendar: self.calendar
                ),
                LaunchViewModel(
                    launch: mockLaunches[1],
                    rocket: Rocket(id: "b", name: "Alice", type: "Bicycle"),
                    now: now,
                    calendar: self.calendar
                ),
                LaunchViewModel(
                    launch: mockLaunches[2],
                    rocket: Rocket(id: "c", name: "Geoff", type: "Plane"),
                    now: now,
                    calendar: self.calendar
                ),
                LaunchViewModel(
                    launch: mockLaunches[3],
                    rocket: nil,
                    now: now,
                    calendar: self.calendar
                ),
            ]
        }
    }
}

private let mockCompanyInfo = Company(
    name: "Bob",
    founder: "Oliver",
    founded: 1,
    employees: 2,
    launchSites: 3,
    valuation: 4
)

private let mockRockets = [
    "a": Rocket(id: "a", name: "Dave", type: "Car"),
    "b": Rocket(id: "b", name: "Alice", type: "Bicycle"),
    "c": Rocket(id: "c", name: "Geoff", type: "Plane"),
]

private let mockLaunches: IdentifiedArrayOf<Launch> = [
    Launch(
        id: "1",
        missionName: "Mission 1",
        launchDate: Date(timeInterval: 20000, since: now),
        rocketId: "a"
    ),
    Launch(
        id: "2",
        missionName: "Mission 2",
        launchDate: Date(timeInterval: 40000, since: now),
        rocketId: "b"
    ),
    Launch(
        id: "3",
        missionName: "Mission 3",
        launchDate: Date(timeInterval: 60000, since: now),
        rocketId: "c"
    ),
    Launch(
        id: "4",
        missionName: "Mission 4",
        launchDate: Date(timeInterval: 80000, since: now),
        rocketId: "d"
    ),
]
