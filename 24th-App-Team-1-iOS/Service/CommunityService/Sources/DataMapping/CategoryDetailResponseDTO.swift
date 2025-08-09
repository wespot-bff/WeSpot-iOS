//
//  CategoryDetailResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/27/25.
//

import Foundation
import CommunityDomain

public struct CategoryDetailResponseDTO: Decodable {
    public let category: String
    public let chips: [CategoryChipsContentResponseDTO]
}

public struct CategoryChipsContentResponseDTO: Identifiable, Decodable {
    public let id: Int
    public let text: String
}


extension CategoryDetailResponseDTO {
    func toDomain() -> CategoryDetailEntity {
        return .init(title: category, chips: chips.map { $0.toDomain()})
    }
}

extension CategoryChipsContentResponseDTO {
    func toDomain() -> CategoryChipsEntity {
        return .init(id: id, text: text)
    }
}
