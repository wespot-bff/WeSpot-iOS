//
//  FetchReportReasonItemUseCase.swift
//  CommunityDomain
//
//  Created by 김도현 on 9/3/25.
//

import Foundation

public protocol FetchReportReasonItemUseCaseProtocol {
    func execute() async throws -> [ReportReason]
}

public final class FetchReportReasonItemUseCase: FetchReportReasonItemUseCaseProtocol {
    private let communityRepository: CommunityRepositoryProtocol
    
    
    public init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
    
    public func execute() async throws -> [ReportReason] {
        try await communityRepository.fetchReportItem()
    }
    
}


