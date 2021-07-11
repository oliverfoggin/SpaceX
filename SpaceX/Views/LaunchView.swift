//
//  LaunchView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchView: View {
    struct ViewState: Equatable {
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
        
        let missionName: String
        let dateTime: String
        let rocketInfo: String
        let days: Int
        let successful: MissionSuccess
        
        init(state: LaunchState) {
            self.missionName = state.launch.missionName
            self.dateTime = "\(Self.dateFormatter.string(from: state.launch.launchDate)) at \(Self.timeFormatter.string(from: state.launch.launchDate))"
            if let rocket = state.rocket {
                self.rocketInfo = "\(rocket.name) / \(rocket.type)"
            } else {
                self.rocketInfo = "Unknown"
            }
            self.days = 100
            self.successful = .init(success: state.launch.success)
        }
    }
    
    let store: Store<LaunchState, LaunchAction>
    @ObservedObject var viewStore: ViewStore<ViewState, LaunchAction>
    
    init(store: Store<LaunchState, LaunchAction>) {
      self.store = store
      self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "paperplane.fill")
            VStack(alignment: .leading) {
                Text("Mission:")
                Text("Date/time:")
                Text("Rocket:")
                Text("Days \(self.viewStore.days < 0 ? "since" : "from") now:")
            }
            VStack(alignment: .leading) {
                Text(self.viewStore.missionName)
                Text(self.viewStore.dateTime)
                Text(self.viewStore.rocketInfo)
                Text("\(self.viewStore.days < 0 ? "-" : "+")\(self.viewStore.days)")
            }
            switch self.viewStore.successful {
            case .success:
                Image(systemName: "checkmark")
            case .failure:
                Image(systemName: "xmark")
            case .unknown:
                Image(systemName: "questionmark")
            }
        }
        .onTapGesture {
            viewStore.send(.launchTapped)
        }
    }
}

extension LaunchView.ViewState {
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
