//  MessageRoomDTO.swift
//  MessageService
//
//  Created by 최지철 on 5/26/25.
//

import Foundation
import MessageDomain 

public struct MessageRoomDTO: Decodable {
    public let id: Int
    public let senderProfile: ProfileDTO
    public let isMeMessageRoomOwner: Bool
    public let isExistsUnreadMessage: Bool
    public let latestChatTime: String
    public let receiverProfile: ProfileDTO
    public let isBookmarked: Bool
    public let isBlocked: Bool
    public let isEver: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case senderProfile
        case isMeMessageRoomOwner
        case isExistsUnreadMessage
        case latestChatTime
        case receiverProfile
        case isBookmarked
        case isBlocked
        case isEver
    }

    public struct ProfileDTO: Decodable {
        public let isAnonymous: Bool
        public let iconUrl: String
        public let name: String
        public let schoolName: String?
        public let grade: Int?
        public let classNumber: Int?

        enum CodingKeys: String, CodingKey {
            case isAnonymous
            case iconUrl
            case name
            case schoolName
            case grade
            case classNumber
        }
    }
}

// MARK: - Mapping to Domain

extension MessageRoomDTO.ProfileDTO {
    public func toDomain() -> MessageRoomEntity.ProfileEntity {
        return MessageRoomEntity.ProfileEntity(
            isAnonymous: isAnonymous,
            iconUrl:    iconUrl,
            name:       name,
            schoolName: schoolName ?? "",
            grade:      grade ?? 1,
            classNumber: classNumber ?? 1
        )
    }
}

extension MessageRoomDTO {
    /// MessageRoomDTO → MessageRoomEntity 매핑
    public func toDomain() -> MessageRoomEntity {
        return MessageRoomEntity(id: id,
                                 senderProfile: senderProfile.toDomain(),
                                 isMeMessageRoomOwner: isMeMessageRoomOwner,
                                 isExistsUnreadMessage: isExistsUnreadMessage,
                                 latestChatTime: latestChatTime,
                                 receiverProfile: receiverProfile.toDomain(),
                                 isBookmarked: isBookmarked,
                                 isBlocked: isBlocked,
                                 isEver: isEver)
    }
}
