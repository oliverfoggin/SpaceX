import SwiftUI
import ComposableArchitecture

struct LoadingView: View {
	let store: Store<AppState, AppAction>

	var body: some View {
		WithViewStore(self.store) { viewStore in
			ProgressView()
				.progressViewStyle(CircularProgressViewStyle())
				.onAppear {
					viewStore.send(.fetchCompany)
					viewStore.send(.fetchRockets)
				}
		}
	}
}
