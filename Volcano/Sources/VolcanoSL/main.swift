//
//  main.swift
//  VolcanoSL
//
//  Created by Serhii Mumriak on 13.06.2021.
//

import CClang
import Foundation
import TinyFoundation
import ArgumentParser
import TSCBasic

enum ShaderStage {
    case vertex
    case fragment
}

enum QualifierType: String, CaseIterable {
    case uniform = "@uniform"
    case input = "@in"
    case output = "@out"

    static var allCasesRaw: [String] = QualifierType.allCases.map { $0.rawValue }

    var name: String {
        switch self {
            case .uniform: return "uniform"
            case .input: return "in"
            case .output: return "out"
        }
    }
}

enum FieldType {
    case bool
    case int
    case uint
    case float
    case double

    case bvec(length: Int64)
    case ivec(length: Int64)
    case uvec(length: Int64)
    case vec(length: Int64)
    case dvec(length: Int64)

    indirect case array(type: FieldType, length: Int64)

    case mat(length: Int64)
    case matx(columns: Int64, rows: Int64)
    case dmat(length: Int64)
    case dmatx(columns: Int64, rows: Int64)

    init?(name: String) {
        switch name {
            case "bool": self = .bool
            case "int": self = .int
            case "uint": self = .uint
            case "float": self = .float
            case "double": self = .double
            case "bvec2": self = .bvec(length: 2)
            case "bvec3": self = .bvec(length: 3)
            case "bvec4": self = .bvec(length: 4)
            case "ivec2": self = .ivec(length: 2)
            case "ivec3": self = .ivec(length: 3)
            case "ivec4": self = .ivec(length: 4)
            case "uvec2": self = .uvec(length: 2)
            case "uvec3": self = .uvec(length: 3)
            case "uvec4": self = .uvec(length: 4)
            case "vec2": self = .vec(length: 2)
            case "vec3": self = .vec(length: 3)
            case "vec4": self = .vec(length: 4)
            case "dvec2": self = .dvec(length: 2)
            case "dvec3": self = .dvec(length: 3)
            case "dvec4": self = .dvec(length: 4)
            case "mat2": self = .mat(length: 2)
            case "mat3": self = .mat(length: 3)
            case "mat4": self = .mat(length: 4)
            case "mat2x3": self = .matx(columns: 2, rows: 3)
            case "mat2x4": self = .matx(columns: 2, rows: 4)
            case "mat3x2": self = .matx(columns: 3, rows: 2)
            case "mat3x4": self = .matx(columns: 3, rows: 4)
            case "mat4x2": self = .matx(columns: 4, rows: 2)
            case "mat4x3": self = .matx(columns: 4, rows: 3)
            case "dmat2": self = .dmat(length: 2)
            case "dmat3": self = .dmat(length: 3)
            case "dmat4": self = .dmat(length: 4)
            case "dmat2x3": self = .dmatx(columns: 2, rows: 3)
            case "dmat2x4": self = .dmatx(columns: 2, rows: 4)
            case "dmat3x2": self = .dmatx(columns: 3, rows: 2)
            case "dmat3x4": self = .dmatx(columns: 3, rows: 4)
            case "dmat4x2": self = .dmatx(columns: 4, rows: 2)
            case "dmat4x3": self = .dmatx(columns: 4, rows: 3)
            default: return nil
        }
    }

    init?(type: CXType) {
        let canonicalType = type.kind == .typedef ? clang_getCanonicalType(type) : type

        switch canonicalType.kind {
            case .bool: self = .bool
            case .int: self = .int
            case .uInt: self = .uint
            case .float: self = .float
            case .double: self = .double

            case .extVector:
                let numberOfElements = clang_getNumElements(canonicalType)
                guard let elementType = FieldType(type: clang_getElementType(canonicalType)) else {
                    return nil
                }

                switch elementType {
                    case .bool: self = .bvec(length: numberOfElements)
                    case .int: self = .ivec(length: numberOfElements)
                    case .uint: self = .uvec(length: numberOfElements)
                    case .float: self = .vec(length: numberOfElements)
                    case .double: self = .dvec(length: numberOfElements)
                    default: return nil
                }

            case .constantArray:
                let numberOfElements = clang_getNumElements(canonicalType)
                guard let elementType = FieldType(type: clang_getElementType(canonicalType)) else {
                    return nil
                }

                switch elementType {
                    case .vec(let length):
                        if length == numberOfElements {
                            self = .mat(length: length)
                        } else {
                            self = .matx(columns: numberOfElements, rows: length)
                        }
                    case .dvec(let length):
                        if length == numberOfElements {
                            self = .dmat(length: length)
                        } else {
                            self = .dmatx(columns: numberOfElements, rows: length)
                        }
                    default: self = .array(type: elementType, length: numberOfElements)
                }

            default: return nil
        }
    }

    var locationStride: Int64 {
        switch self {
            case .bool: return 1
            case .int: return 1
            case .uint: return 1
            case .float: return 1
            case .double: return 1
            case .bvec(_): return 1
            case .ivec(_): return 1
            case .uvec(_): return 1
            case .vec(_): return 1
            case .dvec(_): return 1
            case .array(let subtype, let length):
                switch subtype {
                    case .vec(_): return length
                    case .array(_, _): return length
                    default: return 1
                }
            case .mat(let length): return length
            case .matx(let columns, _): return columns
            case .dmat(let length): return length
            case .dmatx(let columns, _): return columns
        }
    }

    var name: String {
        switch self {
            case .bool: return "bool"
            case .int: return "int"
            case .uint: return "uint"
            case .float: return "float"
            case .double: return "double"
            case .bvec(let length): return "bvec\(length)"
            case .ivec(let length): return "ivec\(length)"
            case .uvec(let length): return "uvec\(length)"
            case .vec(let length): return "vec\(length)"
            case .dvec(let length): return "dvec\(length)"
            case .array(let subtype, _): return subtype.name
            case .mat(let length): return "mat\(length)"
            case .matx(let columns, let rows): return "mat\(columns)x\(rows)"
            case .dmat(let length): return "dmat\(length)"
            case .dmatx(let columns, let rows): return "dmat\(columns)x\(rows)"
        }
    }

    var variableNameArrayCountSuffix: String? {
        switch self {
            case .array(let type, let length):
                if let typeVariableNameArrayCountSuffix = type.variableNameArrayCountSuffix {
                    return "\(typeVariableNameArrayCountSuffix)[\(length)]"
                } else {
                    return "[\(length)]"
                }
                
            default: return nil
        }
    }
}

struct Field {
    let name: String
    let type: FieldType
    let location: Int64

    func constructDeclaration(for stage: ShaderStage, qualifierType: QualifierType, pretty: Bool) -> String {
        switch stage {
            case .vertex:
                if qualifierType == .input {
                    return "layout(location = \(location)) \(qualifierType.name) \(type.name) \(name)\(type.variableNameArrayCountSuffix ?? "");"
                } else {
                    return (pretty ? "\t" : "") + "\(type.name) \(name)\(type.variableNameArrayCountSuffix ?? "");"
                }
            case .fragment: return (pretty ? "\t" : "") + "\(type.name) \(name)\(type.variableNameArrayCountSuffix ?? "");"
        }
    }
}

extension String {
    func starts<PossiblePrefix>(withAnyIn possiblePrefixes: [PossiblePrefix]) -> Bool where PossiblePrefix: Sequence, Character == PossiblePrefix.Element {
        for possiblePrefix in possiblePrefixes {
            if starts(with: possiblePrefix) {
                return true
            }
        }

        return false
    }
}

let glslTypesIncludeFileURL = Bundle.module.url(forResource: "GLSLTypesInclude", withExtension: "h")!

struct VolcanoSL: ParsableCommand {
    @Argument(help: "Path to shader source file")
    var filePath: String

    @Option(name: .customShort("I"), help: "Addition hader search path, no recursion")
    var include: [String] = []

    @Option(name: .shortAndLong, help: "GLSL output file path. Leave empty to get generated file path")
    var glslOutput: String?

    @Option(name: .shortAndLong, help: "SPIR-V output file path. When not-empty volcanosl will automatically invoke glslc on generated glsl file")
    var spvOutput: String?

    @Flag(name: .long, help: "Epands generated strucures with newlines and some tabs")
    var pretty: Bool = false

    mutating func run() throws {
        var encoding: String.Encoding = .ascii
        let fileURL = URL(fileURLWithPath: filePath, isDirectory: false)
        let shaderCode = try String(contentsOfFile: filePath, usedEncoding: &encoding)
        let shaderLines = shaderCode.components(separatedBy: .newlines)
        var shaderStage: ShaderStage? = nil
        let currentDirectoryURL = fileURL.deletingLastPathComponent()

        let lookupURLs = [currentDirectoryURL] + include.map { URL(fileURLWithPath: $0, isDirectory: true) }

        var currentLocations: [QualifierType: Int64] = [:]

        let parsedShaderLines: [String] = try shaderLines.flatMap { line -> [String] in
            switch line {
                case line where line.starts(withAnyIn: QualifierType.allCasesRaw):
                    guard let shaderStage = shaderStage else {
                        fatalError("Not known shader stage")
                    }
                    
                    let importGenerationContext = try parseImportLine(from: line, stage: shaderStage, lookupURLs: lookupURLs, currentLocations: currentLocations, pretty: pretty)
                    currentLocations[importGenerationContext.qualifierType] = importGenerationContext.currentLocation

                    if pretty {
                        return importGenerationContext.results
                    } else {
                        return [importGenerationContext.results.joined(separator: " ")]
                    }
                    
                case line where line.starts(with: "#pragma"):
                    let pragmaArguments = line.components(separatedBy: .whitespaces)
                    
                    if pragmaArguments.count == 2 {
                        switch pragmaArguments[1] {
                            case let stage where stage == "shader_stage(vertex)":
                                shaderStage = .vertex

                            case let stage where stage == "shader_stage(fragment)":
                                shaderStage = .fragment

                            default:
                                break
                        }
                    }

                    return [line]

                default:
                    return [line]
            }
        }

        let result: String = parsedShaderLines.joined(separator: "\n")

        let glslOutputFileURL: URL = {
            if let glslOutput = glslOutput {
                return URL(fileURLWithPath: glslOutput)
            } else {
                return fileURL.appendingPathExtension("glsl")
            }
        }()

        try result.write(to: glslOutputFileURL, atomically: true, encoding: encoding)

        if let spvOutput = spvOutput {
            let arguments: [String] = [
                glslOutputFileURL.absoluteURL.path,
                "-o", spvOutput,
                "-I", fileURL.deletingLastPathComponent().absoluteURL.path,
            ] + include.flatMap {
                ["-I", $0]
            }

            let command = ["glslc"] + arguments

            let glslcCommandResult = try Process.popen(arguments: command, environment: ProcessInfo.processInfo.environment)

            let glslcCommandOutput = try glslcCommandResult.utf8Output() + glslcCommandResult.utf8stderrOutput()

            if glslcCommandResult.exitStatus != .terminated(code: 0) {
                fatalError("Failed to compile SPIR-V using \(command)\n\n\(glslcCommandOutput)")
            }
        }
    }
}

class DeclarationFindingContext {
    let typeName: String
    var cursor: CXCursor? = nil

    init(typeName: String) {
        self.typeName = typeName
    }
}

class ImportGenerationContext {
    let typeName: String
    var currentLocation: Int64
    var results: [String] = []
    let stage: ShaderStage
    let qualifierType: QualifierType
    let pretty: Bool

    init(typeName: String, stage: ShaderStage, qualifierType: QualifierType, currentLocation: Int64, pretty: Bool) {
        self.typeName = typeName
        self.stage = stage
        self.qualifierType = qualifierType
        self.currentLocation = currentLocation
        self.pretty = pretty
    }
}

func headerURL(for typeName: String, lookupURLs: [URL]) -> URL? {
    let fileManager = FileManager.default

    for lookupURL in lookupURLs {
        let headerURL = lookupURL.appendingPathComponent(typeName).appendingPathExtension("h")
        
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: headerURL.path, isDirectory: &isDirectory), isDirectory.boolValue == false {
            return headerURL
        }
    }

    return nil
}

func parseImportLine(from shaderLine: String, stage: ShaderStage, lookupURLs: [URL], currentLocations: [QualifierType: Int64], pretty: Bool) throws -> ImportGenerationContext {
    let importComponents = shaderLine.components(separatedBy: .whitespaces)

    if importComponents.count != 3 {
        fatalError("Malformed import statement")
    }

    guard let qualifierType = QualifierType(rawValue: importComponents[0]) else {
        fatalError("Unsupported qualifier")
    }

    let currentLocation: Int64 = currentLocations[qualifierType] ?? 0

    let index = clang_createIndex(0, 0)
    if index == nil {
        fatalError("can't create index")
    }

    let typeName = importComponents[1]
    let variableName = importComponents[2].filter { $0 != ";" }

    if let standardFieldType = FieldType(name: typeName) {
        let importGenerationContext = ImportGenerationContext(typeName: typeName, stage: stage, qualifierType: qualifierType, currentLocation: currentLocation + standardFieldType.locationStride, pretty: pretty)
        importGenerationContext.results.append("layout(location = \(currentLocation)) \(qualifierType.name) \(standardFieldType.name) \(variableName)\(standardFieldType.variableNameArrayCountSuffix ?? "");")

        return importGenerationContext
    }

    guard let headerURL = headerURL(for: typeName, lookupURLs: lookupURLs) else {
        fatalError("Can not find header for \(typeName)")
    }

    let flags: CXTranslationUnit_Flags = []

    var commandLineArguments: [String] = ["-D__VOLCANO_SL__"]
    commandLineArguments.append("--include=\(glslTypesIncludeFileURL.path)")

    let translationUnit = commandLineArguments.withUnsafeNullableCStringsBufferPointer { commandLineArguments in
        clang_parseTranslationUnit(index, headerURL.path, commandLineArguments.baseAddress!, CInt(commandLineArguments.count), nil, 0, flags.rawValue)
    }
    if translationUnit == nil {
        fatalError("can't parse translation unit")
    }

    let declarationFindingContext = DeclarationFindingContext(typeName: typeName)

    let findDeclatationVisitor: CXCursorVisitor = { cursor, parent, data in
        let declarationFindingContext = Unmanaged<DeclarationFindingContext>.fromOpaque(data!).takeUnretainedValue()

        guard clang_isInvalidDeclaration(cursor) == 0 else {
            return .continue
        }

        guard clang_getCursorKind(cursor) == .structDecl else {
            return .continue
        }
    
        let cursorSpelling = clang_getCursorSpelling(cursor)
        defer { clang_disposeString(cursorSpelling) }

        let name = String(cString: clang_getCString(cursorSpelling)!)

        if name == declarationFindingContext.typeName {
            declarationFindingContext.cursor = cursor
            return .break
        }
        return .recurse
    }

    let cursor = clang_getTranslationUnitCursor(translationUnit)
    clang_visitChildren(cursor, findDeclatationVisitor, Unmanaged<DeclarationFindingContext>.passUnretained(declarationFindingContext).toOpaque())

    guard let foundCursor = declarationFindingContext.cursor else {
        fatalError("The type could not be found")
    }

    let importGenerationContext = ImportGenerationContext(typeName: typeName, stage: stage, qualifierType: qualifierType, currentLocation: currentLocation, pretty: pretty)

    switch stage {
        case .vertex:
            if qualifierType != .input {
                importGenerationContext.results.append("layout(location = \(currentLocation)) \(qualifierType.name) \(typeName) {")
            }
        case .fragment:
            importGenerationContext.results.append("layout(location = \(currentLocation)) \(qualifierType.name) \(typeName) {")
    }

    let importGenerationVisitor: CXCursorVisitor = { cursor, parent, data in
        let importGenerationContext = Unmanaged<ImportGenerationContext>.fromOpaque(data!).takeUnretainedValue()

        guard clang_getCursorKind(cursor) == .fieldDecl else {
            fatalError("Only structs without anything except field declarations are supported")
        }

        guard clang_isInvalidDeclaration(cursor) == 0 else {
            fatalError("Only structs with valid field declarations are supported")
        }

        let cursorType = clang_getCursorType(cursor)

        guard let fieldType = FieldType(type: cursorType) else {
            fatalError("Unsupported type")
        }

        let cursorSpelling = clang_getCursorSpelling(cursor)
        defer { clang_disposeString(cursorSpelling) }

        guard let variableNameCString = clang_getCString(cursorSpelling) else {
            fatalError("Unparsable variable name")
        }

        let variableName = String(cString: variableNameCString)

        let field = Field(name: variableName, type: fieldType, location: importGenerationContext.currentLocation)
        importGenerationContext.currentLocation += fieldType.locationStride

        importGenerationContext.results.append(field.constructDeclaration(for: importGenerationContext.stage, qualifierType: importGenerationContext.qualifierType, pretty: importGenerationContext.pretty))
        
        return .continue
    }

    clang_visitChildren(foundCursor, importGenerationVisitor, Unmanaged<ImportGenerationContext>.passUnretained(importGenerationContext).toOpaque())

    switch stage {
        case .vertex:
            if qualifierType != .input {
                importGenerationContext.results.append("} \(variableName);")
            }
        case .fragment:
            importGenerationContext.results.append("} \(variableName);")
    }

    clang_disposeTranslationUnit(translationUnit)
    clang_disposeIndex(index)

    return importGenerationContext
}

VolcanoSL.main()
