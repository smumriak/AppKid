//
//  DisplayServer+GTK.swift
//  AppKid
//
//  Created by Serhii Mumriak on 18.02.2020.
//

import Foundation

// palkovnik:TODO: This code should be moved to Screen class when refactoring will be performed
internal extension DisplayServer {
    typealias gdk_display_open_f = @convention(c) (UnsafePointer<Int8>) -> OpaquePointer?
    typealias gdk_display_close_f = @convention(c) (OpaquePointer) -> ()

    typealias gdk_display_get_primary_monitor_f = @convention(c) (OpaquePointer) -> (OpaquePointer?)
    typealias gdk_monitor_get_scale_factor_f = @convention(c) (OpaquePointer) -> CInt

    var gtkDisplayScale: CInt? {
        return try? DylibWrapper.perform(on: "libgdk-3.so") {
            let gdk_display_open: gdk_display_open_f = try $0.loadCFunction(with: "gdk_display_open")
            let gdk_display_close: gdk_display_close_f = try $0.loadCFunction(with: "gdk_display_close")
            guard let gtkDisplay = gdk_display_open(display.pointee.display_name) else { return nil }
            defer { gdk_display_close(gtkDisplay) }

            let gdk_display_get_primary_monitor: gdk_display_get_primary_monitor_f = try $0.loadCFunction(with: "gdk_display_get_primary_monitor")
            guard let gtkMonitor = gdk_display_get_primary_monitor(gtkDisplay) else { return nil }

            let gdk_monitor_get_scale_factor: gdk_monitor_get_scale_factor_f = try $0.loadCFunction(with: "gdk_monitor_get_scale_factor")

            return gdk_monitor_get_scale_factor(gtkMonitor)
        }
    }
}
