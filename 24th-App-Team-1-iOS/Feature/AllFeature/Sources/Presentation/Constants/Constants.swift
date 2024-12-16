//
//  Constants.swift
//  AllFeature
//
//  Created by 김도현 on 11/20/24.
//

import Foundation

import Extensions

typealias ProfileConstraint = Const

enum Const {
    static let profileBannerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 70 : 80
    static let profileTableViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 10 : 30
    static let profileSettingTextFiledHeight: CGFloat = Device.isTouchIDCapableDevice ? 50 : 60
}
