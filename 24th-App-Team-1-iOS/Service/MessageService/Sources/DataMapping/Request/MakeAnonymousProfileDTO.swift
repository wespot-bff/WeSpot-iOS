//
//  MakeAnonymousProfileDTO.swift
//  MessageService
//
//  Created by 최지철 on 6/17/25.
//

import Foundation

struct MakeAnonymousProfileDTO: Encodable {
    let imageUrl: String
    let name: String
    let receiverId: Int
}
