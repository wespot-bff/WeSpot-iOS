//
//  FetchMyPostWrittenItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/7/25.
//

import Foundation

public protocol FetchMyPostWrittenItemUseCaseProtocol {
    func execute() async throws -> PostListEntity
}

public final class FetchMyPostWrittenItemUseCase: FetchMyPostWrittenItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute() async throws -> PostListEntity {
        try await communityRepository.fetchMyPostWrittenItem()
    }
}
