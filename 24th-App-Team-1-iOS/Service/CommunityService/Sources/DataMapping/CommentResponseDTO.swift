//
//  CommentResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 8/24/25.
//

import Foundation
import CommunityDomain

public struct CommentDTO: Decodable {
    public let id: Int
    public let isMe: Bool
    public let authorImage: String
    public let authorName: String
    public let content: String
    public let likeCount: Int
    public let hasPushedLike: Bool
    public let isReported: Bool
    public let createdAt: String
}

extension CommentDTO {
    func toDomain() -> CommentEntity {
        return CommentEntity(
            id: id,
            isMine: isMe,
            profileImageURL: URL(string: authorImage),
            nickname: authorName,
            content: content,
            likeCount: likeCount,
            isLiked: hasPushedLike,
            isReported: isReported,
            createdAt: createdAt
        )
    }
}

