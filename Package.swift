// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Tape",
    platforms: [.macOS(.v13)],
    targets: [
        // Resources are copied into Tape.app by scripts/build-app.sh and
        // loaded with Bundle.main, so none are declared here.
        .executableTarget(
            name: "Tape",
            path: "Sources/Tape"
        )
    ]
)
