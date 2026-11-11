// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-whatwg-dom",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "WHATWG DOM", targets: ["WHATWG DOM"]),
        .library(name: "WHATWG DOM Test Support", targets: ["WHATWG DOM Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-whatwg/swift-whatwg.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "WHATWG DOM",
            dependencies: [
                .product(name: "WHATWG", package: "swift-whatwg"),
                .product(name: "Byte", package: "swift-byte"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        ),
        .target(
            name: "WHATWG DOM Test Support",
            dependencies: [
                .target(name: "WHATWG DOM")
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "WHATWG DOM Tests",
            dependencies: [
                .target(name: "WHATWG DOM"),
                .target(name: "WHATWG DOM Test Support"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
