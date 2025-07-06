//
//  MessageSettingListEnum.swift
//  MessageDomain
//
//  Created by 최지철 on 5/29/25.
//

import Foundation

public enum MessageSettingListEnum: CaseIterable {
    case blockList
    case incomingOutgoing
    case alert

    public var title: String {
        switch self {
        case .blockList:
            return "차단한 쪽지방 목록"
        case .incomingOutgoing:
            return "쪽지 수신 및 발신"
        case .alert:
            return "쪽지 알림"
        }
    }
}
