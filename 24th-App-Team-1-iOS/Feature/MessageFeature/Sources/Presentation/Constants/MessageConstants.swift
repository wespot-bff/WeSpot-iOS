//
//  MessageConstants.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import UIKit
import MessageDomain

import Extensions
import DesignSystem

typealias MessageConstants = Const

enum Const {
    static let messageBannerViewHeight: CGFloat = Device.isTouchIDCapableDevice ? 70 : 80
    static let messageSendButtonHeight: CGFloat = Device.isTouchIDCapableDevice ? 46 : 52
    static func reservedMessageViewHeight(for state: MessageHomeTimeStateEntity.PostableTimeState) -> CGFloat {
        switch state {
        case .waitTime:
            return Device.isTouchIDCapableDevice ? 306 : 335
        case .postableTime:
            return Device.isTouchIDCapableDevice ? 330 : 433
        case .etcTime:
            return Device.isTouchIDCapableDevice ? 306 : 352
        }
    }
}
