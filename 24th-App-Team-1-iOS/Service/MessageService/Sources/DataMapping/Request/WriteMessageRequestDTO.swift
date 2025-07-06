//
//  WriteMessageRequestDTO.swift
//  MessageService
//
//  Created by 최지철 on 12/31/24.
//

import Foundation

public struct WriteMessageRequestDTO: Encodable {
    let content: String
    let receiverId: Int
    let senderName: String
    let isAnonymous: Bool
}
