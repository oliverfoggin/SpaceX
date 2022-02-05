import ComposableArchitecture
import Foundation
import FoundationHelpers
import Models

public struct SpaceXClient {
  public struct Failure: Error, Equatable {
    let message: String?
  }
  
  public var fetchCompanyInfo: () -> Effect<Company, Failure>
  public var fetchLaunches: () -> Effect<IdentifiedArrayOf<Launch>, Failure>
  public var fetchRockets: () -> Effect<[String: Rocket], Failure>
}

extension SpaceXClient {
  public static let live = SpaceXClient(
    fetchCompanyInfo: {
      var url = URL(string: "https://api.spacexdata.com/v4/company")!
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: Company.self, decoder: JSONDecoder())
        .mapError { e in Failure(message: e.localizedDescription) }
        .eraseToEffect()
      
    },
    fetchLaunches: {
      var url = URL(string: "https://api.spacexdata.com/v4/launches")!
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [Launch].self, decoder: jsonDecoder)
        .map(IdentifiedArray.init(uniqueElements:))
        .mapError { error in Failure(message: error.localizedDescription) }
        .eraseToEffect()
    },
    fetchRockets: {
      var url = URL(string: "https://api.spacexdata.com/v4/rockets")!
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [Rocket].self, decoder: jsonDecoder)
        .map { $0.keyedDictionary() }
        .mapError { error in Failure(message: error.localizedDescription) }
        .eraseToEffect()
    }
  )
}

extension SpaceXClient {
  static let failing = SpaceXClient(
    fetchCompanyInfo: { .failing("SpaceXClient.fetchCompanyInfo") },
    fetchLaunches: { .failing("SpaceXClient.fetchLaunches") },
    fetchRockets: { .failing("SpaceXClient.fetchRockets") }
  )
}

// MARK: - Private helpers

private extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

private let jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
  d.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
  return d
}()
