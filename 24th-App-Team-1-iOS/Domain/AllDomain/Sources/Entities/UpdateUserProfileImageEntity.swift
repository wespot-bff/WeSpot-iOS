//
//  UpdateUserProfileImageEntity.swift
//  AllDomain
//
//  Created by 김도현 on 11/12/24.
//

import Foundation


public struct UpdateUserProfileImageEntity {
    public let id: Int
    public let url: String
    
    public init(id: Int, url: String) {
        self.id = id
        self.url = url
    }
}
