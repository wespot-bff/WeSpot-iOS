//
//  ReportMessageRequest.swift
//  MessageDomain
//
//  Created by 최지철 on 1/21/25.
//

import Foundation


public struct ReportMessageRequest {
    public let targetId: Int
    public let content: String
    public let reportType: String
}
