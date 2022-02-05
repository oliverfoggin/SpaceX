import ComposableArchitecture
import SwiftUI

public struct FilterView: View {
	let store: Store<FilterState, FilterAction>

	public init(store: Store<FilterState, FilterAction>) {
		self.store = store
	}

	public var body: some View {
		NavigationView {
			WithViewStore(self.store) { viewStore in
				Form {
					Section(header: Text("Sort by date:")) {
						Toggle("Ascending", isOn: viewStore.binding(\.$ascending))
					}

					Section(header: Text("Filter by success:")) {
						Picker(
							"",
							selection: viewStore.binding(\.$successFilter)
						) {
							ForEach(SuccessFilter.allCases, id: \.self) {
								Text($0.rawValue)
							}
						}
						.pickerStyle(SegmentedPickerStyle())
					}

					Section(header: Text("Filter by year:")) {
						Picker(
							"",
							selection: viewStore.binding(\.$year)
						) {
							ForEach(viewStore.years, id: \.self) {
								Text($0)
							}
						}
						.pickerStyle(InlinePickerStyle())
					}
				}
			}
			.navigationTitle("Sort & Filter")
		}
	}
}

struct FilterView_Previews: PreviewProvider {
	static var previews: some View {
		FilterView(
			store: Store(
				initialState: FilterState(
					ascending: true,
					successFilter: .all,
					years: ["All", "2019", "2020", "2021"],
					year: "2020"
				),
				reducer: filterReducer,
				environment: FilterEnvironment()
			)
		)
	}
}
