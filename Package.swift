// swift-tools-version:4.0
// Cannot current support SPM because PMKCoreLocation does not support SPM
//import PackageDescription
//
//let pkg = Package(name: "CPKCoreLocation")
//pkg.products = [
//    .library(name: "CPKCoreLocation", targets: ["CPKCoreLocation"]),
//]
//pkg.dependencies = [
//    .package(url: "https://github.com/dougzilla32/CancelForPromiseKit.git", from: "1.1.0"),
//    .package(url: "https://github.com/PromiseKit/CoreLocation.git", from: "3.0.0")
//]
//
//let cpkcl: Target = .target(name: "CPKCoreLocation")
//cpkcl.path = "Sources"
//cpkcl.dependencies = ["CancelForPromiseKit", "PMKCoreLocation"]
//
//pkg.swiftLanguageVersions = [3, 4]
//pkg.targets = [
//    cpkcl,
//    .testTarget(name: "CPKCLTests", dependencies: ["CPKCoreLocation"], path: "Tests"),
//]
