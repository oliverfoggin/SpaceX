import ComposableArchitecture
import SwiftUI
import Models
import Services

public enum LaunchAction: Equatable {
	case launchTapped(launch: Launch)
	case requestImage
	case imageResponse(Result<UIImage?, ImageClient.Failure>)
}

public struct LaunchEnvironment {
	var imageClient: ImageClient
	var mainQueue: AnySchedulerOf<DispatchQueue>
}

public extension LaunchEnvironment {
	static let live = LaunchEnvironment(
		imageClient: .live,
		mainQueue: .main
	)
}

public let launchReducer = Reducer<Launch, LaunchAction, LaunchEnvironment> { state, action, environment in
	switch action {
	case .launchTapped:
		return .none
	case .requestImage:

		guard let url = state.patchImageURL,
					case .none = state.patchImage
		else {
			return .none
		}

		struct DownloadImageId: Hashable {}

		state.patchImage = .downloading

		return environment.imageClient
			.downloadImage(url)
			.receive(on: environment.mainQueue)
			.catchToEffect()
			.map(LaunchAction.imageResponse)
			.cancellable(id: DownloadImageId())

	case .imageResponse(.failure):
		state.patchImage = .failed
		return .none

	case .imageResponse(.success(nil)):
		state.patchImage = .failed
		return .none

	case let .imageResponse(.success(.some(image))):
		state.patchImage = .complete(image: image)
		return .none
	}
}
