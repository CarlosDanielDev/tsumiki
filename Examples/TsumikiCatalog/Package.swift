// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TsumikiCatalog",
    platforms: [.iOS(.v17), .macOS(.v14)],
    dependencies: [
        .package(name: "Tsumiki", path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "TsumikiCatalog",
            dependencies: [
                .product(name: "TsumikiCore",       package: "Tsumiki"),
                .product(name: "TsumikiTheme",      package: "Tsumiki"),
                .product(name: "TsumikiComponents", package: "Tsumiki"),
                .product(name: "TsumikiAnimations", package: "Tsumiki"),
            ]
        )
    ]
)
