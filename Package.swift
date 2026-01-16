// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let AsyncAlgorithms_v1_0 = "AvailabilityMacro=AsyncAlgorithms 1.0:macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0"
#if compiler(>=6.0) && swift(>=6.0)  // 5.10 doesnt support visionOS availability
let AsyncAlgorithms_v1_1 =
  "AvailabilityMacro=AsyncAlgorithms 1.1:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"
let AsyncAlgorithms_v1_2 =
  "AvailabilityMacro=AsyncAlgorithms 1.2:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"
#else
let AsyncAlgorithms_v1_1 = "AvailabilityMacro=AsyncAlgorithms 1.1:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0"
let AsyncAlgorithms_v1_2 = "AvailabilityMacro=AsyncAlgorithms 1.2:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0"
#endif

let availabilityMacros: [SwiftSetting] = [
  .enableExperimentalFeature(
    AsyncAlgorithms_v1_0
  ),
  .enableExperimentalFeature(
    AsyncAlgorithms_v1_1
  ),
  .enableExperimentalFeature(
    AsyncAlgorithms_v1_2
  ),
]

let package = Package(
  name: "swift-async-algorithms",
  platforms: [.iOS(.v13), .macOS(.v10_15)],
  products: [
    .library(name: "AsyncAlgorithms", targets: ["AsyncAlgorithms"])
  ],
  dependencies: [
    .package(url: "https://github.com/swhitty/swift-mutex/", .upToNextMajor(from: "0.0.6")),
  ],
  targets: [
    .target(
      name: "AsyncAlgorithms",
      dependencies: [
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "DequeModule", package: "swift-collections"),
        .product(name: "Mutex", package: "swift-mutex"),
      ],
      swiftSettings: availabilityMacros + [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .target(
      name: "AsyncSequenceValidation",
      dependencies: [
        "_CAsyncSequenceValidationSupport", "AsyncAlgorithms",
        .product(name: "Mutex", package: "swift-mutex"),
      ],
      swiftSettings: availabilityMacros + [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .systemLibrary(name: "_CAsyncSequenceValidationSupport"),
    .target(
      name: "AsyncAlgorithms_XCTest",
      dependencies: ["AsyncAlgorithms", "AsyncSequenceValidation"],
      swiftSettings: availabilityMacros + [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(
      name: "AsyncAlgorithmsTests",
      dependencies: [
        .target(name: "AsyncAlgorithms"),
        .target(
          name: "AsyncSequenceValidation",
          condition: .when(platforms: [
            .macOS,
            .iOS,
            .tvOS,
            .watchOS,
            .visionOS,
            .macCatalyst,
            .android,
            .linux,
            .openbsd,
            .wasi,
          ])
        ),
        .target(
          name: "AsyncAlgorithms_XCTest",
          condition: .when(platforms: [
            .macOS,
            .iOS,
            .tvOS,
            .watchOS,
            .visionOS,
            .macCatalyst,
            .android,
            .linux,
            .openbsd,
            .wasi,
          ])
        ),
      ],
      swiftSettings: availabilityMacros + [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
  ]
)

if Context.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0")
  ]
} else {
  package.dependencies += [
    .package(path: "../swift-collections")
  ]
}
