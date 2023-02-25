// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepFoodForm",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepFoodForm",
            targets: ["PrepFoodForm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/EmojiPicker", from: "0.0.22"),
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.59"),
//        .package(url: "https://github.com/pxlshpr/FoodLabelCamera", from: "0.0.43"),
        .package(url: "https://github.com/pxlshpr/FoodLabelExtractor", from: "0.0.32"),
        .package(url: "https://github.com/pxlshpr/FoodLabelScanner", from: "0.0.150"),
        .package(url: "https://github.com/pxlshpr/MFPScraper", from: "0.0.62"),
//        .package(url: "https://github.com/pxlshpr/MFPSearch", from: "0.0.15"),
        .package(url: "https://github.com/pxlshpr/NamePicker", from: "0.0.20"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.278"),
        .package(url: "https://github.com/pxlshpr/PrepNetworkController", from: "0.0.22"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.147"),
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.3"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.87"),
        .package(url: "https://github.com/pxlshpr/SwiftUICamera", from: "0.0.41"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.369"),
//        .package(url: "https://github.com/pxlshpr/ZoomableScrollView", from: "0.0.67"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.78"),

        .package(url: "https://github.com/exyte/ActivityIndicatorView", from: "1.1.0"),
        .package(url: "https://github.com/yeahdongcn/RSBarcodes_Swift", from: "5.1.1"),
        .package(url: "https://github.com/fermoya/SwiftUIPager", from: "2.5.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepFoodForm",
            dependencies: [
                .product(name: "EmojiPicker", package: "emojipicker"),
                .product(name: "FoodLabel", package: "foodlabel"),
//                .product(name: "FoodLabelCamera", package: "foodlabelcamera"),
                .product(name: "FoodLabelExtractor", package: "foodlabelextractor"),
                .product(name: "FoodLabelScanner", package: "foodlabelscanner"),
                .product(name: "MFPScraper", package: "mfpscraper"),
//                .product(name: "MFPSearch", package: "mfpsearch"),
                .product(name: "NamePicker", package: "namepicker"),
                .product(name: "Camera", package: "swiftuicamera"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "PrepNetworkController", package: "prepnetworkcontroller"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftHaptics", package: "swifthaptics"),
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "VisionSugar", package: "visionsugar"),
//                .product(name: "ZoomableScrollView", package: "zoomablescrollview"),

                .product(name: "ActivityIndicatorView", package: "activityindicatorview"),
                .product(name: "RSBarcodes_Swift", package: "rsbarcodes_swift"),
                .product(name: "SwiftUIPager", package: "swiftuipager"),
                .product(name: "Shimmer", package: "swiftui-shimmer"),
            ]),
        .testTarget(
            name: "PrepFoodFormTests",
            dependencies: ["PrepFoodForm"]),
    ]
)
