//
//  FetchRestrictionsUseCase.swift
//  CommonDomain
//
//  Created by 김도현 on 10/20/25.
//


import Foundation


public protocol FetchRestrictionsUseCaseProtocol {
    func execute() async throws -> RestrictionsEntity
}


public final class FetchRestrictionsUseCase: FetchRestrictionsUseCaseProtocol {
    
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute() async throws -> RestrictionsEntity {
        return try await commonRepository.fetchRestrictionsItems()
    }
}
