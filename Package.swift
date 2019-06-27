// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsStore",
    products: [
        .library(name: "UserDefaultsStore", targets: ["UserDefaultsStore"])
    ],
    dependencies: [],
    targets: [
        .target(name: "UserDefaultsStore", dependencies: [])
    ]
)