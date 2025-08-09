//
//  CreatePostImagePresignedURLQuery.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//

import Foundation


public struct CreatePostImagePresignedURLQuery {
    public let imageExtension: String
    
    public init(imageExtension: String) {
        self.imageExtension = imageExtension
    }
}
