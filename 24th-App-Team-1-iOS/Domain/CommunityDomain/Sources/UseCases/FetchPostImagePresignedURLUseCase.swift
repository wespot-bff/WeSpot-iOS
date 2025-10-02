//
//  FetchPostImagePresignedURLUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//

import Foundation

public protocol FetchPostImagePresignedURLUseCaseProtocol {
    func execute(query: CreatePostImagePresignedURLQuery) async throws -> CreatePostImagePresignedURLEntity
}


public final class FetchPostImagePresignedURLUseCase: FetchPostImagePresignedURLUseCaseProtocol {
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(query: CreatePostImagePresignedURLQuery) async throws -> CreatePostImagePresignedURLEntity {
        try await communityRepository.fetchPostImagePresignedURL(query: query)
    }
}
