//
//  GetMessageRequest.swift
//  MessageDomain
//
//  Created by 최지철 on 1/13/25.
//

import Foundation

public struct GetMessageRequest {
    public let cursorId: Int
    public let type: String
    
    public init(cursorId: Int, type: String) {
        self.cursorId = cursorId
        self.type = type
    }
}
