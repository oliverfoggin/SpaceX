//
//  LaunchView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 10/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct LaunchViewModel: Identifiable, Equatable {
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
    
    var id: String
    var launch: Launch
    let missionName: String
    let dateTime: String
    let rocketInfo: String
    let days: Int
    let successful: MissionSuccess
    
    init(launch: Launch, rocket: Rocket?, now: Date, calendar: Calendar) {
        self.id = launch.id
        self.launch = launch
        self.missionName = launch.missionName
        self.dateTime = "\(Self.dateFormatter.string(from: launch.launchDate)) at \(Self.timeFormatter.string(from: launch.launchDate))"
        if let rocket = rocket {
            self.rocketInfo = "\(rocket.name) / \(rocket.type)"
        } else {
            self.rocketInfo = "Unknown"
        }
        self.days = calendar.numDaysBetween(now, launch.launchDate)
        self.successful = .init(success: launch.success)
    }
}

extension Calendar {
    func numDaysBetween(_ date1: Date, _ date2: Date) -> Int {
        let fromDate = startOfDay(for: date1)
        let toDate = startOfDay(for: date2)
        
        let numberDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberDays.day ?? 0
    }
}

extension LaunchViewModel {
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

struct LaunchView: View {
    let store: Store<LaunchViewModel, LaunchAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "paperplane.fill")
                VStack(alignment: .leading) {
                    Text("Mission:")
                    Text("Date/time:")
                    Text("Rocket:")
                    Text("Days \(viewStore.days < 0 ? "since" : "from") now:")
                }
                VStack(alignment: .leading) {
                    Text(viewStore.missionName)
                    Text(viewStore.dateTime)
                    Text(viewStore.rocketInfo)
                    Text("\(viewStore.days)")
                }
                Spacer()
                switch viewStore.successful {
                case .success:
                    Image(systemName: "checkmark")
                case .failure:
                    Image(systemName: "xmark")
                case .unknown:
                    Image(systemName: "questionmark")
                }
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                viewStore.send(.launchTapped(launch: viewStore.launch))
            }
        }
    }
}
