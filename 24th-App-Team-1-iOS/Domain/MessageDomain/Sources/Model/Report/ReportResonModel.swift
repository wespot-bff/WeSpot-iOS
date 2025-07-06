//
//  ReportResonModel.swift
//  MessageDomain
//
//  Created by 최지철 on 1/24/25.
//

import Foundation

public enum ReportResonTypeModel {
    case dataLeak   // 유출/사기
    case identityTheft  //  음란물
    case fraudAttempt   //. 욕설/비하
    case ad             // 불법광고
    case input          // 직접입력
    
    public var title: String {
        switch self {
        case .dataLeak:
            return "유출/사칭/사기"
        case .identityTheft:
            return "음란물/불건전한 만남 및 대화"
        case .fraudAttempt:
            return "욕설/비하"
        case .ad:
            return "상업적 광고 및 판매"
        case .input:
            return "직접 입력"
        }
    }
}
