//
//  SignUpResponseDTO.swift
//  LoginService
//
//  Created by 최지철 on 12/5/24.
//

import Foundation
import LoginDomain

public struct SignUpResponseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenExpiredAt: String
    public let setting: UserSettingResponseDTO
    public let name: String
    public let isProfileChanged: Bool
}

extension SignUpResponseDTO {
    public struct UserSettingResponseDTO: Decodable {
        public let isVoteNotification: Bool
        public let isMessageNotification: Bool
        public let isMarketingNotification: Bool
    }
}

extension SignUpResponseDTO {
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

extension CreateAccountResponseDTO.UserSettingResponseDTO {
    func toDomain() -> CreateAccountSettingResponseEntity {
        return .init(
            isVoteNotification: isVoteNotification,
            isMessageNotification: isMessageNotification,
            isMarketingNotification: isMarketingNotification
        )
    }
}
