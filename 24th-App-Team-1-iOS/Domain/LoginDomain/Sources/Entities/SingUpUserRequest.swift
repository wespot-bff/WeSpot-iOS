//
//  SingUpUserRequest.swift
//  LoginDomain
//  Updated by Choi on 12/12/24
//  Created by eunseou on 7/30/24.
//

import Foundation

public struct ConsentsRequest {
    public var marketing: Bool
    
    public init(marketing: Bool = false) {
        self.marketing = marketing
    }
}

public struct SignUpUserRequest {
    public var name: String
    public var gender: String
    public var schoolId: Int
    public var grade: Int
    public var classNumber: Int
    public var consents: ConsentsRequest
    public var signUpToken: String
    public var profileUrl: String?
    public var introduction: String
    
    public init(
        name: String = "",
        gender: String = "",
        schoolId: Int = 0,
        grade: Int = 0,
        classNumber: Int = 0,
        consents: ConsentsRequest = .init(marketing: false),
        signUpToken: String = "",
        profileUrl: String? = nil,
        introduction: String = ""
    ) {
        self.name = name
        self.gender = gender
        self.schoolId = schoolId
        self.grade = grade
        self.classNumber = classNumber
        self.consents = consents
        self.signUpToken = signUpToken
        self.profileUrl = profileUrl
        self.introduction = introduction
    }
}
