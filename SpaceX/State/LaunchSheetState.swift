//
//  LaunchActionState.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 12/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchSheetState: Equatable {
    
    var wikipediaURL: URL?
    var youtubeID: String?
    var aritcleURL: URL?
    
    var title: String = "Which info would you like to see?"
    
    
    init(launch: Launch) {
        self.wikipediaURL = launch.wikipediaURL
        self.youtubeID = launch.youtubeId
        self.aritcleURL = launch.articleURL
    }
}

enum LaunchSheetAction {
    case youtubeButtonTapped
    case wikiButtonTapped
    case articleButtonTapped
    case cancelButtonTapped
}

struct LaunchSheetEnvironment {}

let launchSheetReducer = Reducer<LaunchSheetState, LaunchSheetAction, LaunchSheetEnvironment> {
    state, action, environment in
    switch action {
    case .youtubeButtonTapped:
        return .none
    case .wikiButtonTapped:
        return .none
    case .articleButtonTapped:
        return .none
    case .cancelButtonTapped:
        return .none
    }
}

struct LaunchSheet: View {
    let store: Store<LaunchSheetState, LaunchSheetAction>
    
    var body: some View {
        EmptyView()
    }
}
