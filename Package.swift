// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let filename = "wg-go.xcframework.zip"
let version = "0.0.20260530"
let checksum = "1a9a0209d0d868e1bb70a7c533fb43bb91feff7d7bf70cefbc133c0a69daeecd"

let package = Package(
    name: "wg-go-apple",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "wg-go-apple",
            targets: ["wg-go"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "wg-go",
            url: "https://github.com/partout-io/wg-go-apple/releases/download/\(version)/\(filename)",
            checksum: checksum
        )

//        // local development
//        .binaryTarget(
//            name: "wg-go",
//            path: "build/wg-go.xcframework.zip"
//        )
    ]
)
