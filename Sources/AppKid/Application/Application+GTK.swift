//
//  Application+GTK.swift
//  AppKid
//
//  Created by Serhii Mumriak on 18.02.2020.
//

import Foundation

// palkovnik:TODO: This code should be moved to Screen class when refactoring will be performed
internal extension Application {
    typealias gdk_display_open_f = @convention(c) (UnsafePointer<Int8>?) -> OpaquePointer?
    typealias gdk_display_close_f = @convention(c) (OpaquePointer?) -> ()

    typealias gdk_display_get_primary_monitor_f = @convention(c) (OpaquePointer?) -> (OpaquePointer?)
    typealias gdk_monitor_get_scale_factor_f = @convention(c) (OpaquePointer?) -> CInt

    var gtkDisplayScale: CInt? {
        guard let handle = dlopen("libgdk-3.so", RTLD_NOW) else { return nil }

        guard let gdk_display_open_type_erased = dlsym(handle, "gdk_display_open") else { return nil }
        guard let gdk_display_close_type_erased = dlsym(handle, "gdk_display_close") else { return nil }
        let gdk_display_open = unsafeBitCast(gdk_display_open_type_erased, to: gdk_display_open_f.self)
        let gdk_display_close = unsafeBitCast(gdk_display_close_type_erased, to: gdk_display_close_f.self)

        guard let gtkDisplay = gdk_display_open(display.pointee.display_name) else { return nil }

        defer { gdk_display_close(gtkDisplay) }

        guard let gdk_display_get_primary_monitor_type_erased = dlsym(handle, "gdk_display_get_primary_monitor") else { return nil }
        let gdk_display_get_primary_monitor = unsafeBitCast(gdk_display_get_primary_monitor_type_erased, to: gdk_display_get_primary_monitor_f.self)
        guard let gtkMonitor = gdk_display_get_primary_monitor(gtkDisplay) else { return nil }

        guard let gdk_monitor_get_scale_factor_type_erased = dlsym(handle, "gdk_monitor_get_scale_factor") else { return nil }
        let gdk_monitor_get_scale_factor = unsafeBitCast(gdk_monitor_get_scale_factor_type_erased, to: gdk_monitor_get_scale_factor_f.self)

        return gdk_monitor_get_scale_factor(gtkMonitor)
    }
}
