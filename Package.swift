// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "SpaceX",
	platforms: [.iOS(.v15)],
	products: [
		.library(name: "AppFeature", targets: ["AppFeature"]),
		.library(name: "CompanyFeature", targets: ["CompanyFeature"]),
		.library(name: "FilterFeature", targets: ["FilterFeature"]),
		.library(name: "FoundationHelpers", targets: ["FoundationHelpers"]),
		.library(name: "LaunchFeature", targets: ["LaunchFeature"]),
		.library(name: "Models", targets: ["Models"]),
		.library(name: "ReusableViews", targets: ["ReusableViews"]),
		.library(name: "Services", targets: ["Services"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.1"),
	],
	targets: [
		.target(
			name: "AppFeature",
			dependencies: [
				.byName(name: "CompanyFeature", condition: nil),
				.byName(name: "FilterFeature", condition: nil),
				.byName(name: "FoundationHelpers", condition: nil),
				.byName(name: "LaunchFeature", condition: nil),
				.byName(name: "Models", condition: nil),
				.byName(name: "Services", condition: nil),
				.productItem(name: "ComposableArchitecture", package: "swift-composable-architecture", condition: nil),
			]
		),
		.target(
			name: "CompanyFeature",
			dependencies: [
				.byName(name: "Models", condition: nil),
				.byName(name: "ReusableViews", condition: nil),
			]
		),
		.target(
			name: "FilterFeature",
			dependencies: [
				.byName(name: "FoundationHelpers", condition: nil),
				.productItem(name: "ComposableArchitecture", package: "swift-composable-architecture", condition: nil),
			]
		),
		.target(
			name: "LaunchFeature",
			dependencies: [
				.byName(name: "Models", condition: nil),
				.byName(name: "Services", condition: nil),
				.productItem(name: "ComposableArchitecture", package: "swift-composable-architecture", condition: nil),
			]
		),
		.target(name: "FoundationHelpers"),
		.target(name: "Models"),
		.target(name: "ReusableViews"),
		.target(
			name: "Services",
			dependencies: [
				.byName(name: "Models", condition: nil),
				.byName(name: "FoundationHelpers", condition: nil),
				.productItem(name: "ComposableArchitecture", package: "swift-composable-architecture", condition: nil),
			]
		),
	]
)
