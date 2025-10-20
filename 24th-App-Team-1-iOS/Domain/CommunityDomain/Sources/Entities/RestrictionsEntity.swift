//
//  RestrictionsEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 10/20/25.
//

import Foundation

public struct RestrictionsEntity: Equatable {
    public let restrictionType: RestrictionType
    public let releaseDate: String?
    
    public init(restrictionType: RestrictionType, releaseDate: String?) {
        self.restrictionType = restrictionType
        self.releaseDate = releaseDate
    }
    
    public enum RestrictionType: String, Decodable {
        case none = "NONE"
        case voteReport = "PERMANENT_BAN_VOTE_REPORT"
        case messageTemporaryReport = "TEMPORARY_BAN_MESSAGE_REPORT"
        case messagePermanentReport = "PERMANENT_BAN_MESSAGE_REPORT"
        case communityTemporaryReport = "TEMPORARY_BAN_COMMUNITY_REPORT"
        case communityPermanentReport = "PERMANENT_BAN_COMMUNITY_REPORT"
    }
    
    public var isRestricted: Bool {
        restrictionType != .none
    }
    
    public var restrictionTitle: String {
        "서비스 이용 제한 안내"
    }
    
    public var restrictionMessage: String {
        switch restrictionType {
        default:
            return ""
        }
    }
    
    public var restrictionDetails: [String] {
        switch restrictionType {
        case .none:
            return []
        case .voteReport, .messageTemporaryReport, .communityTemporaryReport:
            // Frame 1, 2 - 임시 제한
            let dateString = releaseDate ?? "20YY.년 M월 DD일"
            return [
                "• 자동 신고 처리 시스템에 의한 신고 누적으로 서비스 일부의 이용이 제한되었습니다",
                "• [이용 제한 기간]\n   \(dateString)까지",
                "• 이용 제한은 기간이 종료된 다음 날 오전에 해제됩니다",
                "• 신고 누적 시 자동 영구정지로 이용 정지될 수 있습니다"
            ]
        case .messagePermanentReport, .communityPermanentReport:
            // Frame 3 - 영구 제한
            return [
                "• 자동 신고 처리 시스템에 의한 신고 누적으로 서비스 일부의 이용이 제한되었습니다",
                "• [이용 제한 사유]\n   우리 커뮤니티 운영 원칙 위반",
                "• 이용 제한 '1:1 문의하기'로 계정정보 변경 신청을 하면 일단 어드민이 없으니 수동으로 이용 제한 해제해줄 거임!!!"
            ]
        }
    }
    
    public var showInquiryButton: Bool {
        switch restrictionType {
        case .messagePermanentReport, .communityPermanentReport:
            return true
        default:
            return false
        }
    }
    
    public var confirmButtonText: String {
        switch restrictionType {
        case .messagePermanentReport, .communityPermanentReport:
            return "닫기"
        default:
            return "확인"
        }
    }
}
