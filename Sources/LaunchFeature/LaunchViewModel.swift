import ComposableArchitecture
import SwiftUI
import Models

public struct LaunchViewModel: Identifiable, Equatable {
  public enum MissionSuccess {
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
  
  public var id: String
  var launch: Launch
  let missionName: String
  let dateTime: String
  let rocketInfo: String
  let days: Int
  let successImage: Image
  let daysTitle: String
  let patchImage: Image
  
  public init(launch: Launch, rocket: Rocket?, now: Date, calendar: Calendar) {
    id = launch.id
    self.launch = launch
    missionName = launch.missionName
    dateTime = "\(Self.dateFormatter.string(from: launch.launchDate)) at \(Self.timeFormatter.string(from: launch.launchDate))"
    if let rocket = rocket {
      rocketInfo = "\(rocket.name) / \(rocket.type)"
    } else {
      rocketInfo = "Unknown"
    }
    days = calendar.numDaysBetween(now, launch.launchDate)
    daysTitle = "Days \(days < 0 ? "since" : "from") now:"
    
    switch MissionSuccess(success: launch.success) {
    case .success:
      successImage = Image(systemName: "checkmark")
    case .failure:
      successImage = Image(systemName: "xmark")
    case .unknown:
      successImage = Image(systemName: "questionmark")
    }
    
    switch launch.patchImage {
    case .none:
      patchImage = Image(systemName: "circle.fill")
    case .downloading:
      patchImage = Image(systemName: "ellipsis.circle.fill")
    case let .complete(image: image):
      patchImage = Image(uiImage: image)
    case .failed:
      patchImage = Image(systemName: "xmark.circle.fill")
    }
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
