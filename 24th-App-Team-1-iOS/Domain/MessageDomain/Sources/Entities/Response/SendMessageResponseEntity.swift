//
//  SendMessageResponseEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 1/6/25.
//

import Foundation

public struct SendMessageResponseEntity: Equatable {
    public let id: Int
    
    public init(id: Int) {
        self.id = id
    }
}
