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
    private let backgound: Color
    private let right: (() -> RightView)?
    
    public init(left: (() -> LeftView)? = nil,
                title: (() -> TitleView)? = nil,
                right: (() -> RightView)? = nil,
                background: Color? = nil
    ) {
        self.left  = left
        self.title = title
        self.right = right
        self.backgound = background ?? DesignSystemAsset.Colors.gray900.swiftUIColor
    }
    
    public func body(content: Content) -> some View {
        let statusBar = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        
        ZStack(alignment: .top) {
            content
            
            VStack(spacing: 0) {
                Spacer().frame(height: statusBar)
                
                ZStack {
                    if let title = title {
                        title()
                            .lineLimit(1)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 64)
                    }
                    
                    HStack(spacing: 0) {
                        if let left = left {
                            HStack(spacing: 0) {
                                left()
                                    .frame(height: 44)
                                Spacer()
                            }
                            .frame(minWidth: 44)
                            .padding(.leading, 20)
                        } else {
                            Spacer()
                                .frame(width: 20)
                        }
                        
                        Spacer()
                        
                        if let right = right {
                            HStack(spacing: 0) {
                                Spacer()
                                right()
                                    .frame(height: 44)
                            }
                            .frame(minWidth: 44)
                            .padding(.trailing, 20)
                        } else {
                            Spacer()
                                .frame(width: 20)
                        }
                    }
                }
                .frame(height: 44)
            }
            .background(backgound)
        }
        .ignoresSafeArea(edges: .top)
    }
}
