//
//  ReportMessageRequestDTO.swift
//  MessageService
//
//  Created by 최지철 on 1/21/25.
//

import Foundation

struct ReportMessageRequestDTO: Encodable {
    let targetId: Int
    let content: String
    let reportType: String
}
