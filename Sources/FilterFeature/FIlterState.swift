import ComposableArchitecture
import FoundationHelpers

public enum SuccessFilter: String, CaseIterable {
	case all = "All"
	case successful = "Success"
	case unsuccessful = "Failed"
}

public struct FilterState: Equatable {
	@BindableState public var ascending: Bool = true
	@BindableState public var successFilter: SuccessFilter = .all
	@BindableState public var years: [String] = []
	@BindableState public var year: String = "All"

	public init(
		ascending: Bool = true,
		successFilter: SuccessFilter = .all,
		years: [String] = [],
		year: String = "All"
	) {
		self.ascending = ascending
		self.successFilter = successFilter
		self.years = years
		self.year = year
	}
}

public extension FilterState {
	static let yearFormatter: NumberFormatter = {
		let nf = NumberFormatter()
		nf.numberStyle = .none
		return nf
	}()

	func sort<U, T: Comparable>(items: IdentifiedArrayOf<U>, by keypath: KeyPath<U, T>) -> [U] {
		items.sorted(by: keypath, using: ascending ? (<) : (>))
	}
}

public enum FilterAction: Equatable, BindableAction {
	case binding(BindingAction<FilterState>)
}

public struct FilterEnvironment {
	public init() {}
}

public let filterReducer = Reducer<FilterState, FilterAction, FilterEnvironment>.empty
	.binding()
