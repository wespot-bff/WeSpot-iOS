//
//  WSNavigationBarModifier.swift
//  DesignSystem
//
//  Created by 김도현 on 7/23/25.
//

import SwiftUI

public extension View {
    func wsNavigationBar<Left: View,
                         Title: View,
                         Right: View>(
        left: (() -> Left)?    = nil,
        title: (() -> Title)?  = nil,
        right: (() -> Right)?  = nil
    ) -> some View {
        self.modifier(WSNavigationBarModifier(
            left: left,
            title: title,
            right: right
        ))
    }
    
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }

}

public struct WSNavigationBarModifier<LeftView: View,
                               TitleView: View,
                               RightView: View>: ViewModifier {

    private let left: (() -> LeftView)?
    private let title: (() -> TitleView)?
    private let right: (() -> RightView)?
    
    init(left: (() -> LeftView)? = nil,
         title: (() -> TitleView)? = nil,
         right: (() -> RightView)? = nil) {
        self.left  = left
        self.title = title
        self.right = right
    }
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .edgesIgnoringSafeArea(.top)
            
            let statusBar = UIApplication
                            .shared
                            .windows
                            .first?
                            .safeAreaInsets.top ?? 0
        
                HStack(spacing: 0) {
                    if let left = left {
                        left()
                            .frame(width: 44, height: 44)
                    } else {
                        Spacer().frame(width: 44)
                    }
                    
                    Spacer()
                    
                    if let title = title {
                        title()
                    }
                    
                    Spacer()
                    
                    if let right = right {
                        right()
                            .frame(height: 44)
                    } else {
                        Spacer().frame(width: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, statusBar + 8 + 44 + 12)
                .frame(height: 60)
                .edgesIgnoringSafeArea(.top)
                .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
    }
}
