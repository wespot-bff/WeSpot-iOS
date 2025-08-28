//
//  CreatePostCommentRequest.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//

import Foundation

public struct CreatePostCommentRequest {
    public let postId: String
    public let content: String
    
    public init(postId: String, content: String) {
        self.postId = postId
        self.content = content
    }
}
