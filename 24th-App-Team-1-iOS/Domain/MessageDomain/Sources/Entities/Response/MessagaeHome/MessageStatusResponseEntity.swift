//
//  MessageStatusResponseEntity.swift
//  MessageDomain
//
//  Created by eunseou on 8/9/24.
//

import Foundation

public struct MessageStatusResponseEntity {
    public let isSendAllowed: Bool
    public let remainingMessages: Int
    public let countUnReadMessages: Int
    public let countUnReplayMessages: Int
    public let isReceivedAllowed: Bool

    public init(isSendAllowed: Bool,
                isReceivedAllowed: Bool,
                remainingMessages: Int,
                countUnReplayMessages: Int,
                countUnReadMessages: Int) {
        self.isReceivedAllowed = isReceivedAllowed
        self.isSendAllowed = isSendAllowed
        self.remainingMessages = remainingMessages
        self.countUnReplayMessages = countUnReplayMessages
        self.countUnReadMessages = countUnReadMessages
    }
}
