//
//  UpdateCommentNotificationUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/22/25.
//


import Foundation

public protocol UpdateCommentNotificationUseCaseProtocol {
    func execute(postId: String) async throws -> Bool
}


public final class UpdateCommentNotificationUseCase: UpdateCommentNotificationUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(postId: String) async throws -> Bool {
        try await communityRepository.updateCommentNotification(postId)
    }
}
