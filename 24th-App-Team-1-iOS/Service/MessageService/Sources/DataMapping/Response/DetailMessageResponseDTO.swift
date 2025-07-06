//
//  DetailMessageResponseDTO.swift
//  MessageService
//
//  Created by 최지철 on 6/26/25.
//

import Foundation

import MessageDomain

struct DetailMessageResponseDTO: Decodable {
    let isReceiverAnonymous: Bool
    let thumbnail: String
    let name: String
    let messageRoomId: Int
    let isBookmarked: Bool
    let messageDetails: [MessageDetailDTO]
}
extension DetailMessageResponseDTO {
    struct MessageDetailDTO: Decodable {
        let id: Int
        let createdAt: String
        let content: String
        let isReceived: Bool
        let isSend: Bool
        let isRead: Bool
        let isAbleToAnswer: Bool
    }

    
    func toDomain() -> MessageRoomDetailEntity {
        // 날짜 문자열을 Date 객체로 변환하기 위한 Formatter
        
        return .init(
            isReceiverAnonymous: self.isReceiverAnonymous,
            thumbnailURL: URL(string: self.thumbnail), // 문자열을 URL 타입으로 변환
            name: self.name,
            roomId: self.messageRoomId,
            isBookmarked: self.isBookmarked,
            messages: self.messageDetails.map { detailDTO in
                // isReceived, isSend Bool 값에 따라 메시지 방향 결정
                let direction: MessageDirectionEnum = detailDTO.isReceived ? .received : .sent
                
                return MessageDetailEntity(
                    id: detailDTO.id,
                    createdAt: detailDTO.createdAt,
                    content: detailDTO.content,
                    direction: direction,
                    isRead: detailDTO.isRead,
                    isAbleToAnswer: detailDTO.isAbleToAnswer
                )
            }
        )
    }
}
