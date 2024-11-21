//
//  CreateProfilePresignedURLResponseDTO.swift
//  CommonService
//
//  Created by 김도현 on 11/12/24.
//

import Foundation

import CommonDomain


public struct CreateProfilePresignedURLResponseDTO: Decodable {
    public let presignedURL: String
    public let imageURL: String
    
    private enum CodingKeys: String, CodingKey {
        case presignedURL = "url"
        case imageURL = "imageUrl"
    }
}

extension CreateProfilePresignedURLResponseDTO {
    public func toDomain() -> CreateProfilePresignedURLEntity {
        return .init(
            presignedURL: presignedURL,
            imageURL: imageURL
        )
    }
    
}
