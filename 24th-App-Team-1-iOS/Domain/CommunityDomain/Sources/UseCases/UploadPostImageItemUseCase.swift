//
//  UploadPostImageItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//


import Foundation

public protocol UploadPostImageItemUseCaseProtocol {
    func execute(_ image: Data, presigendURL: String) async throws -> Bool
}

public final class UploadPostImageItemUseCase: UploadPostImageItemUseCaseProtocol {
    
    private let communityRepository: CommunityRepositoryProtocol
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(_ image: Data, presigendURL: String) async throws -> Bool {
        try await communityRepository.uploadPostImages(image, presingedURL: presigendURL)
    }
    
}
