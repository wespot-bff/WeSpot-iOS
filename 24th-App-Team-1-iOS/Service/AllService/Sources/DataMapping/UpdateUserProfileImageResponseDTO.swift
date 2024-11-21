//
//  UpdateUserProfileImageResponseDTO.swift
//  AllService
//
//  Created by 김도현 on 11/12/24.
//

import Foundation

import AllDomain

public struct UpdateUserProfileImageResponseDTO: Decodable {
    public let id: Int
    public let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "url"
    }
}


extension UpdateUserProfileImageResponseDTO {
    public func toDomain() -> UpdateUserProfileImageEntity {
        return .init(id: id, url: imageURL)
    }
}
