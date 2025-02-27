//
//  ProfileOnbardingInfoRequestDTO.swift
//  CommonService
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

public struct ProfileOnbardingInfoRequestDTO: Encodable {
    public let publishNotificationType: String
    
    
    init(publishNotificationType: String) {
        self.publishNotificationType = publishNotificationType
    }
}
