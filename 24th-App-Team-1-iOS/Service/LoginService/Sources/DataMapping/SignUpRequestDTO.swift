//
//  SignUpRequestDTO.swift
//  LoginService
//
//  Updated by JiCheol on 12/5/24
//  Created by eunseou on 7/30/24.
//

import Foundation

public struct SignUPRequestDTO: Encodable {
    public let name: String
    public let gender: String
    public let schoolId: Int
    public let grade: Int
    public let classNumber: Int
    public let consents: ConsentsRequestDTO
    public let signUpToken: String
    public let profileUrl: String?
    public let introduction: String
    
    public init(
        name: String,
        gender: String,
        schoolId: Int,
        grade: Int,
        classNumber: Int,
        consents: ConsentsRequestDTO,
        signUpToken: String,
        profileUrl: String?,
        introduction: String
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

public struct ConsentsRequestDTO: Encodable {
    public let marketing: Bool
    
    public init(marketing: Bool) {
        self.marketing = marketing
    }
}
