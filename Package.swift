// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftyRA",
    products: [
        .library(
            name: "SwiftyRA",
            targets: ["SwiftyRA"]
        ),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftyRA",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftyRATests",
            dependencies: ["SwiftyRA"]
        ),
    ]
)
