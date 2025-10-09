//
//  UpdatePostAlarmRequest.swift
//  AllDomain
//
//  Created by 김도현 on 9/5/25.
//

import Foundation


public struct UpdatePostAlarmRequest {
    public let isEnablePostNotification: Bool
    
    public init(isEnablePostNotification: Bool) {
        self.isEnablePostNotification = isEnablePostNotification
    }
}
