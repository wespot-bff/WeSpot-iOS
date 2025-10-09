//
//  CreatePostImagePresignedURLEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//

import Foundation

public struct CreatePostImagePresignedURLEntity: Equatable {
    public let presignedURL: String
    public let imageName: String
    
    public init(presignedURL: String, imageName: String) {
        self.presignedURL = presignedURL
        self.imageName = imageName
    }
}
