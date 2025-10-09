//
//  UpdatePostBlockUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//


import Foundation

public protocol UpdatePostBlockUseCaseProtocol {
    func execute(postId: String) async throws -> Bool
}


public final class UpdatePostBlockUseCase: UpdatePostBlockUseCaseProtocol {
    
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(postId: String) async throws -> Bool {
        try await communityRepository.updatePostBlock(postId)
    }
    
}
