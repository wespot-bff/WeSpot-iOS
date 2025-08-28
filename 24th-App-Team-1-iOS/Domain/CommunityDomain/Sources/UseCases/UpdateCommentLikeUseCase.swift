//
//  UpdateCommentLikeUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//



import Foundation

public protocol UpdateCommentLikeUseCaseProtocol {
    func execute(_ commentId: String) async throws -> Bool
}


public final class UpdateCommentLikeUseCase: UpdateCommentLikeUseCaseProtocol {
    
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(_ commentId: String) async throws -> Bool {
        try await communityRepository.updateCommentLike(commentId)
    }
    
}
