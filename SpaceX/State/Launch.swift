//
//  Launch.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct Launch: Identifiable, Equatable {
    var id: String
    var missionName: String
    var launchDate: Date
    var rocketId: String
    var patchImageURL: URL?
    var success: Bool?
    var wikipediaURL: URL?
    var youtubeId: String?
    var articleURL: URL?
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
}

struct LaunchEnvironment {}

let launchReducer = Reducer<Launch, LaunchAction, LaunchEnvironment> {
    state, action, _ in
    switch action {
    case .launchTapped:
        return .none
    }
}
