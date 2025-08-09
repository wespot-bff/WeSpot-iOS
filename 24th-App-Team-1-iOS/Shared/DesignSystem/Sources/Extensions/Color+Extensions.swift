//
//  Color+Extensions.swift
//  DesignSystem
//
//  Created by 김도현 on 7/27/25.
//


import SwiftUI

public extension Color {
    static func token(_ key: String) -> Color {
        switch key {
        case "White": return DesignSystemAsset.Colors.white.swiftUIColor
        case "Gray100": return DesignSystemAsset.Colors.gray100.swiftUIColor
        case "Gray200": return DesignSystemAsset.Colors.gray200.swiftUIColor
        case "Gray300": return DesignSystemAsset.Colors.gray300.swiftUIColor
        case "Gray400": return DesignSystemAsset.Colors.gray400.swiftUIColor
        case "Gray500": return DesignSystemAsset.Colors.gray500.swiftUIColor
        case "Gray600": return DesignSystemAsset.Colors.gray600.swiftUIColor
        case "Gray700": return DesignSystemAsset.Colors.gray700.swiftUIColor
        case "Gray800": return DesignSystemAsset.Colors.gray800.swiftUIColor
        case "Gray900": return DesignSystemAsset.Colors.gray900.swiftUIColor
            
        case "Primary100": return DesignSystemAsset.Colors.primary100.swiftUIColor
        case "Primary200": return DesignSystemAsset.Colors.primary200.swiftUIColor
        case "Primary300": return DesignSystemAsset.Colors.primary300.swiftUIColor
        case "Primary400": return DesignSystemAsset.Colors.primary400.swiftUIColor
        case "Primary500": return DesignSystemAsset.Colors.primary500.swiftUIColor
            
        default:
            return DesignSystemAsset.Colors.gray900.swiftUIColor
        }
    }
}

extension Color {
    init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexFormatted.hasPrefix("#") { hexFormatted.removeFirst() }

        var int = UInt64()
        Scanner(string: hexFormatted).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hexFormatted.count {
        case 8:
            a = (int & 0xff000000) >> 24
            r = (int & 0x00ff0000) >> 16
            g = (int & 0x0000ff00) >> 8
            b = int & 0x000000ff
        case 6:
            a = 255
            r = (int & 0xff0000) >> 16
            g = (int & 0x00ff00) >> 8
            b = int & 0x0000ff
        default:
            a = 255; r = 0; g = 0; b = 0
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

