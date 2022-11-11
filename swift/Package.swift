// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DropboxContentHasher",
    platforms: [
       .macOS(.v11), .iOS(.v13),
    ],

    products: [
        .executable(name: "HashFile", targets: ["HashFile"]),
        .executable(name: "TestHash", targets: ["TestHash"]),
        .library(name: "DropboxContentHasher", targets: ["DropboxContentHasher"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "HashFile",
            dependencies: ["DropboxContentHasher"]),
        .executableTarget(
            name: "TestHash",
            dependencies: [
                "DropboxContentHasher",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]),
        .target(
            name: "DropboxContentHasher"
        )
    ]
)
