//
//  UpdateUserProfileRequestDTO.swift
//  AllService
//
//  Created by Kim dohyun on 8/13/24.
//

import Foundation


public struct UpdateUserProfileRequestDTO: Encodable {
    public let introduction: String
    
    public init(introduction: String) {
        self.introduction = introduction
    }
}
