//
//  DeleteCommentUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/28/25.
//


import Foundation

public protocol DeleteCommentUseCaseProtocol {
    func execute(commentId: Int) async throws -> Bool
}

public final class DeleteCommentUseCase: DeleteCommentUseCaseProtocol {
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(commentId: Int) async throws -> Bool {
        try await communityRepository.deleteComment(commentId)
    }
}
