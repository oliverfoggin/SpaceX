import ComposableArchitecture
import UIKit

public struct ImageClient {
  public struct Failure: Error, Equatable {
    let message: String?
  }

  public var downloadImage: (URL) -> Effect<UIImage?, Failure>
}

extension ImageClient {
  public static let live = ImageClient(
    downloadImage: { url in
      URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .map(UIImage.init(data:))
        .mapError { Failure(message: $0.localizedDescription) }
        .eraseToEffect()
    }
  )
}

public extension ImageClient {
  static let failing = ImageClient(
    downloadImage: { _ in .failing("ImageClient.downloadImage") }
  )
}
