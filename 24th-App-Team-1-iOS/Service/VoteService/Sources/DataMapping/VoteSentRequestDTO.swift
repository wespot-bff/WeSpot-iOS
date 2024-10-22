//
//  VoteSentRequestDTO.swift
//  VoteService
//
//  Created by Kim dohyun on 8/9/24.
//

import Foundation

public struct VoteSentRequestDTO: Encodable {
    public let cursorId: String
    
    public init(cursorId: String) {
        self.cursorId = cursorId
    }
}
