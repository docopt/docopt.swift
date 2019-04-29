// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Docopt",
    products: [
      .library(name: "Docopt", targets: ["Docopt"])
    ],
    targets: [
        .target(
            name: "Docopt",
            path: "Sources"
        ),
         .testTarget(
             name: "DocoptTests",
             dependencies: ["Docopt"],
             path: "DocoptTests"
         )
    ]
)
