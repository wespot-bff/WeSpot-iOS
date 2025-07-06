//
//  MessageBottomSheetButtonList.swift
//  MessageDomain
//
//  Created by 최지철 on 1/16/25.
//

import Foundation

public enum MessageBottomSheetButtonList {
    case block
    case unFavorite
    case favorite
    
    public var titleText: String {
        switch self {
        case .block:
            return "차단하기"
        case .unFavorite:
            return "즐겨찾기 해체하기"
        case .favorite:
            return "즐겨찾기"
        }
    }
}
