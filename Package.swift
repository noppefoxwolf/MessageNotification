// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MessageNotification",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "MessageNotification",
            targets: ["MessageNotification"]
        )
    ],
    targets: [
        .target(
            name: "MessageNotification"
        ),
        .testTarget(
            name: "MessageNotificationTests",
            dependencies: ["MessageNotification"]
        ),
        .testTarget(
            name: "NotificationCenterTests"
        ),
    ]
)
