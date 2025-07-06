//
//  SendMessageRequestDTO.swift
//  MessageService
//
//  Created by 최지철 on 1/6/25.
//

import Foundation

public struct SendMessageRequestDTO: Encodable {
    public let content: String
    public let receiverId: Int
    public let anonymousProfileName: String
    public let isAnonymous: Bool
    public let anonymousImageUrl: String
}
