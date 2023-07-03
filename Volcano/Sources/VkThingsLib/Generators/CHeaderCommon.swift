//
//  CHeaderCommon.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public protocol CHeaderGenerator: Generator {
    var headerName: String { get }
}

public extension CHeaderGenerator {
    func top(from parser: Parser) throws -> String {
        """
        #ifndef \(headerName)_h
        #define \(headerName)_h 1

        #include \"../../../CCore/include/CCore.h\"
        """
    }

    func bottom(from parser: Parser) throws -> String {
        """
        #endif /* \(headerName)_h */
        """
    }
}
