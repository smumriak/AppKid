//
//  SpoonProcess.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 19.10.2023
//

import Spoon
import SystemPackage
import LinuxSys
import TinyFoundation
import Foundation

fileprivate struct ForkMetadata {
    // this stuff should be pre-allocated since we should not really do ANY allocations after forking due to the fact that vfork does not copy original process' memory. it's a very shady gray zone in memory management on OS side
    // essentially, the only thing allocated will be the stack for the `forkedCall` function call
    let executablePath: UnsafePointer<CChar>
    let arguments: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
    let environment: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
    let workDirectoryPath: UnsafePointer<CChar>?
}

fileprivate func forkedCall(info: UnsafeMutableRawPointer!) -> CInt {
    let metadata = info.assumingMemoryBound(to: ForkMetadata.self).pointee

    if let workDirectoryPath = metadata.workDirectoryPath {
        chdir(workDirectoryPath)
    }

    return execve(metadata.executablePath /* path */,
                  metadata.arguments /* argv */,
                  metadata.environment /* envp */ )
}

public func spoonProcess(executablePath: FilePath, arguments: [String] = [], environment: [String: String]? = nil, workDirectoryPath: FilePath? = nil) throws -> CInt {
    let arguments = [executablePath.string] + arguments
    let environment = (environment ?? ProcessInfo.processInfo.environment).map { "\($0)=\($1)" }
    var metadata = ForkMetadata(
        executablePath: arguments[0].withCString { strdup($0) },
        arguments: arguments.nullTerminatedArrayOfCStrings,
        environment: environment.nullTerminatedArrayOfCStrings,
        workDirectoryPath: workDirectoryPath?.withCString { strdup($0) }
    )

    let childID = spoon(forkedCall /* child */,
                        &metadata /* info */ )

    if childID == 0 {
        // we are in forked process, tho technically this code should never be executed unless something failed
        fatalError("Error happened while executing `forkedCall`. TODO: propagate errors properly")
    }

    defer {
        metadata.workDirectoryPath?.deallocate()

        for i in 0..<environment.count {
            (metadata.environment + i).pointee?.deallocate()
        }
        metadata.arguments.deinitialize(count: environment.count + 1)
        metadata.environment.deallocate()
        
        for i in 0..<arguments.count {
            (metadata.arguments + i).pointee?.deallocate()
        }
        metadata.arguments.deinitialize(count: arguments.count + 1)
        metadata.arguments.deallocate()

        metadata.executablePath.deallocate()
    }

    return childID
}
