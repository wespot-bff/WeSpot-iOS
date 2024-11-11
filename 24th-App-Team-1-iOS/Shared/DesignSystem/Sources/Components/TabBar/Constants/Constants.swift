//
//  Constants.swift
//  DesignSystem
//
//  Created by 김도현 on 11/11/24.
//

import UIKit


typealias WSTabbarConstraint = Const


enum Const {
    static let tabarHeight: CGFloat = UIScreen.main.isWideScreen ? 98 : 49
    static let tabbarButtonSize: CGFloat = UIScreen.main.isWideScreen ? 40 : 20
}
