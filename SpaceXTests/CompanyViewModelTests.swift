//
//  CompanyViewModelTests.swift
//  SpaceXTests
//
//  Created by Foggin, Oliver (Developer) on 14/07/2021.
//

import XCTest

@testable import SpaceX

class CompanyViewModelTests: XCTestCase {

    func testCompanyViewTitleCorrect() {
        let company = Company(
            name: "Bob",
            founder: "Alice",
            founded: 1,
            employees: 2,
            launchSites: 3,
            valuation: 4
        )
        
        let viewModel = CompanyViewModel(company: company)
        
        XCTAssertEqual(
            viewModel.description,
            "Bob was founded by Alice in 1. It has now 2 employees, 3 launch sites, and is valued at USD 4"
        )
    }
}
