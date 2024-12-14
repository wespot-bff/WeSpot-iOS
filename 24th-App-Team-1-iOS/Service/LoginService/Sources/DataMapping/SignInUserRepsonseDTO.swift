//
//  SignInUserRepsonseDTO.swift
//  LoginService
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation
import LoginDomain

public struct SignInUserRepsonseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenExpiredAt: String
    public let setting: UserSettingResponseDTO
    public let name: String
    public let isProfileChanged: Bool
}

extension SignInUserRepsonseDTO {
    public struct UserSettingResponseDTO: Decodable {
        public let isVoteNotification: Bool
        public let isMessageNotification: Bool
        public let isMarketingNotification: Bool
    }
}

extension SignInUserRepsonseDTO {
    func toDomain() -> LoginUserEntity {
        return .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            refreshTokenExpiredAt: refreshTokenExpiredAt,
            setting: setting.toDomain(),
            name: name,
            isProfileChanged: isProfileChanged
        )
    }
}

extension SignInUserRepsonseDTO.UserSettingResponseDTO {
    func toDomain() -> UserSettingEntity {
        return .init(
            isVoteNotification: isVoteNotification,
            isMessageNotification: isMessageNotification,
            isMarketingNotification: isMarketingNotification
        )
    }
}
