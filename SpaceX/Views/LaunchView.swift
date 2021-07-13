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
    let successImage: Image
    let daysTitle: String
    let patchImage: Image
    
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
        self.daysTitle = "Days \(self.days < 0 ? "since" : "from") now:"
        
        switch MissionSuccess.init(success: launch.success) {
        case .success:
            self.successImage = Image(systemName: "checkmark")
        case .failure:
            self.successImage = Image(systemName: "xmark")
        case .unknown:
            self.successImage = Image(systemName: "questionmark")
        }
        
        switch launch.patchImage {
        case .none:
            self.patchImage = Image(systemName: "circle.fill")
        case .downloading:
            self.patchImage = Image(systemName: "ellipsis.circle.fill")
        case .complete(image: let image):
            self.patchImage = Image(uiImage: image)
        case .failed:
            self.patchImage = Image(systemName: "xmark.circle.fill")
        }
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
                viewStore.patchImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                VStack(alignment: .leading) {
                    Text("Mission:")
                    Text("Date/time:")
                    Text("Rocket:")
                    Text(viewStore.daysTitle)
                }
                VStack(alignment: .leading) {
                    Text(viewStore.missionName)
                    Text(viewStore.dateTime)
                    Text(viewStore.rocketInfo)
                    Text("\(viewStore.days)")
                }
                Spacer()
                viewStore.successImage
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                viewStore.send(.launchTapped(launch: viewStore.launch))
            }
            .onAppear {
                if case .none = viewStore.launch.patchImage {
                    viewStore.send(.requestImage)
                }
            }
        }
    }
}
