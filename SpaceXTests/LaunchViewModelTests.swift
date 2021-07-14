//
//  LaunchViewModelTests.swift
//  SpaceXTests
//
//  Created by Foggin, Oliver (Developer) on 14/07/2021.
//

import XCTest
import SwiftUI

@testable import SpaceX

class LaunchViewModelTests: XCTestCase {

    let now = Date(timeIntervalSince1970: 0)
    let calendar = Calendar(identifier: .gregorian)
    
    func testLaunchViewModelCorrect() {
        let dateCOmponents = DateComponents(day: 2)
        let launchDate = calendar.date(byAdding: dateCOmponents, to: now)!
        
        let launch = Launch(
            id: "1",
            missionName: "Mission 1",
            launchDate: launchDate,
            rocketId: "1"
        )
        
        let launchViewModel = LaunchViewModel(
            launch: launch,
            rocket: nil,
            now: now,
            calendar: calendar
        )
        
        XCTAssertEqual(launchViewModel.days, 2)
        XCTAssertEqual(launchViewModel.daysTitle, "Days from now:")
        XCTAssertEqual(launchViewModel.id, "1")
        XCTAssertEqual(launchViewModel.rocketInfo, "Unknown")
        XCTAssertEqual(launchViewModel.successImage, Image(systemName: "questionmark"))
        XCTAssertEqual(launchViewModel.patchImage, Image(systemName: "circle.fill"))
    }
    
    func testLaunchViewModelCorrect2() {
        let dateCOmponents = DateComponents(day: -2)
        let launchDate = calendar.date(byAdding: dateCOmponents, to: now)!
        
        let launch = Launch(
            id: "2",
            missionName: "Mission 2",
            launchDate: launchDate,
            rocketId: "a",
            patchImageURL: nil,
            success: false,
            wikipediaURL: nil,
            youtubeId: nil,
            articleURL: nil,
            patchImage: .downloading
        )
        
        let rocket = Rocket(
            id: "a",
            name: "BFR",
            type: "Big Falcon Rocket"
        )
        
        let launchViewModel = LaunchViewModel(
            launch: launch,
            rocket: rocket,
            now: now,
            calendar: calendar
        )
        
        XCTAssertEqual(launchViewModel.days, -2)
        XCTAssertEqual(launchViewModel.daysTitle, "Days since now:")
        XCTAssertEqual(launchViewModel.id, "2")
        XCTAssertEqual(launchViewModel.rocketInfo, "BFR / Big Falcon Rocket")
        XCTAssertEqual(launchViewModel.successImage, Image(systemName: "xmark"))
        XCTAssertEqual(launchViewModel.patchImage, Image(systemName: "ellipsis.circle.fill"))
    }
    
    func testLaunchViewModelCorrect3() {
        let dateCOmponents = DateComponents(day: -2)
        let launchDate = calendar.date(byAdding: dateCOmponents, to: now)!
        let image = UIImage()
        
        let launch = Launch(
            id: "3",
            missionName: "Mission 3",
            launchDate: launchDate,
            rocketId: "a",
            patchImageURL: nil,
            success: true,
            wikipediaURL: nil,
            youtubeId: nil,
            articleURL: nil,
            patchImage: .complete(image: image)
        )
        
        let rocket = Rocket(
            id: "a",
            name: "BFR",
            type: "Big Falcon Rocket"
        )
        
        let launchViewModel = LaunchViewModel(
            launch: launch,
            rocket: rocket,
            now: now,
            calendar: calendar
        )
        
        XCTAssertEqual(launchViewModel.days, -2)
        XCTAssertEqual(launchViewModel.daysTitle, "Days since now:")
        XCTAssertEqual(launchViewModel.id, "3")
        XCTAssertEqual(launchViewModel.rocketInfo, "BFR / Big Falcon Rocket")
        XCTAssertEqual(launchViewModel.successImage, Image(systemName: "checkmark"))
        XCTAssertEqual(launchViewModel.patchImage, Image(uiImage: image))
    }
}
