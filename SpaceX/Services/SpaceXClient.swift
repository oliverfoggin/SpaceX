//
//  SpaceXClient.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import Foundation
import ComposableArchitecture

struct SpaceXClient {
    struct Failure: Error, Equatable {
        let message: String?
    }
    
    var fetchCompanyInfo: () -> Effect<Company, Failure>
    var fetchLaunches: () -> Effect<[Launch], Failure>
}

extension SpaceXClient {
    static let live = SpaceXClient(
        fetchCompanyInfo: {
            var url = URL(string: "https://api.spacexdata.com/v4/company")!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: Company.self, decoder: JSONDecoder())
                .mapError { e in Failure(message: e.localizedDescription) }
                .eraseToEffect()
            
        },
        fetchLaunches: {
            var url = URL(string: "https://api.spacexdata.com/v4/launches")!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in
                    data
                }
                .decode(type: [Launch].self, decoder: jsonDecoder)
                .mapError { error in Failure(message: error.localizedDescription) }
                .eraseToEffect()
        }
    )
}

extension DateFormatter {
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
