//
//  View+Extensions.swift
//  DesignSystem
//
//  Created by 김도현 on 7/29/25.
//

import SwiftUI


private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
            }
        )
        .onPreferenceChange(
            SizePreferenceKey.self,
            perform: onChange
        )
    }
}
