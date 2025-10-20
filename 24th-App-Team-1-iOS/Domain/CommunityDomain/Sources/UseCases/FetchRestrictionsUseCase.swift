//
//  FetchRestrictionsUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 10/20/25.
//



public protocol FetchRestrictionsUseCaseProtocol {
    func execute() async throws -> RestrictionsEntity
}


public final class FetchRestrictionsUseCase: FetchRestrictionsUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute() async throws -> RestrictionsEntity {
        return try await communityRepository.fetchRestrictionsItems()
    }
}
