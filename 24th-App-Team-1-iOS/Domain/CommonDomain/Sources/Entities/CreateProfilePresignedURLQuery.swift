//
//  CreateProfilePresignedURLQuery.swift
//  CommonDomain
//
//  Created by 김도현 on 11/12/24.
//

import Foundation


public struct CreateProfilePresignedURLQuery {
    public let imageExtension: String
    
    public init(imageExtension: String) {
        self.imageExtension = imageExtension
    }
}
