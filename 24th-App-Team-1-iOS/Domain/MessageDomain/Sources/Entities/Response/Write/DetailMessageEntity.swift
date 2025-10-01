//
//  DetailMessageEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 6/26/25.
//

import Foundation
 


// MARK: - MessageDetailEntity
/// 개별 메시지를 나타내는 모델

// MARK: - Message Direction Enum
/// 메시지가 보내는 것인지 받는 것인지 명확히 하기 위한 열거형
public enum MessageDirection {
    case sent
    case received
}
