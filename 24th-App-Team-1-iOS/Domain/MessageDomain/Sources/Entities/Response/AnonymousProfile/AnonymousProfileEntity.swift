//
//  AnonymousProfileEntity.swift
//  MessageDomain
//
//  Created by 최지철 on 4/14/25.
//

import Foundation

public struct AnonymousProfileEntity {
    public let id: Int
    public let name: String
    public let image: String
    public let recentlyTalk: String?
    public let myTurnToAnswer: Bool
    public let isAnonymous: Bool

    public init(
        id: Int,
        name: String,
        image: String,
        recentlyTalk: String?,
        myTurnToAnswer: Bool,
        isAnonymous: Bool
    ) {
        self.id              = id
        self.name            = name
        self.image           = image
        self.recentlyTalk    = recentlyTalk
        self.myTurnToAnswer  = myTurnToAnswer
        self.isAnonymous      = isAnonymous
    }
}
