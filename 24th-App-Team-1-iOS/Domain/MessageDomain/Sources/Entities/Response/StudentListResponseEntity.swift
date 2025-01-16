//
//  StudentListResponseEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 12/26/24.
//

import Foundation

public struct StudentListResponseEntity {
    public var users: [UserEntity]
    public var hasNext: Bool
    public var lastCursorId: Int

    public init(users: [UserEntity],
                hasNext: Bool,
                lastCursorId: Int) {
        self.users = users
        self.hasNext = hasNext
        self.lastCursorId = lastCursorId
    }
}

extension StudentListResponseEntity {
    public struct UserEntity {
        public let id: Int
        public let name: String
        public let gender: String
        public let introduction: String
        public let schoolName: String
        public let grade: Int
        public let classNumber: Int
        public let profile: UserProfileEntity
        public var totalInfo: String
        
        public init(id: Int,
                    name: String,
                    gender: String,
                    introduction: String,
                    schoolName: String,
                    grade: Int,
                    classNumber: Int,
                    profile: UserProfileEntity
                    ,totalInfo: String = "") {
            self.id = id
            self.name = name
            self.gender = gender
            self.introduction = introduction
            self.schoolName = schoolName
            self.grade = grade
            self.classNumber = classNumber
            self.profile = profile
            self.totalInfo = totalInfo
        }
    }
}

extension StudentListResponseEntity.UserEntity {
    public struct UserProfileEntity {
        public let backgroundColor: String
        public let iconUrl: String

        public init(backgroundColor: String,
                    iconUrl: String) {
            self.backgroundColor = backgroundColor
            self.iconUrl = iconUrl
        }
    }
}
