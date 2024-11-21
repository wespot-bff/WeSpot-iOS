//
//  CreateProfilePresignedURLEntity.swift
//  CommonDomain
//
//  Created by 김도현 on 11/12/24.
//

import Foundation

public struct CreateProfilePresignedURLEntity {
    public let presignedURL: String
    public let imageURL: String
    
    public init(presignedURL: String, imageURL: String) {
        self.presignedURL = presignedURL
        self.imageURL = imageURL
    }
}
