//
//  ImageClient.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 13/07/2021.
//

import UIKit
import ComposableArchitecture

struct ImageClient {
    struct Failure: Error, Equatable {
        let message: String?
    }
    
    var downloadImage: (URL) -> Effect<UIImage?, Failure>
}

extension ImageClient {
    static let live = ImageClient(
        downloadImage: { url in
            URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in UIImage(data: data) }
                .mapError { e in Failure(message: e.localizedDescription) }
                .eraseToEffect()
        }
    )
}
