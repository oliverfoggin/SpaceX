//
//  Launch.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct Launch: Identifiable, Equatable {
    enum PatchImageRequest: Equatable {
        case none
        case downloading
        case complete(image: UIImage)
        case failed
    }
    
    var id: String
    var missionName: String
    var launchDate: Date
    var rocketId: String
    var patchImageURL: URL?
    var success: Bool?
    var wikipediaURL: URL?
    var youtubeId: String?
    var articleURL: URL?
    var patchImage: PatchImageRequest = .none
}

extension Launch: Decodable {
    enum RootKeys: String, CodingKey {
        case id = "id"
        case missionName = "name"
        case launchDate = "date_utc"
        case rocketId = "rocket"
        case links
        case success = "success"
    }
    
    enum LinkKeys: String, CodingKey {
        case patch, youtubeId = "youtube_id", wikipedia, article
    }
    
    enum PatchKeys: String, CodingKey {
        case small
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        let linksContainer = try rootContainer.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)
        
        let patchContainer = try linksContainer.nestedContainer(keyedBy: PatchKeys.self, forKey: .patch)
        
        self.id = try rootContainer.decode(String.self, forKey: .id)
        self.missionName = try rootContainer.decode(String.self, forKey: .missionName)
        self.launchDate = try rootContainer.decode(Date.self, forKey: .launchDate)
        self.rocketId = try rootContainer.decode(String.self, forKey: .rocketId)
        self.patchImageURL = try? patchContainer.decode(URL.self, forKey: .small)
        self.success = try? rootContainer.decode(Bool.self, forKey: .success)
        self.wikipediaURL = try? linksContainer.decode(URL.self, forKey: .wikipedia)
        self.youtubeId = try? linksContainer.decode(String.self, forKey: .youtubeId)
        self.articleURL = try? linksContainer.decode(URL.self, forKey: .article)
    }
}

enum LaunchAction: Equatable {
    case launchTapped(launch: Launch)
    case requestImage
    case imageResponse(Result<UIImage?, ImageClient.Failure>)
}

struct LaunchEnvironment {
    var imageClient: ImageClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension LaunchEnvironment {
    static let live = LaunchEnvironment(
        imageClient: .live,
        mainQueue: .main
    )
}

let launchReducer = Reducer<Launch, LaunchAction, LaunchEnvironment> {
    state, action, environment in
    switch action {
    case .launchTapped:
        return .none
    case .requestImage:
        
        guard let url = state.patchImageURL,
            case .none = state.patchImage else {
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
