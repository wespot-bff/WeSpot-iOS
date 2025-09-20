//
//  FilterChips.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/26/25.
//

import Foundation
import CommunityDomain
import SwiftUI


public struct FilterChipResponseDTO: Decodable {
    let type: String //  Type
    let content: FilterChipContentResponseDTO
}


public struct FilterChipContentResponseDTO: Identifiable, Decodable {
    public let id: Int
    public let icon: FilterChipIconItemResponseDTO
    public let text: FilterChipTextItemResponseDTO
    public let target: String
    
}

public struct FilterChipIconItemResponseDTO: Decodable {
    public let imageUrl: String
    public let foregroundColor: FilterChipColorItemResponseDTO
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "url"
        case foregroundColor = "color"
    }
}

public struct FilterChipTextItemResponseDTO: Decodable {
    public let text: String
    public let color: FilterChipColorItemResponseDTO
    public let typography: String
    
}

public struct FilterChipColorItemResponseDTO: Decodable {
    public let value: String
    public let type: String
    
    
    enum CodingKeys: CodingKey {
        case value
        case type
    }
}




extension FilterChipContentResponseDTO {
    func toDomain() -> FilterChipEntity {
        FilterChipEntity(
            id: id,
            iconURL: URL(string: icon.imageUrl),
            iconHexColor: icon.foregroundColor.value,
            text: text.text,
            textHexColor: text.color.value,
            typography: text.typography
        )
    }
}

extension FilterChipResponseDTO {
    func toDomain() -> FilterChipEntity {
        content.toDomain()
    }
}
