//
//  CreatePostImagePresignedURLResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/29/25.
//


import Foundation

import CommunityDomain


public struct CreatePostImagePresignedURLResponseDTO: Decodable {
    public let presignedURL: String
    public let imageName: String
    
    private enum CodingKeys: String, CodingKey {
        case presignedURL = "url"
        case imageName = "imageName"
    }
}

extension CreatePostImagePresignedURLResponseDTO {
    public func toDomain() -> CreatePostImagePresignedURLEntity {
        return .init(
            presignedURL: presignedURL,
            imageName: imageName
        )
    }
    
}

