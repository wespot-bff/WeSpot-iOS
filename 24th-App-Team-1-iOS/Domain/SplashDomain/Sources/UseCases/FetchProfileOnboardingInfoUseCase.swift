//
//  FetchProfileOnboardingInfoUseCase.swift
//  SplashDomain
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

import CommonDomain

public protocol FetchProfileOnboardingInfoUseCaseProtocol {
    func execute(query: ProfileOnboardingQuery) async throws -> ProfileOnboardingEntity
}


public final class FetchProfileOnboardingInfoUseCase: FetchProfileOnboardingInfoUseCaseProtocol {
            
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    
    public func execute(query: CommonDomain.ProfileOnboardingQuery) async throws -> CommonDomain.ProfileOnboardingEntity {
        return try await commonRepository.fetchProfileOnbardingItem(query: query)
    }
    
    
}
