//
//  FetchReportResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 9/3/25.
//

import Foundation
import CommunityDomain


struct FetchReportResponseDTO: Codable {
    let id: Int
    let reason: String
    let isReasonEditable: Bool
}



extension FetchReportResponseDTO {
    func toDomain() -> ReportReason {
        return .init(id: id, title: reason, isEditable: isReasonEditable)
    }
}
