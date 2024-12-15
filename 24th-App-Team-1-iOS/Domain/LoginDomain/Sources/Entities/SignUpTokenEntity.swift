//
//  CreateSignUpToken.swift
//  LoginDomain
//
//  Created by eunseou on 7/30/24.
//

import Foundation

public struct SignUpTokenEntity {
    public let signUpToken: String
    
    public init(signUpToken: String) {
        self.signUpToken = signUpToken
    }
}