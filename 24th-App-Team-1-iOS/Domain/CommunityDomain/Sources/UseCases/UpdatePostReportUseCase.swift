//
//  UpdatePostReportUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//



public protocol UpdatePostReportUseCaseProtocol {
    func execute(_ postId: String) async throws -> Bool
}


public final class UpdatePostReportUseCase: UpdatePostReportUseCaseProtocol {
    
    
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute(_ postId: String) async throws -> Bool {
        try await communityRepository.updatePostReport(postId)
    }
    
}
