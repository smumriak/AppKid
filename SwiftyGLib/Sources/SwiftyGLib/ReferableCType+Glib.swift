//
//  ReferableCType+Glib.swift
//  SwiftyGLib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

import Foundation
import CGlib
import TinyFoundation

extension _GMainContext: RetainableCType {
    public static var retainFunc = g_main_context_ref
    public static var releaseFunc = g_main_context_unref
}

extension _GMainLoop: RetainableCType {
    public static var retainFunc = g_main_loop_ref
    public static var releaseFunc = g_main_loop_unref
}
