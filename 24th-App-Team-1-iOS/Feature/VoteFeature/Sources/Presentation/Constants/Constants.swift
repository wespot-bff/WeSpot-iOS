//
//  Constants.swift
//  VoteFeature
//
//  Created by 김도현 on 11/19/24.
//

import UIKit
import Extensions
import DesignSystem

typealias VoteConstraint = Const

enum Const {
    /// **VoteMainViewController** Constraint 값
    static let voteToggleHeight: CGFloat = Device.isTouchIDCapableDevice ? 36 : 46
    
    /// **VoteHomeViewController** Constraint 값
    static let voteBannerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 64 : 80
    static let voteBannerViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 16 : 20
    static let voteContainerViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 12 : 16
    static let voteContainerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 358 : 400
    static let voteDateLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 24
    static let voteDescriptionLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 0 : 8
    static let voteDescriptionLabelHeight: CGFloat = Device.isTouchIDCapableDevice ? 42 : 54
    static let voteConfirmButtonHorizontalSpacing: CGFloat = Device.isTouchIDCapableDevice ? 20 : 28
    static let voteConfirmButtonHeight: CGFloat = Device.isTouchIDCapableDevice ? 40 : 52
    static let voteConfirmButtonBottomSpacing: CGFloat = Device.isTouchIDCapableDevice ? -18 : -28
    
    static let voteDateLabelFont: WSFont = Device.isTouchIDCapableDevice ? .Body09 : .Body06
    static let voteDescriptionLabelFont: WSFont = Device.isTouchIDCapableDevice ? .Body05 : .Body01
    static let voteBannerMainFont: WSFont = Device.isTouchIDCapableDevice ? .Body06 : .Body04
    static let voteBannerSubFont: WSFont = Device.isTouchIDCapableDevice ? .Body11 : .Body07
    
}
