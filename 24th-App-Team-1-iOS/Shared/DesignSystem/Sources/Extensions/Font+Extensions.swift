//
//  Font+Extensions.swift
//  DesignSystem
//
//  Created by 김도현 on 7/26/25.
//

import SwiftUI


extension Font {
    public static func typography(_ key: String) -> Font {
        switch key {
        case "Header01":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 28)
        case "Header02":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 24)
        case "Header03":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20)
        case "Header04":
            return DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18)
        case "Header05":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14)
        case "Body00":
            return DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14)
        case "Body01":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 18)
        case "Body02":
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16)
        case "Body03":
            return DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16)
        case "Body04":
            return DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16)
        case "Body05":
            return DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14)
        case "Body06":
            return DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14)
        case "Body07":
            return DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13)
        case "Body09":
            return DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 12)
        case "Body12":
            return DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 10)
        case "Badge":
            return DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12)
        case "captionM":
            return DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11)
        case "captionS":
            return DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 10)
        default:
            return DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16)
        }
    }
}
