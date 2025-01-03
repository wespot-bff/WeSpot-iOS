//
//  SignInUserEntity.swift
//  LoginDomain
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation

public struct LoginUserEntity {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenExpiredAt: String
    public let setting: UserSettingEntity
    public let name: String
    public let isProfileChanged: Bool
    
    public init(
        accessToken: String,
        refreshToken: String,
        refreshTokenExpiredAt: String,
        setting: UserSettingEntity,
        name: String,
        isProfileChanged: Bool
    
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.refreshTokenExpiredAt = refreshTokenExpiredAt
        self.setting = setting
        self.name = name
        self.isProfileChanged = isProfileChanged
    }
}


public struct UserSettingEntity {
    public let isVoteNotification: Bool
    public let isMessageNotification: Bool
    public let isMarketingNotification: Bool
    
    public init(isVoteNotification: Bool, isMessageNotification: Bool, isMarketingNotification: Bool) {
        self.isVoteNotification = isVoteNotification
        self.isMessageNotification = isMessageNotification
        self.isMarketingNotification = isMarketingNotification
    }
}
