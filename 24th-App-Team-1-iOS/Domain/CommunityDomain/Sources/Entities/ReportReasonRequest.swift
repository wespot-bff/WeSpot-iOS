//
//  ReportReasonRequest.swift
//  CommunityDomain
//
//  Created by 김도현 on 9/3/25.
//


public struct ReportReasonRequest {
    public let reportReasonRequests: [ReportReasonRequestItem]
    
    public init(reportReasonRequests: [ReportReasonRequestItem]) {
        self.reportReasonRequests = reportReasonRequests
    }
}

public struct ReportReasonRequestItem {
    public let reportReasonId: Int
    public let customReason: String?
    
    public init(reportReasonId: Int, customReason: String? = nil ) {
        self.reportReasonId = reportReasonId
        self.customReason = customReason
    }
}
