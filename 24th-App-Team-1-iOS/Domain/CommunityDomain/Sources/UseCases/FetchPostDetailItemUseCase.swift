//
//  FetchPostDetailItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/18/25.
//


import Foundation

public protocol FetchPostDetailItemUseCaseProtocol {
    func execute(postId: String) async throws -> PostItem
}


public final class FetchPostDetailItemUseCase: FetchPostDetailItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(postId: String) async throws -> PostItem {
        try await communityRepository.fetchFeedDetailItem(postId: postId)
    }
}
