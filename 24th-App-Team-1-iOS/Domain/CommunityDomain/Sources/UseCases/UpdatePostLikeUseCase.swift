//
//  UpdatePostLikeUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/1/25.
//



public protocol UpdatePostLikeUseCaseProtocol {
    func execute(postId: Int) async throws -> Bool
}


public final class UpdatePostLikeUseCase: UpdatePostLikeUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(postId: Int) async throws -> Bool {
        try await communityRepository.updatePostLike(postId)
    }
}
