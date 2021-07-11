//
//  CompanyView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI

struct CompanyView: View {
    let company: Company
    
    var body: some View {
        Text(
            "\(company.name) was founded by \(company.founder) in \(company.yearString). It has now \(company.employees) employees, \(company.launchSites) launch sites, and is valued at USD \(company.valuation)"
        )
        .padding(8)
    }
}

struct CompanyView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyView(
            company: Company(
                name: "SpaceX",
                founder: "Elon Musk",
                founded: 3456,
                employees: 98756,
                launchSites: 567,
                valuation: 123000000
            )
        )
    }
}
