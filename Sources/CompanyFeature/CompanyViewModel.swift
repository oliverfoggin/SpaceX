import Models

public struct CompanyViewModel {
    let description: String

    public init(company: Company) {
        description = """
\(company.name) was founded by \(company.founder) in \
\(company.yearString). It has now \(company.employees) employees, \
\(company.launchSites) launch sites, and is valued at USD \(company.valuation)
"""
    }
}
