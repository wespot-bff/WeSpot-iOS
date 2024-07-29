//
//  CreateVoteReqeuest.swift
//  VoteDomain
//
//  Created by Kim dohyun on 7/25/24.
//

import Foundation

public struct CreateVoteReqeuest {
    public let votes: [CreateVoteReqeuest]
    
    public init(votes: [CreateVoteReqeuest]) {
        self.votes = votes
    }
}

public struct CreateVoteItemReqeuest: Equatable {
    public let userId: Int
    public let voteOptionId: Int
    
    public init(userId: Int, voteOptionId: Int) {
        self.userId = userId
        self.voteOptionId = voteOptionId
    }
}