//
//  UploadPostItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/28/25.
//

import Foundation

public protocol UploadPostItemUseCaseProtocol {
    func execute(body: UploadPostItemRequest) async throws -> Bool
}

public final class UploadPostItemUseCase: UploadPostItemUseCaseProtocol {
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(body: UploadPostItemRequest) async throws -> Bool {
        try await communityRepository.uploadPostItem(body: body)
    }
}
