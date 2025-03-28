//
//  MessageContentModel.swift
//  MessageDomain
//
//  Created by 최지철 on 1/15/25.
//

import Foundation

import RxDataSources

public struct MessageContentModel {
    public let studentInfo: String
    public let date: String
    public var isRead: Bool
    public var isBlocked: Bool
    public var isReported: Bool
    public let content: String
    public let senderName: String
    public let reciverName: String
    public let messageId: Int
    
    public init(studentInfo: String,
                date: String,
                isRead: Bool,
                isBlocked: Bool,
                isReported: Bool,
                content: String,
                senderName: String,
                reciverName: String,
                messageId: Int) {
        self.studentInfo = studentInfo
        self.date = date
        self.isRead = isRead
        self.isBlocked = isBlocked
        self.isReported = isReported
        self.content = content
        self.senderName = senderName
        self.reciverName = reciverName
        self.messageId = messageId
    }
}
extension MessageContentModel: IdentifiableType, Equatable {
    public var identity: Int {
        return self.messageId
    }
    
    public static func == (lhs: MessageContentModel, rhs: MessageContentModel) -> Bool {
        // 두 모델이 같다고 판단할 기준 (예: 모든 필드를 비교하거나 읽음 상태 등 중요한 값 비교)
        return lhs.messageId == rhs.messageId &&
               lhs.isRead == rhs.isRead &&
               lhs.content == rhs.content
        // 필요에 따라 더 많은 필드를 비교할 수 있음
    }
}
