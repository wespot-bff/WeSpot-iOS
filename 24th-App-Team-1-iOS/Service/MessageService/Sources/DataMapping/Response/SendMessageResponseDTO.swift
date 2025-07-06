//
//  SendMessageResponseDTO.swift
//  MessageService
//
//  Created by 최지철 on 1/6/25.
//

import MessageDomain

struct SendMessageResponseDTO: Decodable {
    let id: Int
}
extension SendMessageResponseDTO {
    func toDomain() -> SendMessageResponseEntity {
        return .init(id: id)
    }
}
