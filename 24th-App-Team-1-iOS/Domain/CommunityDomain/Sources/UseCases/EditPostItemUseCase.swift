//
//  EditPostItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/28/25.
//

import Foundation

public protocol EditPostItemUseCaseProtocol {
    func execute(postId: Int, body: UploadPostItemRequest) async throws -> Bool
}


public final class EditPostItemUseCase: EditPostItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(postId: Int, body: UploadPostItemRequest) async throws -> Bool {
        try await communityRepository.editPostItem(postId, body: body)
    }
}
