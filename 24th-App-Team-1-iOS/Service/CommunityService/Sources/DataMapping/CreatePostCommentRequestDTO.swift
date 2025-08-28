//
//  CreatePostCommentRequestDTO.swift
//  CommunityService
//
//  Created by 김도현 on 8/24/25.
//


import Foundation


public struct CreatePostCommentRequestDTO: Encodable {
    public let postId: String
    public let content: String
}
