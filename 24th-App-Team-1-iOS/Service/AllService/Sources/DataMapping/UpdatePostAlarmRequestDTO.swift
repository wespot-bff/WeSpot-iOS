//
//  UpdatePostAlarmRequestDTO.swift
//  AllService
//
//  Created by 김도현 on 9/5/25.
//


public struct UpdatePostAlarmRequestDTO: Encodable {
    public let isEnablePostNotification: Bool
    
    public init(isEnablePostNotification: Bool) {
        self.isEnablePostNotification = isEnablePostNotification
    }
}
