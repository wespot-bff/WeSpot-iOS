//
//  LoginResultEnum.swift
//  LoginDomain
//
//  Created by 최지철 on 12/14/24.
//

import Foundation

public enum LoginResultEnum {
    case success200(LoginUserEntity)
    case success202(SignUpTokenEntity)
    case unknown
}
