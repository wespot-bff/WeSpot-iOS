//
//  FetchCategoryDetailItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/27/25.
//


import Foundation

public protocol FetchCategoryDetailItemUseCaseProtocol {
    func execute() async throws -> [CategoryDetailEntity]
}

public final class FetchCategoryDetailItemUseCase: FetchCategoryDetailItemUseCaseProtocol {

    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute() async throws -> [CategoryDetailEntity] {
        try await communityRepository.fetchCategoryDetailImtes()
    }
    
    
    
}
