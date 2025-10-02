//
//  FetchCategoryItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/26/25.
//

import Foundation


public protocol FetchCategoryItemUseCaseProtocol {
    func execute() async throws -> [FilterChipEntity]
}


public final class FetchCategoryItemUseCase: FetchCategoryItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute() async throws -> [FilterChipEntity] {
        try await communityRepository.fetchCategoryItems()
    }
    
}
