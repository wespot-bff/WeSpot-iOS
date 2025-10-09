//
//  FetchCommentItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//

import Foundation


public protocol FetchCommentItemUseCaseProtocol {
    func execute(_ query: FetchCommentRequestQuery) async throws -> [CommentEntity]
}


public final class FetchCommentItemUseCase: FetchCommentItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(_ query: FetchCommentRequestQuery) async throws -> [CommentEntity] {
        try await communityRepository.fetchCommentItem(query)
    }
}
