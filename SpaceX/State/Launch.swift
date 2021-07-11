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
    var rocketId: String?
    var patchImageURL: URL?
    var success: Bool?
    var wikipediaURL: URL?
    var youtubeId: String?
}

struct LaunchState: Identifiable, Equatable {
    enum MissionSuccess {
        case success, failure, unknown
        
        init(success: Bool?) {
            switch success {
            case .none:
                self = .unknown
            case .some(true):
                self = .success
            case .some(false):
                self = .failure
            }
        }
    }
    
    var id: String { self.launch.id }
    var launch: Launch
    var rocket: Rocket?
    
    let missionName: String
    let dateTime: String
    let rocketInfo: String
    let days: Int
    let successful: MissionSuccess
    
    init(launch: Launch, rocket: Rocket?) {
        self.launch = launch
        self.rocket = rocket
        self.missionName = launch.missionName
        self.dateTime = "\(Self.dateFormatter.string(from: launch.launchDate)) at \(Self.timeFormatter.string(from: launch.launchDate))"
        if let rocket = rocket {
            self.rocketInfo = "\(rocket.name) / \(rocket.type)"
        } else {
            self.rocketInfo = "Unknown"
        }
        self.days = 100
        self.successful = .init(success: launch.success)
    }
}

extension LaunchState {
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
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
        case patch, youtubeId = "youtube_id", wikipedia
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
        self.rocketId = try? rootContainer.decode(String.self, forKey: .rocketId)
        self.patchImageURL = try? patchContainer.decode(URL.self, forKey: .small)
        self.success = try? rootContainer.decode(Bool.self, forKey: .success)
        self.wikipediaURL = try? linksContainer.decode(URL.self, forKey: .wikipedia)
        self.youtubeId = try? linksContainer.decode(String.self, forKey: .youtubeId)
    }
}

enum LaunchAction {
    case launchTapped
}

struct LaunchEnvironment {}

let launchReducer = Reducer<Launch, LaunchAction, LaunchEnvironment> {
    state, action, _ in
    switch action {
    case .launchTapped:
        return .none
    }
}
