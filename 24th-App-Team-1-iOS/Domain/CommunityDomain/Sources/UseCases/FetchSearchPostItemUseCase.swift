//
//  FetchSearchPostItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/3/25.
//


public protocol FetchSearchPostItemUseCaseProtocol {
    func execute(query: FetchPostSearchKeywordQuery) async throws -> PostListEntity
}

public final class FetchSearchPostItemUseCase: FetchSearchPostItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(query: FetchPostSearchKeywordQuery) async throws -> PostListEntity {
        try await communityRepository.fetchSearchPostItems(query: query)
    }
}
