//
//  DetailMessageEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 6/26/25.
//

import Foundation
 
public struct MessageRoomDetailEntity {
    public let isReceiverAnonymous: Bool
    public let thumbnailURL: URL? // UI에서 사용하기 편한 URL 타입
    public let name: String
    public let roomId: Int // DTO의 messageRoomId보다 간결한 이름 사용
    public let isBookmarked: Bool
    public let messages: [MessageDetailEntity]
    
    public init(isReceiverAnonymous: Bool, thumbnailURL: URL?, name: String, roomId: Int, isBookmarked: Bool, messages: [MessageDetailEntity]) {
        self.isReceiverAnonymous = isReceiverAnonymous
        self.thumbnailURL = thumbnailURL
        self.name = name
        self.roomId = roomId
        self.isBookmarked = isBookmarked
        self.messages = messages
    }
}

// MARK: - MessageDetailEntity
/// 개별 메시지를 나타내는 모델
public struct MessageDetailEntity {
    public let id: Int
    public let createdAt: Date // 날짜 계산 및 표시에 용이한 Date 타입
    public let content: String
    public let direction: MessageDirection // 메시지 방향을 명확하게 표현
    public let isRead: Bool
    public let isAbleToAnswer: Bool
    
    public init(id: Int, createdAt: Date, content: String, direction: MessageDirection, isRead: Bool, isAbleToAnswer: Bool) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.direction = direction
        self.isRead = isRead
        self.isAbleToAnswer = isAbleToAnswer
    }
}

// MARK: - Message Direction Enum
/// 메시지가 보내는 것인지 받는 것인지 명확히 하기 위한 열거형
public enum MessageDirection {
    case sent
    case received
}
