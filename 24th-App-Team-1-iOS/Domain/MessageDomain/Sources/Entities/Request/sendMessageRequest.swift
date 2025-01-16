//
//  sendMessageRequest.swift
//  MessageDomain
//
//  Created by 최지철 on 1/6/25.
//

import Foundation

public struct SendMessageRequest: Equatable {
    public let content: String
    public let reciverId: Int
    public let senderName: String
    public let isAnonymous: Bool
}
