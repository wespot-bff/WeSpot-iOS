//
//  NotificationPayload.swift
//  Util
//
//  Created by 김도현 on 12/8/24.
//

import Foundation

public enum NotificationCategory: String, Decodable {
    case voteMain = "VOTE"
    case voteResult = "VOTE_RESULT"
    case voteRecevied = "VOTE_RECEIVED"
    case messageReceived = "MESSAGE_RECEIVED"
    case messageSent = "MESSAGE_SENT"
    case profile = "PROFILE_UPDATE"
}


public struct NotificationPayload: Decodable {
    public let aps: NotificationAPS
    public let userId: String?
    public let targetId: String?
    public let date: String
    public let type: NotificationCategory
    
    public init?(dictionary: [AnyHashable: Any]) {
        do {
            self = try JSONDecoder().decode(NotificationPayload.self, from: JSONSerialization.data(withJSONObject: dictionary))
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

public struct NotificationAPS: Decodable {
    public let alert: NotificationAlert
}

public struct NotificationAlert: Decodable {
    public let title: String
    public let body: String
}
