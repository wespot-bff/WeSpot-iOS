//
//  ProfileOnboardingQuery.swift
//  CommonDomain
//
//  Created by 김도현 on 2/25/25.
//

import Foundation



public struct ProfileOnboardingQuery {
    public let publishNotificationType: String
    
    public init(publishNotificationType: String) {
        self.publishNotificationType = publishNotificationType
    }
}
