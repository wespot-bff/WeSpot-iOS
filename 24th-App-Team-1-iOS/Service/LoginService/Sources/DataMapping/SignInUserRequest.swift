//
//  SignInUserRequest.swift
//  LoginService
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation

public struct SignInUserRequest: Encodable {
    public let socialType: String
    public let authorizationCode: String
    public let identityToken: String
    public let fcmToken: String
    
    public init(socialType: String, authorizationCode: String, identityToken: String, fcmToken: String) {
        self.socialType = socialType
        self.authorizationCode = authorizationCode
        self.identityToken = identityToken
        self.fcmToken = fcmToken
    }
}
