//
//  POSIXErrorCode.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 20.08.2020.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension POSIXErrorCode: Error {}
