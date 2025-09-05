//
//  DeletePostItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/28/25.
//


import Foundation

public protocol DeletePostItemUseCaseProtocol {
    func execute(postId: Int) async throws -> Bool
}

public final class DeletePostItemUseCase: DeletePostItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(postId: Int) async throws -> Bool {
        try await communityRepository.deletePostItem(postId)
    }
}
