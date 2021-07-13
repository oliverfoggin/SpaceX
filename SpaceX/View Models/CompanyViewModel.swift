//
//  CompanyViewModel.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 13/07/2021.
//

import Foundation

struct CompanyViewModel {
    let description: String
    
    init(company: Company) {
        self.description = "\(company.name) was founded by \(company.founder) in \(company.yearString). It has now \(company.employees) employees, \(company.launchSites) launch sites, and is valued at USD \(company.valuation)"
    }
}
