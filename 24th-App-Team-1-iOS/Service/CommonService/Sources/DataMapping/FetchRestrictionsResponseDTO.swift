//
//  FetchRestrictionsResponseDTO.swift
//  CommonService
//
//  Created by 김도현 on 10/20/25.
//


import Foundation

import CommonDomain

struct FetchRestrictionsResponseDTO: Decodable {
    
    public let restrictionType: String
    public let releaseDate: String
}

extension FetchRestrictionsResponseDTO {
    func toDomain() -> RestrictionsEntity {
        return .init(
            restrictionType: RestrictionsEntity.RestrictionType(rawValue: restrictionType) ?? .none,
            releaseDate: releaseDate
        )
    }
}
