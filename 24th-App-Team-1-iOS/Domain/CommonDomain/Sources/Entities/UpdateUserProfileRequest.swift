//
//  UpdateUserProfileRequest.swift
//  AllDomain
//
//  Created by Kim dohyun on 8/13/24.
//

import Foundation


public struct UpdateUserProfileRequest {
    public let introduction: String
    
    public init(introduction: String) {
        self.introduction = introduction
    }
}
