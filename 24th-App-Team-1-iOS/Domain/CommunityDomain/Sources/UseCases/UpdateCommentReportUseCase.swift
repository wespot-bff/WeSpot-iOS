//
//  UpdateCommentReportUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//


import Foundation

public protocol UpdateCommentReportUseCaseProtocol {
    func execute(_ commentId: String, body: ReportReasonRequest) async throws -> Bool
}


public final class UpdateCommentReportUseCase: UpdateCommentReportUseCaseProtocol {

    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    
    public func execute(_ commentId: String, body: ReportReasonRequest) async throws -> Bool {
        try await communityRepository.updateCommentReport(commentId, body: body)
    }
    
}
