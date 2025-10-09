//
//  CreateReportReasonRequestDTO.swift
//  CommunityService
//
//  Created by 김도현 on 9/3/25.
//

import Foundation

public struct CreateReportReasonRequestDTO: Encodable {
    public let reportReasonRequests: [CreateReportReasonRequesItemtDTO]
    
    public init(reportReasonRequests: [CreateReportReasonRequesItemtDTO]) {
        self.reportReasonRequests = reportReasonRequests
    }
}

public struct CreateReportReasonRequesItemtDTO: Encodable {
    public let reportReasonId: Int
    public let customReason: String?
    
    public init(reportReasonId: Int, customReason: String?) {
        self.reportReasonId = reportReasonId
        self.customReason = customReason
    }
}
