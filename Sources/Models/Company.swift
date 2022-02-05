import Foundation

public struct Company: Equatable, Decodable {
	public var name: String
	public var founder: String
	public var founded: Int
	public var employees: Int
	public var launchSites: Int
	public var valuation: Int

	public init(name: String, founder: String, founded: Int, employees: Int, launchSites: Int, valuation: Int) {
		self.name = name
		self.founder = founder
		self.founded = founded
		self.employees = employees
		self.launchSites = launchSites
		self.valuation = valuation
	}
}

public extension Company {
	static let yearFormatter: NumberFormatter = {
		let nf = NumberFormatter()
		nf.numberStyle = .none
		return nf
	}()

	var yearString: String {
		Company.yearFormatter.string(from: NSNumber(value: founded))!
	}

	enum CodingKeys: String, CodingKey {
		case name
		case founder
		case founded
		case employees
		case launchSites = "launch_sites"
		case valuation
	}
}
