//
//  MessageHomeTimeStateEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 12/20/24.
//

import Foundation

public struct MessageHomeTimeStateEntity: Equatable {
    public let messageAvailabilityTime: PostableTimeState
    public var topTitle: String {
        switch messageAvailabilityTime {
        case .waitTime, .etcTime:
            return "님을 설레게 한 친구에게 익명 쪽지로 마음을 표현해 보세요"
        case .postableTime:
            return "님을 설레게 한 친구에게 익명 쪽지로 마음을 표현해 보세요"
        }
    }
    public var postButtonTitle: String {
        switch messageAvailabilityTime {
        case .waitTime, .etcTime:
            return "매일 저녁 5시에 쪽지를 보낼 수 있어요"
        case .postableTime:
            return "익명 쪽지 보내기"
        }
    }
    
    public init(messageAvailabilityTime: PostableTimeState) {
        self.messageAvailabilityTime = messageAvailabilityTime
    }
}

extension MessageHomeTimeStateEntity {
    public enum PostableTimeState: Equatable {
        case waitTime   // 00:00 ~ 17:00
        case postableTime   // 17:00 ~ 22:00
        case etcTime    // 22:00 ~ 24:00
    }
}
