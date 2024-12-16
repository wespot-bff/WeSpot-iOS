//
//  UpdateUserProfileImageRequestDTO.swift
//  AllService
//
//  Created by 김도현 on 11/12/24.
//

import Foundation


public struct UpdateUserProfileImageRequestDTO: Encodable {
    public let url: String?
    
    public init(url: String?) {
        self.url = url
    }
}
