//
//  AnonymousProfileListDTO.swift
//  MessageService
//
//  Created by 최지철 on 5/25/25.
//

import Foundation
import MessageDomain

struct AnonymousProfileListDTO: Decodable {
    let id: Int
    let name: String
    let image: String
    let recentlyTalk: String?
    let myTurnToAnswer: Bool
    let isAnonymous: Bool
}
extension AnonymousProfileListDTO {
    func toDomain() -> AnonymousProfileEntity {
        return AnonymousProfileEntity(id: id,
                                      name: name,
                                      image: image,
                                      recentlyTalk: recentlyTalk,
                                      myTurnToAnswer: myTurnToAnswer,
                                      isAnonymous: isAnonymous)
    }
}
