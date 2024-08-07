//
//  VoteSentEntity.swift
//  VoteDomain
//
//  Created by Kim dohyun on 8/7/24.
//

import Foundation

public struct VoteSentEntity {
    public let response: [VoteSentItemEntity]
    
    public init(response: [VoteSentItemEntity]) {
        self.response = response
    }
}


public struct VoteSentItemEntity {
    public let date: String
    public let sentResponse: [VoteSentResponseEntity]
    
    public init(
        date: String,
        sentResponse: [VoteSentResponseEntity]
    ) {
        self.date = date
        self.sentResponse = sentResponse
    }
}


public struct VoteSentResponseEntity {
    public let voteContent: VoteSentContentResponseEntity
    public let voteUser: VoteSentUserResponseEntity
    
    public init(
        voteContent: VoteSentContentResponseEntity,
        voteUser: VoteSentUserResponseEntity
    ) {
        self.voteContent = voteContent
        self.voteUser = voteUser
    }
}


public struct VoteSentContentResponseEntity {
    public let voteOption: VoteSentContentItemResponseEntity
    
    public init(voteOption: VoteSentContentItemResponseEntity) {
        self.voteOption = voteOption
    }
}

public struct VoteSentContentItemResponseEntity: Identifiable {
    public let id: Int
    public let content: String
    
    public init(id: Int, content: String) {
        self.id = id
        self.content = content
    }
}

public struct VoteSentUserResponseEntity: Identifiable {
    public let id: Int
    public let name: String
    public let introduction: String
    public let profile: VoteSentProfileResponseEntity
    
    public init(
        id: Int,
        name: String,
        introduction: String,
        profile: VoteSentProfileResponseEntity
    ) {
        self.id = id
        self.name = name
        self.introduction = introduction
        self.profile = profile
    }
}

public struct VoteSentProfileResponseEntity {
    public let backgroundColor: String
    public let iconUrl: URL
    
    public init(backgroundColor: String, iconUrl: URL) {
        self.backgroundColor = backgroundColor
        self.iconUrl = iconUrl
    }
}
