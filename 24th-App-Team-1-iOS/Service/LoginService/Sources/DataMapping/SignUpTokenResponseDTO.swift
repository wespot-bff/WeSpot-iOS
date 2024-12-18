//
//  SignUpTokenResponseDTO.swift
//  LoginService
//
//  Created by 최지철 on 12/13/24.
//

import Foundation
import LoginDomain

public struct SignUpTokenResponseDTO: Decodable {
    let signUpToken: String
}
extension SignUpTokenResponseDTO {
    func toDomain() -> SignUpTokenEntity {
        return .init(signUpToken: signUpToken)
    }
}
