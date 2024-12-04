//
//  SignInRepsonseDTO.swift
//  LoginService
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation
import LoginDomain

public struct SignInRepsonseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenExpiredAt: String
    public let setting: UserSettingResponseDTO
    public let name: String
    public let isProfileChanged: Bool
}

extension SignInRepsonseDTO {
    public struct UserSettingResponseDTO: Decodable {
        public let isVoteNotification: Bool
        public let isMessageNotification: Bool
        public let isMarketingNotification: Bool
    }
}

extension SignInRepsonseDTO {
    func toDomain() -> CreateAccountResponseEntity {
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

extension SignInRepsonseDTO.UserSettingResponseDTO {
    func toDomain() -> CreateAccountSettingResponseEntity {
        return .init(
            isVoteNotification: isVoteNotification,
            isMessageNotification: isMessageNotification,
            isMarketingNotification: isMarketingNotification
        )
    }
}
