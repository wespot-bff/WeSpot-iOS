//
//  MessagesStatusResponseDTO.swift
//  MessageService
//
//  Created by eunseou on 8/9/24.
//

import Foundation
import MessageDomain

public struct MessagesStatusResponseDTO: Decodable {
    public let isSendAllowed: Bool
    public let isReceivedAllowed: Bool
    public let countRemainingMessages: Int
    public let countUnReadMessages: Int
    public let countUnReplayMessages: Int
}

extension MessagesStatusResponseDTO {
    func toDomain() -> MessageStatusResponseEntity {
        return .init(isSendAllowed: isSendAllowed,
                     isReceivedAllowed: isReceivedAllowed,
                     remainingMessages: countRemainingMessages,
                     countUnReplayMessages: countUnReplayMessages,
                     countUnReadMessages: countUnReadMessages)
    }
}
