//
//  SearchStudentRequest.swift
//  MessageDomain
//
//  Created by 최지철 on 12/26/24.
//

import Foundation

public struct SearchStudentRequest {
    
    public var name: String
    public var cursorId: Int
    
    public init(name: String,
                cursorId: Int) {
        self.name = name
        self.cursorId = cursorId
    }
    
}
