// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tsumiki",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TsumikiCore",       targets: ["TsumikiCore"]),
        .library(name: "TsumikiTheme",      targets: ["TsumikiTheme"]),
        .library(name: "TsumikiComponents", targets: ["TsumikiComponents"]),
        .library(name: "TsumikiAnimations", targets: ["TsumikiAnimations"]),
        .library(name: "TsumikiServices",   targets: ["TsumikiServices"]),
    ],
    targets: [
        .target(name: "TsumikiCore"),
        .target(name: "TsumikiTheme",      dependencies: ["TsumikiCore"]),
        .target(name: "TsumikiComponents", dependencies: ["TsumikiCore", "TsumikiTheme"]),
        .target(name: "TsumikiAnimations", dependencies: ["TsumikiCore", "TsumikiTheme"]),
        .target(name: "TsumikiServices",   dependencies: ["TsumikiCore"]),
        .testTarget(name: "TsumikiCoreTests",       dependencies: ["TsumikiCore"]),
        .testTarget(name: "TsumikiThemeTests",      dependencies: ["TsumikiTheme"]),
        .testTarget(name: "TsumikiComponentsTests", dependencies: ["TsumikiComponents"]),
        .testTarget(name: "TsumikiAnimationsTests", dependencies: ["TsumikiAnimations"]),
        .testTarget(name: "TsumikiServicesTests",   dependencies: ["TsumikiServices"]),
    ]
)
