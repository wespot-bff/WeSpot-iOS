//
//  MessagePostError.swift
//  MessageDomain
//
//  Created by 최지철 on 10/12/25.
//

import Foundation

public struct MessagePostError: Error {
    public let errorDescription: String
    public let errorView: MessageErrorViewType
    
    
    public init(errorDescription: String, errorView: MessageErrorViewType) {
        self.errorDescription = errorDescription
        self.errorView = errorView
    }
}
