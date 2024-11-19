//
//  Constants.swift
//  DesignSystem
//
//  Created by 김도현 on 11/11/24.
//

import UIKit
import Extensions

typealias WSTabbarConstraint = Const


enum Const {
    static let tabarHeight: CGFloat = Device.isTouchIDCapableDevice ? 80 : 98
    static let tabbarButtonSize: CGFloat = Device.isTouchIDCapableDevice ? 32 : 40
    static let tabbarButtonSpacing: CGFloat = Device.isTouchIDCapableDevice ? 60 : 30
}
