//
//  GetMessageRequestDTO.swift
//  MessageService
//
//  Created by 최지철 on 1/13/25.
//

import Foundation

struct GetMessageRequestDTO: Encodable {
    let cursorId: Int
    let type: String
}
