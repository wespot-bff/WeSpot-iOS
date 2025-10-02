//
//  FetchPostItemListUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//


import Foundation

public protocol FetchPostItemListUseCaseProtocol {
    func execute(query: FetchPostDetailItemRequestQuery)  async throws -> PostListEntity
}


public final  class FetchPostItemListUseCase: FetchPostItemListUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(query: FetchPostDetailItemRequestQuery) async throws -> PostListEntity {
        try await communityRepository.fetchPostDetailItems(query: query)
    }
}
