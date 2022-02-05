import ComposableArchitecture
import SwiftUI
import AppFeature

@main
struct SpaceXApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: .init(),
          reducer: appReducer,
          environment: .live
        )
      )
    }
  }
}
