//
//  CompleteSignUpResponseDTO.swift
//  LoginService
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation
import LoginDomain

public struct CompleteSignUpResponseDTO: Decodable {
    public let signUpToken: String
}


extension CompleteSignUpResponseDTO {
    func toDomain() -> SignUpTokenEntity {
        return .init(signUpToken: signUpToken)
    }
}
