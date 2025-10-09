//
//  FetchCommentRequestQuery.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/24/25.
//


import Foundation

public struct FetchCommentRequestQuery {
    public let postId: String
    
    public init(postId: String) {
        self.postId = postId
    }
}
