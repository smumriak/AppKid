import Foundation

let fileManager = FileManager.default

extension URL {
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        return pathComponents.reduce(self) { url, pathComponent in
            return url.appendingPathComponent(pathComponent)
        }
    }

    init(fileURLWithPathComponents pathComponents: [String], isDirectory: Bool = false, relativeTo: URL? = nil) {
        if pathComponents.isEmpty {
            self = URL(fileURLWithPath: "")
        } else {
            self = pathComponents[1..<pathComponents.count].reduce(URL(fileURLWithPath: pathComponents[0], relativeTo: relativeTo)) { url, pathComponent in
                return url.appendingPathComponent(pathComponent)
            }
        }
    }
}

enum Version: CustomStringConvertible {
    case literal(String)
    case numeric(major: Int, minor: Int, patch: Int)

    var description: String {
        switch self {
            case .literal(let value): return value
            case .numeric(let major, let minor, let patch): return "\(major).\(minor).\(patch)"
        }
    }
}

enum Architecture: String {
    case aarch64 = "aarch64"
    case x86_64 = "x86_64"
}

protocol DebianPackage {
    var name: String { get }
    var fileExtension: String { get }
    var symlinksExtensions: [String] { get }
    var version: Version { get }
    var originURL: URL { get }
    var architecture: String { get }
    var binaryInstallationPathComponents: [String] { get }
    var bundleInstallationPathComponents: [String] { get }
    var desktopFilePathComponents: [String] { get }
}

extension DebianPackage {
    var bundleName: String {
        return "\(name)_\(name).resources"
    }

    var controlFileString: String {
        return """
        Package: \(name)
        Version: 1.0
        Architecture: amd64
        Essential: no
        Priority: optional
        Depends: 
        Maintainer: Serhii Mumriak
        Description: \(name)

        """
    }
}

class DebianPackageURLs {
    let package: DebianPackage
    let rootURL: URL

    init(package: DebianPackage, rootURL: URL) {
        self.package = package
        self.rootURL = rootURL
    }

    private(set) lazy var basePackageURL = rootURL.appendingPathComponent("\(package.name)_\(package.version)_\(package.architecture)", isDirectory: true)

    private(set) lazy var binaryDestinationDirectoryURL = URL(fileURLWithPathComponents: package.binaryInstallationPathComponents, relativeTo: basePackageURL)
    private(set) lazy var binaryDestinationURL = binaryDestinationDirectoryURL
        .appendingPathComponent(package.name, isDirectory: false)
        .appendingPathExtension(package.fileExtension)

    private(set) lazy var binaryOriginURL = package.originURL.appendingPathComponent(package.name, isDirectory: false).appendingPathExtension(package.fileExtension)
    private(set) lazy var bundleOriginURL = package.originURL.appendingPathComponent(package.bundleName, isDirectory: true)
    private(set) lazy var bundleDestinationDirectoryURL = URL(fileURLWithPathComponents: package.bundleInstallationPathComponents, isDirectory: true, relativeTo: basePackageURL)
    private(set) lazy var bundleDestinationURL = bundleDestinationDirectoryURL.appendingPathComponent(package.bundleName, isDirectory: true)
    private(set) lazy var debianDirectoryURL = URL(fileURLWithPathComponents: ["DEBIAN"], isDirectory: true, relativeTo: basePackageURL)
    private(set) lazy var debianControlFileURL = debianDirectoryURL.appendingPathComponent("control")
    private(set) lazy var symlinkURLs: [URL] = package.symlinksExtensions.map { fileExtension in
        return binaryDestinationDirectoryURL
            .appendingPathComponent(package.name, isDirectory: false)
            .appendingPathExtension(fileExtension)
    }

    private(set) lazy var desktopFileURL: URL? = {
        if package.desktopFilePathComponents.isEmpty {
            return nil
        }

        return URL(fileURLWithPathComponents: package.desktopFilePathComponents, relativeTo: basePackageURL)
            .appendingPathComponent("\(package.name).desktop")
    }()

    var desktopFileString: String {
        return """
        [Desktop Entry]
        Name=\(package.name)
        Comment=\(package.name) application that is built using AppKid
        Icon=/\(bundleDestinationURL.appendingPathComponent("AppIcon.png").relativePath)
        Terminal=false
        Type=Application
        Categories=System
        Exec=/\(binaryDestinationURL.relativePath)

        """
    }
}

struct Library: DebianPackage {
    let name: String
    var fileExtension: String = "so"
    var symlinksExtensions: [String] = []
    let version: Version
    let originURL: URL
    let architecture: String = "x86_64"
    var binaryInstallationPathComponents: [String] {
        return ["usr", "lib", "\(architecture)"]
    }

    let bundleInstallationPathComponents: [String] = ["usr", "share"]
    let desktopFilePathComponents: [String] = []
}

struct Application: DebianPackage {
    let name: String
    let fileExtension: String = ""
    let symlinksExtensions: [String] = []
    let version: Version
    let originURL: URL
    let architecture: String = "x86_64"
    let binaryInstallationPathComponents: [String] = ["usr", "bin"]
    let bundleInstallationPathComponents: [String] = ["usr", "share"]
    let desktopFilePathComponents: [String] = ["usr", "share", "applications"]
}

let swiftRuntimeURL = URL(fileURLWithPath: "/opt/swift/usr/lib/swift/linux/", isDirectory: true)
let swiftRuntimeVersion = Version.numeric(major: 5, minor: 5, patch: 0)
let appKidLibsURL = URL(fileURLWithPath: "build/AppKidDemo/release/", isDirectory: true)
let appKidLibsVersion = Version.numeric(major: 0, minor: 0, patch: 1)

let swiftRuntime = [
    "libBlocksRuntime",
    "libdispatch",
    "libFoundationNetworking",
    "libFoundation",
    "libFoundationXML",
    "libswiftCore",
    "libswiftDispatch",
    "libswiftGlibc",
    "libswiftRemoteMirror",
    "libswiftSwiftOnoneSupport",
].map {
    return Library(name: $0, version: swiftRuntimeVersion, originURL: swiftRuntimeURL)
}

let swiftICULibs: [Library] = [
    "libicudataswift",
    "libicui18nswift",
    "libicuucswift",
].map {
    var result = Library(name: $0, version: swiftRuntimeVersion, originURL: swiftRuntimeURL)
    result.fileExtension = "so.65.1"
    result.symlinksExtensions = ["so", "so.65"]
    return result
}

let appKidLibs = [
    "libAppKid",
    "libCairoGraphics",
    "libContentAnimation",
    "libTinyFoundation",
    "libVolcano",
].map {
    return Library(name: $0, version: appKidLibsVersion, originURL: appKidLibsURL)
}

let AppKidDemoApp = Application(name: "AppKidDemo", version: appKidLibsVersion, originURL: appKidLibsURL)

let packages: [DebianPackage] = swiftRuntime + appKidLibs + swiftICULibs + [AppKidDemoApp]

let currentDirectoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)

extension DebianPackage {
    func serializeDeb(rootURL: URL) throws {
        let packageURLs = DebianPackageURLs(package: self, rootURL: rootURL)

        debugPrint(packageURLs.binaryDestinationURL)

        try fileManager.createDirectory(at: packageURLs.basePackageURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        try fileManager.createDirectory(at: packageURLs.binaryDestinationDirectoryURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])

        try fileManager.copyItem(at: packageURLs.binaryOriginURL, to: packageURLs.binaryDestinationURL)

        try packageURLs.symlinkURLs.forEach { symlinkURL in
            try fileManager.createSymbolicLink(atPath: symlinkURL.path, withDestinationPath: packageURLs.binaryDestinationURL.lastPathComponent)
        }

        if fileManager.fileExists(atPath: packageURLs.bundleOriginURL.path) {
            try fileManager.createDirectory(at: packageURLs.bundleDestinationDirectoryURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
            try fileManager.copyItem(at: packageURLs.bundleOriginURL, to: packageURLs.bundleDestinationURL)
        }

        try fileManager.createDirectory(at: packageURLs.debianDirectoryURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        try controlFileString.write(to: packageURLs.debianControlFileURL, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: packageURLs.debianControlFileURL.path)

        if let desktopFileURL = packageURLs.desktopFileURL {
            let desktopFileDirectoryURL = desktopFileURL.deletingLastPathComponent()
            
            try fileManager.createDirectory(at: desktopFileDirectoryURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
            try packageURLs.desktopFileString.write(to: desktopFileURL, atomically: true, encoding: .utf8)
            try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: desktopFileURL.path)
        }
    }
}

do {
    try packages.forEach { package in
        try package.serializeDeb(rootURL: currentDirectoryURL)
    }
} catch {
    debugPrint(error)
}
