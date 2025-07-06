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
    static let voteBannerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 70 : 80
    static let voteBannerViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 20
    static let voteContainerViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 12 : 16
    static let voteContainerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 332 : 400
    static let voteLottieHorizontalSpacing: CGFloat = Device.isTouchIDCapableDevice ? 22 : 0
    static let voteLottieTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 12 : 0
    static let voteLottieBottomSpacing: CGFloat = Device.isTouchIDCapableDevice ? 30 : 0
    static let voteDateLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 24
    static let voteConfirmButtonHorizontalSpacing: CGFloat = Device.isTouchIDCapableDevice ? 20 : 28
    static let voteConfirmButtonHeight: CGFloat = Device.isTouchIDCapableDevice ? 46 : 52
    static let voteConfirmButtonBottomSpacing: CGFloat = Device.isTouchIDCapableDevice ? -14 : -28
    
    /// **VoteResultViewController** Constraint 값
    static let voteResultTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 0 : 32
    static let voteResultItemHeight: CGFloat = Device.isTouchIDCapableDevice ? 330 : 392
    
    static let voteResultRankViewWidth: CGFloat = Device.isTouchIDCapableDevice ? 86 : 102
    static let voteResultRankViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 31 : 38
    static let voteResultRankViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 16 : 18
    static let voteResultRankViewLeftSpacing: CGFloat = Device.isTouchIDCapableDevice ? 20 : 20
    static let voteResultRankViewFont: WSFont = Device.isTouchIDCapableDevice ? .Header02 : .Header01
    static let voteRankImageViewSize: CGFloat = Device.isTouchIDCapableDevice ? 26 : 30
    static let voteRankImageViewLeftSpacing: CGFloat = Device.isTouchIDCapableDevice ? 10 : 12
    static let voteRankLabelLeftSpacing: CGFloat = Device.isTouchIDCapableDevice ? 10 : 8
    static let voteRankLabelHeight: CGFloat = Device.isTouchIDCapableDevice ? 21 : 30
    
    static let voteResultDescriptionLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 8 : 12
    static let voteResultFaceImageViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 11
    static let voteResultFaceImageViewSize: CGFloat = Device.isTouchIDCapableDevice ? 90 : 120
    static let voteResultNameLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 11
    static let voteResultNameLabelHeight: CGFloat = Device.isTouchIDCapableDevice ? 27 : 30
    static let voteResultRankViewRadius: CGFloat = Device.isTouchIDCapableDevice ? 16 : 18
    static let voteResultIntroduceLabelTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 0 : 4
    static let voteResultIntroduceLabelHeight: CGFloat = Device.isTouchIDCapableDevice ? 15 : 20
    static let voteResultContainerViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 17 : 20
    
    static let voteResultNameLableFont: WSFont = Device.isTouchIDCapableDevice ? .Header02 : .Header01
    
    
    /// **VoteProcessViewController** Constraint 값
    static let voteProfileViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 39
    static let voteProcessTableViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 14 : 32
    static let voteProcessCellHeight: CGFloat = Device.isTouchIDCapableDevice ? 66 : 72
    static let voteProfileViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 100 : 120
    static let voteProcessTableHeight: CGFloat = Device.isTouchIDCapableDevice ? 330 : 364
    
    
    /// **VoteEffectViewController** Constraint 값
    static let voteCompleteCollectionViewTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 0 : 25
    static let voteEffectCollectionViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 416 : 480
    static let voteRankerCellHorizontalTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? 60 : 55
    static let voteRankerCellVerticalItemHeight: CGFloat = Device.isTouchIDCapableDevice ? 68 : 78
    static let voteRankerCellVeticalSectionTopSpacing: CGFloat = Device.isTouchIDCapableDevice ? -20 : 0
}
