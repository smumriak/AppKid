//
//  VolcanoPlatform.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public enum VolcanoPlatform: String {
    case linux = "VOLCANO_PLATFORM_LINUX"
    case iOS = "VOLCANO_PLATFORM_IOS"
    case macOS = "VOLCANO_PLATFORM_MACOS"
    case appleMetal = "VOLCANO_PLATFORM_APPLE_METAL"
    case android = "VOLCANO_PLATFORM_ANDROID"
    case windows = "VOLCANO_PLATFORM_WINDOWS"

    public init?(rawValue: String) {
        switch rawValue.lowercased() {
            case "volcano_platform_linux", "xlib", "xlib_xrandr", "xcb", "wayland":
                self = .linux

            case "volcano_platform_ios", "ios":
                self = .iOS

            case "volcano_platform_macos", "macos":
                self = .macOS

            case "volcano_platform_apple_metal", "metal":
                self = .appleMetal

            case "volcano_platform_android", "android":
                self = .android

            case "volcano_platform_windows", "win32":
                self = .windows

            default:
                return nil
        }
    }
}
