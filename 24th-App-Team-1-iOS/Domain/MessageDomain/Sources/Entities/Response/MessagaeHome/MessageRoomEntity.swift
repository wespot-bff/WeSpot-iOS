//
//  MessageRoomEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 6/7/25.
//

import Foundation
import RxDataSources


public struct MessageRoomEntity {
    public let id: Int
    public let senderProfile: ProfileEntity
    public let isMeMessageRoomOwner: Bool
    public let isExistsUnreadMessage: Bool
    public let latestChatTime: String
    public let receiverProfile: ProfileEntity
    public var isBookmarked: Bool
    public let isBlocked: Bool
    public let isEver: Bool

    public init(
        id: Int,
        senderProfile: ProfileEntity,
        isMeMessageRoomOwner: Bool,
        isExistsUnreadMessage: Bool,
        latestChatTime: String,
        receiverProfile: ProfileEntity,
        isBookmarked: Bool,
        isBlocked: Bool,
        isEver: Bool
    ) {
        self.id = id
        self.senderProfile = senderProfile
        self.isMeMessageRoomOwner = isMeMessageRoomOwner
        self.isExistsUnreadMessage = isExistsUnreadMessage
        self.latestChatTime = latestChatTime
        self.receiverProfile = receiverProfile
        self.isBookmarked = isBookmarked
        self.isBlocked = isBlocked
        self.isEver = isEver
    }
}
extension MessageRoomEntity {
    public struct ProfileEntity: Equatable {
        public let isAnonymous: Bool
        public let iconUrl: String
        public let name: String
        public let schoolName: String
        public let grade: Int?
        public let classNumber: Int

        public init(
            isAnonymous: Bool,
            iconUrl: String,
            name: String,
            schoolName: String,
            grade: Int,
            classNumber: Int
        ) {
            self.isAnonymous = isAnonymous
            self.iconUrl = iconUrl
            self.name = name
            self.schoolName = schoolName
            self.grade = grade
            self.classNumber = classNumber
        }
    }
}


extension MessageRoomEntity: IdentifiableType, Equatable {
    // IdentifiableType
    public typealias Identity = Int
    public var identity: Identity { id }

    // Equatable
    public static func == (lhs: MessageRoomEntity, rhs: MessageRoomEntity) -> Bool {
        // RxDataSources가 "내용"이 바뀌었는지 감지하기 위해 비교합니다.
        // UI에 영향을 주는 모든 값을 비교해야 합니다.
        return lhs.id == rhs.id &&
               lhs.isBookmarked == rhs.isBookmarked &&
               lhs.isExistsUnreadMessage == rhs.isExistsUnreadMessage &&
               lhs.latestChatTime == rhs.latestChatTime &&
               lhs.senderProfile == rhs.senderProfile &&
               lhs.receiverProfile == rhs.receiverProfile
    }
}
