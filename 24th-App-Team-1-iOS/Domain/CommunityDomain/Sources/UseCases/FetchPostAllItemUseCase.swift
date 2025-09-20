//
//  FetchPostAllItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/31/25.
//



import Foundation

public protocol FetchPostAllItemUseCaseProtocol {
    func execute(query: FetchPostAllItemRequestQuery) async throws -> PostListEntity
}

public final class FetchPostAllItemUseCase: FetchPostAllItemUseCaseProtocol {
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    public func execute(query: FetchPostAllItemRequestQuery) async throws -> PostListEntity {
        try await communityRepository.fetchPostAllItems(query: query)
    }
}
