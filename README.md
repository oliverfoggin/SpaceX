# SpaceX
SpaceX Launch details

## Frameworks
 - SwiftUI
 - [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

## SpaceX-API
- [SpaceX REST API](https://github.com/r-spacex/SpaceX-API)

## App Icon
 - [CoreUIBrands](https://icon-icons.com/icon/spacex-logo/144865)
 - [CC License](https://creativecommons.org/licenses/by/4.0/)

## Description
The app is built on top of TheComposableArchitecture. A compositional framework built for constructing composable apps with a redux style data store. I chose this mainly as a learning exercise for myself as I've been learning about it for a while but had yet to actually dig in and create an app using it. But also because I feel it is one of the better architectures for creating a SwiftUI app. In the past I have found it vbery easy to end up in a spaghetti code mess of observable objects etc... when trying to create anything slightly complex with SwiftUI and so always tended to stay with Swift and UIKit.

The "Root" of the app lies in `AppState.swift` and `AppView.swift`. AppState contains the company info, array of launches, and array of rockets that the app uses to display everything. It also contains the FilterState (used to show and update the FilterView) and the `compiledLaunchViewModels`.

The `compiledLaunchViewModels` is a sorted and filtered version of the launches which are then mapped onto their view models for passing to the view.

Because each launch is persistent throughout the app it also holds onto its patch image and patch image download state so that I can update the view but, more importantly, ensure I am only requesting each image once. (And also only on the first time the launch is displayed on screen).
