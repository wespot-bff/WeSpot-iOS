//
//  CreatePostCommentUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//


import Foundation


public protocol CreatePostCommentUseCaseProtocol {
    func execute(body: CreatePostCommentRequest) async throws -> Bool
}


public final class CreatePostCommentUseCase: CreatePostCommentUseCaseProtocol {
    
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(body: CreatePostCommentRequest) async throws -> Bool {
        try await communityRepository.createPostComment(body)
    }
}
