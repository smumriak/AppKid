//
//  Font.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.02.2020.
//

import Foundation
import CPango
import CCairo
import TinyFoundation

public struct Font {
    public fileprivate(set) var familyName: String
    public fileprivate(set) var size: CGFloat
    public fileprivate(set) var weight: Weight

    public func with(size: CGFloat) -> Font {
        var copy = self
        copy.size = size
        return copy
    }

    public init(familyName: String, size: CGFloat, weight: Weight = .normal) {
        self.familyName = familyName
        self.size = size
        self.weight = weight
    }

    public lazy var cairoFontDescription: CopyablePointer<PangoFontDescription> = {
        let result = CopyablePointer(with: pango_font_description_new())
        pango_font_description_set_family(result.pointer, familyName)
        pango_font_description_set_weight(result.pointer, weight.pangoWeight)
        pango_font_description_set_absolute_size(result.pointer, Double(size * CGFloat(PANGO_SCALE)))
        return result
    }()
}

public extension Font {
    static func systemFont(ofSize size: CGFloat) -> Font {
        // TODO: smumriak: Use GTK dylib to fetch system font for GTK-based environment and vice versa
        return Font(familyName: "Liberation Sans", size: size)
    }
}

public extension Font {
    struct Weight: Equatable, RawRepresentable {
        public typealias RawValue = CUnsignedInt
        public let rawValue: RawValue

        public init?(rawValue: RawValue) {
            guard (100...1000) ~= rawValue else {
                return nil
            }

            self.rawValue = rawValue
        }

        public init(pangoWeight: PangoWeight) {
            guard (100...1000) ~= pangoWeight.rawValue else {
                fatalError("Pango Weight is always in 100...1000 range.")
            }
            self.rawValue = pangoWeight.rawValue
        }

        public var pangoWeight: PangoWeight {
            return PangoWeight(rawValue: rawValue)
        }
    }

    enum Style: CUnsignedInt {
        case normal
        case oblique
        case italic

        public init(pangoStyle: PangoStyle) {
            switch pangoStyle {
                case PANGO_STYLE_NORMAL: self = .normal
                case PANGO_STYLE_OBLIQUE: self = .oblique
                case PANGO_STYLE_ITALIC: self = .italic
                default: self = .normal
            }
        }

        public var pangoStyle: PangoStyle {
            switch self {
                case .normal: return PANGO_STYLE_NORMAL
                case .oblique: return PANGO_STYLE_OBLIQUE
                case .italic: return PANGO_STYLE_ITALIC
            }
        }
    }
}

public extension Font.Weight {
    static var thin = Font.Weight(pangoWeight: PANGO_WEIGHT_THIN)
    static var ultralight = Font.Weight(pangoWeight: PANGO_WEIGHT_ULTRALIGHT)
    static var light = Font.Weight(pangoWeight: PANGO_WEIGHT_LIGHT)
    static var semilight = Font.Weight(pangoWeight: PANGO_WEIGHT_SEMILIGHT)
    static var book = Font.Weight(pangoWeight: PANGO_WEIGHT_BOOK)
    static var normal = Font.Weight(pangoWeight: PANGO_WEIGHT_NORMAL)
    static var medium = Font.Weight(pangoWeight: PANGO_WEIGHT_MEDIUM)
    static var semibold = Font.Weight(pangoWeight: PANGO_WEIGHT_SEMIBOLD)
    static var bold = Font.Weight(pangoWeight: PANGO_WEIGHT_BOLD)
    static var ultrabold = Font.Weight(pangoWeight: PANGO_WEIGHT_ULTRABOLD)
    static var heavy = Font.Weight(pangoWeight: PANGO_WEIGHT_HEAVY)
    static var ultraheavy = Font.Weight(pangoWeight: PANGO_WEIGHT_ULTRAHEAVY)
}
