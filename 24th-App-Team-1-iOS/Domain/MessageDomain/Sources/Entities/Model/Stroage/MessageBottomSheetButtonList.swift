//
//  MessageBottomSheetButtonList.swift
//  MessageDomain
//
//  Created by 최지철 on 1/16/25.
//

import Foundation

public enum MessageBottomSheetButtonList {
    case block
    case delete
    case report
    
    public var titleText: String {
        switch self {
        case .block:
            return "차단하기"
        case .delete:
            return "삭제하기"
        case .report:
            return "신고하기"
        }
    }
}
