//
//  AnonymousProfileStatusEnum.swift
//  MessageDomain
//
//  Created by 최지철 on 4/15/25.
//

import Foundation

public enum AnonymousProfileStatusEnum {
    case oneOrNone
    case two
    case third
    case full
    
    public var totalHeight: CGFloat {
        switch self {
        case .oneOrNone:
            return 269
        case .two:
            return 331
        case .full, .third:
            return 393
        }
    }
    
    public var profileTableViewHeight: CGFloat {
        switch self {
        case .oneOrNone:
            return 34
        case .two:
            return 92
        case .third:
            return 158
        case .full:
            return 208
        }
    }
}
