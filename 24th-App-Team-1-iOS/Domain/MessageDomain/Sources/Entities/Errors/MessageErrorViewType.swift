//
//  MessageErrorViewType.swift
//  MessageDomain
//
//  Created by 최지철 on 10/12/25.
//

import Foundation

public enum MessageErrorViewType {
    case toast
    case alert
    case none // UI 표시가 필요 없는 경우
    case unknown // 정의되지 않은 타입
}
