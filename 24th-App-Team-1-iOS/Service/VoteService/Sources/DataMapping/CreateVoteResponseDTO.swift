//
//  CreateVoteResponseDTO.swift
//  VoteService
//
//  Created by Kim dohyun on 7/25/24.
//

import Foundation

import VoteDomain

public struct CreateVoteResponseDTO: Decodable {
    public let id: Int
}

extension CreateVoteResponseDTO {
    public func toDomain() -> CreateVoteEntity {
        return .init(voteId: id)
    }
}
