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
    var top: String {
        """

        #ifndef \(headerName)_h
        #define \(headerName)_h 1

        #include \"../../../CCore/include/CCore.h\"
        
        """
    }

    var bottom: String {
        """
        
        #endif /* \(headerName)_h */
        
        """
    }
}
