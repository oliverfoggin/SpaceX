//
//  FilterTests.swift
//  SpaceXTests
//
//  Created by Foggin, Oliver (Developer) on 14/07/2021.
//

import XCTest
import ComposableArchitecture

@testable import SpaceX

private let now = Date(timeIntervalSince1970: 1626215596)

class FilterTests: XCTestCase {
    let scheduler = DispatchQueue.test
    let calendar = Calendar.init(identifier: .gregorian)

    func testSortOrder() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: AppEnvironment(
                spaceXClient: .failing,
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
        
        store.send(.launchesResponse(.success([launchOne, launchTwo, launchThree]))) {
            $0.launches = [launchOne, launchTwo, launchThree]
            $0.launchesFetchStatus = .complete
            $0.filterState.years = ["All", "2021", "1970"]
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.ascending, false)))) {
            $0.filterState.ascending = false
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.ascending, true)))) {
            $0.filterState.ascending = true
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.successFilter, .successful)))) {
            $0.filterState.successFilter = .successful
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.successFilter, .unsuccessful)))) {
            $0.filterState.successFilter = .unsuccessful
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.successFilter, .all)))) {
            $0.filterState.successFilter = .all
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.year, "1970")))) {
            $0.filterState.year = "1970"
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.year, "2021")))) {
            $0.filterState.year = "2021"
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
                LaunchViewModel(launch: launchTwo, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.successFilter, .successful)))) {
            $0.filterState.successFilter = .successful
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchOne, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.year, "1970")))) {
            $0.filterState.year = "1970"
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = [
                LaunchViewModel(launch: launchThree, rocket: nil, now: now, calendar: self.calendar),
            ]
        }
        store.send(.filterAction(action: .binding(.set(\.successFilter, .unsuccessful)))) {
            $0.filterState.successFilter = .unsuccessful
        }
        store.receive(.compileLaunches) {
            $0.compiledLaunchViewModels = []
        }
    }
}

private let launchOne = Launch(
    id: "1",
    missionName: "1",
    launchDate: now,
    rocketId: "a",
    patchImageURL: nil,
    success: true,
    wikipediaURL: nil,
    youtubeId: nil,
    articleURL: nil,
    patchImage: .failed
)

private let launchTwo = Launch(
    id: "2",
    missionName: "2",
    launchDate: Date(timeInterval: 10000, since: now),
    rocketId: "b",
    patchImageURL: nil,
    success: false,
    wikipediaURL: nil,
    youtubeId: nil,
    articleURL: nil,
    patchImage: .failed
)

private let launchThree = Launch(
    id: "3",
    missionName: "3",
    launchDate: Date(timeIntervalSince1970: 0),
    rocketId: "c",
    patchImageURL: nil,
    success: true,
    wikipediaURL: nil,
    youtubeId: nil,
    articleURL: nil,
    patchImage: .failed
)
