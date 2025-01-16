//
//  SearchStudentRequestDTO.swift
//  MessageService
//
//  Created by 최지철 on 12/26/24.
//

import Foundation

public struct SearchStudentRequestDTO: Encodable {
    
    public let name: String
    public let cursorId: Int
    
    public init(name: String,
                cursorId: Int) {
        self.name = name
        self.cursorId = cursorId
    }
    
}
